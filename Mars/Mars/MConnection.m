//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MConnection.h"
#import "CTLogger.h"
#import "MQuery+Private.h"
#import "MSelectQuery.h"

void myTraceFunc(void *uData, const char *statement)
{
	CTLog(@"TRACE: %s", statement);
}

@implementation MConnection {
	sqlite3 *_dbHandle;
	NSString *_dbPath;
}

- (id)init {
	return [self initWithPath:nil];
}

- (id)initWithPath:(NSString *)path {
	self = [super init];
	if (self) {
		_dbPath = path;
	}
	return self;
}

- (BOOL)open {
	int err = sqlite3_open_v2(_dbPath ? (char *)[_dbPath fileSystemRepresentation] : ":memory:", &_dbHandle,
							  SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_SHAREDCACHE, NULL);
	
	if (err != SQLITE_OK) {
		CTLog(@"ERROR OPENING DB: %d", err);
		return NO;
	}
	
	[self configureDatabaseSettings];
	
	return YES;
}

- (void)close {
	sqlite3_close(_dbHandle);
	_dbHandle = NULL;
}

- (BOOL)exec:(NSString *)sql error:(NSError **)error {
	const char *charSql = [sql cStringUsingEncoding:NSUTF8StringEncoding];
	char *errorPointer;
	if (sqlite3_exec(_dbHandle, charSql, NULL, NULL, &errorPointer) != SQLITE_OK) {
		CTLog(@"ERROR RUNNING %@: %s", sql, errorPointer);
		if (error) {
			*error = self.lastError;
		}
		sqlite3_free(errorPointer);
		return NO;
	}
	return YES;
}
- (int64_t)executeUpdate:(MQuery *)query error:(NSError **)error {
	if ([query isKindOfClass:[MSelectQuery class]]) {
		[NSException raise:@"Invalid Query Type" format:@"Only UPDATE, DELETE, INSERT queries are allowed"];
	}
#if LOG_SQL
	NSLog(@"%@", query.sql);
#endif
	sqlite3_stmt *stmt = [self createStatement:query.sql bindings:query.bindings error:error];
	if (!stmt) {
		return kNoPk;
	}
	int64_t row = [self executeUpdateWithStatement:stmt error:error];
	[self finalizeStatement:stmt];
	return row;
}

- (NSArray *)executeQuery:(MQuery *)query error:(NSError **)error {
	if (![query isKindOfClass:[MSelectQuery class]]) {
		[NSException raise:@"Invalid Query Type" format:@"Only SELECT queries are allowed"];
	}
#if LOG_SQL
	NSLog(@"%@", query.sql);
#endif
	sqlite3_stmt *stmt = [self createStatement:query.sql bindings:query.bindings error:error];
	if (!stmt) {
		return nil;
	}
	NSArray *results = [self executeQueryWithStatement:stmt error:error];
	[self finalizeStatement:stmt];
	return results;
}

- (BOOL)beginTransaction:(NSError **)error {
	return [self exec:@"BEGIN TRANSACTION" error:error];
}

- (BOOL)commit:(NSError **)error {
	return [self exec:@"COMMIT" error:error];
}

- (BOOL)rollback:(NSError **)error {
	return [self exec:@"ROLLBACK" error:error];
}

- (sqlite3 *)dbHandle {
	return _dbHandle;
}

- (int64_t)lastInsertRowId {
	return sqlite3_last_insert_rowid(_dbHandle);
}

- (NSError *)lastError {
	NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
	[errorDetail setValue:[self lastErrorMessage] forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:@"MDatabase" code:[self lastErrorCode] userInfo:errorDetail];
}

- (NSString *)lastErrorMessage {
	return [NSString stringWithUTF8String:sqlite3_errmsg(_dbHandle)];
}

- (int)lastErrorCode {
	return sqlite3_errcode(_dbHandle);
}

- (void)configureDatabaseSettings {
	[self exec:@"PRAGMA foreign_keys = ON;" error:nil];
	[self exec:@"PRAGMA synchronous = OFF;" error:nil];
	[self exec:@"PRAGMA journal_mode = WAL;" error:nil];
}

- (NSArray *)executeQueryWithStatement:(sqlite3_stmt *)stmt error:(NSError **)error {
	int r = 0;
	NSMutableArray *results = [NSMutableArray array];
	NSArray *columnNames = [self columnsForStatement:stmt];
	
	while ((r = sqlite3_step(stmt)) != SQLITE_DONE) {
		if (r == SQLITE_ROW) {
			NSDictionary *columns = [NSMutableDictionary dictionary];
			int i = 0;
			for (NSString *columnName in columnNames) {
				[columns setValue:[self valueForColumn:i query:stmt] forKey:columnName];
				++i;
			}
			[results addObject:columns];
		} else {
			CTLog(@"Error %li calling sqlite3_step exec_query %@", r, self.lastError);
			sqlite3_trace(self.dbHandle, myTraceFunc, NULL);
			if (error) {
				*error = self.lastError;
			}
		}
	}
	return results;
}

- (BOOL)executeUpdateWithStatement:(sqlite3_stmt *)stmt error:(NSError **)error {
	int rc = sqlite3_step(stmt);
	
	if (SQLITE_DONE == rc) {
		return YES;
	} else if (rc == SQLITE_ROW) {
		NSAssert(NO, @"A executeUpdate is being called with a query string");
	} else {
		CTLog(@"Error %li calling sqlite3_step exec_update_query %@", rc, self.lastError);
		sqlite3_trace(self.dbHandle, myTraceFunc, NULL);
		if (error) {
			*error = self.lastError;
		}
		return NO;
	}
	
	return NO;
}


// Taken from FMDB
- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)pStmt {
	if ((!obj) || ((NSNull *)obj == [NSNull null])) {
		sqlite3_bind_null(pStmt, idx);
	} else if ([obj isKindOfClass:[NSData class]]) {
		const void *bytes = [obj bytes];
		if (!bytes) {
			// it's an empty NSData object, aka [NSData data].
			// Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
			bytes = "";
		}
		sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
	} else if ([obj isKindOfClass:[NSDate class]]) {
		sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
	} else if ([obj isKindOfClass:[NSNumber class]]) {
		if (strcmp([obj objCType], @encode(BOOL)) == 0) {
			sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
		} else if (strcmp([obj objCType], @encode(int)) == 0) {
			sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		} else if (strcmp([obj objCType], @encode(long)) == 0) {
			sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		} else if (strcmp([obj objCType], @encode(long long)) == 0) {
			sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
		} else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
			sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
		} else if (strcmp([obj objCType], @encode(float)) == 0) {
			sqlite3_bind_double(pStmt, idx, [obj floatValue]);
		} else if (strcmp([obj objCType], @encode(double)) == 0) {
			sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
		} else {
			sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
		}
	} else {
		sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
}

// Take from DatabaseKit
- (id)valueForColumn:(unsigned int)colIndex query:(sqlite3_stmt *)query {
	int columnType = sqlite3_column_type(query, colIndex);
	switch (columnType) {
		case SQLITE_INTEGER:
			return @(sqlite3_column_int(query, colIndex));
			break;
		case SQLITE_FLOAT:
			return @(sqlite3_column_double(query, colIndex));
			break;
		case SQLITE_BLOB:
			return [NSData dataWithBytes:sqlite3_column_blob(query, colIndex)
								  length:sqlite3_column_bytes(query, colIndex)];
			break;
		case SQLITE_NULL:
			return [NSNull null];
			break;
		case SQLITE_TEXT:
			return @((const char *)sqlite3_column_text(query, colIndex));
			break;
		default:
			// It really shouldn't ever come to this.
			break;
	}
	return nil;
}

// Taken from DatabaseKit
- (NSArray *)columnsForStatement:(sqlite3_stmt *)query {
	int columnCount = sqlite3_column_count(query);
	if (columnCount <= 0) {
		return nil;
	}
	
	NSMutableArray *columnNames = [NSMutableArray array];
	for (int i = 0; i < columnCount; ++i) {
		const char *name;
		name = sqlite3_column_name(query, i);
		[columnNames addObject:@(name)];
	}
	return columnNames;
}

- (sqlite3_stmt *)createStatement:(NSString *)sql bindings:(NSArray *)bindings error:(NSError **)error {
	sqlite3_stmt *stmt;
	int rc = sqlite3_prepare_v2(self.dbHandle, [sql UTF8String], -1, &stmt, 0);
	if (SQLITE_OK != rc) {
		if (error) *error = self.lastError;
		CTLog(@"Error preparing statement: %@ ", sql, self.lastError);
		sqlite3_finalize(stmt);
		return NULL;
	}
	
	for (int i = 0; i < bindings.count; i++) {
		id value = [bindings objectAtIndex:i];
		[self bindObject:value toColumn:i+1 inStatement:stmt];
	}
	return stmt;
}

- (void)finalizeStatement:(sqlite3_stmt *)stmt {
	sqlite3_finalize(stmt);
}


@end

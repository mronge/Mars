//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "CTDBConnection.h"
#import "CTLogger.h"
#import "CTDatabase.h"
#import "CTQuery+Private.h"

@implementation CTDBConnection {
    sqlite3 *_dbHandle;
    NSString *_dbPath;
}

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _dbPath = path;
    }
    return self;
}

- (BOOL)open {
    int err = sqlite3_open([_dbPath fileSystemRepresentation], &_dbHandle);
    if (err != SQLITE_OK) {
        CTLog(@"ERROR OPENING DB: %d", err);
        return NO;
    }
    
    [self configureDatabaseSettings];
    
    return YES;
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

- (int64_t)executeUpdateWithStatement:(sqlite3_stmt *)stmt error:(NSError **)error {
    int rc = sqlite3_step(stmt);
    
    if (SQLITE_DONE == rc) {
        return YES;
    } else {
        CTLog(@"Error calling sqlite3_step %@", self.lastError);
        if (error) {
            *error = self.lastError;
        }
        return kCTNoPk;
    }
    
    if (rc == SQLITE_ROW) {
        NSAssert(NO, @"A executeUpdate is being called with a query string");
    }
    
    return sqlite3_last_insert_rowid(_dbHandle);
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

- (sqlite3_stmt *)createStatement:(NSString *)sql bindings:(NSArray *)bindings error:(NSError **)error {
    sqlite3_stmt *stmt;
    int rc = sqlite3_prepare_v2(self.dbHandle, [sql UTF8String], -1, &stmt, 0);
    if (SQLITE_OK != rc) {
        *error = self.lastError;
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

- (int64_t)executeUpdate:(CTQuery *)query error:(NSError **)error {
    sqlite3_stmt *stmt = [self createStatement:query.sql bindings:query.bindings error:error];
    if (!stmt) {
        return kCTNoPk;
    }
    int64_t row = [self executeUpdateWithStatement:stmt error:error];
    [self finalizeStatement:stmt];
    return row;
}

- (CTResults *)executeQuery:(CTQuery *)query error:(NSError **)error {
    return nil;
}

- (void)configureDatabaseSettings {
    [self exec:@"PRAGMA foreign_keys = ON;" error:nil];
    [self exec:@"PRAGMA synchronous = OFF;" error:nil];
    [self exec:@"PRAGMA journal_mode = WAL;" error:nil];
}

- (sqlite3 *)dbHandle {
    return _dbHandle;
}

- (NSError *)lastError {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:[self lastErrorMessage] forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"CTDatabase" code:[self lastErrorCode] userInfo:errorDetail];
}

- (NSString *)lastErrorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(_dbHandle)];
}

- (int)lastErrorCode {
    return sqlite3_errcode(_dbHandle);
}



@end

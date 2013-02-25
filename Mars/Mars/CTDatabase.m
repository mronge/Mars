//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "CTDatabase.h"
#import "CTDBConnection.h"

#import <sqlite3.h>

@implementation CTDatabase {
    NSString *_dbPath;
    CTDBConnection *_writer;
    NSMutableSet *_readers;
    
    dispatch_queue_t _lockQueue;
    NSOperationQueue *_writeQueue;
    NSOperationQueue *_readQueue;
}

- (id)initWithPath:(NSString *)path schema:(NSString *)schema {
    self = [super init];
    if (self) {
        _writeQueue = [[NSOperationQueue alloc] init];
        _writeQueue.maxConcurrentOperationCount = 1;
        _readQueue = [[NSOperationQueue alloc] init];
        _lockQueue = dispatch_queue_create("CTDatabaseLock", NULL);
        
        _readers = [[NSMutableSet alloc] init];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        BOOL exists = [fm fileExistsAtPath:path];
        
        _dbPath = path;
        _writer = [[CTDBConnection alloc] initWithPath:path];
        if (![_writer open]) {
            return nil;
        }
        
        if (!exists && schema) {
            // Create db from schema
            [_writer exec:schema error:nil];
        }
    }
    return self;
}

- (id)initWithDBFileName:(NSString *)dbFileName schemaFileName:(NSString *)schemaFileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullDBPath = [docDir stringByAppendingPathComponent:dbFileName];
    
    NSString *schemaPath = [[NSBundle mainBundle] pathForResource:schemaFileName ofType:@"sql"];
    NSString *schema = nil;
    if (schemaPath) {
        schema = [[NSString alloc] initWithContentsOfFile:schemaPath usedEncoding:nil error:nil];
    }
    
    return [self initWithPath:fullDBPath schema:schema];
}

- (NSOperation *)select:(id)rows from:(id)tables where:(id)expression groupBy:(id)groupBy
                orderBy:(id)orderBy limit:(unsigned int)limit offset:(unsigned int)offset
        completionBlock:(void (^)(NSError *err, CTResults *results))completionBlock {
    return nil;
}

- (NSOperation *)select:(id)rows from:(id)tables where:(id)expression
        completionBlock:(void (^)(NSError *err, CTResults *results))completionBlock {
    return nil;
}

- (NSOperation *)insert:(NSString *)table fields:(NSDictionary *)fields
        completionBlock:(void (^)(NSError *err, int64_t row))completionBlock {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
//        NSError *error = nil;
//        sqlite3_stmt *stmt = [_writer.sql statementForInsert:table fields:fields error:&error];
//        if (stmt) {
//            int64_t row = [_writer executeUpdate:stmt error:&error];
//            sqlite3_finalize(stmt);
//            completionBlock(error, row);
//        } else {
//            completionBlock(error, kCTNoPk);
//        }
    }];
    [_writeQueue addOperation:op];
    return op;
}

- (NSOperation *)update:(NSString *)table fields:(NSDictionary *)fields where:(id)expression
        completionBlock:(void (^)(NSError *err))completionBlock {
    return nil;
}

- (NSOperation *)deleteFrom:(NSString *)table where:(id)expression
            completionBlock:(void (^)(NSError *err))completionBlock {
    return nil;
}

- (CTDBConnection *)reader {
    __block CTDBConnection *aReader = nil;
    dispatch_sync(_lockQueue, ^{
        aReader = [_readers anyObject];
        
        if (aReader) {
            [_readers removeObject:aReader];
        } else {
            // No readers available, create a new one
            aReader = [[CTDBConnection alloc] initWithPath:_dbPath];
            if (![aReader open]) {
                NSLog(@"Failed to open reader");
                aReader = nil;
            }
        }
    });
    return aReader;
}

- (void)putBackReader:(CTDBConnection *)reader {
    dispatch_sync(_lockQueue, ^{
        NSAssert(![_readers containsObject:reader], @"The reader shouldn't already be in the set!");
        [_readers addObject:reader];
    });
}

@end

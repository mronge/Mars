//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MDatabase.h"
#import "MConnection.h"
#import "MQuery.h"
#import "MInsertQuery.h"

#import <sqlite3.h>

@implementation MDatabase {
    NSString *_dbPath;
    MConnection *_writer;
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
        _lockQueue = dispatch_queue_create("MDatabaseLock", NULL);
        
        _readers = [[NSMutableSet alloc] init];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        BOOL exists = [fm fileExistsAtPath:path];
        
        _dbPath = path;
        _writer = [[MConnection alloc] initWithPath:path];
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

- (NSOperation *)query:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock {
    if ([query modifies]) {
        return [self change:query completionBlock:completionBlock];
    } else {
        return [self select:query completionBlock:completionBlock];
    }
}

- (NSOperation *)select:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        MConnection *reader = [self reader];
        NSError *error = nil;
        NSArray *val = [reader executeQuery:query error:&error];
        if (val) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, val);
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(error, nil);
            }];
        }
        [self putBackReader:reader];
    }];
    [_readQueue addOperation:op];
    return op;
}

- (NSOperation *)change:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error = nil;
        BOOL success = [_writer executeUpdate:query error:&error];
        if (success) {
            id val = nil;
            if ([query isKindOfClass:[MInsertQuery class]]) {
                val = @([_writer lastInsertRowId]);
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, val);
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(error, nil);
            }];
        }
    }];
    [_writeQueue addOperation:op];
    return op;
}

- (MConnection *)reader {
    __block MConnection *aReader = nil;
    dispatch_sync(_lockQueue, ^{
        aReader = [_readers anyObject];
        
        if (aReader) {
            [_readers removeObject:aReader];
        } else {
            // No readers available, create a new one
            aReader = [[MConnection alloc] initWithPath:_dbPath];
            if (![aReader open]) {
                NSLog(@"Failed to open reader");
                aReader = nil;
            }
        }
    });
    return aReader;
}

- (void)putBackReader:(MConnection *)reader {
    dispatch_sync(_lockQueue, ^{
        NSAssert(![_readers containsObject:reader], @"The reader shouldn't already be in the set!");
        [_readers addObject:reader];
    });
}

@end

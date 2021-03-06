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
#import "MDatabase+Private.h"

#import <sqlite3.h>

@interface MDatabase ()
@property (nonatomic, strong, readonly) NSOperationQueue *readQueue;
@property (nonatomic, strong, readonly) MConnection *writer;
@property (nonatomic, strong, readonly) NSString *dbPath;
@property (nonatomic, strong, readonly) NSMutableSet *readers;
@property (nonatomic, strong, readonly) dispatch_queue_t lockQueue;
@property (nonatomic, strong, readonly) NSMutableSet *openTransactions;
@end

@implementation MDatabase

- (id)initWithPath:(NSString *)path schema:(NSString *)schema {
    self = [super init];
    if (self) {
        _writeQueue = [[NSOperationQueue alloc] init];
        _writeQueue.maxConcurrentOperationCount = 1;
        _readQueue = [[NSOperationQueue alloc] init];
        _lockQueue = dispatch_queue_create("MDatabaseLock", NULL);
        
        _readers = [[NSMutableSet alloc] init];
        _openTransactions = [[NSMutableSet alloc] init];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        BOOL exists = [fm fileExistsAtPath:path];
        
        _dbPath = path;
        _writer = [[MConnection alloc] initWithPath:path];
        if (![self.writer open]) {
            return nil;
        }
        
        if (!exists && schema) {
            // Create db from schema
            [self.writer exec:schema error:nil];
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
        return [self change:query completionBlock:^(NSError *err, id result) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (completionBlock) completionBlock(err, result);
            }];
        }];
    } else {
        return [self select:query completionBlock:^(NSError *err, id result) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (completionBlock) completionBlock(err, result);
            }];
        }];
    }
}

- (id)query:(MQuery *)query error:(NSError **)err {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSError *error = nil;
    __block id result = nil;
    
    if ([query modifies]) {
        [self change:query completionBlock:^(NSError *e, id r) {
            result = r;
            error = e;
            dispatch_semaphore_signal(semaphore);
        }];
    } else {
        [self select:query completionBlock:^(NSError *e, id r) {
            result = r;
            error = e;
            dispatch_semaphore_signal(semaphore);
        }];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (err) *err = error;
    if (error) {
        return nil;
    } else {
        return result;
    }
}

- (NSOperation *)select:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock {
    __weak MDatabase *weakSelf = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        MDatabase *strongSelf = weakSelf;
        MConnection *reader = [strongSelf reader];
        NSError *error = nil;
        NSArray *val = [reader executeQuery:query error:&error];
        if (val) {
            if (completionBlock) completionBlock(nil, val);
        } else {
            if (completionBlock) completionBlock(error, nil);
        }
        [self putBackReader:reader];
    }];
    [self.readQueue addOperation:op];
    return op;
}

- (NSOperation *)change:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock {
    __weak MDatabase *weakSelf = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        MDatabase *strongSelf = weakSelf;
        NSError *error = nil;
        int64_t r = [strongSelf.writer executeUpdate:query error:&error];
        if (r > 0) {
            id val = nil;
            if ([query isKindOfClass:[MInsertQuery class]]) {
                val = @([strongSelf.writer lastInsertRowId]);
            }
            if (completionBlock) completionBlock(nil, val);
        } else {
            if (completionBlock) completionBlock(error, nil);
        }
    }];
    [self.writeQueue addOperation:op];
    return op;
}

- (MConnection *)reader {
    __block MConnection *aReader = nil;
    dispatch_sync(self.lockQueue, ^{
        aReader = [self.readers anyObject];
        
        if (aReader) {
            [self.readers removeObject:aReader];
        } else {
            // No readers available, create a new one
            aReader = [[MConnection alloc] initWithPath:self.dbPath];
            if (![aReader open]) {
                NSLog(@"Failed to open reader");
                aReader = nil;
            }
        }
    });
    return aReader;
}

- (void)putBackReader:(MConnection *)reader {
    dispatch_sync(self.lockQueue, ^{
        NSAssert(![self.readers containsObject:reader], @"The reader shouldn't already be in the set!");
        [self.readers addObject:reader];
    });
}

@end

//
//  MTransaction.m
//  Mars
//
//  Created by Matt Ronge on 03/12/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MTransaction.h"
#import "MQuery.h"
#import "MConnection.h"
#import "MDatabase+Private.h"

@interface MTransaction ()
@property (nonatomic, strong, readonly) MConnection *connection;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, weak, readonly) MDatabase *database;
@end

@implementation MTransaction {
}

- (id)initWithPath:(NSString *)path schema:(NSString *)schema {
    [NSException raise:@"Unsupported" format:@"You can't instantiate MTransaction directly"];
    return nil;
}

- (id)initWithDBFileName:(NSString *)dbFileName schemaFileName:(NSString *)schemaFileName {
    [NSException raise:@"Unsupported" format:@"You can't instantiate MTransaction directly"];
    return nil;
}

- (id)initWithConnection:(MConnection *)connection database:(MDatabase *)database {
    self = [super init];
    if (self) {
        _connection = connection;
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _database = database;
    }
    return self;
}

- (NSOperation *)commitWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    __weak MTransaction *weakSelf = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        MTransaction *strongSelf = weakSelf;
        NSError *error = nil;
        BOOL success = [self.connection commit:&error];
        [_connection close];
        [_database endTransaction:strongSelf];
        if (success) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil);
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(error);
            }];
        }
    }];
    [self.writeQueue addOperation:op];
    return op;
}

- (NSOperation *)rollbackWithCompletionBlock:(void (^)(NSError *error))completionBlock {
    __weak MTransaction *weakSelf = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        MTransaction *strongSelf = weakSelf;
        NSError *error = nil;
        BOOL success = [self.connection rollback:&error];
        [_connection close];
        [_database endTransaction:strongSelf];
        if (success) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil);
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(error);
            }];
        }
    }];
    [self.writeQueue addOperation:op];
    return op;
}

#pragma mark - Overridden

- (MTransaction *)beginTransaction {
    [NSException raise:@"Unsupported" format:@"You can't have a transaction within a transaction!"];
    return nil;
}

// Transactions only have one database connection that is shared for reading and writing
// All reads and writes go through a single serial queue

- (MConnection *)reader {
    return self.connection;
}

- (void)putBackReader:(MConnection *)reader {
    // Do nothing
}

- (MConnection *)writer {
    return self.connection;
}

- (NSOperationQueue *)writeQueue {
    return self.queue;
}

- (NSOperationQueue *)readQueue {
    return self.queue;
}

@end

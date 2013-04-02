//
//  MTransaction.h
//  Mars
//
//  Created by Matt Ronge on 03/12/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Mars/MDatabase.h>

@class MQuery;

/* Create a transaction by calling -beginTransaction on MDatabase.
 * Don't instantiate this class directly */
@interface MTransaction : MDatabase

- (NSOperation *)commitWithCompletionBlock:(void (^)(NSError *error))completionBlock;
- (NSOperation *)rollbackWithCompletionBlock:(void (^)(NSError *error))completionBlock;

@end

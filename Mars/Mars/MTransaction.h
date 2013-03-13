//
//  MTransaction.h
//  Mars
//
//  Created by Matt Ronge on 03/12/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MDatabase.h"

@class MQuery;

@interface MTransaction : MDatabase

- (NSOperation *)commitWithCompletionBlock:(void (^)(NSError *error))completionBlock;
- (NSOperation *)rollbackWithCompletionBlock:(void (^)(NSError *error))completionBlock;

@end

//
//  MDatabase+AsyncAdditions.m
//  VMail
//
//  Created by Matt Ronge on 04/01/13.
//  Copyright (c) 2013 Central Atomics Inc. All rights reserved.
//

#import "MDatabase+AsyncAdditions.h"
#import "MQuery.h"

@implementation MDatabase (AsyncAdditions)
- (void)queries:(NSArray *)queries completionBlock:(void (^)(NSError *err, NSArray *results))completionBlock {
    __block int finished = 0;
    NSMutableArray *results = [NSMutableArray array];
    for (MQuery *query in queries) {
        [results addObject:[NSNull null]]; // Acts as a placeholder
    }


    for (MQuery *query in queries) {
        [self query:query completionBlock:^(NSError *err, id result) {
            if (err) {
                completionBlock(err, nil);
                return;
            }

            NSUInteger pos = [queries indexOfObject:query];
            results[pos] = result;

            finished++;
            if (finished == queries.count) {
                completionBlock(nil, results);
            }
        }];
    }
}
@end

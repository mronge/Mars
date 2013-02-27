//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

// FMDB, Korma, DatabaseKit, Django

#import <Foundation/Foundation.h>

#define MToNull(v)   (v == nil ? [NSNull null] : v)
#define MFromNull(v) (v == [NSNull null] ? nil : v)


@class MQuery;

@interface MDatabase : NSObject

- (id)initWithPath:(NSString *)path schema:(NSString *)schema;
- (id)initWithDBFileName:(NSString *)dbFileName schemaFileName:(NSString *)schemaFileName;

- (NSOperation *)query:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock;

@end

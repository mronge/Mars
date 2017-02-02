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
@class MTransaction;

@interface MDatabase : NSObject

- (id)initWithPath:(NSString *)path schema:(NSString *)schema;
- (id)initWithDBFileName:(NSString *)dbFileName schemaFileName:(NSString *)schemaFileName;

// Non blocking versions
- (NSOperation *)query:(MQuery *)query completionBlock:(void (^)(NSError *err, id result))completionBlock;

- (NSOperation *)query:(MQuery *)query
withCompletionOnMainThread:(BOOL)completionOnMainThread
       completionBlock:(void (^)(NSError *err, id result))completionBlock;

// Blocking version
- (id)query:(MQuery *)query error:(NSError **)err;

- (id)rawQuery:(NSString *)query error:(NSError **)error;
- (NSOperation *)rawQuery:(NSString *)query completionBlock:(void (^)(NSError *err, id result))completionBlock;
@end

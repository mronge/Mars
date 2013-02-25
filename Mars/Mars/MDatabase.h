//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

// FMDB, Korma, DatabaseKit, Django

#import <Foundation/Foundation.h>

#define MCheckNull(v) (v == nil ? [NSNull null] : v)

@class MResults;

@interface MDatabase : NSObject

- (id)initWithPath:(NSString *)path schema:(NSString *)schema;
- (id)initWithDBFileName:(NSString *)dbFileName schemaFileName:(NSString *)schemaFileName;

// SELECT

- (NSOperation *)select:(id)rows
                   from:(id)tables
                  where:(id)expression
                groupBy:(id)groupBy
                orderBy:(id)orderBy
                  limit:(unsigned int)limit
                 offset:(unsigned int)offset
        completionBlock:(void (^)(NSError *err, NSArray *results))completionBlock;

- (NSOperation *)select:(id)rows
                   from:(id)tables
                  where:(id)expression
        completionBlock:(void (^)(NSError *err, NSArray *results))completionBlock;

// INSERT

- (NSOperation *)insert:(NSString *)table
                 fields:(NSDictionary *)fields
        completionBlock:(void (^)(NSError *err, int64_t row))completionBlock;

// UPDATE

- (NSOperation *)update:(NSString *)table
                 fields:(NSDictionary *)fields
                  where:(id)expression
        completionBlock:(void (^)(NSError *err))completionBlock;

// DELETE

- (NSOperation *)deleteFrom:(NSString *)table
                      where:(id)expression
            completionBlock:(void (^)(NSError *err))completionBlock;

@end

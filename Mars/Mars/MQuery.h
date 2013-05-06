//
//  CTQuery.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDeleteQuery;
@class MUpdateQuery;
@class MSelectQuery;
@class MInsertQuery;

@interface MQuery : NSObject
+ (MSelectQuery *)selectFrom:(id)table;
+ (MSelectQuery *)select:(id)columns from:(NSString *)table;
+ (MInsertQuery *)insertInto:(NSString *)table values:(NSDictionary *)values;
+ (MUpdateQuery *)update:(NSString *)table values:(NSDictionary *)values;
+ (MDeleteQuery *)deleteFrom:(NSString *)table;

- (NSString *)sql;
- (NSArray *)bindings;
- (BOOL)modifies;
@end

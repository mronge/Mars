//
//  CTQuery.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQuery : NSObject
+ (MQuery *)selectFrom:(id)table;
+ (MQuery *)select:(id)columns from:(NSString *)table;
+ (MQuery *)insertInto:(NSString *)table values:(NSDictionary *)values;
+ (MQuery *)update:(NSString *)table values:(NSDictionary *)values;
+ (MQuery *)deleteFrom:(NSString *)table;
- (MQuery *)where:(NSDictionary *)expressions;
- (MQuery *)orderBy:(NSString *)field;

- (NSString *)sql;
- (NSArray *)bindings;
- (BOOL)modifies;
@end

//
//  CTQuery.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQuery : NSObject
+ (MQuery *)selectFrom:(NSString *)table;
+ (MQuery *)select:(id)columns from:(NSString *)table;
+ (MQuery *)insertInto:(NSString *)table values:(NSDictionary *)values;
+ (MQuery *)update:(NSString *)table values:(NSDictionary *)values;
+ (MQuery *)deleteFrom:(NSString *)table;
- (MQuery *)where:(NSDictionary *)expressions;

- (NSString *)sql;
- (NSArray *)bindings;
@end

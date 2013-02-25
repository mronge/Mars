//
//  CTQuery.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTQuery : NSObject
+ (CTQuery *)selectFrom:(NSString *)table;
+ (CTQuery *)select:(id)columns from:(NSString *)table;
+ (CTQuery *)insertInto:(NSString *)table values:(NSDictionary *)values;
+ (CTQuery *)update:(NSString *)table values:(NSDictionary *)values;
+ (CTQuery *)deleteFrom:(NSString *)table;
- (CTQuery *)where:(NSDictionary *)expressions;
@end

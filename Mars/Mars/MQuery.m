//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MQuery.h"
#import "MQuery+Private.h"
#import "MSelectQuery.h"
#import "NSDictionary+Mars.h"

static NSArray *ExpandToArray(id obj) {
    if (obj == nil) {
        return nil;
    } else if ([obj isKindOfClass:[NSString class]]) {
        return @[obj];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    [NSException raise:@"Unsupported" format:@"Unsupported type"];
    return nil;
}

@implementation MQuery
+ (MQuery *)selectFrom:(NSString *)table {
    return [[self class] select:nil from:table];
}

+ (MQuery *)select:(id)columns from:(NSString *)table {
    MSelectQuery *selectQuery = [[MSelectQuery alloc] init];
    selectQuery.columns = ExpandToArray(columns);
    selectQuery.table = table;
    return selectQuery;
}

+ (MQuery *)insertInto:(NSString *)table values:(NSDictionary *)values {
    return nil;
}

+ (MQuery *)update:(NSString *)table values:(NSDictionary *)values {
    return nil;
}

+ (MQuery *)deleteFrom:(NSString *)table {
    return nil;
}

- (MQuery *)where:(NSDictionary *)expressions {
    MQuery *query = [self copy];
    query.where = expressions;
    return query;
}

- (NSString *)sql {
    return nil;
}

- (NSArray *)bindings {
    NSMutableArray *bindings = [NSMutableArray array];
    for (NSString *key in [self.where sortedKeys]) {
        [bindings addObject:[self.where objectForKey:key]];
    }
    return bindings;
}
@end

//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "CTQuery.h"
#import "CTQuery+Private.h"
#import "CTSelectQuery.h"
#import "NSDictionary+Mars.h"

static NSArray *ExpandToArray(id obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        return @[obj];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    [NSException raise:@"Unsupported" format:@"Unsupported type"];
    return nil;
}

@implementation CTQuery
+ (CTQuery *)selectFrom:(NSString *)table {
    return [[self class] select:nil from:table];
}

+ (CTQuery *)select:(id)columns from:(NSString *)table {
    CTSelectQuery *selectQuery = [[CTSelectQuery alloc] init];
    selectQuery.columns = ExpandToArray(columns);
    selectQuery.table = table;
    return selectQuery;
}

+ (CTQuery *)insertInto:(NSString *)table values:(NSDictionary *)values {
    return nil;
}

+ (CTQuery *)update:(NSString *)table values:(NSDictionary *)values {
    return nil;
}

+ (CTQuery *)deleteFrom:(NSString *)table {
    return nil;
}

- (CTQuery *)where:(NSDictionary *)expressions {
    CTQuery *query = [self copy];
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

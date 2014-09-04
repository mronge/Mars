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
#import "MInsertQuery.h"
#import "MDeleteQuery.h"

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
+ (MSelectQuery *)selectFrom:(id)tables {
    return [[self class] select:nil from:tables];
}

+ (MSelectQuery *)select:(id)columns from:(id)tables {
    MSelectQuery *selectQuery = [[MSelectQuery alloc] init];
    selectQuery.columns = ExpandToArray(columns);
    selectQuery.table = tables;
    return selectQuery;
}

+ (MInsertQuery *)insertInto:(NSString *)table values:(NSDictionary *)values {
    MInsertQuery *insertQuery = [[MInsertQuery alloc] init];
    insertQuery.table = table;
    insertQuery.values = values;
    return insertQuery;
}

+ (MUpdateQuery *)update:(NSString *)table values:(NSDictionary *)values {
    MUpdateQuery *updateQuery = [[MUpdateQuery alloc] init];
    updateQuery.table = table;
    updateQuery.values = values;
    return updateQuery;
}

+ (MDeleteQuery *)deleteFrom:(NSString *)table {
    MDeleteQuery *deleteQuery = [[MDeleteQuery alloc] init];
    deleteQuery.table = table;
    return deleteQuery;
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
        id obj = self.where[key];
        if ([obj isKindOfClass:[NSArray class]]) {
            [bindings addObjectsFromArray:(NSArray *)obj];
        } else {
            [bindings addObject:[self.where objectForKey:key]];
        }
    }
    return bindings;
}

- (BOOL)modifies {
    return YES;
}

- (NSString *)placeholdStringForCount:(NSInteger)count {
    NSMutableArray *questions = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        [questions addObject:@"?"];
    }
    return [questions componentsJoinedByString:@","];
}

- (NSString *)whereString {
    NSMutableArray *whereExprs = [NSMutableArray array];
    for (NSString *column in [self.where sortedKeys]) {
        id obj = self.where[column];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)obj;
            NSString *inStr = [NSString stringWithFormat:@" IN (%@)", [self placeholdStringForCount:array.count]];
            NSString *str = [[self quote:column] stringByAppendingString:inStr];
            [whereExprs addObject:str];
        } else {
            [whereExprs addObject:[[self quote:column] stringByAppendingString:@"=?"]];
        }
    }
    return [whereExprs componentsJoinedByString:@" AND "];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), [self sql]];
}

- (NSString *)quote:(NSString *)str {
    NSAssert([str isKindOfClass:[NSString class]], @"The arg must be a string!");
    if ([str compare:@"COUNT(*)" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        // No need to quote this
        return str;
    }

    // Need to make sure we quote things like M.user properly to "M"."user"

    NSArray *components = [str componentsSeparatedByString:@"."];
    NSMutableArray *quotedComponents = [NSMutableArray array];
    for (NSString *comp in components) {
        [quotedComponents addObject:[NSString stringWithFormat:@"\"%@\"", comp]];
    }

    return [quotedComponents componentsJoinedByString:@"."];
}
@end

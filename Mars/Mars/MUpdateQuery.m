//
//  MUpdateQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MUpdateQuery.h"
#import "MQuery+Private.h"
#import "NSDictionary+Mars.h"

@implementation MUpdateQuery

- (id)copyWithZone:(NSZone *)zone {
    MUpdateQuery *query = [[[self class] alloc] init];
    query.table = self.table;
    query.values = self.values;
    query.where = query.where;
    return query;
}

- (NSString *)sql {
    NSAssert(self.table, nil);
    NSAssert(self.values, nil);
    
    NSMutableArray *columns = [NSMutableArray array];
    for (NSString *column in [self.values sortedKeys]) {
        [columns addObject:[column stringByAppendingString:@"=?"]];
    }
    NSString *columnsStr = [columns componentsJoinedByString:@", "];
    
    if (self.where) {
        return [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", self.table, columnsStr, [self whereString]];
    } else {
        return [NSString stringWithFormat:@"UPDATE %@ SET %@", self.table, columnsStr];
    }
}

- (NSArray *)bindings {
    NSMutableArray *bindings = [NSMutableArray array];
    for (NSString *key in [self.values sortedKeys]) {
        [bindings addObject:[self.values objectForKey:key]];
    }
    [bindings addObjectsFromArray:[super bindings]];
    return bindings;
}

@end

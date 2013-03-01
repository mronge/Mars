//
//  CTSelectQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MSelectQuery.h"
#import "MQuery+Private.h"

@implementation MSelectQuery

- (id)copyWithZone:(NSZone *)zone {
    MSelectQuery *query = [[MSelectQuery alloc] init];
    query.table = self.table;
    query.columns = self.columns;
    query.where = self.where;
    return query;
}

- (NSString *)sql {
    NSAssert(self.table, nil);
    
    NSString *rowStr = nil;
    if (self.columns) {
        rowStr = [self.columns componentsJoinedByString:@", "];
    } else {
        rowStr = @"*";
    }
    
    NSMutableString *str = nil;
    if (self.where) {
        str = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", rowStr, self.table, [self whereString]];
    } else {
        str = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", rowStr, self.table];
    }
    
    if (self.orderBy) {
        [str appendFormat:@" ORDER BY %@ DESC", self.orderBy];
    }
    return str;
}

- (BOOL)modifies {
    return NO;
}
@end

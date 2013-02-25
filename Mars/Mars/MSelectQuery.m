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
    
    if (self.where) {
        return [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", rowStr, self.table, [self whereString]];
    } else {
        return [NSString stringWithFormat:@"SELECT %@ FROM %@", rowStr, self.table];
    }
}

@end

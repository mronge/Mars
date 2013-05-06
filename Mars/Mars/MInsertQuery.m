//
//  MInsertQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MInsertQuery.h"
#import "MQuery+Private.h"
#import "NSDictionary+Mars.h"

@implementation MInsertQuery

- (NSString *)sql {
    NSAssert(self.table, nil);
    NSAssert(self.values, nil);

    NSMutableArray *quotedValues = [NSMutableArray array];
    for (NSString *value in [self.values sortedKeys]) {
        [quotedValues addObject:[self quote:value]];
    }
    
    NSString *columnsStr = [quotedValues componentsJoinedByString:@", "];
    NSMutableArray *placeholders = [NSMutableArray array];
    for (int i = 0; i < self.values.count; i++) {
        [placeholders addObject:@"?"];
    }
    NSString *valuesStr = [placeholders componentsJoinedByString:@", "];

    return [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", [self quote:self.table], columnsStr, valuesStr];
}

@end

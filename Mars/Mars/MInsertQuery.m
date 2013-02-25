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
    
    NSString *columnsStr = [[self.values sortedKeys] componentsJoinedByString:@", "];
    NSMutableArray *placeholders = [NSMutableArray array];
    for (int i = 0; i < self.values.count; i++) {
        [placeholders addObject:@"?"];
    }
    NSString *valuesStr = [placeholders componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", self.table, columnsStr, valuesStr];
}

- (MQuery *)where:(NSDictionary *)expressions {
    [NSException raise:@"Unsupported" format:@"You can't use WHERE with an INSERT"];
    return nil;
}


@end

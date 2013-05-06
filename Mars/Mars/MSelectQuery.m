//
//  CTSelectQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MSelectQuery.h"
#import "MQuery+Private.h"

@interface MSelectQuery ()
@property (nonatomic, strong) NSString *orderBy;
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, strong) NSString *join;
@end

@implementation MSelectQuery

- (id)copyWithZone:(NSZone *)zone {
    MSelectQuery *query = [[MSelectQuery alloc] init];
    query.table = self.table;
    query.columns = self.columns;
    query.where = self.where;
    query.limit = self.limit;
    query.offset = self.offset;
    query.join = self.join;
    return query;
}

- (NSString *)sql {
    NSAssert(self.table, nil);
    
    NSString *rowStr = nil;
    if (self.columns) {
        NSMutableArray *columns = [NSMutableArray array];
        for (NSString *column in self.columns) {
            [columns addObject:[self quote:column]];
        }
        rowStr = [columns componentsJoinedByString:@", "];
    } else {
        rowStr = @"*";
    }
    
    NSMutableString *str = nil;
    if (self.where || self.join) {
        str = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", rowStr, [self tableString], [self whereString]];
    } else {
        str = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", rowStr, [self tableString]];
    }
    
    if (self.orderBy) {
        [str appendFormat:@" ORDER BY %@ DESC", [self quote:self.orderBy]];
    }

    if (self.limit != 0 && self.offset != 0) {
        [str appendFormat:@" LIMIT %d OFFSET %d", self.limit, self.offset];
    } else if (self.limit != 0) {
        [str appendFormat:@" LIMIT %d", self.limit];
    }

    return str;
}

- (BOOL)modifies {
    return NO;
}

- (NSString *)tableString {
    if ([self.table isKindOfClass:[NSString class]]) {
        // Plain old string format "tablename"
        return [self quote:self.table];
    } else if ([self.table isKindOfClass:[NSArray class]]) {
        NSArray *tableInfos = (NSArray *)self.table;
        if (tableInfos.count == 2 && [tableInfos[0] isKindOfClass:[NSString class]] && [tableInfos[1] isKindOfClass:[NSString class]]) {
            // Is of the format ["table" "alias"]
            return [self asString:tableInfos[0] alias:tableInfos[1]];
        } else if (tableInfos.count > 0) {
            NSMutableArray *asStatements = [NSMutableArray array];
            for (id obj in tableInfos) {
                if (![obj isKindOfClass:[NSArray class]]) {
                    [NSException raise:@"Unsupported" format:@"Must be a NSArray!"];
                }
                NSArray *info = (NSArray *)obj;
                [asStatements addObject:[self asString:info[0] alias:info[1]]];
            }
            return [asStatements componentsJoinedByString:@", "];
        }
    }
    [NSException raise:@"Unsupported" format:@"The table must be a string or an array like [tablename alias], or [[table1 t1], [table2 t2]]"];
    return nil;
}

- (NSString *)whereString {
    NSMutableString *where = [[super whereString] mutableCopy];
    if (self.join && where.length > 0) {
        [where appendFormat:@" AND %@", self.join];
    } else if (self.join && where.length == 0) {
        return self.join;
    }
    return where;

}

- (NSString *)asString:(NSString *)table alias:(NSString *)alias {
    return [NSString stringWithFormat:@"%@ AS %@", [self quote:table], [self quote:alias]];
}

// Have to do this to get the compiler to stop complaining
- (instancetype)where:(NSDictionary *)expressions {
    return (MSelectQuery *)[super where:expressions];
}

- (instancetype)orderBy:(NSString *)field {
    MSelectQuery *query = [self copy];
    query.orderBy = field;
    return query;
}

- (instancetype)limit:(NSUInteger)limit {
    MSelectQuery *query = [self copy];
    query.limit = limit;
    return query;
}

- (instancetype)limit:(NSUInteger)limit offset:(NSUInteger)offset {
    MSelectQuery *query = [self copy];
    query.limit = limit;
    query.offset = offset;
    return query;
}

- (instancetype)join:(NSString *)join {
    MSelectQuery *query = [self copy];
    query.join = join;
    return query;
}

@end

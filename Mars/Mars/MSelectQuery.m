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
@property (nonatomic, strong) NSString *order;
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, strong) NSString *join;
@property (nonatomic, strong) NSString *groupBy;
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
    query.order = self.order;
    query.orderBy = self.orderBy;
	query.groupBy = self.groupBy;
    return query;
}

- (NSString *)sql {
    NSAssert(self.table, nil);
    
    NSString *rowStr = nil;
    if (self.columns) {
        rowStr = [self expandAsStrings:self.columns];
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
        [str appendFormat:@" ORDER BY %@ %@", [self quote:self.orderBy], self.order];
    }

    if (self.limit != 0 && self.offset != 0) {
        [str appendFormat:@" LIMIT %lu OFFSET %lu", (unsigned long)self.limit, (unsigned long)self.offset];
    } else if (self.limit != 0) {
        [str appendFormat:@" LIMIT %lu", (unsigned long)self.limit];
    }

    return str;
}

- (BOOL)modifies {
    return NO;
}

- (NSString *)tableString {
    return [self expandAsStrings:self.table];
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

- (NSString *)expandAsStrings:(id)structure {
    if ([structure isKindOfClass:[NSString class]]) {
        // Plain old string format "tablename"
        return [self quote:structure];
    } else if ([structure isKindOfClass:[NSArray class]]) {
        NSArray *infos = (NSArray *)structure;
        if (infos.count > 0) {
            NSMutableArray *asStatements = [NSMutableArray array];
            for (id obj in infos) {
                if ([obj isKindOfClass:[NSString class]]) {
                    [asStatements addObject:[self quote:obj]];
                } else if ([obj isKindOfClass:[NSArray class]]) {
                    NSArray *info = (NSArray *)obj;
                    if (info.count == 2) {
                        [asStatements addObject:[self asString:info[0] alias:info[1]]];
                    } else {
                        [NSException raise:@"Unsupported" format:@"Must be of the form [table1 t1]!"];
                    }
                } else {
                    [NSException raise:@"Unsupported" format:@"Must be a NSArray of the form [table1 t1] or a NSString!"];
                }
            }
            return [asStatements componentsJoinedByString:@", "];
        }
    }
    [NSException raise:@"Unsupported" format:@"Must be a string or an array like [[table1 t1], [table2 t2], table3]"];
    return nil;
}

- (NSString *)asString:(NSString *)table alias:(NSString *)alias {
    return [NSString stringWithFormat:@"%@ AS %@", [self quote:table], [self quote:alias]];
}

// Have to do this to get the compiler to stop complaining
- (instancetype)where:(NSDictionary *)expressions {
    return (MSelectQuery *)[super where:expressions];
}

- (instancetype)orderByAsc:(NSString *)field {
    MSelectQuery *query = [self copy];
    query.orderBy = field;
    query.order = @"ASC";
    return query;
}

- (instancetype)orderByDesc:(NSString *)field {
    MSelectQuery *query = [self copy];
    query.orderBy = field;
    query.order = @"DESC";
    return query;
}

- (instancetype)limit:(NSUInteger)limit {
    MSelectQuery *query = [self copy];
    query.limit = limit;
    return query;
}

- (instancetype)groupBy:(NSString *)group
{
	MSelectQuery *query = [self copy];
	query.groupBy = group;
	
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

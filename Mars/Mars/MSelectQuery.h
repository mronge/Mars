//
//  CTSelectQuery.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MQuery.h"

@interface MSelectQuery : MQuery
- (instancetype)where:(NSDictionary *)expressions;
- (instancetype)orderByAsc:(NSString *)field;
- (instancetype)orderByDesc:(NSString *)field;
- (instancetype)limit:(NSUInteger)limit;
- (instancetype)limit:(NSUInteger)limit offset:(NSUInteger)offset;
- (instancetype)join:(NSString *)join;
- (instancetype)groupBy:(NSString *)group;
@end

//
//  MUpdateQuery.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MQuery.h"

@interface MUpdateQuery : MQuery
@property (nonatomic, strong) NSDictionary *values;

- (instancetype)where:(NSDictionary *)expressions;
@end

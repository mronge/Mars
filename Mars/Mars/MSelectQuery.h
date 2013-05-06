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
- (instancetype)orderBy:(NSString *)field;
@end

//
//  CTQuery+Private.h
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MQuery.h"

@interface MQuery ()
@property (nonatomic, strong) id table;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSDictionary *where;
@property (nonatomic, strong) NSString *orderBy;

- (NSString *)whereString;
- (NSString *)quote:(NSString *)str;
- (instancetype)where:(NSDictionary *)expressions;
@end

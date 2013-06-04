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
@property (nonatomic, strong) id columns;
@property (nonatomic, strong) NSDictionary *where;

- (NSString *)whereString;
- (NSString *)quote:(NSString *)str;
- (instancetype)where:(NSDictionary *)expressions;

- (NSString *)sql;
- (NSArray *)bindings;
@end

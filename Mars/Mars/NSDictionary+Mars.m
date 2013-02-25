//
//  NSDictionary+Mars.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "NSDictionary+Mars.h"

@implementation NSDictionary (Mars)
- (NSArray *)sortedKeys {
    return [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}
@end

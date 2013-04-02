//
//  MDatabase+AsyncAdditions.h
//  VMail
//
//  Created by Matt Ronge on 04/01/13.
//  Copyright (c) 2013 Central Atomics Inc. All rights reserved.
//



#import <Mars/MDatabase.h>

@interface MDatabase (AsyncAdditions)
- (void)queries:(NSArray *)queries completionBlock:(void (^)(NSError *err, NSArray *results))completionBlock;
@end

//
//  MDatabase+Private.h
//  Mars
//
//  Created by Matt Ronge on 03/13/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//



#import "MDatabase.h"

@class MTransaction;

@interface MDatabase ()
@property (nonatomic, strong, readonly) NSOperationQueue *writeQueue;

- (void)endTransaction:(MTransaction *)transaction;
@end

//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

#define kNoPk -1

@class MQuery;
@class MResults;

@interface MConnection : NSObject
@property (nonatomic, assign, readonly) sqlite3 *dbHandle;

- (id)init;
- (id)initWithPath:(NSString *)path;
- (BOOL)open;
- (BOOL)exec:(NSString *)sql error:(NSError **)error;
- (int64_t)executeUpdate:(MQuery *)query error:(NSError **)error;
- (MResults *)executeQuery:(MQuery *)query error:(NSError **)error;
@end

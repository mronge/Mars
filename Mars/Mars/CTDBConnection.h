//
//  CTQuery.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@class CTQuery;
@class CTResults;

@interface CTDBConnection : NSObject
@property (nonatomic, assign, readonly) sqlite3 *dbHandle;

- (id)initWithPath:(NSString *)path;
- (BOOL)open;
- (BOOL)exec:(NSString *)sql error:(NSError **)error;
- (int64_t)executeUpdate:(CTQuery *)query error:(NSError **)error;
- (CTResults *)executeQuery:(CTQuery *)query error:(NSError **)error;
@end

//
//  QueryTests.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "QueryTests.h"
#import "MQuery.h"

@implementation QueryTests

- (void)testSelectQuery {
    MQuery *query = nil;
    
    query = [MQuery selectFrom:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT * FROM emails", nil);
    
    query = [MQuery select:@"name" from:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT name FROM emails", nil);
    
    query = [MQuery select:@[@"name", @"to", @"from"] from:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT name, to, from FROM emails", nil);
    
    query = [[MQuery selectFrom:@"emails"] where:@{@"to":@"matt", @"count":@(3)}];
    STAssertEqualObjects(@"SELECT * FROM emails WHERE count=? AND to=?", [query sql], nil);
    NSArray *correctBindings = @[@(3), @"matt"];
    STAssertEqualObjects([query bindings], correctBindings, nil);
}
@end

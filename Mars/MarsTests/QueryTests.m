//
//  QueryTests.m
//  Mars
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "QueryTests.h"
#import "MQuery.h"
#import "MSelectQuery.h"
#import "MInsertQuery.h"
#import "MDeleteQuery.h"

@implementation QueryTests

- (void)testSelectQuery {
    MSelectQuery *query = nil;
    
    query = [MQuery selectFrom:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\"", nil);
    
    query = [MQuery select:@"name" from:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT \"name\" FROM \"emails\"", nil);

    query = [MQuery select:@"emails.name" from:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT \"emails\".\"name\" FROM \"emails\"", nil);
    
    query = [MQuery select:@[@"name", @"to", @"from"] from:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT \"name\", \"to\", \"from\" FROM \"emails\"", nil);
    
    query = [[MQuery selectFrom:@"emails"] where:@{@"to":@"matt", @"count":@(3)}];
    STAssertEqualObjects(@"SELECT * FROM \"emails\" WHERE \"count\"=? AND \"to\"=?", [query sql], nil);
    NSArray *correctBindings = @[@(3), @"matt"];
    STAssertEqualObjects([query bindings], correctBindings, nil);
}

- (void)testInsertQuery {
    MInsertQuery *query = nil;
    
    query = [MQuery insertInto:@"emails" values:@{@"to":@"matt", @"count":@(3)}];
    STAssertEqualObjects(@"INSERT INTO \"emails\" (\"count\", \"to\") VALUES (?, ?)", [query sql], nil);
    NSArray *correctBindings = @[@(3), @"matt"];
    STAssertEqualObjects([query bindings], correctBindings, nil);
}

- (void)testUpdateQuery {
    MUpdateQuery *query = nil;
    
    query = [MQuery update:@"emails" values:@{@"count":@(8), @"from":@"Bear"}];
    STAssertEqualObjects(@"UPDATE \"emails\" SET \"count\"=?, \"from\"=?", [query sql], nil);
    NSArray *correctBindings = @[@(8), @"Bear"];
    STAssertEqualObjects([query bindings], correctBindings, nil);
    
    query = [[MQuery update:@"emails" values:@{@"count":@(2), @"from":@"bear"}] where:@{@"to":@"matt"}];
    STAssertEqualObjects(@"UPDATE \"emails\" SET \"count\"=?, \"from\"=? WHERE \"to\"=?", [query sql], nil);
    correctBindings = @[@(2), @"bear", @"matt"];
    STAssertEqualObjects([query bindings], correctBindings, nil);
}

- (void)testDeleteQuery {
    MDeleteQuery *query = nil;
    
    query = [MQuery deleteFrom:@"emails"];
    STAssertEqualObjects(@"DELETE FROM \"emails\"", [query sql], nil);
    
    query = [[MQuery deleteFrom:@"emails"] where:@{@"to":@"matt"}];
    STAssertEqualObjects(@"DELETE FROM \"emails\" WHERE \"to\"=?", [query sql], nil);
    NSArray *correctBindings = @[@"matt"];
    STAssertEqualObjects([query bindings], correctBindings, nil);
}

- (void)testTableFormats {
    MSelectQuery *query = nil;

    query = [MQuery selectFrom:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\"", nil);

    query = [MQuery selectFrom:@[@"emails", @"e"]];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" AS \"e\"", nil);

    query = [MQuery selectFrom:@[@[@"emails", @"e"], @[@"address", @"a"]]];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" AS \"e\", \"address\" AS \"a\"", nil);
}
@end

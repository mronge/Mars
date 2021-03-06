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
#import "MQuery+Private.h"

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

- (void)testSelectWhereInQuery {
    MSelectQuery *query = [[MQuery selectFrom:@"emails"] where:@{@"to":@"matt", @"count":@(3), @"uid":@[@(1), @(2)]}];
    STAssertEqualObjects(@"SELECT * FROM \"emails\" WHERE \"count\"=? AND \"to\"=? AND \"uid\" IN (?,?)", [query sql], nil);
    NSArray *correctBindings = @[@(3), @"matt", @(1), @(2)];
    STAssertEqualObjects([query bindings], correctBindings, nil);
}

- (void)testSelectAsQuery {
    MSelectQuery *query = nil;

    query = [MQuery select:@[@[@"name", @"n"], @"to", @[@"from", @"f"]] from:@"emails"];
    STAssertEqualObjects([query sql], @"SELECT \"name\" AS \"n\", \"to\", \"from\" AS \"f\" FROM \"emails\"", nil);
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

    query = [MQuery selectFrom:@[@[@"emails", @"e"]]];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" AS \"e\"", nil);

    query = [MQuery selectFrom:@[@[@"emails", @"e"], @[@"address", @"a"]]];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" AS \"e\", \"address\" AS \"a\"", nil);
}

- (void)testLimit {
    MSelectQuery *query = nil;

    query = [[MQuery selectFrom:@"emails"] limit:50];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" LIMIT 50", nil);

    query = [[MQuery selectFrom:@"emails"] limit:50 offset:10];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" LIMIT 50 OFFSET 10", nil);
}

- (void)testJoin {
    NSArray *tables = @[@[@"emails", @"e"], @[@"address", @"a"]];
    MQuery *query = [[[MQuery select:@[@"e.name", @"a.location"] from:tables] where:@{@"to" : @"matt"}] join:@"a.id=e.address"];
    STAssertEqualObjects(@"SELECT \"e\".\"name\", \"a\".\"location\" FROM \"emails\" AS \"e\", \"address\" AS \"a\" WHERE \"to\"=? AND a.id=e.address", [query sql], nil);

    query = [[MQuery select:@[@"e.name", @"a.location"] from:tables] join:@"a.id=e.address"];
    STAssertEqualObjects(@"SELECT \"e\".\"name\", \"a\".\"location\" FROM \"emails\" AS \"e\", \"address\" AS \"a\" WHERE a.id=e.address", [query sql], nil);
}

- (void)testOrderBy {
    MSelectQuery *query = nil;
    query = [[MQuery selectFrom:@"emails"] orderByAsc:@"date"];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" ORDER BY \"date\" ASC", nil);
    
    query = [[MQuery selectFrom:@"emails"] orderByDesc:@"date"];
    STAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" ORDER BY \"date\" DESC", nil);
}
@end

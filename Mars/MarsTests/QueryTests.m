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
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\"");
    
    query = [MQuery select:@"name" from:@"emails"];
    XCTAssertEqualObjects([query sql], @"SELECT \"name\" FROM \"emails\"");

    query = [MQuery select:@"emails.name" from:@"emails"];
    XCTAssertEqualObjects([query sql], @"SELECT \"emails\".\"name\" FROM \"emails\"");
    
    query = [MQuery select:@[@"name", @"to", @"from"] from:@"emails"];
    XCTAssertEqualObjects([query sql], @"SELECT \"name\", \"to\", \"from\" FROM \"emails\"");
    
    query = [[MQuery selectFrom:@"emails"] where:@{@"to":@"matt", @"count":@(3)}];
    XCTAssertEqualObjects(@"SELECT * FROM \"emails\" WHERE \"count\"=? AND \"to\"=?", [query sql]);
    NSArray *correctBindings = @[@(3), @"matt"];
    XCTAssertEqualObjects([query bindings], correctBindings);
}

- (void)testSelectWhereInQuery {
    MSelectQuery *query = [[MQuery selectFrom:@"emails"] where:@{@"to":@"matt", @"count":@(3), @"uid":@[@(1), @(2)]}];
    XCTAssertEqualObjects(@"SELECT * FROM \"emails\" WHERE \"count\"=? AND \"to\"=? AND \"uid\" IN (?,?)", [query sql]);
    NSArray *correctBindings = @[@(3), @"matt", @(1), @(2)];
    XCTAssertEqualObjects([query bindings], correctBindings);
}

- (void)testSelectWhereRawSqlQuery {
	MSelectQuery *query = [[MQuery select:@[@"email"] from:@[@[@"accounts", @"a"]]] whereRawSql:@"a.email LIKE ?" args:@[@"test"]];
	XCTAssertEqualObjects([query sql], @"SELECT \"email\" FROM \"accounts\" AS \"a\" WHERE a.email LIKE ?");
}

- (void)testSelectAsQuery {
    MSelectQuery *query = nil;

    query = [MQuery select:@[@[@"name", @"n"], @"to", @[@"from", @"f"]] from:@"emails"];
    XCTAssertEqualObjects([query sql], @"SELECT \"name\" AS \"n\", \"to\", \"from\" AS \"f\" FROM \"emails\"");
}

- (void)testInsertQuery {
    MInsertQuery *query = nil;
    
    query = [MQuery insertInto:@"emails" values:@{@"to":@"matt", @"count":@(3)}];
    XCTAssertEqualObjects(@"INSERT INTO \"emails\" (\"count\", \"to\") VALUES (?, ?)", [query sql]);
    NSArray *correctBindings = @[@(3), @"matt"];
    XCTAssertEqualObjects([query bindings], correctBindings);
}

- (void)testUpdateQuery {
    MUpdateQuery *query = nil;
    
    query = [MQuery update:@"emails" values:@{@"count":@(8), @"from":@"Bear"}];
    XCTAssertEqualObjects(@"UPDATE \"emails\" SET \"count\"=?, \"from\"=?", [query sql]);
    NSArray *correctBindings = @[@(8), @"Bear"];
    XCTAssertEqualObjects([query bindings], correctBindings);
    
    query = [[MQuery update:@"emails" values:@{@"count":@(2), @"from":@"bear"}] where:@{@"to":@"matt"}];
    XCTAssertEqualObjects(@"UPDATE \"emails\" SET \"count\"=?, \"from\"=? WHERE \"to\"=?", [query sql]);
    correctBindings = @[@(2), @"bear", @"matt"];
    XCTAssertEqualObjects([query bindings], correctBindings);
}

- (void)testDeleteQuery {
    MDeleteQuery *query = nil;
    
    query = [MQuery deleteFrom:@"emails"];
    XCTAssertEqualObjects(@"DELETE FROM \"emails\"", [query sql]);
    
    query = [[MQuery deleteFrom:@"emails"] where:@{@"to":@"matt"}];
    XCTAssertEqualObjects(@"DELETE FROM \"emails\" WHERE \"to\"=?", [query sql]);
    NSArray *correctBindings = @[@"matt"];
    XCTAssertEqualObjects([query bindings], correctBindings);
}

- (void)testTableFormats {
    MSelectQuery *query = nil;

    query = [MQuery selectFrom:@"emails"];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\"");

    query = [MQuery selectFrom:@[@[@"emails", @"e"]]];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" AS \"e\"");

    query = [MQuery selectFrom:@[@[@"emails", @"e"], @[@"address", @"a"]]];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" AS \"e\", \"address\" AS \"a\"");
}

- (void)testLimit {
    MSelectQuery *query = nil;

    query = [[MQuery selectFrom:@"emails"] limit:50];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" LIMIT 50");

    query = [[MQuery selectFrom:@"emails"] limit:50 offset:10];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" LIMIT 50 OFFSET 10");
}

- (void)testJoin {
    NSArray *tables = @[@[@"emails", @"e"], @[@"address", @"a"]];
    MQuery *query = [[[MQuery select:@[@"e.name", @"a.location"] from:tables] where:@{@"to" : @"matt"}] join:@"a.id=e.address"];
    XCTAssertEqualObjects(@"SELECT \"e\".\"name\", \"a\".\"location\" FROM \"emails\" AS \"e\", \"address\" AS \"a\" WHERE \"to\"=? AND a.id=e.address", [query sql]);

    query = [[MQuery select:@[@"e.name", @"a.location"] from:tables] join:@"a.id=e.address"];
    XCTAssertEqualObjects(@"SELECT \"e\".\"name\", \"a\".\"location\" FROM \"emails\" AS \"e\", \"address\" AS \"a\" WHERE a.id=e.address", [query sql]);
}

- (void)testOrderBy {
    MSelectQuery *query = nil;
    query = [[MQuery selectFrom:@"emails"] orderByAsc:@"date"];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" ORDER BY \"date\" ASC");
    
    query = [[MQuery selectFrom:@"emails"] orderByDesc:@"date"];
    XCTAssertEqualObjects([query sql], @"SELECT * FROM \"emails\" ORDER BY \"date\" DESC");
}
@end

//
//  MarsTests.m
//  MarsTests
//
//  Created by Matt Ronge on 2/24/13.
//  Copyright (c) 2013 Central Atomics. All rights reserved.
//

#import "MarsTests.h"
#import "MConnection.h"
#import "MQuery.h"

@implementation MarsTests {
    MConnection *_conn;
}

- (void)setUp {
    [super setUp];
    
    _conn = [[MConnection alloc] init];
    [_conn open];
    [_conn exec:@"CREATE TABLE \"emails\" (\"name\" TEXT, \"email\" TEXT, \"count\" INTEGER);" error:nil];
    
    MQuery *insert = [MQuery insertInto:@"emails" values:@{@"name":@"Matt", @"email":@"matt@gmail.com", @"count":@(3)}];
    BOOL r = [_conn executeUpdate:insert error:nil];
    STAssertTrue(r, nil);
    STAssertTrue([_conn lastInsertRowId] == 1, nil);
}

- (void)tearDown {
    [_conn close];
    _conn = nil;
    [super tearDown];
}

- (void)testSelect {
    MQuery *query = [MQuery selectFrom:@"emails"];
    NSArray *results = [_conn executeQuery:query error:nil];
    STAssertTrue(results.count > 0, nil);
    STAssertEqualObjects(@"Matt", results[0][@"name"], nil);
}

- (void)testSelectCount {
    MQuery *query = [MQuery select:@"COUNT(*)" from:@"emails"];
    NSArray *results = [_conn executeQuery:query error:nil];
    STAssertTrue(results.count > 0, nil);
    STAssertEqualObjects(@(1), results[0][@"COUNT(*)"], nil);
}

- (void)testDeleteCount {
    MQuery *query = [[MQuery deleteFrom:@"emails"] where:@{@"name":@"Matt"}];
    BOOL r = [_conn executeUpdate:query error:nil];
    STAssertTrue(r, nil);
    
    query = [MQuery select:@"COUNT(*)" from:@"emails"];
    NSArray *results = [_conn executeQuery:query error:nil];
    STAssertTrue(results.count > 0, nil);
    STAssertEqualObjects(@(0), results[0][@"COUNT(*)"], nil);
}


@end

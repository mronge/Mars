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
#import "MDeleteQuery.h"
#import "MUpdateQuery.h"
#import "MInsertQuery.h"
#import "MSelectQuery.h"

@implementation MarsTests {
    MConnection *_conn;
}

- (void)setUp {
    [super setUp];
    
    _conn = [[MConnection alloc] init];
    [_conn open];
    [_conn exec:@"CREATE TABLE \"emails\" (\"name\" TEXT, \"email\" TEXT, \"count\" INTEGER);" error:nil];
    
    MQuery *insert = [MQuery insertInto:@"emails" values:@{@"name":@"Matt", @"email":@"matt@gmail.com", @"count":@(3)}];
    int64_t r = [_conn executeUpdate:insert error:nil];
    XCTAssertTrue(r > 0);
    XCTAssertTrue([_conn lastInsertRowId] == 1);
}

- (void)tearDown {
    [_conn close];
    _conn = nil;
    [super tearDown];
}

- (void)testSelect {
    MQuery *query = [MQuery selectFrom:@"emails"];
    NSArray *results = [_conn executeQuery:query error:nil];
    XCTAssertTrue(results.count > 0);
    XCTAssertEqualObjects(@"Matt", results[0][@"name"]);
}

- (void)testSelectCount {
    XCTAssertTrue(1 == self.emailCount);
}

- (void)testDeleteCount {
    int64_t r = [_conn executeUpdate:self.deletionQuery error:nil];
    XCTAssertTrue(r > 0);
    XCTAssertTrue(0 == self.emailCount);
}

- (void)testRollbackTransactions {
    BOOL success = [_conn beginTransaction:nil];
    XCTAssertTrue(success);

    int64_t r = [_conn executeUpdate:self.deletionQuery error:nil];
    XCTAssertTrue(r > 0);

    success = [_conn rollback:nil];
    XCTAssertTrue(success);
    XCTAssertTrue(1 == self.emailCount, @"Query was rolled back shouldn't have changed");
}

- (void)testCommitTransaction {
    BOOL success = [_conn beginTransaction:nil];
    XCTAssertTrue(success);

    int64_t r = [_conn executeUpdate:self.deletionQuery error:nil];
    XCTAssertTrue(r > 0);

    success = [_conn commit:nil];
    XCTAssertTrue(success);
    XCTAssertTrue(0 == self.emailCount);
}

- (MQuery *)deletionQuery {
    return [[MQuery deleteFrom:@"emails"] where:@{@"name":@"Matt"}];
}

- (int)emailCount {
    MQuery *query = [MQuery select:@"COUNT(*)" from:@"emails"];
    NSArray *results = [_conn executeQuery:query error:nil];
    XCTAssertTrue(results.count > 0);
    return [results[0][@"COUNT(*)"] intValue];
}
@end

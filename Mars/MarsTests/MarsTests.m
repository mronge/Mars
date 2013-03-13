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
    int64_t r = [_conn executeUpdate:insert error:nil];
    STAssertTrue(r > 0, nil);
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
    STAssertTrue(1 == self.emailCount, nil);
}

- (void)testDeleteCount {
    int64_t r = [_conn executeUpdate:self.deletionQuery error:nil];
    STAssertTrue(r > 0, nil);
    STAssertTrue(0 == self.emailCount, nil);
}

- (void)testRollbackTransactions {
    BOOL success = [_conn beginTransaction:nil];
    STAssertTrue(success, nil);

    int64_t r = [_conn executeUpdate:self.deletionQuery error:nil];
    STAssertTrue(r > 0, nil);

    success = [_conn rollback:nil];
    STAssertTrue(success, nil);
    STAssertTrue(1 == self.emailCount, @"Query was rolled back shouldn't have changed");
}

- (void)testCommitTransaction {
    BOOL success = [_conn beginTransaction:nil];
    STAssertTrue(success, nil);

    int64_t r = [_conn executeUpdate:self.deletionQuery error:nil];
    STAssertTrue(r > 0, nil);

    success = [_conn commit:nil];
    STAssertTrue(success, nil);
    STAssertTrue(0 == self.emailCount, nil);
}

- (MQuery *)deletionQuery {
    return [[MQuery deleteFrom:@"emails"] where:@{@"name":@"Matt"}];
}

- (int)emailCount {
    MQuery *query = [MQuery select:@"COUNT(*)" from:@"emails"];
    NSArray *results = [_conn executeQuery:query error:nil];
    STAssertTrue(results.count > 0, nil);
    return [results[0][@"COUNT(*)"] intValue];
}
@end

//
//  _63pinglunUnitTests.m
//  163pinglunUnitTests
//
//  Created by _ on 16/8/30.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZFQURLConnectionOperation.h"

@interface _63pinglunUnitTests : XCTestCase

@end

@implementation _63pinglunUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testZFQOperationWithURL:(NSURL *)URL
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
   XCTestExpectation *reqExpectation = [self expectationWithDescription:@"operationTest"];
    
    NSString *str1 = @"http://img3.cache.netease.com/photo/0025/2016-08-30/BVN9PBQS0BGT0025.jpg";
    NSURL *url = [NSURL URLWithString:str1];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(NSData *data) {
        UIImage *img = [UIImage imageWithData:data];
        NSLog(@"---->%@",NSStringFromCGSize(img.size));
        [reqExpectation fulfill];
    } failureBlk:^(NSError *error) {
        XCTFail(@"operationTest测试失败:%@",error);
    }];
    [operation start];
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testZFQOperation
{
    NSString *str1 = @"http://img3.cache.netease.com/photo/0025/2016-08-30/BVN9PBQS0BGT0025.jpg";
    NSURL *url = [NSURL URLWithString:str1];
    [self testZFQOperationWithURL:url];
}

- (void)testMutableOperation
{
    NSString *str1 = @"http://img3.cache.netease.com/photo/0025/2016-08-30/BVN9PBQS0BGT0025.jpg";
    NSString *str2 = @"http://imgsize.ph.126.net/?imgurl=http://img2.cache.netease.com/news/2016/8/30/20160830093600a1e77.jpg_300x400x1x85.jpg";
    NSString *str3 = @"http://imgsize.ph.126.net/?imgurl=http://img4.cache.netease.com/photo/0001/2016-08-31/BVPR9IE56VVV0001.jpg_190x120x1x85.jpg";
    NSString *str4 = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    NSArray *strs = @[str1,str2,str3,str4];
    NSInteger i = 0;
    for (NSString *tempStr in strs) {
        i++;
        NSString *desc = [NSString stringWithFormat:@"mutableOperationTest%zi",i];
        XCTestExpectation *reqExpectation = [self expectationWithDescription:desc];
        NSURL *url = [NSURL URLWithString:tempStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(NSData *data) {
            UIImage *img = [UIImage imageWithData:data];
            NSLog(@"---->%@",NSStringFromCGSize(img.size));
            [reqExpectation fulfill];
        } failureBlk:^(NSError *error) {
            XCTFail(@"operationTest测试失败:%@",error);
        }];
        [operation start];
    }
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testCancel
{
    NSString *str4 = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    XCTestExpectation *reqExpectation = [self expectationWithDescription:@"cancel"];
    NSURL *url = [NSURL URLWithString:str4];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(NSData *data) {
        UIImage *img = [UIImage imageWithData:data];
        NSLog(@"---->%@",NSStringFromCGSize(img.size));
        [reqExpectation fulfill];
    } failureBlk:^(NSError *error) {
        XCTFail(@"operationTest测试失败:%@",error);
        [reqExpectation fulfill];
    }];
    [operation start];
    [operation cancel];

    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

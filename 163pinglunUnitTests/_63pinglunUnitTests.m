//
//  _63pinglunUnitTests.m
//  163pinglunUnitTests
//
//  Created by _ on 16/8/30.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZFQURLConnectionOperation.h"
#import "ZFQURLOperationManager.h"
#import "AFNetworking.h"
#import "ItemStore.h"

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
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        UIImage *img = [UIImage imageWithData:data];
        NSLog(@"---->%@",NSStringFromCGSize(img.size));
        [reqExpectation fulfill];
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
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
    NSArray *strs = [self urlStrs];
    NSInteger i = 0;
    for (NSString *tempStr in strs) {
        i++;
        NSString *desc = [NSString stringWithFormat:@"mutableOperationTest%zi",i];
        XCTestExpectation *reqExpectation = [self expectationWithDescription:desc];
        NSURL *url = [NSURL URLWithString:tempStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
            UIImage *img = [UIImage imageWithData:data];
            NSLog(@"---->%@",NSStringFromCGSize(img.size));
            [reqExpectation fulfill];
        } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
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
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        XCTFail(@"cancelOperation测试失败");
        [reqExpectation fulfill];
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
        NSLog(@"operation error:%@",error);
        [reqExpectation fulfill];
    }];
    [operation start];
    [operation cancel];

    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testZFQOperationCancel
{
    NSString *str4 = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    XCTestExpectation *reqExpectation = [self expectationWithDescription:@"cancel"];
    NSURL *url = [NSURL URLWithString:str4];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        UIImage *img = [UIImage imageWithData:data];
        NSLog(@"---->%@",NSStringFromCGSize(img.size));
        XCTFail(@"testCancel2测试失败");
        [reqExpectation fulfill];
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [reqExpectation fulfill];
    }];
    [operation cancel];
    [operation start];
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testAFHTTPRequestOperationCancel
{
    NSString *str4 = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    XCTestExpectation *reqExpectation = [self expectationWithDescription:@"cancel"];
    NSURL *url = [NSURL URLWithString:str4];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *img = [UIImage imageWithData:responseObject];
        NSLog(@"---->%@",NSStringFromCGSize(img.size));
        [reqExpectation fulfill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        XCTFail(@"testCancel2测试失败:%@",error);
        [reqExpectation fulfill];
    }];
    [operation start];
    [operation cancel];
    
    BOOL isFinished = operation.isFinished;
    BOOL isReady = operation.isReady;
    BOOL isExecuting = operation.isExecuting;
    BOOL isCanceled = operation.isCancelled;
    
    NSLog(@"isFinished:%zi",isFinished);
    NSLog(@"isReady:%zi",isReady);
    NSLog(@"isExecuting:%zi",isExecuting);
    NSLog(@"isCanceled:%zi",isCanceled);
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testNSBlockOperationCancel
{
    XCTestExpectation *reqExpectation = [self expectationWithDescription:@"cancel"];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        sleep(2);
        NSLog(@"调用");
        [reqExpectation fulfill];
    }];
    
    [operation cancel];
    [operation start];
    
    if (operation.isCancelled == NO) {
        XCTAssert(0,@"测试失败");
        [reqExpectation fulfill];
    }
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testZFQURLConnectionOperationOriginState
{
    NSString *str4 = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    NSURL *url = [NSURL URLWithString:str4];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:nil failureBlk:nil];
    
    BOOL isFinished = operation.isFinished;
    BOOL isReady = operation.isReady;
    BOOL isExecuting = operation.isExecuting;
    BOOL isCanceled = operation.isCancelled;
    
    NSLog(@"isFinished:%zi",isFinished);
    NSLog(@"isReady:%zi",isReady);
    NSLog(@"isExecuting:%zi",isExecuting);
    NSLog(@"isCanceled:%zi",isCanceled);
}

- (void)testAFHTTPRequestOperationOriginState
{
    NSString *str = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    BOOL isFinished = operation.isFinished;
    BOOL isReady = operation.isReady;
    BOOL isExecuting = operation.isExecuting;
    BOOL isCanceled = operation.isCancelled;
    
    NSLog(@"isFinished:%zi",isFinished);
    NSLog(@"isReady:%zi",isReady);
    NSLog(@"isExecuting:%zi",isExecuting);
    NSLog(@"isCanceled:%zi",isCanceled);
}

- (void)testNSBlockOperationOriginState
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
    }];
    
    BOOL isFinished = operation.isFinished;
    BOOL isReady = operation.isReady;
    BOOL isExecuting = operation.isExecuting;
    BOOL isCanceled = operation.isCancelled;
    
    NSLog(@"isFinished:%zi",isFinished);
    NSLog(@"isReady:%zi",isReady);
    NSLog(@"isExecuting:%zi",isExecuting);
    NSLog(@"isCanceled:%zi",isCanceled);
}

- (void)testAFHTTPRequestOperationBatch
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"operationBatch"];
    
    dispatch_group_t group = dispatch_group_create();
    NSBlockOperation *blkOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"全部完成");
            [expectation fulfill];
        });
    }];
    //测试addDependency是否能够自动执行Operaion
    NSArray *strs = [self urlStrs];
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:strs.accessibilityElementCount];
    
    for (NSString *tempStr in strs) {
        NSURL *url = [NSURL URLWithString:tempStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operations addObject:operation];
        
        __weak typeof(operation) weakOperation = operation;
        operation.completionBlock = ^{
            __strong typeof (weakOperation) strongOperation = weakOperation;
            NSData *imgData = strongOperation.responseObject;
            if (imgData) {
                UIImage *img = [UIImage imageWithData:imgData];
                NSLog(@"----->%@",NSStringFromCGSize(img.size));
            }
            
            dispatch_group_leave(group);
        };
        
        dispatch_group_enter(group);
        [blkOperation addDependency:operation];
    }
    
    [operations addObject:blkOperation];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:operations waitUntilFinished:YES];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

- (NSArray<NSString *> *)urlStrs
{
    NSString *str1 = @"http://img3.cache.netease.com/photo/0025/2016-08-30/BVN9PBQS0BGT0025.jpg";
    NSString *str2 = @"http://imgsize.ph.126.net/?imgurl=http://img2.cache.netease.com/news/2016/8/30/20160830093600a1e77.jpg_300x400x1x85.jpg";
    NSString *str3 = @"http://imgsize.ph.126.net/?imgurl=http://img4.cache.netease.com/photo/0001/2016-08-31/BVPR9IE56VVV0001.jpg_190x120x1x85.jpg";
    NSString *str4 = @"http://img3.cache.netease.com/photo/0001/2016-08-31/BVPR9I6G6VVV0001.jpg";
    NSArray *strs = @[str1,str2,str3,str4];
    
    return strs;
}

- (void)testAFHTTPRequestOperationBatch2
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"operationBatch"];
    
    //测试addDependency是否能够自动执行Operaion
    NSArray *strs = [self urlStrs];
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:strs.count];
    
    for (NSString *tempStr in strs) {
        NSURL *url = [NSURL URLWithString:tempStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operations addObject:operation];
    }
    
    
    NSArray *finalOperations = [AFHTTPRequestOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        
    } completionBlock:^(NSArray *operations) {
        NSLog(@"全部完成");
        [expectation fulfill];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:finalOperations waitUntilFinished:YES];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testZFQURLOperationDependency
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"zfqOperationBatch"];
    
    NSArray *strs = [self urlStrs];
    
    NSURL *url1 = [NSURL URLWithString:strs[0]];
    NSURLRequest *request1 = [[NSURLRequest alloc] initWithURL:url1];
    ZFQURLConnectionOperation *operation1 = [[ZFQURLConnectionOperation alloc] initWithRequest:request1 successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        if (data) {
            UIImage *img = [UIImage imageWithData:data];
            NSLog(@"----->1111111%@",NSStringFromCGSize(img.size));
        }
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
    }];
    operation1.completionBlock = ^{
        NSLog(@"++++++++回调11111ok!");
    };
    
    
    NSURL *url2 = [NSURL URLWithString:strs[3]];
    NSURLRequest *request2 = [[NSURLRequest alloc] initWithURL:url2];
    ZFQURLConnectionOperation *operation2 = [[ZFQURLConnectionOperation alloc] initWithRequest:request2 successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        if (data) {
            UIImage *img = [UIImage imageWithData:data];
            NSLog(@"----->2222222%@",NSStringFromCGSize(img.size));
        }
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
        NSLog(@"失败:%@",error);
    }];
    operation2.completionBlock = ^{
        NSLog(@"++++++++回调222222ok!");
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operation1,operation2] waitUntilFinished:YES];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testZFQURLOperationBatch
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"zfqOperationBatch"];
    
    NSArray *strs = [self urlStrs];
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:strs.count];
    
    for (NSString *tempStr in strs) {
        NSURL *url = [NSURL URLWithString:tempStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
            if (data) {
                UIImage *img = [UIImage imageWithData:data];
                NSLog(@"----->%@",NSStringFromCGSize(img.size));
            }
        } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
        }];
        [operations addObject:operation];
    }
    
    NSArray *finalOperations = [ZFQURLConnectionOperation batchOfOperations:operations progressBlk:^(NSInteger numberOfFinishedOperations, NSInteger numberOfOperations) {
        NSLog(@"---------->%f",numberOfFinishedOperations/(CGFloat)numberOfOperations);
    } completionBlk:^{
        NSLog(@"全部完成");
        [expectation fulfill];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:finalOperations waitUntilFinished:NO];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testErrorURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"errorURL"];
    NSString *str = @"http://163pinglun.com/http:/163pinglun.com/wp-json/wp/v2/posts";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];

    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        NSLog(@"----->成功");
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
        NSLog(@"======>>失败%@",error);
        [expectation fulfill];
    }];
    
    [operation start];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)test222
{
    NSArray *postIDs = [ItemStore allPostIDFromDB];
    NSArray *postItems = @[@"18888",@"18696",@"18688",@"18677",@"18676",@"18670"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger i = 0,j = 0;
    
    NSInteger count = postItems.count;
    NSString *str1,*str2;
    while (i < count) {
        str1 = postItems[i];
        if (j < postIDs.count) {
            str2 = postIDs[j];
        } else {
            //添加
            [array addObject:(postItems[i])];
            i++;
        }
        
        NSComparisonResult result = [str1 compare:str2];
        if (result == NSOrderedAscending) {  //str1 < str2
            j++;
        } else if (result == NSOrderedSame) {
            i++;
            j++;
        } else {
            [array addObject:(postItems[i])];
            i++;
        }
    }
    NSLog(@"%@",array);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

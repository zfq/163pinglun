//
//  ZFQURLOperationManager.m
//  163pinglun
//
//  Created by _ on 16/9/7.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQURLOperationManager.h"

@implementation ZFQURLOperationManager

static NSOperationQueue * zfqUrlConnectionOperationQueue()
{
    static NSOperationQueue *zfqOperationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        zfqOperationQueue = [[NSOperationQueue alloc] init];
    });
    return zfqOperationQueue;
}

/*
 假定字典里没有数组，即是简单的字符串
 */
NSString *queryString(NSDictionary *params)
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *pairStr = [NSString stringWithFormat:@"%@=%@",[key description],[obj description]];
        [array addObject:pairStr];
    }];
    
    return [array componentsJoinedByString:@"&"];
}

+ (void)sendRequest:(NSURLRequest *)request
         successBlk:(ZFQURLOperationSuccessBlk)successBlk
         failureBlk:(ZFQURLOperationFailureBlk)failureBlk
{
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:successBlk failureBlk:failureBlk];
    [zfqUrlConnectionOperationQueue() addOperation:operation];
}

+ (void)GETWithURL:(NSString *)url
            params:(NSDictionary *)params
        successBlk:(ZFQURLOperationSuccessBlk)successBlk
        failureBlk:(ZFQURLOperationFailureBlk)failureBlk
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *urlStr = nil;
    NSString *queryStr = queryString(params);
    if (queryStr.length > 0) {
        urlStr = [url stringByAppendingFormat:@"?%@",queryStr];
    } else {
        urlStr = url;
    }
    
    request.URL = [NSURL URLWithString:urlStr];
    request.HTTPMethod = @"GET";
    ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:request successBlk:successBlk failureBlk:failureBlk];
    [zfqUrlConnectionOperationQueue() addOperation:operation];
}

+ (void)startBatchOfOperations:(NSArray<NSOperation *> *)operations
                   progressBlk:(void (^)(NSInteger numberOfFinishedOperations,NSInteger numberOfOperations))progressBlk
                 completionBlk:(void (^)(void))completionBlk
{
    NSArray *finalOperations = [ZFQURLConnectionOperation batchOfOperations:operations progressBlk:progressBlk completionBlk:completionBlk];
    [zfqUrlConnectionOperationQueue() addOperations:finalOperations waitUntilFinished:NO];
}

@end

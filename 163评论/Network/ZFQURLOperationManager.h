//
//  ZFQURLOperationManager.h
//  163pinglun
//
//  Created by _ on 16/9/7.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQURLConnectionOperation.h"

@interface ZFQURLOperationManager : NSObject

+ (void)sendRequest:(NSURLRequest *)request
         successBlk:(ZFQURLOperationSuccessBlk)successBlk
         failureBlk:(ZFQURLOperationFailureBlk)failureBlk;

+ (void)sendRequestWithURL:(NSString *)url
                httpMethod:(NSString *)httpMethod
                    params:(NSDictionary *)params
                successBlk:(ZFQURLOperationSuccessBlk)successBlk
                failureBlk:(ZFQURLOperationFailureBlk)failureBlk;

+ (void)startBatchOfOperations:(NSArray<NSOperation *> *)operations
                   progressBlk:(void (^)(NSInteger numberOfFinishedOperations,NSInteger numberOfOperations))progressBlk
                 completionBlk:(void (^)(void))completionBlk;

@end

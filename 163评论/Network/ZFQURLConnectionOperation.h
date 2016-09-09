//
//  ZFQURLConnectionOperation.h
//  163pinglun
//
//  Created by _ on 16/8/28.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFQURLConnectionOperation;
typedef void (^ZFQURLOperationFailureBlk)(ZFQURLConnectionOperation *operation, NSError *error);
typedef void (^ZFQURLOperationSuccessBlk)(ZFQURLConnectionOperation *operation, NSData *data);

@interface ZFQURLConnectionOperation : NSOperation

@property (nonatomic,copy) ZFQURLOperationSuccessBlk successBlk;
@property (nonatomic,copy) ZFQURLOperationFailureBlk failureBlk;
@property (nonatomic,strong) NSURLResponse *response;


- (instancetype)initWithRequest:(NSURLRequest *)request
                     successBlk:(ZFQURLOperationSuccessBlk)successBlk
                     failureBlk:(ZFQURLOperationFailureBlk)failureBlk;

+ (NSArray<ZFQURLConnectionOperation *> *)batchOfOperations:(NSArray<NSOperation *> *)operations
                                                progressBlk:(void (^)(NSInteger numberOfFinishedOperations,NSInteger numberOfOperations))progressBlk
                                              completionBlk:(void (^)(void))completionBlk;

@end

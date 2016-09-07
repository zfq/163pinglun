//
//  ZFQURLConnectionOperation.h
//  163pinglun
//
//  Created by _ on 16/8/28.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ZFQURLOperationFailureBlk)(NSError *error);
typedef void (^ZFQURLOperationSuccessBlk)(NSData *data);

@interface ZFQURLConnectionOperation : NSOperation

@property (nonatomic,copy) ZFQURLOperationSuccessBlk successBlk;
@property (nonatomic,copy) ZFQURLOperationFailureBlk failureBlk;

- (instancetype)initWithRequest:(NSURLRequest *)request
                     successBlk:(ZFQURLOperationSuccessBlk)successBlk
                     failureBlk:(ZFQURLOperationFailureBlk)failureBlk;

+ (void)batchOfOperations:(NSArray<NSOperation *> *)operations
              progressBlk:(void (^)(NSInteger numberOfFinishedOperations,NSInteger numberOfOperations))progressBlk
            completionBlk:(void (^)(void))completionBlk;

@end

//
//  ZFQBaseRequest.h
//  163pinglun
//
//  Created by _ on 16/9/8.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFQURLOperationManager;

@interface ZFQBaseRequest : NSObject

@property (nonatomic,copy) NSDictionary *userInfo;  //自定义参数
@property (nonatomic,assign) NSInteger errorCode;   //消息返回值
@property (nonatomic,strong) NSString *errorMsg;    //错误消息内容

///host地址
- (NSString *)baseURL;

///
- (NSString *)pathURL;

- (NSString *)httpMethod;

///请求参数
- (NSDictionary *)requestParam;

///响应结果
- (void)response:(id)responseObj;

@end

@interface ZFQRequestObj : NSObject

+ (ZFQRequestObj *)sharedInstance;

//普通请求
- (void)sendRequest:(ZFQBaseRequest *)request
         successBlk:(void(^)(ZFQBaseRequest *request, id responseObject))successBlk
         failureBlk:(void(^)(ZFQBaseRequest *request, NSError *error))failureBlk;

- (void)sendRequestWithURL:(ZFQBaseRequest *)request
         successBlk:(void(^)(ZFQBaseRequest *request, id responseObject))successBlk
         failureBlk:(void(^)(ZFQBaseRequest *request, NSError *error))failureBlk;

@end
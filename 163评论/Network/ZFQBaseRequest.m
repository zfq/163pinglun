//
//  ZFQBaseRequest.m
//  163pinglun
//
//  Created by _ on 16/9/8.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseRequest.h"
#import "MacroDefinition.h"
#import "ZFQURLOperationManager.h"

@implementation ZFQBaseRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

///host地址
- (NSString *)baseURL
{
    return @"";
}

///
- (NSString *)pathURL
{
    return @"";
}

- (NSString *)httpMethod
{
    return @"GET";
}

///请求参数
- (NSDictionary *)requestParam
{
    return nil;
}

- (void)response:(id)responseObj
{
    
}

@end

@implementation ZFQRequestObj

static ZFQRequestObj *sharedRequestObj = nil;

#pragma mark -

+ (ZFQRequestObj *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRequestObj = [[ZFQRequestObj alloc] init];
    });
    return sharedRequestObj;
}

/*
 覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，
 因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedRequestObj) {
            sharedRequestObj = [super allocWithZone:zone];
        }
    });
    return sharedRequestObj;
}

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return self;
}

#pragma mark -

- (NSString*)makeURLWithRequest:(ZFQBaseRequest*)request
{
    if (request.baseURL.length > 0) {
        return [NSString stringWithFormat: @"%@/%@",NULLSTR(request.baseURL),NULLSTR(request.pathURL)];
    } else {
        return [NSString stringWithFormat: @"%@/%@",HOSTURL,NULLSTR(request.pathURL)];
    }
}

#pragma mark -
//普通请求
- (void)sendRequest:(ZFQBaseRequest *)request
         successBlk:(void(^)(ZFQBaseRequest *request, id responseObject))successBlk
         failureBlk:(void(^)(ZFQBaseRequest *request, NSError *error))failureBlk
{
    //1.创建请求路径
    NSString *urlStr = [self makeURLWithRequest:request];
    
    //2.创建请求参数
    NSDictionary *param = [request requestParam];
    NSMutableDictionary *mulParam = nil;
    if (param == nil) {
        mulParam = [[NSMutableDictionary alloc] init];
    } else {
        mulParam = [[NSMutableDictionary alloc] initWithDictionary:param copyItems:YES];
    }
    
    //3.发送请求
    [ZFQURLOperationManager sendRequestWithURL:urlStr httpMethod:request.httpMethod params:mulParam successBlk:^(ZFQURLConnectionOperation *operation, NSData *data) {
        
        //4.解析数据
        [request response:data];
        
        //5.成功回调
        if (successBlk) {
            successBlk(request,data);
        }
    } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
        if (failureBlk) {
            failureBlk(request,error);
        }
    }];

}

@end
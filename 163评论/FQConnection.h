//
//  FQConnection.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface FQConnection : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSURLConnection *internalConnection;
    NSMutableData *container;
}

@property (nonatomic,copy) NSURLRequest *request;
@property (nonatomic,copy) void (^completionBlock)(id obj,NSError *err);
@property (nonatomic,strong) id<NSXMLParserDelegate> xmlRootObject;
@property (nonatomic,strong) id<JSONSerializable> jsonRootObject;
@property (nonatomic) BOOL isDictionary;

- (instancetype) initWithRequest:(NSURLRequest *)req;
- (void)start;
- (void)cancel;
@end

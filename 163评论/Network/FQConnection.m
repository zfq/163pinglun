//
//  FQConnection.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FQConnection.h"
#import "GeneralService.h"
#import "NSError+networkMsg.h"
#import "NSString+Addition.h"
#import "MacroDefinition.h"
#import "ZFQHUD.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation FQConnection

- (instancetype)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        self.request = req;
        self.isDictionary = YES;
    }
    return self;
}

- (void)start
{
    container = [[NSMutableData alloc] init];
    internalConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
//    [internalConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    [internalConnection start];
    if (sharedConnectionList == nil)
        sharedConnectionList = [[NSMutableArray alloc] init];
    
    [sharedConnectionList addObject:internalConnection];
}

- (void)cancel
{
    if (internalConnection != nil) {
        [internalConnection cancel];
        [sharedConnectionList removeObject:internalConnection];
        internalConnection = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionBlock != nil)
        [self completionBlock](nil,error);
    
    //提示错误信息
    ZFQLog(@"%@",error);
    NSString *desc = [NSError urlErrorDesciptionForCode:error.code];
    [[ZFQHUD sharedView] showWithMsg:desc duration:2.5 completionBlk:nil];
    
    [sharedConnectionList removeObject:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#if TEST_163_LOSS
    NSString *fileName = nil;
    if ([self.request.URL.absoluteString rangeOfString:@"baidu"].length > 0) {
        fileName = @"post";
    } else {
        fileName = @"comment1";
    }
    NSString *postJsonPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    container = [[NSMutableData alloc] initWithContentsOfFile:postJsonPath];
#endif
    
    //根据帖子id号来区分进行不同的解析
    /*
    NSArray *pathComponets = connection.originalRequest.URL.pathComponents;
    NSInteger postID = -1;
    for (NSString *str in pathComponets) {
        if ([str isNumStr]) {
            postID = [str integerValue];
            break;
        }
    }*/
    NSInteger postID = -1;
    NSString *query = connection.originalRequest.URL.query;
    NSArray *comp = [query componentsSeparatedByString:@"="];
    if (comp.count == 2) {
        postID = [comp[1] integerValue];
    }
    
    id rootObject = nil;
    if (self.xmlRootObject != nil) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:container];
        [parser setDelegate:self.xmlRootObject];
        [parser parse];
        rootObject = self.xmlRootObject;
    } else if (self.jsonRootObject != nil) {
        
        if (self.isDictionary) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:container options:0 error:nil];
            [self.jsonRootObject readFromJSONDictionary:dictionary];
        } else {
            //过滤尾部的<!--xxx-->
            container = [self resultDataFromData:container];
            
            NSArray *array = [NSJSONSerialization JSONObjectWithData:container options:0 error:nil];
            if (postID > kSeparatorPostID) {
                //新版API
                [self.jsonRootObject readFromJSONArray:array apiVersion:nil];
            } else {
                [self.jsonRootObject readFromJSONArray:array];
            }
            
        }
        rootObject = self.jsonRootObject;
    }
    
    if (self.completionBlock != nil)
        [self completionBlock](rootObject,nil);
    
    [sharedConnectionList removeObject:connection];
    connection = nil;
}

- (NSMutableData *)resultDataFromData:(NSMutableData *)data
{
    NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *pattern = @"(<!--.*-->)$";
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error != nil) {
        return nil;
    } else {
        NSArray *match = [reg matchesInString:tempStr options:NSMatchingReportCompletion range:NSMakeRange(0, [tempStr length])];
        if (match.count > 0) {
            NSTextCheckingResult *result = match.firstObject;
            NSRange range = [result range];
            NSString *subStr = [tempStr substringToIndex:range.location];
            return [[NSMutableData alloc] initWithData:[subStr dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            return data;
        }
    }
}
@end




//
//  FQConnection.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FQConnection.h"
#import "MBProgressHUD.h"
#import "UIDeviceHardware.h"

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
    
    if (sharedConnectionList == nil)
        sharedConnectionList = [[NSMutableArray alloc] init];
    
    [sharedConnectionList addObject:internalConnection];
}

- (void)cancel
{
    if (internalConnection != nil) {
        [internalConnection cancel];
        [sharedConnectionList removeObject:internalConnection];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionBlock != nil)
        [self completionBlock](nil,error);
    
    [sharedConnectionList removeObject:connection];
    
    //提示错误信息
    NSString *errorCode = [NSString stringWithFormat:@"%d", error.code];
    [UIDeviceHardware showHUDWithTitle:errorCode andDetail:error.localizedDescription image:@"MBProgressHUD.bundle/error"];

     [sharedConnectionList removeObject:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
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
            NSArray *array = [NSJSONSerialization JSONObjectWithData:container options:0 error:nil];
            [self.jsonRootObject readFromJSONArray:array];
        }
        rootObject = self.jsonRootObject;
    }
    
    if (self.completionBlock != nil)
        [self completionBlock](rootObject,nil);
    
    [sharedConnectionList removeObject:connection];
}
@end




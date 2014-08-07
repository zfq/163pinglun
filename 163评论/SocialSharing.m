//
//  SocialSharing.m
//  社交分享
//
//  Created by zhaofuqiang on 14-8-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "SocialSharing.h"

@implementation SocialSharing

+ (SocialSharing *)sharedInstance
{
    static SocialSharing *socialSharing = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socialSharing = [[SocialSharing alloc] init];
    });
    return socialSharing;
}

+ (BOOL)registerWeiboSDK
{
    [WeiboSDK enableDebugMode:YES];
    return [WeiboSDK registerApp:kWeiboAppKey];
}

- (NSString *)weiboToken
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"weiboToken"];
}

- (void)saveWeiboToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"weiboToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (WBMessageObject *)initMessageWithText:(NSString *)text image:(UIImage *)image;
{
    WBMessageObject *messageObj = [WBMessageObject message];
    messageObj.text = text;
    
    if (image != nil) {
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.imageData = UIImageJPEGRepresentation(image, 0);
        messageObj.imageObject = imageObj;
    }
    
    return messageObj;
}

+ (void)sendWeiboWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(BOOL success))completion
{   
    //创建微博信息
    WBMessageObject *messageObj = [[self class] initMessageWithText:text image:image];
    WBSendMessageToWeiboRequest *response = [WBSendMessageToWeiboRequest requestWithMessage:messageObj];
    
    SocialSharing *sharing = [[self class] sharedInstance];
    if ([WeiboSDK sendRequest:response])
    {
        [sharing setCompletionBlock:completion];
        if ([sharing completionBlock] != nil) {
            [sharing completionBlock](YES);
        }
        
    } else {
        [sharing setCompletionBlock:completion];
        if ([sharing completionBlock] != nil) {
            [sharing completionBlock](NO);
        }
    }
}

#pragma mark - weiboSDK delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        NSLog(@"wewe成功");
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = @"发送结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = @"认证结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        NSString *token = [(WBAuthorizeResponse *)response accessToken];
        [self saveWeiboToken:token];
        
        [alert show];
    }

}

@end

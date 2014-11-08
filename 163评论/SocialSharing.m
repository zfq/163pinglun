//
//  SocialSharing.m
//  社交分享
//
//  Created by zhaofuqiang on 14-8-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "SocialSharing.h"
//#import "TencentOpenAPI/QQApiInterface.h"
#import "GeneralService.h"
#import <TencentOpenAPI/QQApiInterface.h>
@interface SocialSharing()
{
    TencentOAuth *_tencentOAuth;
    
    NSString *_title;
    NSString *_description;
    NSString *_urlString;
    UIImage *_image;
    
    SocialSharingType _shareType;
}
@end

@implementation SocialSharing

+ (SocialSharing *)sharedInstance
{
    static SocialSharing *socialSharing = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socialSharing = [[SocialSharing alloc] init];
        
        [socialSharing registerWeiboSDK];
    });
    return socialSharing;
}

- (BOOL)handleURL:(NSURL *)url
{
    NSString *shareName = self.shareTypeName;
    if ([shareName isEqualToString:@"新浪微博"]) {
        _shareType = SocialSharingTypeWeibo;
    } else if ([shareName isEqualToString:@"QQ空间"]) {
        _shareType = SocialSharingTypeTencent;
    }
    
    return [self handleURL:url withSocailSharingType:_shareType];
}

- (BOOL)handleURL:(NSURL *)url withSocailSharingType:(SocialSharingType)sharingType
{
    SocialSharing *sharing = [[self class] sharedInstance];
    switch (sharingType) {
        case SocialSharingTypeWeibo: {
            return [WeiboSDK handleOpenURL:url delegate:sharing];
        }break;
        case SocialSharingTypeTencent: {
            if (YES == [TencentOAuth CanHandleOpenURL:url])
            {
                return [TencentOAuth HandleOpenURL:url];
            }
            return YES;
        }break;
    }
}

- (BOOL)registerWeiboSDK
{
    [WeiboSDK enableDebugMode:NO]; //Release时把它改为NO
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

- (void)sendWeiboWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(BOOL success))completion
{
    //创建微博信息
    WBMessageObject *messageObj = [[self class] initMessageWithText:text image:image];
    WBSendMessageToWeiboRequest *response = [WBSendMessageToWeiboRequest requestWithMessage:messageObj];
    
    SocialSharing *sharing = [[self class] sharedInstance];
    if ([WeiboSDK sendRequest:response]) {
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
//        NSLog(@"wewe成功");
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
    /*
        NSString *title = @"发送结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
      */
        [GeneralService showHUDWithTitle:@"分享成功" andDetail:nil image:@"MBProgressHUD.bundle/success"];
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
/*---------qq---------*/
- (NSString *)tencentToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tencentToken"];
}

- (NSString *)tencentOpenId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tencentOpenId"];
}

- (void)saveTencentToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setValue:_tencentOAuth.accessToken forKey:@"tencentToken"];
    [[NSUserDefaults standardUserDefaults] setValue:_tencentOAuth.openId forKey:@"tencentOpenId"];
    [[NSUserDefaults standardUserDefaults] setValue:_tencentOAuth.expirationDate forKey:@"tencentExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)tencentOAuthLoad
{
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppID andDelegate:self];
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_ADD_SHARE,

                            nil];
    //设置token
    [_tencentOAuth setAccessToken:self.tencentToken];
    [_tencentOAuth setOpenId:self.tencentOpenId];
    return [_tencentOAuth authorize:permissions inSafari:NO];
}

- (void)sendQQShareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)urlString
{
    SocialSharing *sharing = [[self class] sharedInstance];
    sharing->_title = title;
    sharing->_description = description;
    sharing->_image = image;
    sharing->_urlString = urlString;
    if ([sharing tencentOAuthLoad]) {
        DNSLog(@"authorize YES");
    } else {
        DNSLog(@"authorize NO");
    }
   
}

- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        [self saveTencentToken:_tencentOAuth.accessToken];
        SocialSharing *sharing = [[self class] sharedInstance];
        
        NSString *str = sharing.tencentToken;
        if ((str != nil) && (str.length != 0)) { //还要判断过期时间
            
            dispatch_queue_t mySendReqQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(mySendReqQueue, ^{
                NSData *imgData = UIImageJPEGRepresentation(sharing->_image, 0.8);
                NSURL *url = [NSURL URLWithString:sharing->_urlString];
                QQApiNewsObject *qqApiObject = [QQApiNewsObject objectWithURL:url title:sharing->_title description:sharing->_description previewImageData:imgData];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:qqApiObject];
                QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                if (sent == EQQAPISENDSUCESS) {
                    DNSLog(@"发表成功");
                } else {
                    DNSLog(@"发表失败:%d",sent);
                }
                
            });
            
        }

    }
    else
    {
        NSLog(@"登录失败");
    }
   
}
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"登录失败回调");
}

- (void)tencentDidNotNetWork
{
    NSLog(@"网络不工作");
}
- (void)addShareResponse:(APIResponse*) response
{
    NSLog(@"%@",response.errorMsg);
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    NSLog(@"close");
}
@end



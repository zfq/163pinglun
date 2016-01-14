//
//  SocialSharing.h
//  社交分享
//
//  Created by zhaofuqiang on 14-8-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>

typedef enum {
    SocialSharingTypeWeibo = 0,
    SocialSharingTypeTencent
}SocialSharingType;

@interface SocialSharing : NSObject <WeiboSDKDelegate,TencentSessionDelegate>

@property (nonatomic,strong) NSString *shareTypeName;
@property (nonatomic,strong,readonly) NSString *weiboToken;
@property (nonatomic,strong,readonly) NSString *tencentToken;
@property (nonatomic,strong,readonly) NSString *tencentOpenId;
@property (nonatomic,copy) void (^completionBlock)(BOOL success);

+ (SocialSharing *)sharedInstance;

- (BOOL)handleURL:(NSURL *)url;
- (BOOL)handleURL:(NSURL *)url withSocailSharingType:(SocialSharingType)sharingType;
/* ------weibo-------- */
- (BOOL)registerWeiboSDK;
- (void)sendWeiboWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(BOOL success))completion;
+ (WBMessageObject *)initMessageWithText:(NSString *)text image:(UIImage *)image;

- (void)saveWeiboToken:(NSString *)token;

/*-------qq-----------*/
- (void)sendQQShareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)urlString;


@end

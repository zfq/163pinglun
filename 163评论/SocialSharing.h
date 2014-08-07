//
//  SocialSharing.h
//  社交分享
//
//  Created by zhaofuqiang on 14-8-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

@interface SocialSharing : NSObject <WeiboSDKDelegate>

@property (nonatomic,strong,readonly) NSString *weiboToken;
@property (nonatomic,copy) void (^completionBlock)(BOOL success);

+ (SocialSharing *)sharedInstance;

+ (BOOL)registerWeiboSDK;
+ (void)sendWeiboWithText:(NSString *)text image:(UIImage *)image completion:(void (^)(BOOL success))completion;
+ (WBMessageObject *)initMessageWithText:(NSString *)text image:(UIImage *)image;

- (void)saveWeiboToken:(NSString *)token;

@end

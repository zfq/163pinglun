//
//  UIDeviceHardware.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDeviceHardware : NSObject

+ (NSString *)platform;
+ (NSString *)platformString;

+ (void)showHUDWithTitle:(NSString *)title andDetail:(NSString *)detail image:(NSString *)imageName;
+ (void)showHUDWithTitle:(NSString *)title andDetail:(NSString *)detail image:(NSString *)imageName inView:(UIView *)view;
+ (void)setNetworkReachability:(BOOL)isReachable;
+ (BOOL)isReachable;
@end

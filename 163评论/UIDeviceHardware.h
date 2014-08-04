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

+ (NSString *)urlErrorDesciptionForCode:(NSInteger)code;

+ (void)showHUDWithTitle:(NSString *)title andDetail:(NSString *)detail image:(NSString *)imageName;

@end

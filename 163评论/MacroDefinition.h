//
//  MacroDefinition.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#ifndef _63___MacroDefinition_h
#define _63___MacroDefinition_h

//-----------------------屏幕宽高-------------------------------
#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEITHT    [UIScreen mainScreen].bounds.size.height

//-----------------------系统版本-------------------------------
#define SYSTERM_VERSION  [[[UIDevice currentDevice] systemVersion] floatValue]

//-----------------------设备名称-------------------------------
#define DEVICE_NAME      [[UIDevice currentDevice] model]

//-----------------------设备UUID-------------------------------
#define DEVICE_UUID       [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//-----------------------颜色-------------------------------
#define RGBCOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#endif

//-----------------------日志打印-------------------------------
#ifdef DEBUG
#define DNSLog(...)     NSLog(__VA_ARGS__)
#else
#define DNSLog(...)
#endif


//-----------------------程序内-------------------------------
#define HOST_NAME     @"www.163pinglun.com"

#define kWeiboAppKey  @"1728477038"
#define kRedirectURI  @"https://api.weibo.com/oauth2/default.html"

#define kTencentAppKey     @"j0Fj8pHh7PkS7Sws"
#define kTencentAppID      @"1101994241"

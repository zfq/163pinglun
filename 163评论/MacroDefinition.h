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
#define SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height

//-----------------------系统版本-------------------------------
#define SYSTERM_VERSION  [[[UIDevice currentDevice] systemVersion] floatValue]

//-----------------------设备名称-------------------------------
#define DEVICE_NAME      [[UIDevice currentDevice] model]

//-----------------------设备UUID-------------------------------
#define DEVICE_UUID       [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//-----------------------颜色-------------------------------
#define RGBCOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//-----------------------导航栏 状态栏高度-------------------------------
#define NAV_HEIGHT(VC)    (VC).navigationController.navigationBar.bounds.size.height
#define STATUSBAR_HEIGHT  [UIApplication sharedApplication].statusBarFrame.size.height

//-----------------release----
#define zfq_CFRelease(cfRef) if (cfRef != NULL) {CFRelease(cfRef);}

//-----------------------程序内-------------------------------
#define HOST_NAME     @"www.apple.com"

#define kWeiboAppKey  @"1728477038"
#define kRedirectURI  @"https://api.weibo.com/oauth2/default.html"

#define kTencentAppKey     @"j0Fj8pHh7PkS7Sws"
#define kTencentAppID      @"1101994241"

#define CURR_HOME_PAGE @"currHomePage"
#define CURR_TAG_PAGE @"currTagPage"

#define TITLE_COLOR RGBCOLOR(0, 160, 233, 1)    //导航栏title颜色
#define LABEL_COLOR RGBCOLOR(51,153,255,1.0f) // 3399FF
#define SEPARATOR_COLOR RGBCOLOR(51,153,255,1.0f)  //(223,223,223,0.5f)

#define DEFAULT_CONTENT_FONT_SIZE 15
#define DEFAULT_SUBTITLE_FONT_SIZE 11

#define kDefContentFontSize @"defaultContentFontSize"
#define kDefSubtitleFontSize @"defaultSubtitleFontSize"
#define kCurrContentFontSize @"currContentFontSize"
#define kCurrSubtitleFontSize @"currSubtitleFontSize"
#define kFontSizeStyle @"fontSizeStyle"
#define kFontIndexStyle @"fontIndexStyle"
#define FontSizeChangeNotification @"fontSizeChangeNotification"


#define LOGO @"163评论"
#define HOSTURL @"www.163pinglun.com"
#endif

//-----------------------日志打印-------------------------------
#ifdef DEBUG
#define DNSLog(...)     NSLog(__VA_ARGS__)
#else
#define DNSLog(...)
#endif

#define DEBUG_163 1
#ifdef DEBUG_163
#define debug_163(xx,...) NSLog(xx,##__VA_ARGS__)
#else
#define debug_163(xx,...) ((void)0)
#endif

//---------------测试---------
//#define TEST_163_LOSS 0



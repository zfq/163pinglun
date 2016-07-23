//
//  UIDeviceHardware.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GeneralService : NSObject

+ (NSString *)platform;
+ (NSString *)platformString;

+ (void)setNetworkReachability:(BOOL)isReachable;
+ (BOOL)isReachable;

+ (CGFloat)userFontSizeWithIndex:(NSInteger)index;
+ (CGFloat)contentFontSizeWithIndex:(NSInteger)index;
+ (NSDictionary *)fontSizeDic;
+ (CGFloat)currContentFontSize;
+ (void)saveCurrSubtitleFontSize:(CGFloat)fontSize;
+ (CGFloat)currSubtitleFontSize;
+ (void)saveCurrContentFontSize:(CGFloat)fontSize;
+ (CGFloat)defaultContentFontSize;
+ (CGFloat)defaultSubtitleFontSize;
+ (NSInteger)fontIndex;
+ (NSString *)fontSizeName;
//+ (BOOL)fontSizeIsChanged;
@end

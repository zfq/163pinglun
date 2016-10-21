//
//  UIFont+Custom.h
//  GuangShengXing
//
//  自定义字体
//
//  Created by 163pinglun on 15/7/29.
//  Copyright (c) 2015年 163pinglun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Custom)

//---中文字体 SourceHanSanCN
+ (UIFont *)customYouYuanFontWithSize:(CGFloat)size;
+ (UIFont *)customCNLightFontWithSize:(CGFloat)size;
+ (UIFont *)customCNNormalFontWithSize:(CGFloat)size;

//---英文字体 Lato
+ (UIFont *)customENLightFontWithSize:(CGFloat)size;
+ (UIFont *)customENRegularFontWithSize:(CGFloat)size;

@end

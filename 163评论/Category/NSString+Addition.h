//
//  NSString+Addition.h
//  163pinglun
//
//  Created by _ on 16/1/22.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Addition)

+ (NSString *)SubStrFromStr:(NSString *)str pattern:(NSString *)pattern;
+ (CGSize)TextSizeWithAttrStr:(NSAttributedString *)attrStr preferWidth:(CGFloat)preferWidth;
+ (CGSize)SinglLineTextSizeWithAttrStr:(NSAttributedString **)attrStr preferWidth:(CGFloat)preferWidth;

//截取字符串
- (NSString *)weiboTextWithUrl:(NSString *)url;

///判断字符串是否是数字字符串
- (BOOL)isNumStr;

@end

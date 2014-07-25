//
//  NSString+Html.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-16.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Html)

+ (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim;
+ (NSString *)replaceBr:(NSString *)brStr;
+ (NSString *)flattenHTMLSpace:(NSString *)html;
+ (NSString *)getExcerptFromString:(NSMutableString *)string;

@end

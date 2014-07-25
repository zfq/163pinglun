//
//  NSString+Html.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-16.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "NSString+Html.h"

@implementation NSString (Html)
// ida 该方法用于去除NSString中的html标签
/**
 * @brief  去掉字符串NSString中的html标签 “<>”
 *
 * @param html 要修改的nsstring
 * @param trim 是否要将nsstring 中开始的空白用@“”替换,yes会替换，no不会替换
 *
 * @return  nsstring 去掉html标签后的nsstring
 */
+ (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim
{
	NSScanner *theScanner = [NSScanner scannerWithString:html];
	NSString *text = nil;
    
	while ([theScanner isAtEnd] == NO) {
		// find start of tag
		[theScanner scanUpToString:@"<" intoString:NULL];
		// find end of tag
		[theScanner scanUpToString:@">" intoString:&text];
		// replace the found tag with a space
		//(you can filter multi-spaces out later if you wish)
		html = [html stringByReplacingOccurrencesOfString:
		        [NSString stringWithFormat:@"%@>", text]
		                                       withString:@""];
	}
    
	return trim ? [html stringByTrimmingCharactersInSet:
	               [NSCharacterSet whitespaceAndNewlineCharacterSet]]
    : html;
}

+ (NSString *)replaceBr:(NSString *)brStr
{
    NSString *str = [brStr stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
	return [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
}

+ (NSString *)flattenHTMLSpace:(NSString *)html
{
    NSString *str = [[self class] flattenHTML:html trimWhiteSpace:NO];
    return [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
}

+ (NSString *)getExcerptFromString:(NSMutableString *)string
{
    if ([string isEqualToString:@""]) {
        return @"";
    } else {
        [string deleteCharactersInRange:NSMakeRange(0, 3)];
        [string deleteCharactersInRange:NSMakeRange(string.length-5, 4)];
        return [self replaceBr:string];
    }
}

@end

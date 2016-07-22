//
//  NSString+Addition.m
//  163pinglun
//
//  Created by _ on 16/1/22.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "NSString+Addition.h"
#import <CoreText/CoreText.h>
#import "MacroDefinition.h"

@implementation NSString (Addition)

+ (NSString *)SubStrFromStr:(NSString *)str pattern:(NSString *)pattern
{
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error != nil) {
        return nil;
    } else {
        NSArray *match = [reg matchesInString:str options:NSMatchingReportCompletion range:NSMakeRange(0, [str length])];
        if (match.count > 0) {
            NSTextCheckingResult *result = match.firstObject;
            NSRange range = [result range];
            NSString *subStr = [str substringToIndex:range.location];
            return subStr;
        } else {
            return str;
        }
    }
}

+ (CGSize)TextSizeWithAttrStr:(NSAttributedString *)attrStr preferWidth:(CGFloat)preferWidth
{
    //1.创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    
    //2.获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(preferWidth, HUGE_VALF);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    
    //3.释放
    CFRelease(framesetter);
    return coreTextSize;
}

+ (CGSize)SinglLineTextSizeWithAttrStr:(NSAttributedString **)attrStr preferWidth:(CGFloat)preferWidth
{
    CGSize constraintSize = CGSizeMake(preferWidth, CGFLOAT_MAX);
    
    //1.创建path
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = CGRectMake(0, 0, preferWidth, CGFLOAT_MAX);
    CGPathAddRect(path, NULL, rect);
    //2.根据NSAttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)(*attrStr));
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    if (textFrame == nil) {
        zfq_CFRelease(framesetter);
        zfq_CFRelease(path);
        zfq_CFRelease(textFrame);
        return CGSizeZero;
    }
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        zfq_CFRelease(path);
        zfq_CFRelease(framesetter);
        zfq_CFRelease(textFrame);
        return CGSizeZero;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    if (count == 0) {
        zfq_CFRelease(path);
        zfq_CFRelease(framesetter);
        zfq_CFRelease(textFrame);
        return CGSizeZero;
    }
    
    CTLineRef line = CFArrayGetValueAtIndex(lines, 0);
    CFRange range = CTLineGetStringRange(line);
    if ((range.location + range.length < (*attrStr).length)) {
        //字符串太长，需要设置...
        NSUInteger truncationLocation = range.location + range.length - 1;
        CFDictionaryRef dict = (__bridge CFDictionaryRef)([(*attrStr) attributesAtIndex:truncationLocation effectiveRange:NULL]);
        CFAttributedStringRef tokenString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), dict);
        
        NSMutableAttributedString *truncationString = [[(*attrStr) attributedSubstringFromRange:NSMakeRange(range.location, range.length-1)] mutableCopy];
        [truncationString appendAttributedString:(__bridge NSAttributedString * _Nonnull)(tokenString)];
        
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
        CTLineRef truncatedLine = CTLineCreateTruncatedLine(line, preferWidth, kCTLineTruncationEnd, truncationToken);
        if (!truncatedLine) {
            line = truncationToken;
        } else {
            *attrStr = truncationString;
            line = truncatedLine;
            CFRelease(truncatedLine);
        }
        
        zfq_CFRelease(tokenString);
        zfq_CFRelease(truncationToken);
    }
    
    zfq_CFRelease(framesetter);
    zfq_CFRelease(textFrame);
    
    CTFramesetterRef framesetter2 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)(*attrStr));
    CTFrameRef textFrame2 = CTFramesetterCreateFrame(framesetter2, CFRangeMake(0, 0), path, NULL);
    
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter2, CFRangeMake(0, 0), NULL, constraintSize, NULL);

    zfq_CFRelease(framesetter2);
    zfq_CFRelease(textFrame2);
    zfq_CFRelease(path);
    
    return coreTextSize;
}

- (NSString *)weiboTextWithUrl:(NSString *)url
{
    NSUInteger urlLength = url.length + 1;  //留个空格
    NSInteger maxLength = 140;
    if (self.length + urlLength > maxLength) {
        //
        NSUInteger realLength = maxLength - urlLength;
        NSString *subStr = [self substringToIndex:realLength];
        NSString *weiboStr = [NSString stringWithFormat:@"%@ %@",subStr,url];
        return weiboStr;
    } else {
        return [NSString stringWithFormat:@"%@ %@",self,url];
    }
}

- (BOOL)isNumStr
{
    static NSPredicate *predicate = nil;
    if (!predicate) {
        NSString *pattern = @"^\\d+?$";
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    }
    return [predicate evaluateWithObject:self];
}
@end

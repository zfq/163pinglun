//
//  FQCoreTextUtils.m
//  MyCoreTextDemo
//
//  Created by 163pinglun on 15/9/1.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import "FQCoreTextUtils.h"
#import "FQCoreTextData.h"
#import <CoreText/CoreText.h>

@implementation FQCoreTextUtils

+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(FQCoreTextData *)data
{
    CTFrameRef textFrame = data.ctFrame;
    //1.获取行数
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    //2.获取每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    //3.翻转坐标
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.frame.size.height);
    transform = CGAffineTransformScale(transform, 1, -1);
    
    CFIndex idx = -1;
    for (int i=0; i < count; i++) {
        CGPoint lineOrigin = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //获取每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line lineOriginPoint:lineOrigin]; //翻转后的rect
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
            //获取点击点对应的字符串的偏移量
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
            //为啥不break?
            break;
        }
    }
    return idx;
}

+ (CGRect)getLineBounds:(CTLineRef)line lineOriginPoint:(CGPoint)point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y  - descent, width, height);  //注意坐标原点的计算 暂时不明白咋回事?????
}
@end

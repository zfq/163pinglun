//
//  ZFQTumbLayer.m
//  字体大小控件
//
//  Created by _ on 16/7/26.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQTumbLayer.h"
#import <UIKit/UIKit.h>

@implementation ZFQTumbLayer

- (void)drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    
    CGRect thumbFrame = CGRectInset(self.bounds, 2, 2);
    CGFloat radius = thumbFrame.size.height/2;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:thumbFrame cornerRadius:radius];
    
    UIColor *shadowColor = [UIColor grayColor];
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2), 2, shadowColor.CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddPath(ctx, path.CGPath);
    CGContextFillPath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, shadowColor.CGColor);
    CGFloat lineWidth = 1/([UIScreen mainScreen].scale);
    CGContextSetLineWidth(ctx, lineWidth);

    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);
    
    if (_hightlighted) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.1].CGColor);
        CGContextAddPath(ctx, path.CGPath);
        CGContextFillPath(ctx);
    }
    
    UIGraphicsPopContext();
}

- (void)setHightlighted:(BOOL)hightlighted
{
    _hightlighted = hightlighted;
    [self setNeedsDisplay];
    [self displayIfNeeded];
}
@end

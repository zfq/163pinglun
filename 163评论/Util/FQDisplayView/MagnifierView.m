//
//  MagnifierView.m
//  MyCoreTextDemo
//
//  Created by 163pinglun on 15/9/14.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import "MagnifierView.h"

@implementation MagnifierView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 80, 80)];
    if (self) {
        //设置圆形边框
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 40;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setTouchPoint:(CGPoint)touchPoint
{
    _touchPoint = touchPoint;
    self.center = CGPointMake(touchPoint.x, touchPoint.y - self.bounds.size.height + 10);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //绘制放大镜效果
    CGContextRef context = UIGraphicsGetCurrentContext();
    //1.重新设置原点
    CGContextTranslateCTM(context, rect.size.width * 0.5, rect.size.height * 0.5);
    //2.放大1.5倍
    CGContextScaleCTM(context, 1.5, 1.5);
    //3.再次设置原点
    CGContextTranslateCTM(context, -1 * _touchPoint.x, -1 * _touchPoint.y);
    //4.绘制
    [self.viewToMagnify.layer renderInContext:context];
}
@end

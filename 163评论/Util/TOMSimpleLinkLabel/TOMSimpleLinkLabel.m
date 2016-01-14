//
//  TOMSimpleLinkLabel.m
//  GuangShengXing
//
//  带链接功能的label
//
//  Created by wecash on 15/8/7.
//  Copyright (c) 2015年 wecash. All rights reserved.
//

#import "TOMSimpleLinkLabel.h"

typedef NS_ENUM(NSInteger, TOMLinkLabelState) {
    TOMLinkLabelStateNormal = 0,
    TOMLinkLabelStateHighlight,
    TOMLinkLabelStateEnd
};

@interface TOMSimpleLinkLabel() <UIGestureRecognizerDelegate>
{
    TOMLinkLabelState t_currLinkLabelState;
    UILongPressGestureRecognizer *t_longGesture;
}

@end

@implementation TOMSimpleLinkLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        t_currLinkLabelState = TOMLinkLabelStateNormal;
        _t_cornerRadius = 4;
        
        t_longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
        t_longGesture.delegate = self;
        t_longGesture.minimumPressDuration = 0.2;
        [self addGestureRecognizer:t_longGesture];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *tempBcgColor = nil;
    if (t_currLinkLabelState != TOMLinkLabelStateHighlight) {
        tempBcgColor = self.backgroundColor;
    } else {
        tempBcgColor = [UIColor colorWithRed:_tom_red green:_tom_green blue:_tom_blue alpha:_tom_alpha];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //绘制背景色
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_t_cornerRadius];
    CGContextAddPath(context, path.CGPath);
    
    [tempBcgColor setFill];
    CGContextFillPath(context);
    
    [super drawRect:rect];
}
/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isContain = CGRectContainsPoint(self.bounds, point);
    if (isContain) {
        return self;
    }

    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //设置背景色
    UITouch *touch = [touches anyObject];
    NSLog(@"%f",touch.timestamp);
    t_currLinkLabelState = TOMLinkLabelStateHighlight;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    t_currLinkLabelState = TOMLinkLabelStateNormal;
    
    [self setNeedsDisplay];
    
    //如果此时的点击点落在label内,则执行delegate方法
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    BOOL isInRect = CGRectContainsPoint(self.bounds, p);
    if (isInRect) {
        if ([self.simpleLinkDelegate respondsToSelector:@selector(didTappedLink:text:)]) {
            [self.simpleLinkDelegate didTappedLink:self.attributedText text:self.text];
        }
    }

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    t_currLinkLabelState = TOMLinkLabelStateNormal;
    [self setNeedsDisplay];
}
*/
- (void)gestureAction:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            t_currLinkLabelState = TOMLinkLabelStateHighlight;
            [self setNeedsDisplay];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            t_currLinkLabelState = TOMLinkLabelStateNormal;
            [self setNeedsDisplay];
            
            if ([self.simpleLinkDelegate respondsToSelector:@selector(didTappedLink:text:)]) {
                [self.simpleLinkDelegate didTappedLink:self.attributedText text:self.text];
            }
            break;
        }
        default:
            break;
    }
}

- (void)dealloc
{
    [self removeGestureRecognizer:t_longGesture];
}
@end

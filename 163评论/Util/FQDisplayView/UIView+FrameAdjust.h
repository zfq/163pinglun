//
//  UIView+FrameAdjust.h
//  MyCoreTextDemo
//
//  Created by wecash on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameAdjust)

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGPoint)origin;
- (void)setOrigin:(CGPoint)origin;

- (void)setCenterX:(CGFloat)centerX;

@end

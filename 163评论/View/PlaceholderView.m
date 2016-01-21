//
//  PlaceholderView.m
//  163评论
//
//  Created by zhaofuqiang on 14-11-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "PlaceholderView.h"
#import "MacroDefinition.h"

@implementation PlaceholderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame content:(NSString *)contentStr fontSize:(CGFloat)fontSize
{
    self = [self initWithFrame:frame];
    
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.text = contentStr;
    _placeholderLabel.font = [UIFont systemFontOfSize:fontSize];
    _placeholderLabel.textColor = RGBCOLOR(153, 153, 153, 1);
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_placeholderLabel];   //别忘添加logo图片
    
    //为_placeholderLabel添加布局约束
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *consCenterX = [NSLayoutConstraint constraintWithItem:_placeholderLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *consCenterY = [NSLayoutConstraint constraintWithItem:_placeholderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self addConstraints:@[consCenterX,consCenterY]];

    return self;
}

@end

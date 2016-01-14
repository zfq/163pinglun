//
//  ShareItem.m
//  ReuseScroll
//
//  Created by zhaofuqiang on 14-11-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "ShareItem.h"

@interface ShareItem()
{
    UIImageView *_myImgView;
    UILabel *titleLabel;
}
@end
@implementation ShareItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)img
{
    self = [self initWithFrame:frame];
    _img = img;
    _title = title;
    
    _myImgView = [[UIImageView alloc] init];
    _myImgView.image = img;
    [self addSubview:_myImgView];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    [self addTarget:self action:@selector(zoomInItem) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(zoomOutItem) forControlEvents:UIControlEventTouchUpInside];
    
    //添加约束
    NSDictionary *nameMap = @{@"img":_myImgView,@"title":titleLabel};
    _myImgView.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *imgW = [NSLayoutConstraint constraintWithItem:_myImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:img.size.width];
    [_myImgView addConstraint:imgW];
    NSLayoutConstraint *imgCenterX = [NSLayoutConstraint constraintWithItem:_myImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:imgCenterX];
    
    NSLayoutConstraint *titleW = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.frame.size.width];
    [titleLabel addConstraint:titleW];
    NSLayoutConstraint *titleCenterX = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:titleCenterX];
    
    NSString *vfV = [NSString stringWithFormat:@"V:|-2-[img(%f)]-(>=0)-[title(26)]-0-|",img.size.height];
    NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:vfV options:0 metrics:nil views:nameMap];
    [self addConstraints:consV];
    
    return self;
}

- (void)zoomInItem
{
    [self.layer addAnimation:[self zoomInAnimation]  forKey:@"zoomIn"];
}

- (void)zoomOutItem
{
    [self.layer addAnimation:[self zoomOutAnimation]  forKey:@"zoomOut"];
}

- (CAKeyframeAnimation *)zoomInAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.values =@[@(1.0),@(1.3),@(1.0)];;
    animation.keyTimes = @[@(0.0),@(0.4),@(1.0)];

    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.calculationMode = kCAAnimationLinear;
    
    return animation;
}

- (CAKeyframeAnimation *)zoomOutAnimation
{
    [self.layer removeAnimationForKey:@"large"];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.values =@[@(1.0),@(0.7),@(1.0)];;
    animation.keyTimes = @[@(0.0),@(0.4),@(1.0)];
    animation.calculationMode = kCAAnimationLinear;
    
    return animation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([_shareItemDelegate respondsToSelector:@selector(tapShareItem:)]) {
        [_shareItemDelegate tapShareItem:self];
    }
   
}
@end

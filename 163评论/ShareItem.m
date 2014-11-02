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
    UIImageView *imgView;
    UILabel *titleLabel;
}
@end
@implementation ShareItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imgView];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:titleLabel];
        
        [self addTarget:self action:@selector(zoomInItem) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(zoomOutItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize itemSize = self.frame.size;
    imgView.image = self.img;
    imgView.bounds = CGRectMake(0, 0, self.img.size.width, self.img.size.height);
    imgView.center = CGPointMake(itemSize.width/2.0, imgView.frame.size.height/2.0+2);
    CGFloat labelHeight = 26;
    titleLabel.frame = CGRectMake(0, CGRectGetMaxY(imgView.frame), itemSize.width, labelHeight);
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = self.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
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
    
    animation.values =@[@(1.0),@(1.3),@(1.1)];;
    animation.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];

    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.calculationMode = kCAAnimationLinear;
    
    return animation;
}

- (CAKeyframeAnimation *)zoomOutAnimation
{
    [self.layer removeAnimationForKey:@"large"];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.values =@[@(1.0),@(0.7),@(1.0)];;
    animation.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
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

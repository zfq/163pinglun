//
//  ShareView.m
//  ReuseScroll
//
//  Created by zhaofuqiang on 14-11-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "ShareView.h"
#import "ShareItem.h"
#import "SocialSharing.h"

@interface ShareView() <ShareItemDeleage>
{
    UIView *subView;
}
@end
@implementation ShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showShareView
{
    CGSize viewSize = self.bounds.size;
    CGFloat height = 260;
    if (subView == nil) {
        subView = [[UIView alloc] init];
        subView.backgroundColor = [UIColor colorWithRed:0.964 green:0.964 blue:0.964 alpha:1];
        [self addSubview:subView];
        [subView addSubview:self.weiboItem];
        [subView addSubview:self.qqItem];
        
        //为subView添加约束
        NSDictionary *nameMap = @{@"subView":subView};
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *subViewConsW = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
         NSLayoutConstraint *subViewConsCenterX = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self addConstraints:@[subViewConsW,subViewConsCenterX]];
        NSArray *subViewConsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[subView(260)]-0-|" options:0 metrics:nil views:nameMap];
        [self addConstraints:subViewConsV];
        
        //为separatorView添加约束
        UIView *separatorView = [[UIView alloc] init];
        separatorView.backgroundColor = [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:1];
        [subView addSubview:separatorView];
        separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *sepaConsW = [NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *sepaConsCenterX = [NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [subView addConstraints:@[sepaConsW,sepaConsCenterX]];
        
        //为cancelBtn添加约束
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[UIColor colorWithRed:0.964 green:0.964 blue:0.964 alpha:1]];
        [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:button];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *btnConsW = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *btnConsCenterX = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [subView addConstraints:@[btnConsW,btnConsCenterX]];
        //添加纵向约束
        NSDictionary *nameMapV = @{@"separa":separatorView,@"btn":button};
        NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[separa(6)]-0-[btn(36)]-14-|" options:0 metrics:nil views:nameMapV];
        [subView addConstraints:consV];

    }
    
    subView.transform = CGAffineTransformMakeTranslation(0, -subView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        subView.frame = CGRectMake(0, viewSize.height - height, viewSize.width, height);
        subView.alpha = 1;
    }];
}

- (void)dismiss
{
    [self dismissShareView];
}

- (void)dismissShareView
{
    CGSize viewSize = self.bounds.size;
    CGFloat height = 300;

    [UIView animateWithDuration:0.3 animations:^{
        subView.frame = CGRectMake(0, viewSize.height, viewSize.width, height);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (ShareItem *)weiboItem
{
    if (_weiboItem == nil) {
        _weiboItem = [[ShareItem alloc] initWithFrame:CGRectMake(20, 20, 60, 60) title:@"新浪微博" image:[UIImage imageNamed:@"weibo"]];
        _weiboItem.shareItemDelegate = self;
    }
    return _weiboItem;
}

- (ShareItem *)qqItem
{
    if (_qqItem == nil) {
        _qqItem = [[ShareItem alloc] initWithFrame:CGRectMake(100, 20, 60, 60) title:@"QQ空间" image:[UIImage imageNamed:@"zone"]];
        _qqItem.shareItemDelegate = self;
    }
    return _qqItem;
}

#pragma mark - shareItem delegate
- (void)tapShareItem:(ShareItem *)shareItem
{
    [SocialSharing sharedInstance].shareTypeName = shareItem.title;
    
    if ([_shareViewDelegate respondsToSelector:@selector(didTapedShareItem:)]) {
        [_shareViewDelegate didTapedShareItem:shareItem];
    }
}

@end

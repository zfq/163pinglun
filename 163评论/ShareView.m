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
        subView = [[UIView alloc] initWithFrame:CGRectMake(0, viewSize.height, viewSize.width, height)];
        subView.backgroundColor = [UIColor colorWithRed:0.964 green:0.964 blue:0.964 alpha:1];
        [self addSubview:subView];
        
        [subView addSubview:self.weiboItem];
        [subView addSubview:self.qqItem];
        
        CGSize subViewSize = subView.frame.size;
        CGFloat cancelBtnHeight = 36;
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,subViewSize.height-cancelBtnHeight-30, viewSize.width, 10)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:1];
        [subView addSubview:separatorView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake(0, 0, subViewSize.width, cancelBtnHeight);
        button.center = CGPointMake(subViewSize.width/2, subViewSize.height-button.bounds.size.height/2 - 10);
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[UIColor colorWithRed:0.964 green:0.964 blue:0.964 alpha:1]];
        [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:button];
    }
    
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
        _weiboItem = [[ShareItem alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        _weiboItem.title = @"新浪微博";
        _weiboItem.img = [UIImage imageNamed:@"weibo"];
        _weiboItem.shareItemDelegate = self;
    }
    return _weiboItem;
}

- (ShareItem *)qqItem
{
    if (_qqItem == nil) {
        _qqItem = [[ShareItem alloc] initWithFrame:CGRectMake(100, 20, 60, 60)];
        _qqItem.title = @"QQ空间";
        _qqItem.img = [UIImage imageNamed:@"zone"];
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

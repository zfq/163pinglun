//
//  UIScrollView+ZFQLoadView.m
//  仿知乎加载
//
//  Created by _ on 16/8/17.
//  Copyright © 2016年 NXB. All rights reserved.
//

#import "UIScrollView+ZFQLoadView.h"
#import <objc/runtime.h>

static const char *zfqHeaderViewKey = "zfqHearderView";
static const char *zfqFooterViewKey = "zfqFooterView";

@implementation UIScrollView (ZFQLoadView)

#pragma mark - Getter Setter
- (void)setZfqHeaderView:(ZFQLoadHeaderView *)zfqHeaderView
{
    objc_setAssociatedObject(self, zfqHeaderViewKey, zfqHeaderView, OBJC_ASSOCIATION_RETAIN);
}

- (ZFQLoadHeaderView *)zfqHeaderView
{
    return objc_getAssociatedObject(self, zfqHeaderViewKey);
}

- (void)setZfqFooterView:(ZFQLoadFooterView *)zfqFooterView
{
    objc_setAssociatedObject(self, zfqFooterViewKey, zfqFooterView, OBJC_ASSOCIATION_RETAIN);
}

- (ZFQLoadFooterView *)zfqFooterView
{
    return objc_getAssociatedObject(self, zfqFooterViewKey);
}

#pragma mark - Public
- (void)addLoadHeaderWithRefreshingBlk:(void (^)())blk
{
    if (self.zfqHeaderView == nil) {
        ZFQLoadHeaderView *hearderView = [[ZFQLoadHeaderView alloc] init];
        hearderView.backgroundColor = [UIColor clearColor];
        [self addSubview:hearderView];
        
        //添加约束
        hearderView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{@"v":hearderView};
        NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v(>=0)]-0-|" options:0 metrics:nil views:views];
        NSLayoutConstraint *widthC = [NSLayoutConstraint constraintWithItem:hearderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *heightC = [NSLayoutConstraint constraintWithItem:hearderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:zfqLoadViewHeight];
        NSLayoutConstraint *bottomC = [NSLayoutConstraint constraintWithItem:hearderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:-zfqLoadViewHeight];
        
        [self addConstraints:hCons];
        [self addConstraints:@[widthC,heightC,bottomC]];
        
        hearderView.beginRefreshBlk = blk;
        self.zfqHeaderView = hearderView;
    }
}

- (void)addLoadFooterWithRefreshingBlk:(void (^)())blk
{
    if (self.zfqFooterView == nil) {
        ZFQLoadFooterView *footerView = [[ZFQLoadFooterView alloc] init];
        footerView.backgroundColor = [UIColor clearColor];
        [self addSubview:footerView];
        
        //添加约束
        footerView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{@"v":footerView};
        NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v(>=0)]-0-|" options:0 metrics:nil views:views];
        NSLayoutConstraint *widthC = [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *heightC = [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:zfqLoadViewHeight];
        NSLayoutConstraint *topC = [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:zfqLoadViewHeight];
        footerView.topC = topC;
        [self addConstraints:hCons];
        [self addConstraints:@[widthC,heightC,topC]];
        
        footerView.beginRefreshBlk = blk;
        self.zfqFooterView = footerView;
    }
}
@end

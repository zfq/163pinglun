//
//  UIScrollView+ZFQLoadView.h
//  仿知乎加载
//
//  Created by _ on 16/8/17.
//  Copyright © 2016年 NXB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFQLoadFrontOrNextView.h"

@interface UIScrollView (ZFQLoadView)

@property (nonatomic,strong) ZFQLoadHeaderView *zfqHeaderView;
@property (nonatomic,strong) ZFQLoadFooterView *zfqFooterView;

- (void)addLoadHeaderWithRefreshingBlk:(void (^)())blk;

- (void)addLoadFooterWithRefreshingBlk:(void (^)())blk;

@end

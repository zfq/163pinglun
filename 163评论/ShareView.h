//
//  ShareView.h
//  ReuseScroll
//
//  Created by zhaofuqiang on 14-11-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShareItem;
@protocol ShareViewDeleage;

@interface ShareView : UIControl

@property (nonatomic,strong) ShareItem *weiboItem;
@property (nonatomic,strong) ShareItem *qqItem;
@property (nonatomic,weak) id<ShareViewDeleage> shareViewDelegate;

- (void)showShareView;
- (void)dismissShareView;

@end

@protocol ShareViewDeleage <NSObject>
@optional
- (void)didTapedShareItem:(ShareItem *)shareItem;
@end

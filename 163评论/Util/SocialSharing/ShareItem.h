//
//  ShareItem.h
//  ReuseScroll
//
//  Created by zhaofuqiang on 14-11-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareItemDeleage;

@interface ShareItem : UIControl

@property (nonatomic,strong,readonly) UIImage *img;
@property (nonatomic,strong,readonly) NSString *title;

@property (nonatomic,weak) id<ShareItemDeleage> shareItemDelegate;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)img;
@end

@protocol ShareItemDeleage <NSObject>
@optional
- (void)tapShareItem:(ShareItem *)shareItem;
@end

//
//  MenuViewController.h
//  163评论
//
//  Created by zhaofuqiang on 14-9-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MenuViewDelegate;

@interface MenuView : UIView

@property (nonatomic,weak) id<MenuViewDelegate> menuViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems;

- (void)showMenuView;
- (void)dismissMenuView;
@end

@protocol MenuViewDelegate <NSObject>

@optional
- (void)menuViewDidDisappear;
@end
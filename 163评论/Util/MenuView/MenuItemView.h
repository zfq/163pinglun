//
//  MenuItemView.h
//  163评论
//
//  Created by zhaofuqiang on 14-9-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MenuView,MenuItem;

@interface MenuItemView : UIView

@property (nonatomic,weak) MenuView *menuView;
@property (nonatomic,strong) MenuItem *menuItem;
@property (nonatomic,strong,readonly) UIButton *button;

- (instancetype)initWithMenuItem:(MenuItem *)menuItem;
@end

//
//  MenuItemView.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MenuItemView.h"
#import "MenuView.h"
#import "MenuItem.h"
#import "UIButton+menuItem.h"

@implementation MenuItemView

- (instancetype)initWithMenuItem:(MenuItem *)menuItem
{
    self = [super initWithFrame:menuItem.frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _menuItem = menuItem;
        
        CGRect btnFrame = CGRectMake(0, 0, menuItem.frame.size.width, menuItem.frame.size.height);
        _button = [UIButton buttomWithTitle:menuItem.title titleEdgeInsets:menuItem.titleEdageInsets imageName:menuItem.imageName imageEdgeInset:menuItem.imageEdageInsets frame:btnFrame];
        [_button addTarget:self action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_button];
    }
    return self;
}

- (void)performAction
{
    [_menuView dismissMenuViewWithAnimation:NO];
    if (_menuItem.target && _menuItem.action) {
        [_menuItem.target performSelector:_menuItem.action withObject:nil afterDelay:0];
    }
}

- (void)setMenuItem:(MenuItem *)menuItem
{
    _menuItem = menuItem;
    _button = [UIButton buttomWithTitle:menuItem.title titleEdgeInsets:menuItem.titleEdageInsets imageName:menuItem.imageName imageEdgeInset:menuItem.imageEdageInsets frame:CGRectMake(0, 0, menuItem.frame.size.width, menuItem.frame.size.height)];
    [_button addTarget:self action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
}
@end

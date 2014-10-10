//
//  MenuViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MenuView.h"
#import "MenuItemView.h"

@interface MenuView()
{
    
}
@end
@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEITHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems
{
    self = [self initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEITHT)];
    if (self) {
        //显示menuView
        UIView *menuView = [[UIView alloc] init];
        menuView.frame = frame;//
        menuView.backgroundColor = RGBCOLOR(239, 239, 239, 1.0); //
        menuView.layer.shadowColor = RGBCOLOR(109, 109, 109, 0.4).CGColor;
        menuView.layer.shadowOpacity = 1.0;
        menuView.layer.shadowOffset = CGSizeMake(1,1);
        menuView.layer.shadowRadius = 1.0;
        
        NSInteger count = menuItems.count;
        __block CGFloat y = 0;
        if (count == 1) {
            MenuItem *item = [menuItems firstObject];
            MenuItemView *itemView = [[MenuItemView alloc] initWithMenuItem:item];
            itemView.menuView = self;
            [menuView addSubview:itemView];
            y = itemView.button.frame.size.height;
        } else if (count >= 2){
            [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MenuItem *item = (MenuItem *)obj;
                MenuItemView *itemView = [[MenuItemView alloc] initWithMenuItem:item];
                itemView.menuView = self;
                itemView.frame = CGRectMake(0, y, itemView.frame.size.width, itemView.frame.size.height);
                [menuView addSubview:itemView];
                y += itemView.frame.size.height;
                if (idx < (count-1)) {      //确保在最后一个不加
                    //添加分割线
                    CALayer *seperatorLine = [CALayer layer];
                    seperatorLine.frame = CGRectMake(0, y, menuView.frame.size.width, 1);
                    seperatorLine.backgroundColor = RGBCOLOR(109, 109, 109, 0.1).CGColor;
                    [menuView.layer addSublayer:seperatorLine];
                    y += 1;
                }
            }];
        }
        //确保menuView的高度是自动增加的
        CGRect rect = menuView.frame;
        rect.size.height = y;
        menuView.frame = rect;
        [self addSubview:menuView];
    }
    return self;
}

#pragma mark - 显示菜单
- (void)showMenuView
{
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    [topWindow.rootViewController.view addSubview:self];
}

- (void)dismissMenuView
{
    [self removeFromSuperview];
    [_menuViewDelegate menuViewDidDisappear];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
    [_menuViewDelegate menuViewDidDisappear];
}

@end

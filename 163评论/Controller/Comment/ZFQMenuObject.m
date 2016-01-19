//
//  ZFQMenuObject.m
//  163评论
//
//  Created by _ on 16/1/18.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQMenuObject.h"
#import "MacroDefinition.h"

@interface ZFQMenuObject()

@property (nonatomic,strong) NSMutableArray *menuItems;

@end

@implementation ZFQMenuObject

- (void)showMenu
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:_contentFrame inView:_hostView];
    
    if (!_menuItems) {
        _menuItems = [[NSMutableArray alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        //创建menuItem
        UIMenuItem *snapshootItem = [[UIMenuItem alloc] initWithTitle:@"保存快照" action:@selector(snapshootContent)];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(copyContent)];
        UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareContent)];
        [_menuItems addObject:copyItem];
        [_menuItems addObject:shareItem];
        [_menuItems addObject:snapshootItem];
        [menuController setMenuItems:_menuItems];
#pragma clang diagnostic pop
    }
    
    [menuController setMenuVisible:YES animated:YES];
}

- (void)dealloc
{
    DNSLog(@"释放ZFQMenuObject");
}
@end

//
//  ZFQMenuObject.h
//  163评论
//
//  Created by _ on 16/1/18.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFQMenuObject : NSObject

@property (nonatomic,copy) NSString *content;
@property (nonatomic) CGRect contentFrame;
@property (nonatomic,weak) UIView *hostView;

- (void)showMenu;

@end

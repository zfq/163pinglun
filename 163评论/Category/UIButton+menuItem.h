//
//  UIButton+menuItem.h
//  163评论
//
//  Created by zhaofuqiang on 14-9-22.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (menuItem)

+ (instancetype )buttonWithTitle:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
                       imageName:(NSString *)imageName imageEdgeInset:(UIEdgeInsets)imageEdgeInsets
                           frame:(CGRect)frame ;

+ (UIButton *)backTypeBtnWithTintColor:(UIColor *)tintColor;

@end

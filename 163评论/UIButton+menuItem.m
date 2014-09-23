//
//  UIButton+menuItem.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-22.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "UIButton+menuItem.h"

@implementation UIButton (menuItem)

+ (instancetype )buttomWithTitle:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
                    imageName:(NSString *)imageName imageEdgeInset:(UIEdgeInsets)imageEdgeInsets
                           frame:(CGRect)frame
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setBackgroundImage:[UIImage imageNamed:@"button_select_background"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_pressed",imageName]] forState:UIControlStateHighlighted];
    btn.tintColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.titleEdgeInsets = titleEdgeInsets;
    btn.imageEdgeInsets = imageEdgeInsets;
    
    NSMutableAttributedString *nomalTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableAttributedString *hightlightTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange titleRange = {0,[title length]};
    NSDictionary *nomalAttrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0],
                                 NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
    NSDictionary *hightlightAttrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0],
                                      NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                      NSForegroundColorAttributeName:[UIColor whiteColor]};
    [nomalTitle addAttributes:nomalAttrs range:titleRange];
    [hightlightTitle addAttributes:hightlightAttrs range:titleRange];
    [btn setAttributedTitle:nomalTitle forState:UIControlStateNormal];
    [btn setAttributedTitle:hightlightTitle forState:UIControlStateHighlighted];
    return btn;
}

@end

//
//  MenuItem.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-22.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

- (instancetype)initWithTitle:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
                        imageName:(NSString *)imageName imageEdgeInset:(UIEdgeInsets)imageEdgeInsets
                        frame:(CGRect)frame target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
        _frame = frame;
        _title = title;
        _imageName = imageName;
        _titleEdageInsets = titleEdgeInsets;
        _imageEdageInsets = imageEdgeInsets;
        
    }
    return self;
}

@end

//
//  PlaceholderView.h
//  163评论
//
//  Created by zhaofuqiang on 14-11-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderView : UIView
{
    UILabel *_placeholderLabel;
}

- (instancetype)initWithFrame:(CGRect)frame content:(NSString *)contentStr fontSize:(CGFloat)fontSize;

@end

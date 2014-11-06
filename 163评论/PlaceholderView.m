//
//  PlaceholderView.m
//  163评论
//
//  Created by zhaofuqiang on 14-11-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "PlaceholderView.h"

@implementation PlaceholderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame content:(NSString *)contentStr fontSize:(CGFloat)fontSize
{
    self = [self initWithFrame:frame];
    
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.text = contentStr;
    _placeholderLabel.font = [UIFont systemFontOfSize:fontSize];
    _placeholderLabel.textColor = RGBCOLOR(153, 153, 153, 1);
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.textAlignment = NSTextAlignmentCenter;
    [_placeholderLabel sizeToFit];
    _placeholderLabel.center = CGPointMake(frame.size.width/2,frame.size.height/2-64);
    [self addSubview:_placeholderLabel];   //别忘添加logo图片
    
    return self;
}
@end

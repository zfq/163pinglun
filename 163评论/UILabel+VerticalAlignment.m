//
//  UILabel+VerticalAlignment.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-14.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "UILabel+VerticalAlignment.h"

@implementation UILabel (VerticalAlignment)
- (void)verticalUpAlignmentWithText:(NSString *)text maxHeight:(CGFloat)maxHeight
{
    CGRect frame = self.frame;
    CGSize size = [text sizeWithFont:self.font constrainedToSize:CGSizeMake(frame.size.width, maxHeight)];
    frame.size = CGSizeMake(frame.size.width, size.height);
    self.frame = frame;
    self.text = text;
}
@end

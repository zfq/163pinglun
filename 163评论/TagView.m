//
//  TagView.m
//  MyScrollTag
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "TagView.h"

@interface TagView()
{
   
}
@end
@implementation TagView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        _centerHorizontally = YES;
        _centerVertically = NO;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)tag
{
    self.tagLabel.text = tag;
    [self.tagLabel sizeToFit];
    
    self = [self initWithFrame:CGRectMake(0, 0, self.tagLabel.frame.size.width, self.tagLabel.frame.size.height)];
    if (self) {
        [self addSubview:self.tagLabel];
    }
    return self;
}

//考虑点击翻转显示另一面为多少个话题
- (void)setTagLabel:(UILabel *)tagLabel
{
    if (_tagLabel != nil) {
        [_tagLabel removeFromSuperview];
        _tagLabel = nil;
    }
    _tagLabel = tagLabel;
}

- (UILabel *)tagLabel
{
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.font = [UIFont systemFontOfSize:18];
    }
    return _tagLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setTagLabelCenterHorizontal:_centerHorizontally vertical:_centerVertically];
}

- (void)setCenterHorizontally:(BOOL)centerHorizontally
{
    [self setTagLabelCenterHorizontal:centerHorizontally vertical:_centerVertically];
}

- (void)setCenterVertically:(BOOL)centerVertically
{
    [self setTagLabelCenterHorizontal:_centerHorizontally vertical:centerVertically];
}

- (void)setTagLabelCenterHorizontal:(BOOL)horizontalCenter vertical:(BOOL)verticalCenter
{
    
    if (_tagLabel != nil) {
        CGRect originFrame = _tagLabel.frame;
        if (horizontalCenter) {
            originFrame.origin.x = (self.frame.size.width-_tagLabel.frame.size.width)/2;
            _tagLabel.frame = originFrame;
        }
        if (verticalCenter) {
            originFrame.origin.y = (self.frame.size.height-_tagLabel.frame.size.height)/2;
            _tagLabel.frame = originFrame;
        }
    }
}
@end

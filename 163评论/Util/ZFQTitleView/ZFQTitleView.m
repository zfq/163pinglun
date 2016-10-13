//
//  ZFQTitleView.m
//  仿知乎TitleLabel
//
//  Created by _ on 16/10/8.
//  Copyright © 2016年 Wecash. All rights reserved.
//

#import "ZFQTitleView.h"

@interface ZFQTitleView()
{
    CGFloat _changeRate;
    CGFloat _detailLabelChangeRate;
    CGFloat _originY;
    CGFloat _tmpOffsetY;
    
    CGFloat _acceV; //加速度
    CGFloat _titleAcceV;
}
@property (nonatomic,strong,readwrite) UILabel *titleLabel;
@property (nonatomic,strong,readwrite) UILabel *detailLabel;
@end

@implementation ZFQTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat fontSize = 18;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:fontSize];
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.font = [UIFont systemFontOfSize:fontSize];
        
        [self addSubview:_titleLabel];
        [self addSubview:_detailLabel];
        self.clipsToBounds = YES;
        
        //初始状态
        _detailLabel.alpha = 0;

        //默认临界值是50;
        [self setCriticalOffset:50];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.frame;
    CGFloat sw = self.bounds.size.width;
    
    //设置titleLabel的frame
    CGSize size = [_titleLabel sizeThatFits:CGSizeMake(sw, CGFLOAT_MAX)];
    CGFloat x = (rect.size.width - size.width)/2;
    CGFloat y = (rect.size.height - size.height)/2;
    _titleLabel.frame = CGRectMake(x , y, size.width, size.height);
    
    //设置detailLabel的frame
    size = rect.size;
    x = (rect.size.width - size.width)/2;
    y = (rect.size.height - size.height)/2;
    _detailLabel.frame = CGRectMake(x , y, size.width, size.height);
    
    _originY = (rect.size.height - _detailLabel.frame.size.height)/2;
    _detailLabelChangeRate = 1/(rect.size.height - _originY);
    
    //计算加速度
    CGFloat a = rect.size.height - _originY;
    _acceV = 2/(a * a);
    
    _titleAcceV = 2/(_criticalOffset * _criticalOffset);
}

- (void)setCriticalOffset:(CGFloat)criticalOffset
{
    _criticalOffset = criticalOffset;
    _changeRate = 1/criticalOffset;
}

- (void)settingLabelWithOffset:(CGFloat)offsetY
{
    //往上滑动太多 只显示detailLabel
    if (offsetY >= _criticalOffset) {
        _detailLabel.alpha = 1;
        _titleLabel.alpha = 0;
        //调整detailLabel的位置
        CGSize size = _detailLabel.frame.size;
        _detailLabel.frame = CGRectMake(0, 0, size.width, size.height);
        return;
    }
    
    //往下滑 只显示标题 因为已经到最顶部了
    if (offsetY <= 0) {
        _titleLabel.alpha = 1;
        _detailLabel.alpha = 0;
        _titleLabel.transform = CGAffineTransformIdentity;
        return;
    }
    
    //线性渐变
//    _titleLabel.alpha = 1-offsetY * _changeRate;
    _titleLabel.alpha = 1 - 0.5f * offsetY * offsetY * _titleAcceV;
    
    //修改detailTitleLabel的frame
    CGRect originFrame = _detailLabel.frame;
    originFrame.origin.y = _criticalOffset -  offsetY + _originY;
    _detailLabel.frame = originFrame;
    
    if (originFrame.origin.y <= self.frame.size.height) {
        //线性渐变
//        CGFloat alpha = (offsetY - _tmpOffsetY) * _detailLabelChangeRate;
        //匀加速渐变
        CGFloat alpha = 0.5f * (offsetY - _tmpOffsetY) * (offsetY - _tmpOffsetY) * _acceV;
        _detailLabel.alpha = alpha;
    } else {
        _tmpOffsetY = offsetY;
    }
}

@end

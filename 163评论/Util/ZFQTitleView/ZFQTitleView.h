//
//  ZFQTitleView.h
//  仿知乎TitleLabel
//
//  Created by _ on 16/10/8.
//  Copyright © 2016年 163pinglun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFQTitleView : UIView

@property (nonatomic,strong,readonly) UILabel *titleLabel;
@property (nonatomic,strong,readonly) UILabel *detailLabel;


/**
 发生渐变的临界偏移量值
 */
@property (nonatomic,assign) CGFloat criticalOffset;

- (void)settingLabelWithOffset:(CGFloat)offsetY;

@end

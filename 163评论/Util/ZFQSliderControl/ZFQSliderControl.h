//
//  ZFQSliderControl.h
//  字体大小控件
//
//  Created by _ on 16/7/24.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFQSliderControl;
@protocol ZFQSliderControlDelegate <NSObject>

@optional

- (void)sliderBarDidMoved:(nonnull ZFQSliderControl *)control;

@end

@interface ZFQSliderControl : UIControl

@property (nonatomic,weak,nullable) id<ZFQSliderControlDelegate> sliderDelegate;
@property (nonatomic,assign,readwrite) NSInteger currIndex;             //滑块的当前的索引
@property (nonatomic,copy,nullable) NSArray<NSString *> *numberStrs;    //数组30% 40% 50%
@property (nonatomic,assign) BOOL allowTapToChange;         //是否允许点击更改，默认是YES

@property (nonatomic,assign) CGFloat thumbWidth;            //默认是34
@property (nonatomic,strong,nullable) UIColor *lineColor;   //刻度线的颜色

@end

//
//  ZFQTumbLayer.h
//  字体大小控件
//
//  Created by _ on 16/7/26.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class ZFQSliderControl;
@interface ZFQTumbLayer : CALayer

@property (nonatomic,assign) BOOL hightlighted;
@property (nonatomic,weak) ZFQSliderControl *sliderControl;

@end

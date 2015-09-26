//
//  FQDisplayView.h
//  MyCoreTextDemo
//
//  持有FQCoreTextData类的实例，负责将CTFrameRef绘制到界面上
//
//  Created by wecash on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQCoreTextData.h"
#import "UIView+FrameAdjust.h"

@interface FQDisplayView : UIView

@property (nonatomic,strong) FQCoreTextData * data;

@property (nonatomic,strong) UIColor *heighlightTextBcgColor;   //字体高亮的背景色
@end

//
//  FQDisplayView.h
//  MyCoreTextDemo
//
//  持有FQCoreTextData类的实例，负责将CTFrameRef绘制到界面上
//
//  Created by 163pinglun on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQCoreTextData.h"
#import "UIView+FrameAdjust.h"

@interface FQDisplayView : UIView

@property (nonatomic,strong) FQCoreTextData * data;

@property (nonatomic,strong) UIColor *heighlightTextBcgColor;   //字体高亮的背景色

@property (nonatomic,weak) UIView *otherPanGestureView;  //

@property (nonatomic,assign) BOOL canBeSelected;    //是否是可选择的，即是否可选择其中的文本 默认是NO

@end

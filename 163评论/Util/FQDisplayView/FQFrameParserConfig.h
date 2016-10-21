//
//  FQFrameParserConfig.h
//  MyCoreTextDemo
//  用于配置绘制的参数，例如文字颜色 大小 行间距等
//
//  Created by 163pinglun on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FQFrameParserConfig : NSObject

@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat lineSpace;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic) CTTextAlignment textAlignment;
@property (nonatomic) CTLineBreakMode lineBreakMode;

@end

//
//  FQFrameParserConfig.m
//  MyCoreTextDemo
//
//  用于配置绘制的参数，例如文字颜色 大小 行间距等
//
//  Created by 163pinglun on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import "FQFrameParserConfig.h"

@implementation FQFrameParserConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxWidth = 200.0f;
        _fontSize = 16.0f;
        _lineSpace = 0.0f; //8
        _textColor = [UIColor whiteColor];
        _textAlignment = kCTTextAlignmentLeft;
        _lineBreakMode = kCTLineBreakByWordWrapping;
    }
    return self;
}
@end

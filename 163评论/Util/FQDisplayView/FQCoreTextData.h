//
//  FQCoreTextData.h
//  MyCoreTextDemo
//
//  Created by wecash on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface FQCoreTextData : NSObject

@property (nonatomic,assign) CTFrameRef ctFrame;
@property (nonatomic) CGFloat height;   //实际高度
@property (nonatomic) CGFloat width;    //实际宽度
@property (nonatomic,strong) NSArray * imageArray; //存的是FQCoreTextImageData
@property (nonatomic,strong) NSArray * linkArray;

@property (strong, nonatomic) NSAttributedString *content;

@end

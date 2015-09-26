//
//  FQCoreTextUtils.h
//  MyCoreTextDemo
//
//  Created by wecash on 15/9/1.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FQCoreTextLinkData,FQCoreTextData;

@interface FQCoreTextUtils : NSObject

+ (FQCoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(FQCoreTextData *)data;

+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(FQCoreTextData *)data;

@end

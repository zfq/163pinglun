//
//  MagnifierView.h
//  MyCoreTextDemo
//
//  Created by 163pinglun on 15/9/14.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MagnifierView : UIView

@property (nonatomic,weak) UIView *viewToMagnify;
@property (nonatomic) CGPoint touchPoint;

@end

//
//  FQNavigationController.h
//
//  navigation切换动画
//
//  Created by zhaofuqiang on 14-3-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FQNavBackStyleNone = 0,
    FQNavBackStyleScale,
    FQNavBackStyleMove
} FQNavBackStyle;

@interface FQNavigationController : UINavigationController

@property (nonatomic) FQNavBackStyle backStyle;
@property (nonatomic) BOOL canDragBack;

@end

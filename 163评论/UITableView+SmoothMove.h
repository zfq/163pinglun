//
//  UITableView+SmoothMove.h
//  tableView动画
//
//  Created by zhaofuqiang on 14-9-10.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SmoothMove)

- (void)beginSmoothMoveAnimationWithCount:(NSInteger)cellCount;
@end

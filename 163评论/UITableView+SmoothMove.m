//
//  UITableView+SmoothMove.m
//  tableView动画
//
//  Created by zhaofuqiang on 14-9-10.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "UITableView+SmoothMove.h"

@implementation UITableView (SmoothMove)

- (void)beginSmoothMoveAnimationWithCount:(NSInteger)cellCount
{
    [self reloadData];
    [self setHidden:NO];
    [self setContentOffset:self.contentOffset animated:NO];
    //连续点击问题修复：cell复位已经确保之前动画被取消
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        UITableViewCell *cell = [self cellForRowAtIndexPath:path];
        cell.frame = [self rectForRowAtIndexPath:path];
        cell.hidden = YES;
        [cell.layer removeAllAnimations];
        NSArray *array = @[path];
        [self performSelector:@selector(animationStart:) withObject:array afterDelay:0.04*i];
    }

}

- (void)animationStart:(NSArray *)array
{
    NSIndexPath *path = [array objectAtIndex:0];
    UITableViewCell *cell = [self cellForRowAtIndexPath:path];
    cell.hidden = NO;
    [self addSmoothMoveAnimationForCellLayer:cell.layer];
}

- (void)addSmoothMoveAnimationForCellLayer:(CALayer *)layer
{
    layer.anchorPoint = CGPointMake(0, 0.5);
    //关键帧动画
    CGPoint beginPoint = CGPointMake(80, layer.position.y);
    CGPoint endPoint1 = CGPointMake(40, layer.position.y);
    CGPoint endPoint2 = CGPointMake(0, layer.position.y);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.values = @[[NSValue valueWithCGPoint:beginPoint],[NSValue valueWithCGPoint:endPoint1],[NSValue valueWithCGPoint:endPoint2]];
    animation.keyTimes=@[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:1.0]];
    animation.timingFunctions = @[
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                  ]; //EaseIn
    
    animation.repeatCount = 1;
    //透明度渐变动画
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = [NSNumber numberWithFloat:0.2];
    alphaAnimation.toValue = [NSNumber numberWithFloat:1];
    alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation,alphaAnimation];
    group.duration = 0.3;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [layer addAnimation:group forKey:@"smoothMove"];
}

@end

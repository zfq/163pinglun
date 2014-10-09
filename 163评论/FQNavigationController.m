//
//  FQNavigationController.m
//
//  navigation切换动画
//
//  Created by zhaofuqiang on 14-3-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FQNavigationController.h"

#define FQ_KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define FQ_NAV_WIDTH   [UIScreen mainScreen].bounds.size.width

@interface FQNavigationController ()
{
    NSMutableArray *screenShots;
    CGPoint startPoint;
}
@end

@implementation FQNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.hidden = YES;
    //设置阴影
    self.view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(-1, 0);
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius = 2;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    //添加手势
    self.interactivePopGestureRecognizer.enabled = NO;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - push/pop
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //将截屏添加到array中
    if (self.viewControllers.count != 0) {
        if (screenShots == nil)
            screenShots = [[NSMutableArray alloc] init];
        [screenShots addObject:[self.view snapshotViewAfterScreenUpdates:NO]];//注意要设置为NO,YES时会闪烁
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //移除截屏
    [self removeTopSnapshotView];
    
    [super popViewControllerAnimated:animated];
    //重置view,不能少
    [self resetView];
    return self.viewControllers.lastObject;
}

- (void)resetView
{
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;
}

- (void)addSnapshotView
{
    UIView *lastScreenShotView = [screenShots lastObject];
    [FQ_KEY_WINDOW insertSubview:lastScreenShotView belowSubview:self.view];
}

- (void)removeTopSnapshotView
{
    //移除已经截取的view
    UIView *topView = (UIView *)[screenShots lastObject];
    [topView removeFromSuperview];
    topView = nil;
    [screenShots removeLastObject];
}

#pragma mark - 手势
- (void)move:(UIPanGestureRecognizer *)gesture
{
    if (self.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        gesture.enabled = NO;
        return;
    }
    if (self.viewControllers.count < 2) {
        return;
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            startPoint = [gesture locationInView:FQ_KEY_WINDOW];
            //将截图添加到self.view下面
            [self addSnapshotView];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currPoint = [gesture locationInView:FQ_KEY_WINDOW];
            CGFloat offsetX = currPoint.x - startPoint.x;
            if (offsetX > 0) {
                [self moveView:offsetX];
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint currPoint = [gesture locationInView:FQ_KEY_WINDOW];
            if (currPoint.x-startPoint.x >= 100) {   //移动距离比较大 就pop
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveView:FQ_NAV_WIDTH];
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self popViewControllerAnimated:NO];
                    }
                }];
            } else {    //移动距离太小 不pop,因为之前已经add过了
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveView:0];
                } completion:^(BOOL finished) {
                    UIView *topView = (UIView *)[screenShots lastObject];
                    [topView removeFromSuperview];
                    topView = nil;
                }];
            }
            
        }
            break;
        default:
            break;
    }
}

- (void)moveView:(CGFloat)x
{
    CGRect originFrame = self.view.frame;
    originFrame.origin.x = x;
    self.view.frame = originFrame;
    CGFloat quarterWidth = FQ_NAV_WIDTH/4;
    static BOOL beginMove = YES;
    UIView *view = [screenShots lastObject];
    
    if (beginMove) {
        CGRect originFrame = view.frame;
        originFrame.origin.x = -quarterWidth;
        view.frame = originFrame;
        beginMove = NO;
    } else {
        CGRect newFrame = view.frame;
        newFrame.origin.x = -quarterWidth+x/4;
        view.frame = newFrame;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end




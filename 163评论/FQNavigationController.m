//
//  FQNavigationController.m
//
//  navigation切换动画
//
//  Created by zhaofuqiang on 14-3-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FQNavigationController.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

@interface FQNavigationController ()
{
    CGPoint _startTouch;
    UIImageView *_lastScreenShotView;
    BOOL _usePanGesture;
    UIView *blackMask;
}

@property (nonatomic,strong) NSMutableArray *screenShotsList;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic) BOOL isMoving;

@end

@implementation FQNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
        self.canDragBack = YES;
        _usePanGesture = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //给view添加左侧的阴影
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
    shadowImageView.frame = CGRectMake(-10, 0, shadowImageView.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    //添加滑动手势
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paningGestureReceive:)];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    [self.backgroundView removeFromSuperview];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self screenCapture]];
    [super pushViewController:viewController animated:animated];
}

- (void)checkBackgroundViewIsExist  //backgroundView是一直存在的，他是在window之上
{
    if (self.backgroundView == nil) {
        CGSize size = self.view.frame.size;
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        [KEY_WINDOW insertSubview:self.backgroundView belowSubview:self.view];
        
        blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width , size.height)];
        blackMask.backgroundColor = [UIColor blackColor];
        [self.backgroundView addSubview:blackMask];
    }
    self.backgroundView.hidden = NO;
}

- (void)addLastScreenShotView
{
    if (_lastScreenShotView != nil) {
        [_lastScreenShotView removeFromSuperview];
    }
    
    UIImage *lastScreenShot = [self.screenShotsList lastObject];
    _lastScreenShotView = [[UIImageView alloc] initWithImage:lastScreenShot];
    [self.backgroundView insertSubview:_lastScreenShotView belowSubview:blackMask];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (animated) {
        switch (self.backStyle) {
            case FQNavBackStyleNone: {
                CGSize size = [UIScreen mainScreen].bounds.size;
                [self checkBackgroundViewIsExist];
                [self addLastScreenShotView];
                blackMask.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveViewWithX:(size.width)];
                } completion:^(BOOL finished) {
                    [super popViewControllerAnimated:NO];
                    [self resetView];
                }];
                return [self.viewControllers lastObject];
            } break;
            case FQNavBackStyleMove: {
                CGSize size = [UIScreen mainScreen].bounds.size;
                [self checkBackgroundViewIsExist];
                [self addLastScreenShotView];
                blackMask.alpha = 0;
                CGFloat halfWidth = size.width/3;
                //先将截图的x改为-1/3,再把它改为0，最后再remove,并显示真正的view
                CGRect originFrame = _lastScreenShotView.frame;
                originFrame.origin.x = -halfWidth;
                _lastScreenShotView.frame = originFrame;
                
                [UIView animateWithDuration:0.3f animations:^{
                    CGRect newFrame = _lastScreenShotView.frame;
                    newFrame.origin.x = 0;
                    _lastScreenShotView.frame = newFrame;
                    [self moveViewWithX:size.width];
                } completion:^(BOOL finished) {
                    [super popViewControllerAnimated:NO];
                    [self resetView];
                }];
                return [self.viewControllers lastObject];
            } break;
            case FQNavBackStyleScale: {
                CGSize size = [UIScreen mainScreen].bounds.size;
                [self checkBackgroundViewIsExist];
                [self addLastScreenShotView];
                
                _lastScreenShotView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                [UIView animateWithDuration:0.3f animations:^{
                    [self moveViewWithX:size.width];
                } completion:^(BOOL finished) {
                    [super popViewControllerAnimated:NO];
                    [self resetView];
                }];
                return [self.viewControllers lastObject];
            } break;
            default:
                break;
        }
        
        [self.screenShotsList removeLastObject];
        return [super popViewControllerAnimated:NO];
    } else {
        [self.screenShotsList removeLastObject];
        return [super popViewControllerAnimated:NO];
    }
}

- (void)resetView
{
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;
    self.backgroundView.hidden = YES;
    [self.screenShotsList removeLastObject];
}

- (UIImage *)screenCapture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recognizer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) {
        return;
    }
    
    _usePanGesture = YES;
    //获取点击位置
    CGPoint touchPoint = [recognizer locationInView:KEY_WINDOW];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isMoving = YES;
        _startTouch = touchPoint;
        [self checkBackgroundViewIsExist];
        [self addLastScreenShotView];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        if (touchPoint.x - _startTouch.x > ((NSInteger)(width/3))) {        //如果滑动距离大于1/3宽度就让视图完全显示
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:self.view.frame.size.width];
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                _isMoving = NO;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }
        return;
    } else if (recognizer.state == UIGestureRecognizerStateCancelled){
    
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        return;
    }
    
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - _startTouch.x];
    }
}

- (void)moveViewWithX:(CGFloat)x
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    x = x > size.width ? size.width : x;
    x= x < 0 ? 0 : x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    switch (self.backStyle) {
        case FQNavBackStyleNone: {
            blackMask.alpha = 0;
        } break;
        case FQNavBackStyleMove: {
            if (_usePanGesture)
            {
                blackMask.alpha = 0;
                CGFloat halfWidth = frame.size.width/3;
                static BOOL beginMove = YES;
                if (beginMove) {
                    CGRect originFrame = _lastScreenShotView.frame;
                    originFrame.origin.x = -halfWidth;
                    _lastScreenShotView.frame = originFrame;
                    beginMove = NO;
                } else {
                    CGRect newFrame = _lastScreenShotView.frame;
                    newFrame.origin.x = -halfWidth+x/3;
                    _lastScreenShotView.frame = newFrame;
                }
            }
        } break;
        case FQNavBackStyleScale: {
            CGFloat scale = (x/(size.width/0.1))+0.9; //4000 = 320/0.08
            _lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
            CGFloat alpha = 0.4 - (x/800);
            blackMask.alpha = alpha;
        } break;
        default:
            break;
    }

//
}
@end




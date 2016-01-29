//
//  MenuViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MenuView.h"
#import "MenuItemView.h"
#import "MacroDefinition.h"
#import "MenuItem.h"

@interface MenuView()
{
    UIView *_menuView;
}
@end
@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems
{
    self = [self initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        //显示menuView
        _menuView = [[UIView alloc] init];
        _menuView.frame = frame;//
        _menuView.backgroundColor = RGBCOLOR(239, 239, 239, 1.0); //
        _menuView.layer.shadowColor = RGBCOLOR(109, 109, 109, 0.4).CGColor;
        _menuView.layer.shadowOpacity = 1.0;
        _menuView.layer.shadowOffset = CGSizeMake(1,1);
        _menuView.layer.shadowRadius = 1.0;
        
        NSInteger count = menuItems.count;
        __block CGFloat y = 0;
        if (count == 1) {
            MenuItem *item = [menuItems firstObject];
            MenuItemView *itemView = [[MenuItemView alloc] initWithMenuItem:item];
            itemView.menuView = self;
            [_menuView addSubview:itemView];
            
            y = itemView.button.frame.size.height;
        } else if (count >= 2){
            [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MenuItem *item = (MenuItem *)obj;
                MenuItemView *itemView = [[MenuItemView alloc] initWithMenuItem:item];
                itemView.menuView = self;
                itemView.frame = CGRectMake(0, y, itemView.frame.size.width, itemView.frame.size.height);
                [_menuView addSubview:itemView];
                y += itemView.frame.size.height;
                if (idx < (count-1)) {      //确保在最后一个不加
                    //添加分割线
                    CALayer *seperatorLine = [CALayer layer];
                    seperatorLine.frame = CGRectMake(0, y, _menuView.frame.size.width, 1);
                    seperatorLine.backgroundColor = RGBCOLOR(109, 109, 109, 0.1).CGColor;
                    [_menuView.layer addSublayer:seperatorLine];
                    y += 1;
                }
            }];
        }
        //确保menuView的高度是自动增加的
        CGRect rect = _menuView.frame;
        rect.size.height = y;
        _menuView.frame = rect;
        [self addSubview:_menuView];
    }
    return self;
}

#pragma mark - 显示菜单
- (void)showMenuView
{
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    //1.设置缩放的锚点
    CGRect menuViewFrame = _menuView.frame;
    _menuView.alpha = 1;
    _menuView.layer.anchorPoint = CGPointMake(1, 0);
    _menuView.frame = menuViewFrame;
    _menuView.transform = CGAffineTransformMakeScale(0.8,0.8);
    
    //2.添加self
    UIView *rootView = topWindow.rootViewController.view;
    self.frame = CGRectMake(0, 0, rootView.frame.size.width, rootView.frame.size.height);
    [topWindow.rootViewController.view addSubview:self];

    //3.开始放大动画
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1 options:0 animations:^{
        _menuView.transform = CGAffineTransformMakeScale(1,1);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissMenuViewWithAnimation:(BOOL)animation
{
    if (animation == NO) {
        [self removeFromSuperview];
    } else {
        
        UIView *animationView = self.subviews.firstObject;
        //先放大，再加速缩小
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.duration = 0.15f;
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @1;
        alphaAnimation.toValue = @0;
        alphaAnimation.duration = 0.15f;
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        alphaAnimation.beginTime = 0.15f;

        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[animation,alphaAnimation];
        group.duration = 0.3f;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        group.delegate = self;
        [animationView.layer addAnimation:group forKey:nil];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissMenuViewWithAnimation:YES];
    [_menuViewDelegate menuViewDidDisappear];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag == YES) {
        UIView *animationView = self.subviews.firstObject;
        [animationView.layer removeAllAnimations];
        [self removeFromSuperview];
        
        if ([_menuViewDelegate respondsToSelector:@selector(menuViewDidDisappear)]) {
            [_menuViewDelegate menuViewDidDisappear];
        }

    }
    
}
@end

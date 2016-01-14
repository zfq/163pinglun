//
//  MenuViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "MenuView.h"
#import "MenuItemView.h"

@interface MenuView()
{
    CGRect menuViewFrame;
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
        UIView *menuView = [[UIView alloc] init];
        menuView.frame = frame;//
        menuView.backgroundColor = RGBCOLOR(239, 239, 239, 1.0); //
        menuView.layer.shadowColor = RGBCOLOR(109, 109, 109, 0.4).CGColor;
        menuView.layer.shadowOpacity = 1.0;
        menuView.layer.shadowOffset = CGSizeMake(1,1);
        menuView.layer.shadowRadius = 1.0;
        
        NSInteger count = menuItems.count;
        __block CGFloat y = 0;
        if (count == 1) {
            MenuItem *item = [menuItems firstObject];
            MenuItemView *itemView = [[MenuItemView alloc] initWithMenuItem:item];
            itemView.menuView = self;
            [menuView addSubview:itemView];
            y = itemView.button.frame.size.height;
        } else if (count >= 2){
            [menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MenuItem *item = (MenuItem *)obj;
                MenuItemView *itemView = [[MenuItemView alloc] initWithMenuItem:item];
                itemView.menuView = self;
                itemView.frame = CGRectMake(0, y, itemView.frame.size.width, itemView.frame.size.height);
                [menuView addSubview:itemView];
                y += itemView.frame.size.height;
                if (idx < (count-1)) {      //确保在最后一个不加
                    //添加分割线
                    CALayer *seperatorLine = [CALayer layer];
                    seperatorLine.frame = CGRectMake(0, y, menuView.frame.size.width, 1);
                    seperatorLine.backgroundColor = RGBCOLOR(109, 109, 109, 0.1).CGColor;
                    [menuView.layer addSublayer:seperatorLine];
                    y += 1;
                }
            }];
        }
        //确保menuView的高度是自动增加的
        CGRect rect = menuView.frame;
        rect.size.height = y;
        menuView.frame = rect;
        menuViewFrame = rect;
        [self addSubview:menuView];
    }
    return self;
}

#pragma mark - 显示菜单
- (void)showMenuView
{
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *animationView = self.subviews.firstObject;
    animationView.alpha = 1;
    animationView.layer.anchorPoint = CGPointMake(1, 0);
    
    //为animationView添加约束
    NSDictionary *nameMap = @{@"menuView":animationView,@"viewForSelf":self};
    animationView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *animConsW = [NSLayoutConstraint constraintWithItem:animationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:menuViewFrame.size.width];
    [animationView addConstraint:animConsW];
    NSString *vfH = [NSString stringWithFormat:@"H:[menuView]-(-%f)-|",menuViewFrame.size.width/2.0f - 6];
    NSString *vfV = [NSString stringWithFormat:@"V:|-0-[menuView(%f)]",menuViewFrame.size.height];
    NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:vfH options:0 metrics:nil views:nameMap];
    NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:vfV options:0 metrics:nil views:nameMap];
    [self addConstraints:consH];
    [self addConstraints:consV];
    
    animationView.transform = CGAffineTransformMakeScale(0.8,0.8);
    
    //为self添加约束
    UIView *rootView = topWindow.rootViewController.view;
    [topWindow.rootViewController.view addSubview:self]; 
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *selfConsW = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *selfConsH = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSArray *consHForSelf = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[viewForSelf]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *consVForSelf = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[viewForSelf]-0-|" options:0 metrics:nil views:nameMap];
    [rootView addConstraints:@[selfConsW,selfConsH]];
    [rootView addConstraints:consHForSelf];
    [rootView addConstraints:consVForSelf];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1 options:0 animations:^{
        animationView.alpha = 1;
        animationView.transform = CGAffineTransformMakeScale(1,1);
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

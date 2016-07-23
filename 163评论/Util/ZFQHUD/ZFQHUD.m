//
//  ZFQHUD.m
//  ZFQHUD
//
//  Created by _ on 16/2/28.
//  Copyright © 2016年 zfq. All rights reserved.
//

#import "ZFQHUD.h"
#import "UIImage+REFrostedViewController.h"

@implementation ZFQHUDConfig

static ZFQHUDConfig *zfqHUDConfig = nil;
+ (ZFQHUDConfig *)globalConfig
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!zfqHUDConfig) {
            zfqHUDConfig = [[ZFQHUDConfig alloc] init];
        }
    });
    return zfqHUDConfig;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!zfqHUDConfig) {
            zfqHUDConfig = [super allocWithZone:zone];
        }
    });
    return zfqHUDConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        _waitingViewWidth = 40;
        _alertViewMinWidth = zfqHUDConfig.waitingViewWidth + zfqHUDConfig.edgeInsets.left + zfqHUDConfig.edgeInsets.right;
        _alertViewCornerRadius = 4;
        _alertViewBcgColor = [UIColor whiteColor];
        _alertViewTintColor = [UIColor blueColor];
        
    }
    return self;
}
@end


@interface ZFQHUD()
{
    CGFloat _preferMaxWidth;
    CGFloat _preferMaxHeight;
}
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIScrollView *msgScrollView;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) UIImage *blurImg;

@property (nonatomic, strong) CAAnimationGroup *animations;
@property (nonatomic, strong) CAShapeLayer *waitingLayer;

@property (nonatomic,assign) BOOL tapClearDismiss;
@property (nonatomic,assign) BOOL isShowAnimating;      //是否正在动画
@property (nonatomic,assign) BOOL isHideAnimating;
@property (nonatomic,assign,readwrite) BOOL isVisible;    //是否可见
@property (nonatomic,strong) dispatch_source_t timeSource;

@end

@implementation ZFQHUD
static ZFQHUD *zfqHUD = nil;

- (nonnull UIView *)hudView
{
    if (!_hudView) {
        _hudView = [[UIView alloc] init];
    }
    return _hudView;
}

+ (ZFQHUD *)sharedView
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if (!zfqHUD) {
            zfqHUD = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
    });
    
    return zfqHUD;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!zfqHUD) {
            zfqHUD = [super allocWithZone:zone];
        }
    });
    return zfqHUD;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _isVisible = NO;
        _tapClearDismiss = NO;
        _isShowAnimating = NO;
        _isHideAnimating = NO;
        _showAnimationBlk = [self alertShowAnimation];
        _hideAnimationBlk = [self alertHideAnimation];
    }
    return self;
}

+ (void)setHUDMaskType:(ZFQHUDMaskType)hudMaskType
{
    [self sharedView].hudMaskType = hudMaskType;
    
    switch (hudMaskType) {
        case ZFQHUDClear: {
            [self sharedView].backgroundColor = [UIColor clearColor];
            break;
        }
        case ZFQHUDBlur:
            
            break;
        case ZFQHUDAlertViewBlur:
            [self sharedView].backgroundColor = [UIColor clearColor];
            break;
        default:
            break;
    }
}

+ (void)setTapClearDismiss:(BOOL)dismiss
{
    [self sharedView].tapClearDismiss = dismiss;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == self ) {
        if (self.tapClearDismiss) {
            if (self.timeSource) {
                dispatch_source_cancel(self.timeSource);
            }
            [self dismissWithAnimation:YES];
        }
    }
}

- (UIImage *)applyBlurToImage:(UIImage *)image
{
    CGFloat radius = 5;
    UIColor *tintColor = [UIColor colorWithWhite:1 alpha:0.75f];
    CGFloat saturationFactor = 1.8f; //饱和度
    return [image re_applyBlurWithRadius:radius tintColor:tintColor saturationDeltaFactor:saturationFactor maskImage:nil];
}

- (UIImage *)applyBlurToImage:(UIImage *)image area:(CGRect)maskArea
{
    CGFloat radius = 10;
    UIColor *tintColor = [UIColor colorWithWhite:1 alpha:0.65f];
    CGFloat saturationFactor = 1.8f; //饱和度
    //从image上的maskArea区域上裁剪出图片，然后再进行模糊处理
    UIGraphicsBeginImageContextWithOptions(maskArea.size,NO,[UIScreen mainScreen].scale);
    //注意坐标是反向的
    [image drawAtPoint:CGPointMake(-maskArea.origin.x, -maskArea.origin.y)];
    UIImage *smallImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [smallImg re_applyBlurWithRadius:radius tintColor:tintColor saturationDeltaFactor:saturationFactor maskImage:nil];
}

- (void)showWithType:(ZFQHUDType)hudType msg:(nullable NSString *)alertMsg duration:(NSTimeInterval)interval completionBlk:(nullable void (^)(void))blk
{
    ZFQHUDConfig *config = [ZFQHUDConfig globalConfig];
    
    if (self.hudMaskType == ZFQHUDBlur) {
        //1.截图
        UIImage *simg = [[self class] snapShotImg];
        UIImage *img = [self applyBlurToImage:simg];
        //2.填充内容
        self.layer.contents = (__bridge id)img.CGImage;
    }
    
    if (self.superview == nil) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal){
                [window addSubview:self];
                break;
            }
        }
    }
    
    //添加hudView
    UIView *hudView = [self hudView];
    hudView.layer.cornerRadius = config.alertViewCornerRadius;
    hudView.layer.borderColor = config.alertViewBorderColor.CGColor;
    hudView.layer.borderWidth = config.alertViewBorderWidth;
    hudView.backgroundColor = config.alertViewBcgColor;

    if (!hudView.superview) {
        [self addSubview:hudView];
    }
    CGFloat height = 0;
    CGFloat width = config.alertViewMinWidth;
    hudView.bounds = CGRectMake(0, 0, width, width);
    //分三种情况
    //1.只有文字
    //2.只有等待视图和文字(如果文字的长度为0，相当于只有等待视图)
    //3.只有自定义图片和文字(如果文字的长度为0，相当于只有等待视图)
    
    UIImage *img = config.alertImg;
    if (!img) {
        BOOL hideWaiting = NO;
        if (hudType == ZFQHUDTypeAlert) {
            hideWaiting = YES;
        } else if (hudType == ZFQHUDTypeActivity) {
            hideWaiting = NO;
        }
        [self showWithMsg:alertMsg hideWaiting:hideWaiting onView:hudView width:&width height:&height];
    } else {
        if (alertMsg.length == 0) {
            //只显示自定义视图
        } else {
            //显示自定义视图和文字
        }
    }
        
    //设置hudView的frame
    hudView.frame = CGRectMake(self.center.x-width/2, self.center.y-height/2, width, height);
    
    if (self.hudMaskType == ZFQHUDAlertViewBlur) {
        hudView.layer.masksToBounds = YES;
        UIImage *simg = [[self class] snapShotImg];
        UIImage *img = [self applyBlurToImage:simg area:hudView.frame];
        hudView.layer.contents = (__bridge id)img.CGImage;
    }
    
    //添加显示动画
    _isVisible = YES;
    if (self.showAnimationBlk && self.isShowAnimating == NO) {
        self.showAnimationBlk(self);
    }
    
    //dismiss弹出视图
    if (interval > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        self.timeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, mainQueue);
        dispatch_source_set_timer(_timeSource, time, (int64_t)(1 * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(_timeSource, ^{
            dispatch_source_cancel(weakSelf.timeSource);
            [weakSelf dismissWithAnimation:YES];
            if (blk) {
                blk();
            }
        });
        dispatch_resume(_timeSource);
    }
}

- (void)showWithMsg:(NSString *)msg hideWaiting:(BOOL)hideWaiting onView:(UIView *)view width:(CGFloat *)width height:(CGFloat *)height
{
    //1.添加等待视图
    CGFloat padding = 8;    //等待视图与msgLabel的垂直间距
    CGFloat viewWidth = view.bounds.size.width;
    ZFQHUDConfig *hudConfig = [ZFQHUDConfig globalConfig];
    UILabel *msgLabel = self.msgLabel;
    
    CAShapeLayer *layer = hideWaiting ? nil : self.waitingLayer;
    if (layer) {
        CGSize layerSize = layer.bounds.size;
        if (!layer.superlayer) {
            layer.position = CGPointMake(viewWidth/2, hudConfig.edgeInsets.top + layerSize.height/2);
            [view.layer addSublayer:layer];
            [layer addAnimation:self.animations forKey:@"aaa"];
        }
    } else {
        [_waitingLayer removeAllAnimations];
        [_waitingLayer removeFromSuperlayer];
    }
    
    //2.添加msgLabel
    if (msg.length > 0) {
        UILabel *label = self.msgLabel;
        label.textColor = hudConfig.alertViewTintColor;
        //这里可以先不用添加label
        if (!label.superview) {
            [view addSubview:label];
        }
        label.text = msg;
        
        _preferMaxWidth = [UIScreen mainScreen].bounds.size.width * 0.8;
        _preferMaxHeight = [UIScreen mainScreen].bounds.size.height * 0.8;
        
        CGFloat x = 0;
        CGSize actualSize = [label sizeThatFits:CGSizeMake(_preferMaxWidth, CGFLOAT_MAX)];

        if (layer) {
            if (actualSize.width > layer.bounds.size.width) {
                viewWidth = actualSize.width + hudConfig.edgeInsets.left + hudConfig.edgeInsets.right;
                x = hudConfig.edgeInsets.left;
            } else {
                x = (viewWidth - actualSize.width)/2;
            }
        } else {
            if (actualSize.width > viewWidth) {
                viewWidth = actualSize.width + hudConfig.edgeInsets.left + hudConfig.edgeInsets.right;
                x = hudConfig.edgeInsets.left;
            } else {
                x = (viewWidth - actualSize.width)/2;
            }
        }
        
        CGFloat y = 0;
        if (layer) {
            y = layer.position.y + layer.bounds.size.height/2 + padding;
        } else {
            y = hudConfig.edgeInsets.top;
        }
        label.frame = CGRectMake(x, y, actualSize.width, actualSize.height);
    } else {
        _msgLabel.text = nil;
        [_msgLabel removeFromSuperview];
    }
    
    //调整hudView的宽度
    if (hudConfig.alertViewMinWidth - viewWidth > 0.1f) {
        viewWidth = hudConfig.alertViewMinWidth;
    }
    
    //调整等待视图的位置
    layer.position = CGPointMake(viewWidth/2, layer.position.y);
    
    //将hudView的实际宽高传出去
    if (width != NULL) {
        *width = viewWidth;
    }
    if (height != NULL) {
        if (msg.length > 0) {
            if (CGRectGetMaxY(msgLabel.frame) + hudConfig.edgeInsets.bottom > _preferMaxHeight) {
                *height = _preferMaxHeight;
                
                //将label添加在scrollView上
                UIScrollView *scrollView = self.msgScrollView;
                
                //设置scrollView
                if (msgLabel.superview != scrollView) {
                    [msgLabel removeFromSuperview];
                    [scrollView addSubview:msgLabel];
                }
                scrollView.contentSize = msgLabel.bounds.size;
                scrollView.frame = CGRectMake(msgLabel.frame.origin.x, msgLabel.frame.origin.y, msgLabel.frame.size.width, *height - hudConfig.edgeInsets.top - layer.bounds.size.height - hudConfig.edgeInsets.bottom);
                msgLabel.frame = CGRectMake(0, 0, msgLabel.bounds.size.width, msgLabel.bounds.size.height);
                
                //将scrollView添加view上
                if (scrollView.superview != view) {
                    [view addSubview:scrollView];
                }
            } else {
                [_msgScrollView removeFromSuperview];
                if (msgLabel.superview != view) {
                    [msgLabel removeFromSuperview];
                    [view addSubview:msgLabel];
                }
                *height = CGRectGetMaxY(msgLabel.frame) + hudConfig.edgeInsets.bottom;
            }
        } else {
            
            if (layer) {
                *height = layer.position.y + layer.bounds.size.height/2 + hudConfig.edgeInsets.bottom;
            } else {
                *height = hudConfig.edgeInsets.top + hudConfig.edgeInsets.bottom;
            }
            
        }
    }
}

+ (UIImage *)snapShotImg
{
    CGRect rect = [UIScreen mainScreen].bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, [UIScreen mainScreen].scale);
    
    UIView *v = [UIApplication sharedApplication].keyWindow;
    [v drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)showWithMsg:(nullable NSString *)alertMsg
{
    [self showWithMsg:alertMsg duration:0 completionBlk:nil];
}

- (void)showWithMsg:(nullable NSString *)msg duration:(NSTimeInterval)interval completionBlk:(nullable void (^)(void))blk
{
    [self showWithType:ZFQHUDTypeAlert msg:msg duration:interval completionBlk:blk];
}

- (void)dismiss
{
    [self dismissWithAnimation:NO];
}

- (void)dismissWithAnimation:(BOOL)animation
{
    if (!self.superview) {
        return;
    }

    if (self.isShowAnimating) {
        [self.layer removeAllAnimations];
        [self.hudView.layer removeAllAnimations];
        self.isShowAnimating = NO;
    }
    if (self.hideAnimationBlk && self.isHideAnimating == NO) {
        self.hideAnimationBlk(self);
    } else {
        [self removeFromSuperview];
        self.isHideAnimating = NO;
        self.isVisible = NO;
    }
}

#pragma mark - default show hide animation
- (ZFQHUDPopupBlock)alertShowAnimation
{
    __weak typeof (self) weakSelf = self;
    ZFQHUDPopupBlock blk = ^(ZFQHUD *hud) {
        weakSelf.isShowAnimating = YES;
        weakSelf.hudView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        weakSelf.alpha = 0.1;
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.hudView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            weakSelf.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                weakSelf.isShowAnimating = NO;
                if (weakSelf.showAnimationCompleteBlk) {
                    weakSelf.showAnimationCompleteBlk(weakSelf);
                }
            }
        }];
    };
    return blk;
}

- (ZFQHUDPopupBlock)alertHideAnimation
{
    __weak typeof (self) weakSelf = self;
    ZFQHUDPopupBlock blk = ^(ZFQHUD *hud) {
        weakSelf.isHideAnimating = YES;
        weakSelf.alpha = 1;
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.hudView.layer.transform = CATransform3DMakeScale(0.01f,0.01f,1);
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [weakSelf removeFromSuperview];
                weakSelf.hudView.layer.transform = CATransform3DIdentity;
                weakSelf.isVisible = NO;
                weakSelf.isHideAnimating = NO;
                if (weakSelf.hideAnimationCompleteBlk) {
                    weakSelf.hideAnimationCompleteBlk(weakSelf);
                }
            }
        }];
    };
    return blk;
}

#pragma mark - getter setter
- (CAAnimationGroup *)animations
{
    if (!_animations) {
        NSTimeInterval d1 = 1;
        NSTimeInterval d2 = 1;
        
        CGFloat delta = 0.15;
        
        CABasicAnimation *animation0 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation0.duration = d2+d1;
        animation0.fromValue = @0;
        animation0.toValue = @(M_PI * 2);
        animation0.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation1.duration = d1;
        animation1.fromValue = @(0);
        animation1.toValue = @(delta);
        animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation2.duration = d1;
        animation2.fromValue = @0;
        animation2.toValue = @(1-delta);
        animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation3.beginTime = d1;
        animation3.duration = d2;
        animation3.fromValue = @(delta);
        animation3.toValue = @1;
        
        CABasicAnimation *animation4 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation4.beginTime = d1;
        animation4.duration = d2;
        animation4.fromValue = @(1-delta);
        animation4.toValue = @1;
        
        CAAnimationGroup *animations = [CAAnimationGroup animation];
        animations.animations = @[animation0,animation1,animation2,animation3,animation4];
        animations.duration = d1+d2;
        animations.repeatCount = HUGE_VALF;
        animations.removedOnCompletion = NO;
        
        _animations = animations;
    }
    return _animations;
}

- (CAShapeLayer *)waitingLayer
{
    if (!_waitingLayer) {
        ZFQHUDConfig *config = [ZFQHUDConfig globalConfig];
        CGSize size = CGSizeMake(config.waitingViewWidth, config.waitingViewWidth);
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = CGRectMake(0, 0, size.width, size.height);
        shapeLayer.strokeColor = config.alertViewTintColor.CGColor;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.lineWidth = 2;
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
        shapeLayer.path = path.CGPath;
        _waitingLayer = shapeLayer;
    }
    return _waitingLayer;
}

- (UILabel *)msgLabel
{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.font = [UIFont systemFontOfSize:18];
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (UIScrollView *)msgScrollView
{
    if (!_msgScrollView) {
        _msgScrollView = [[UIScrollView alloc] init];
    }
    return _msgScrollView;
}
@end

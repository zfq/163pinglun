//
//  ZFQLoadFrontOrNextView.m
//  仿知乎加载
//
//  Created by _ on 16/8/15.
//  Copyright © 2016年 NXB. All rights reserved.
//

#import "ZFQLoadFrontOrNextView.h"

#define ZFQLoadViewAnimationDuration 0.5
#define ZFQLoadViewBoundceAnimationDuration 0.5

static NSString * const ZFQLoadViewContentOffset = @"contentOffset";
static NSString * const ZFQLoadViewContentSize = @"contentSize";

@interface ZFQLoadFrontOrNextView()
{
    CGPathRef orginPath;
    CGPathRef arrowTopPath;
    CGPathRef arrowBottomPath;
    BOOL _isOriginState;
}

@end

@implementation ZFQLoadFrontOrNextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _retainOriginalShape = NO;
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        _shapeLayer.lineWidth = 3;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineJoin = kCALineJoinRound;
        _shapeLayer.bounds = CGRectMake(0, 0, 40, 20);
        [self.layer addSublayer:_shapeLayer];
        
        _isOriginState = YES;
        _ignoreRefresh = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    //更新label位置
    CGSize actualSize = [_titleLabel sizeThatFits:frame.size];
    CGFloat orginX = fabs((frame.size.width - actualSize.width)/2);
    CGFloat originY = zfqLoadViewHeight/4;
    _titleLabel.frame = CGRectMake(orginX, originY, actualSize.width, actualSize.height);
    
    //更新shapLayer的位置
    CGFloat pX = frame.size.width/2;
    CGFloat pY = CGRectGetMaxY(_titleLabel.frame) + 8 + _shapeLayer.bounds.size.height/2;
    _shapeLayer.position = CGPointMake(pX, pY);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (_loadScrollView != newSuperview) {
        [_loadScrollView removeObserver:self forKeyPath:ZFQLoadViewContentOffset];
        _loadScrollView = (UIScrollView *)newSuperview;
        [_loadScrollView addObserver:self forKeyPath:ZFQLoadViewContentOffset options:NSKeyValueObservingOptionNew context:NULL];
    }
}

#pragma mark - Getter
- (void)setIgnoreRefresh:(BOOL)ignoreRefresh
{
    _ignoreRefresh = ignoreRefresh;
    if (_ignoreRefresh == NO) {
        _shapeLayer.hidden = NO;
    } else {
        _shapeLayer.hidden = YES;
    }
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    _shapeLayer.strokeColor = _lineColor.CGColor;
}

//横线
- (CGPathRef)originPath
{
    if (!orginPath) {
        CGSize size = self.shapeLayer.bounds.size;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, size.height/2);
        CGPathAddLineToPoint(path, NULL, size.width/2, size.height/2);
        CGPathMoveToPoint(path, NULL, size.width, size.height/2);
        CGPathAddLineToPoint(path, NULL, size.width/2, size.height/2);
        orginPath = path;
    }
    return orginPath;
}

- (CGPathRef)arrowTopPath
{
    if (!arrowTopPath) {
        CGSize size = self.shapeLayer.bounds.size;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, size.height/2);
        CGPathAddLineToPoint(path, NULL, size.width/2, 0);
        CGPathMoveToPoint(path, NULL, size.width, size.height/2);
        CGPathAddLineToPoint(path, NULL, size.width/2, 0);
        arrowTopPath = path;
    }
    return arrowTopPath;
}

- (CGPathRef)arrowBottomPath
{
    if (!arrowBottomPath) {
        CGSize size = self.shapeLayer.bounds.size;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, size.height/2);
        CGPathAddLineToPoint(path, NULL, size.width/2, size.height);
        CGPathMoveToPoint(path, NULL, size.width, size.height/2);
        CGPathAddLineToPoint(path, NULL, size.width/2, size.height);
        arrowBottomPath = path;
    }
    return arrowBottomPath;
}

- (void)pathAnimationFrom:(id)fromValue to:(id)toValue forKey:(NSString *)key
{
    if (self.retainOriginalShape == NO) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = ZFQLoadViewAnimationDuration;
        animation.fromValue = fromValue;
        animation.toValue = toValue;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        self.retainOriginalShape = YES;
        [self.shapeLayer addAnimation:animation forKey:key];
    }
}

- (void)beginRefresh {}
- (void)stopLoading {}

- (void)dealloc
{
    CGPathRelease(orginPath);
    CGPathRelease(arrowTopPath);
    CGPathRelease(arrowBottomPath);
    
    [_loadScrollView removeObserver:self forKeyPath:ZFQLoadViewContentOffset];
}

@end

//----------------------------------
//----------------------------------
@implementation UIScrollView(ZFQAdditions)

- (void)setContentInsetsTop:(CGFloat)top
{
    UIEdgeInsets insets = self.contentInset;
    self.contentInset = UIEdgeInsetsMake(top, insets.left, insets.bottom, insets.right);
}

- (void)setContentInsetsBottom:(CGFloat)bottom
{
    UIEdgeInsets insets = self.contentInset;
    self.contentInset = UIEdgeInsetsMake(insets.top, insets.left, bottom, insets.right);
}

- (void)setContentOffsetY:(CGFloat)y animated:(BOOL)animated
{
    [self setContentOffset:CGPointMake(self.contentOffset.x, y) animated:animated];
}

@end


//----------------------------------
//----------------------------------
#pragma mark - 加载上一篇
@implementation ZFQLoadHeaderView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.shapeLayer.path = [self arrowTopPath];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    _orginInsetsTop = _loadScrollView.contentInset.top;
    _orginInsetsBottom = _loadScrollView.contentInset.bottom;
    _originOffsetY = _loadScrollView.contentOffset.y;
    
    _originOffset = _loadScrollView.contentOffset;
}

- (void)beginRefresh
{
    [_loadScrollView setContentOffsetY:-zfqLoadViewHeight animated:YES];
}

- (void)stopLoading
{
    _oldRefreshState = ZFQLoadRefreshStatePulling;
    self.refreshState = ZFQLoadRefreshStateNormal;
}

- (void)begainPullAnimation
{
    id fromValue = (__bridge id)[self arrowTopPath];
    id toValue = (__bridge id)[self originPath];
    [self pathAnimationFrom:fromValue to:toValue forKey:@"header"];
}

- (void)endPullAnimation
{
    id fromValue = (__bridge id)[self originPath];
    id toValue = (__bridge id)[self arrowTopPath];
    [self pathAnimationFrom:fromValue to:toValue forKey:@"header"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (_refreshState == ZFQLoadRefreshStateLoading
        || self.userInteractionEnabled == NO
        || self.alpha <= 0.01
        || self.ignoreRefresh
        || ([keyPath isEqualToString:ZFQLoadViewContentOffset] == NO)) {
        return;
    }
    
    CGFloat offsetY = _loadScrollView.contentOffset.y;
    CGFloat happenOffsetY = 0;
    if (_orginInsetsTop > 0) {
        happenOffsetY = -_orginInsetsTop - zfqLoadViewHeight;
    } else {
        happenOffsetY = _orginInsetsTop - zfqLoadViewHeight;
    }
    
    if (offsetY < 0) {
        if (_loadScrollView.isDragging) {
            if (self.refreshState == ZFQLoadRefreshStateNormal && offsetY <= happenOffsetY) {
                //临界条件即将开始加载
                self.refreshState = ZFQLoadRefreshStatePulling;
            } else if (self.refreshState == ZFQLoadRefreshStatePulling && offsetY > happenOffsetY) {
                //转为普通状态
                self.refreshState = ZFQLoadRefreshStateNormal;
            }
        } else if (self.refreshState == ZFQLoadRefreshStatePulling){
            //开始加载后设置为正在加载状态
            self.refreshState = ZFQLoadRefreshStateLoading;
        }
        
    }
}

- (void)setRefreshState:(ZFQLoadRefreshState)refreshState
{
    if (_refreshState == refreshState) {
        return;
    }
    
    //针对push一个新VC时，新的带有导航栏的VC的UIScrollView的contentInset可能改变
    if (_refreshState != ZFQLoadRefreshStateLoading) {
        _orginInsetsTop = _loadScrollView.contentInset.top;
    }
    
    _refreshState = refreshState;
    

    if (_refreshState == ZFQLoadRefreshStateNormal) {
        //关闭动画
        self.retainOriginalShape = NO;
        [self endPullAnimation];
        
        if (_oldRefreshState == ZFQLoadRefreshStatePulling) {
            [UIView animateWithDuration:ZFQLoadViewBoundceAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                
                //如下的代码是调试出来的
                CGFloat currInsetT = _loadScrollView.contentInset.top;
                if (_orginInsetsTop == zfqLoadViewHeight) {
                    [_loadScrollView setContentInsetsTop:currInsetT - zfqLoadViewHeight];
                } else {
                    [_loadScrollView setContentInsetsTop:_orginInsetsTop];
                }
                
            } completion:^(BOOL finished) {
                _oldRefreshState = ZFQLoadRefreshStateNormal;
                if (self.animationCompletionBlk) {
                    self.animationCompletionBlk();
                }
            }];
            
        }
    } else if (_refreshState == ZFQLoadRefreshStatePulling) {
        //开始动画
        self.retainOriginalShape = NO;
        [self begainPullAnimation];
    } else if (_refreshState == ZFQLoadRefreshStateLoading) {
        CGFloat offsetY = _loadScrollView.contentOffset.y;
        
        [_loadScrollView setContentInsetsTop:_orginInsetsTop + zfqLoadViewHeight];
        [_loadScrollView setContentOffset:CGPointMake(0, offsetY)];
        if (self.beginRefreshBlk) {
            self.beginRefreshBlk();
        }
    }
}

- (void)dealloc
{
    [_loadScrollView removeObserver:self forKeyPath:ZFQLoadViewContentSize];
}
@end

#pragma mark - 加载下一篇
@implementation ZFQLoadFooterView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.shapeLayer.path = [self arrowBottomPath];
    CGFloat height = _loadScrollView.contentSize.height;
    [self.topC setConstant:height];
    
    _orginInsetsTop = _loadScrollView.contentInset.top;
    _orginInsetsBottom = _loadScrollView.contentInset.bottom;
    _originOffsetY = _loadScrollView.contentOffset.y;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    _orginInsetsTop = _loadScrollView.contentInset.top;
    _orginInsetsBottom = _loadScrollView.contentInset.bottom;
    _originOffsetY = _loadScrollView.contentOffset.y;
    
    if (_loadScrollView == newSuperview) {
        _loadScrollView = (UIScrollView *)newSuperview;
        [_loadScrollView addObserver:self forKeyPath:ZFQLoadViewContentSize options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)beginRefresh
{
    [_loadScrollView setContentOffsetY:zfqLoadViewHeight animated:YES];
}

- (void)stopLoading
{
    _oldRefreshState = ZFQLoadRefreshStateLoading;
    self.refreshState = ZFQLoadRefreshStateNormal;
}

- (void)begainPullAnimation
{
    id fromValue = (__bridge id)[self arrowBottomPath];
    id toValue = (__bridge id)[self originPath];
    [self pathAnimationFrom:fromValue to:toValue forKey:@"footer"];
}

- (void)endPullAnimation
{
    id fromValue = (__bridge id)[self originPath];
    id toValue = (__bridge id)[self arrowBottomPath];
    [self pathAnimationFrom:fromValue to:toValue forKey:@"footer"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    //只有scrollView的contentSize改变时，才调整位置
    if ([keyPath isEqualToString:ZFQLoadViewContentSize]) {
        CGFloat height = _loadScrollView.contentSize.height;
        [self.topC setConstant:height];
    }
    if (_refreshState == ZFQLoadRefreshStateLoading
        || self.userInteractionEnabled == NO
        || self.alpha <= 0.01
        || self.ignoreRefresh) {
        return;
    }
    
    CGFloat offsetY = _loadScrollView.contentOffset.y;
    CGFloat contentH = _loadScrollView.contentSize.height;
    CGFloat frameH = _loadScrollView.frame.size.height;
    
    if (offsetY+_orginInsetsTop > 0) {
        
        if (_loadScrollView.isDragging) {
            
            if (contentH+_orginInsetsTop >= frameH) {
                if (self.refreshState == ZFQLoadRefreshStateNormal && (offsetY + frameH) >= (zfqLoadViewHeight + contentH)) {
                    //临界条件即将开始加载
                    self.refreshState = ZFQLoadRefreshStatePulling;
                } else if (self.refreshState == ZFQLoadRefreshStatePulling && (offsetY + frameH) < (zfqLoadViewHeight + contentH)) {
                    self.refreshState = ZFQLoadRefreshStateNormal;
                }
            } else {
                if (self.refreshState == ZFQLoadRefreshStateNormal && (offsetY+_orginInsetsTop >= zfqLoadViewHeight)) {
                    //临界条件即将开始加载
                    self.refreshState = ZFQLoadRefreshStatePulling;
                } else if (self.refreshState == ZFQLoadRefreshStatePulling && (offsetY+_orginInsetsTop < zfqLoadViewHeight)) {
                    self.refreshState = ZFQLoadRefreshStateNormal;
                }
            }
            
        } else if (self.refreshState == ZFQLoadRefreshStatePulling){
            //开始加载后设置为正在加载状态
            self.refreshState = ZFQLoadRefreshStateLoading;
        }
        
    }
    
}

- (void)setRefreshState:(ZFQLoadRefreshState)refreshState
{
    if (_refreshState == refreshState) {
        return;
    }
    _oldRefreshState = _refreshState;
    _refreshState = refreshState;
    
    if (_refreshState == ZFQLoadRefreshStatePulling) {
        
        //开始动画
        self.retainOriginalShape = NO;
        [self begainPullAnimation];
        
    } else if (_refreshState == ZFQLoadRefreshStateLoading) {
        
        CGFloat offsetY = _loadScrollView.contentOffset.y;
        [_loadScrollView setContentInsetsBottom:_orginInsetsBottom + zfqLoadViewHeight];
        [_loadScrollView setContentOffset:CGPointMake(0, offsetY)];
        
        if (self.beginRefreshBlk) {
            self.beginRefreshBlk();
        }
        
    } else if (_refreshState == ZFQLoadRefreshStateNormal) {
        
        self.retainOriginalShape = NO;
        [self endPullAnimation];
        
        if (_oldRefreshState == ZFQLoadRefreshStateLoading) {
            [UIView animateWithDuration:ZFQLoadViewBoundceAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
                [_loadScrollView setContentInsetsBottom:_orginInsetsBottom];
            } completion:^(BOOL finished) {
                _oldRefreshState = ZFQLoadRefreshStateNormal;
                [_loadScrollView setContentOffset:CGPointMake(_loadScrollView.contentOffset.x, 0) animated:NO];
                if (self.animationCompletionBlk) {
                    self.animationCompletionBlk();
                }
//                [_loadScrollView setContentOffset:CGPointMake(_loadScrollView.contentOffset.x, _originOffsetY) animated:NO];
            }];
        }
        
    }
}

@end

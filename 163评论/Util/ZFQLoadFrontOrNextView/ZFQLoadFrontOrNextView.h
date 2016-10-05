//
//  ZFQLoadFrontOrNextView.h
//  仿知乎加载
//
//  Created by _ on 16/8/15.
//  Copyright © 2016年 NXB. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const zfqLoadViewHeight = 70;

typedef NS_ENUM(NSInteger, ZFQLoadRefreshState) {
    ZFQLoadRefreshStateNormal,
    ZFQLoadRefreshStatePulling,
    ZFQLoadRefreshStateLoading
};

@interface ZFQLoadFrontOrNextView : UIView
{
    UIScrollView *_loadScrollView;
    ZFQLoadRefreshState _refreshState;
    ZFQLoadRefreshState _oldRefreshState;
    CGFloat _orginInsetsTop;
    CGFloat _orginInsetsBottom;
    CGFloat _originOffsetY;
    CGPoint _originOffset;
}
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic,assign) BOOL retainOriginalShape;    //保持原有形状
@property (nonatomic,assign) BOOL ignoreRefresh; //是否忽略刷新,默认是NO,当设置为YES时会隐藏shapeLayer
@property (nonatomic,assign) ZFQLoadRefreshState refreshState;
@property (nonatomic,copy) void (^beginRefreshBlk)();

- (void)beginRefresh;
- (void)stopLoading;

@end

//加载上一篇
@interface ZFQLoadHeaderView : ZFQLoadFrontOrNextView

- (void)begainPullAnimation;
- (void)endPullAnimation;

@end

//加载下一篇
@interface ZFQLoadFooterView : ZFQLoadFrontOrNextView

@property (nonatomic,strong) NSLayoutConstraint *topC;

- (void)begainPullAnimation;
- (void)endPullAnimation;

@end
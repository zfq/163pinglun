//
//  ZFQHUD.h
//  ZFQHUD
//
//  Created by _ on 16/2/28.
//  Copyright © 2016年 zfq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZFQHUDConfig : NSObject

/**
 *  边距的填充,默认是{20,8,8,8}
 */
@property (nonatomic,assign) UIEdgeInsets edgeInsets;

/**
 *  弹出框的最小宽度，默认为waitingViewWidth+edgeInsets.left+edgeInsets.height
 */
@property (nonatomic,assign) CGFloat alertViewMinWidth;

/**
 *  等待圈圈的默认宽度,默认是40
 */
@property (nonatomic,assign) CGFloat waitingViewWidth;

/**
 *  弹出框的圆角半径
 */
@property (nonatomic,assign) CGFloat alertViewCornerRadius;

/**
 *  弹出框的边框颜色
 */
@property (nonatomic,strong,nullable) UIColor *alertViewBorderColor;

/**
 *  弹出框的边框宽度，默认是0
 */
@property (nonatomic,assign) CGFloat alertViewBorderWidth;

/**
 *  弹出框的背景色，可为空,默认为黑色
 */
@property (nonatomic,strong,nullable) UIColor *alertViewBcgColor;

/**
 *  弹出框的tintColor，可为空,默认为白色,影响字体颜色和等待圈圈颜色
 */
@property (nonatomic,strong,nullable) UIColor *alertViewTintColor;

/**
 *  弹出框的提示小图，比如X 对勾 叹号等一类的小图片
 */
@property (nonatomic,strong,nullable) UIImage *alertImg;


+ (nonnull ZFQHUDConfig *)globalConfig;

@end


@class ZFQHUD;
typedef void(^ZFQHUDPopupBlock)(ZFQHUD * _Nonnull hud);
typedef void(^ZFQHUDPopupBlock)(ZFQHUD * _Nonnull hud);

typedef NS_ENUM(NSInteger,ZFQHUDMaskType){
    ZFQHUDClear,
    ZFQHUDBlur,         //模糊背景
    ZFQHUDAlertViewBlur //仅仅提示框背景模糊
};

typedef NS_ENUM(NSInteger,ZFQHUDType){
    ZFQHUDTypeAlert,    //仅仅显示文字
    ZFQHUDTypeActivity, //显示等待视图和文字，若文字长度为0，则只显示等待视图
};

@interface ZFQHUD : UIView

@property (nonatomic,assign,readonly) BOOL isVisible;    //是否可见
@property (nonatomic,assign) ZFQHUDMaskType hudMaskType;

@property (nonatomic,copy,nullable) ZFQHUDPopupBlock showAnimationBlk;
@property (nonatomic,copy,nullable) ZFQHUDPopupBlock showAnimationCompleteBlk;

@property (nonatomic,copy,nullable) ZFQHUDPopupBlock hideAnimationBlk;
@property (nonatomic,copy,nullable) ZFQHUDPopupBlock hideAnimationCompleteBlk;

+ (nonnull ZFQHUD *)sharedView;

+ (void)setHUDMaskType:(ZFQHUDMaskType)hudType;
+ (void)setTapClearDismiss:(BOOL)dismiss;   //点击空白部分消失,这个会强制隐藏掉hud

/**
 *  只显示文字,不会hide,需要调用dismiss函数来关闭hud
 */
- (void)showWithMsg:(nullable NSString *)alertMsg;

/**
 *  只显示文字,在interval时间后会hide,hide完成后会调用completionBlk
 */
- (void)showWithMsg:(nullable NSString *)msg duration:(NSTimeInterval)interval completionBlk:(nullable void (^)(void))blk;

/**
 *  在interval时间后会hide,hide完成后会调用completionBlk,如果duration参数为0,则hud会一直显示
 */
- (void)showWithType:(ZFQHUDType)hudType msg:(nullable NSString *)alertMsg duration:(NSTimeInterval)interval completionBlk:(nullable void (^)(void))blk;

/**
 *  关闭hud
 */
- (void)dismiss;

@end

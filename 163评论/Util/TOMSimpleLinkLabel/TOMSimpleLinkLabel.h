//
//  TOMSimpleLinkLabel.h
//  GuangShengXing
//
//  带链接功能的label
//
//  Created by 163pinglun on 15/8/7.
//  Copyright (c) 2015年 163pinglun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TOMSimpleLinkLabelDelegate <NSObject>

@optional
- (void)didTappedLink:(NSAttributedString *)linkStr text:(NSString *)text;
@end

@interface TOMSimpleLinkLabel : UILabel

@property (nonatomic) CGFloat t_cornerRadius;                 //高亮背景的圆角半径
@property (nonatomic,weak) id<TOMSimpleLinkLabelDelegate> simpleLinkDelegate;

@property (nonatomic) CGFloat tom_red;
@property (nonatomic) CGFloat tom_green;
@property (nonatomic) CGFloat tom_blue;
@property (nonatomic) CGFloat tom_alpha;

@end


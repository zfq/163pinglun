//
//  TagScrollView.h
//  MyScrollTag
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagView.h"

@protocol TagScrollViewDelegate,TagScrollViewDatasource;

@interface TagScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic,weak) id<TagScrollViewDelegate> tagScrollViewDelegate;
@property (nonatomic,weak) id<TagScrollViewDatasource> tagScrollViewDatasource;

@property (nonatomic,strong) NSArray *tagViews;
@property (nonatomic,strong) NSArray *tagsCountInCell;

@property (nonatomic,assign) CGFloat leftMargin;        //左边距
@property (nonatomic,assign) CGFloat rightMargin;       //右边距
@property (nonatomic,assign) CGFloat topMargin;         //上边距
@property (nonatomic,assign) CGFloat bottomMargin;      //下边距
@property (nonatomic,assign) CGFloat horizontalPadding; //水平间距
@property (nonatomic,assign) CGFloat verticalPadding;   //垂直间距

- (void)initialize;
- (void)addVisibleTagView;
@end

/**
 *  代理
 */
@protocol TagScrollViewDelegate <NSObject>
@optional

@end

/**
 * 数据源
 */
@protocol TagScrollViewDatasource <NSObject>


@end

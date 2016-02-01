//
//  TagViewController.h
//  163评论
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagView.h"

@protocol TagViewControllerDelegate;

@interface TagViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic,weak) id<TagViewControllerDelegate> tvcDelegate;

- (void)showTagView;
- (void)dismissTagViewWithAnimation:(BOOL)animation;
+ (void)clearTagKey;

@end

@protocol TagViewControllerDelegate <NSObject>

@optional
- (void)didSelectTagView:(TagView *)tagView controller:(TagViewController *)tVC;

@end


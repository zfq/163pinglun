//
//  PostViewModel.h
//  163pinglun
//
//  Created by _ on 16/1/29.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQRequest.h"

@interface HomeViewModel : NSObject

@property (nonatomic,copy) NSString *tagName;
@property (nonatomic,assign) BOOL headRefreshing;   //YES表示为下拉刷新,NO表示上拉加载
@property (nonatomic,assign) NSInteger homePageIndex;
@property (nonatomic,assign) NSInteger tagPageIndex;
@property (nonatomic,strong) NSMutableArray<Post *> *postItems;

@property (nonatomic,copy) void (^latestPostRefreshBlk)(void);

- (void)fetchPostsWithCompletion:(void (^)(NSArray<Post *> *postItems,NSArray<Post *> *increasedPostItems,NSError *error))completionBlk;

@end

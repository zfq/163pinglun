//
//  HomeViewModel2.h
//  163pinglun
//
//  Created by _ on 16/9/22.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface HomeViewModel2 : NSObject

@property (nonatomic,copy) NSString *tagName;
@property (nonatomic,assign) BOOL headRefreshing;   //YES表示为下拉刷新,NO表示上拉加载
@property (nonatomic,assign) NSInteger homePageIndex;
@property (nonatomic,strong) NSMutableArray<Post *> *postItems;

@property (nonatomic,copy) void (^latestPostRefreshBlk)(void);

@end

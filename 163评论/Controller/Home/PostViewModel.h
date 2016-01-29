//
//  PostViewModel.h
//  163pinglun
//
//  Created by _ on 16/1/29.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostViewModel : NSObject

/**
 *  获取加载指定标签对应的帖子列表的url
 *
 *  @param tagName        标签名称，如果为nil，则表示为获取最新帖子列表的url
 *  @param headRefreshing YES表示为下拉刷新,NO表示上拉加载
 *
 *  @return 指定标签对应的帖子列表的url
 */
- (NSString *)postUrlWithTagName:(NSString *)tagName headRefreshing:(BOOL)headRefreshing;

- (NSInteger)homePageIndex;
- (void)setHomePageIndex:(NSInteger)homePageIndex;

@end

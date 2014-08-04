//
//  Posts.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Posts.h"
#import "Post.h"
#import "ItemStore.h"

@implementation Posts

- (id)init
{
    return [self initWithPosts:nil];
}

- (instancetype)initWithPosts:(NSArray *)posts
{
    self = [super init];
    if (self) {
        if (posts == nil)
            _postItems = [NSMutableArray array];
        else
            _postItems = [NSMutableArray arrayWithArray:posts];
    }
    return self;
}

- (void)readFromJSONArray:(NSArray *)array
{
    for (NSDictionary *dic in array) {
//        Post *p = [[Post alloc] init];
        Post *p = [[ItemStore sharedItemStore] createPost];
        [p readFromJSONDictionary:dic];
        [_postItems addObject:p];
    }
}

- (void)addPostItems:(NSArray *)objects
{
    [_postItems addObjectsFromArray:objects];
}

@end

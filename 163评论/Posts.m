//
//  Posts.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Posts.h"
#import "Post.h"

@implementation Posts

- (id)init
{
    self = [super init];
    if (self) {
        _postItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)readFromJSONArray:(NSArray *)array
{
    for (NSDictionary *dic in array) {
        Post *p = [[Post alloc] init];
        [p readFromJSONDictionary:dic];
        [_postItems addObject:p];
    }
}

@end

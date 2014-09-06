//
//  RandomPosts.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "RandomPosts.h"
#import "RandomPost.h"

@implementation RandomPosts

- (id)init
{
    self = [super init];
    if (self) {
        _randomPosts = [NSMutableArray array];
    }
    
    return self;
}
- (void)readFromJSONArray:(NSArray *)array
{
    for (NSDictionary *dic in array) {
        RandomPost *post = [[RandomPost alloc] init];
        post.title = [dic objectForKey:@"title"];
        post.postURL = [dic objectForKey:@"url"];
        [_randomPosts addObject:post];
    }
}
@end

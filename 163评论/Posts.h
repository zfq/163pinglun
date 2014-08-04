//
//  Posts.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface Posts : NSObject <JSONSerializable>

@property (nonatomic,readonly,strong) NSMutableArray *postItems;

- (instancetype)initWithPosts:(NSArray *)posts;
- (void)addPostItems:(NSArray *)objects;
@end

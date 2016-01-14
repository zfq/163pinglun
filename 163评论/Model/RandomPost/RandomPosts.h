//
//  RandomPosts.h
//  163评论
//
//  Created by zhaofuqiang on 14-9-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RandomPosts : NSObject <JSONSerializable>

@property (nonatomic,readonly,strong) NSMutableArray *randomPosts;

@end

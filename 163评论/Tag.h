//
//  Tag.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface Tag : NSObject <JSONSerializable>

@property (nonatomic) NSInteger ID;
@property (nonatomic,strong) NSString *tagName; //标签名
@property (nonatomic,strong) NSString *slug;    //别名
@property (nonatomic) NSInteger count;      //帖子数量


@end

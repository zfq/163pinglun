//
//  Tag.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"
#import "DBSerializable.h"

@interface Tag : NSObject <JSONSerializable,DBSerializable>

@property (nonatomic,assign) NSInteger index;  //序号
@property (nonatomic,copy) NSString * tagID;   //标签ID
@property (nonatomic,copy) NSString * tagName; //标签名
@property (nonatomic,copy) NSString * tagSlug; //别名
@property (nonatomic,assign) NSInteger count;  //该标签所含帖子数量

@end

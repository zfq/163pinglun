//
//  Tag.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONSerializable.h"

@interface Tag : NSManagedObject <JSONSerializable>

@property (nonatomic,retain) NSNumber *index;       //序号
@property (nonatomic, retain) NSNumber * tagID;     //标签ID
@property (nonatomic, retain) NSString * tagName;   //标签名
@property (nonatomic, retain) NSString * tagSlug;   //别名
@property (nonatomic, retain) NSNumber * count;     //该标签所含帖子数量

@end

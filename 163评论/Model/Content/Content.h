//
//  Content.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONSerializable.h"

@class Post;

@interface Content : NSObject <JSONSerializable>

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSNumber *groupID;
@property (nonatomic, strong) NSNumber *floorIndex;
@property (nonatomic, strong) NSNumber *preAllRows;
@property (nonatomic, strong) NSNumber *currRows;

@end

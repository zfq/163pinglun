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

@interface Content : NSManagedObject <JSONSerializable>

@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber *postID;
@property (nonatomic, retain) NSNumber *groupID;
@property (nonatomic, retain) NSNumber *floorIndex;
@property (nonatomic, retain) NSNumber *preAllRows;
@property (nonatomic, retain) NSNumber *currRows;
@end

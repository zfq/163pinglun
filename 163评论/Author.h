//
//  Author.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONSerializable.h"

@class Post;

@interface Author : NSManagedObject <JSONSerializable>

@property (nonatomic, retain) NSString * authorID;      //推荐人ID
@property (nonatomic, retain) NSString * authorName;    //推荐人名字
@property (nonatomic, retain) NSString * authorSlug;    //推荐人别名
@property (nonatomic, retain) NSSet *posts;
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end

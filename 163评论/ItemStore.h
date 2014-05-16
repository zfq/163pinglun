//
//  ItemStore.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tags;
@class Posts;
@class Contents;

@interface ItemStore : NSObject

@property (nonatomic,strong) NSString *cotentsURL;

+ (ItemStore*)sharedTagStore;

- (void)fetchTagsWithCompletion:(void(^)(Tags *tags,NSError *error))block;
- (void)fetchPostsWithCompletion:(void (^)(Posts *posts,NSError *error))block;

- (void)fetchContentsWithCompletion:(void (^)(Contents *contents,NSError *error))block;
@end

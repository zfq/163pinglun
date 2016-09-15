//
//  Post.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@class Author;

@interface Post : NSObject <JSONSerializable>

@property (nonatomic, copy) NSString *postID;  //帖子ID
@property (nonatomic, copy) NSString *tag;     //所属标签
@property (nonatomic, copy) NSString *title;   //帖子名
@property (nonatomic, copy) NSString *excerpt;  //摘要
@property (nonatomic, strong) NSNumber *views;  //浏览量
@property (nonatomic, copy) NSString *date;     //发表时间
@property (nonatomic, strong) Author *inAuthor; //帖子推荐人

@property (nonatomic,copy) NSString *prevPostID; //上一篇帖子ID
@property (nonatomic,copy) NSString *nextPostID; //下一篇帖子ID

@end

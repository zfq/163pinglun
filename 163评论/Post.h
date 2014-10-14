//
//  Post.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONSerializable.h"

@class Author;

@interface Post : NSManagedObject <JSONSerializable>
//@property (nonatomic, retain) NSNumber * orderValue; //顺序
@property (nonatomic, retain) NSNumber * postID;  //帖子ID
@property (nonatomic, retain) NSString * tag;     //所属标签
@property (nonatomic, retain) NSString * title;   //帖子名
@property (nonatomic, retain) NSString * excerpt; //摘要
@property (nonatomic, retain) NSNumber * views;   //浏览量
@property (nonatomic, retain) NSString * date;    //发表时间
@property (nonatomic, retain) Author *inAuthor;   //帖子推荐人

@end

//
//  Post.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-29.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@class Author;
@interface Post : NSObject <JSONSerializable>

@property (nonatomic) NSInteger ID;     //该条帖子的ID
@property (nonatomic,strong) Author *author;    //推荐人
@property (nonatomic) NSInteger views; //浏览量
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *excerpt; //摘要
@property (nonatomic,strong) NSString *tag; //所属标签
@property (nonatomic,strong) NSDate *date;  //发表时间

@end

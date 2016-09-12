//
//  ZFQRequest.h
//  163pinglun
//
//  Created by _ on 16/9/8.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQBaseRequest.h"
#import "Post.h"
#import "Content.h"
/*
@interface Author : NSObject

@property (nonatomic, retain) NSString * authorID;      //推荐人ID
@property (nonatomic, retain) NSString * authorName;    //推荐人名字
@property (nonatomic, retain) NSString * authorSlug;    //推荐人别名
@property (nonatomic, retain) NSSet *posts;

@end

@interface Post : NSObject

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
*/

@interface ZFQPostRequest : ZFQBaseRequest

//辅助参数
@property (nonatomic,assign) NSInteger tagPageIndex;
@property (nonatomic,assign) NSInteger homePageIndex;
@property (nonatomic,assign) BOOL headRefreshing;
@property (nonatomic,copy) NSString *tagName;

//返回结果
@property (nonatomic,copy) NSArray<Post *> *postItems;

@end

@interface ZFQCommentRequest : ZFQBaseRequest

//请求参数
@property (nonatomic,copy) NSString *postID;

//返回结果
@property (nonatomic,copy) NSArray<NSArray *> *contentsItems;

@end

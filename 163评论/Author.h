//
//  Author.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface Author : NSObject <JSONSerializable>

@property (nonatomic) NSInteger authorID;  //ID
@property (nonatomic,strong) NSString *authorName;  //姓名
@property (nonatomic,strong) NSString *authorSlug;  //别名
//@property (nonatomic,strong) UIImage *authorAvatar; //头像

@end

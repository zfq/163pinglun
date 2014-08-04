//
//  Contents.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface Contents : NSObject <JSONSerializable>

@property (nonatomic,strong) NSString *title; //标题
@property (nonatomic,strong) NSString *subhead; //副标题
@property (nonatomic) NSInteger views; //浏览量
@property (nonatomic,readonly,strong) NSMutableArray *contentItems;

- (instancetype)initWithContents:(NSArray *)contents;

@end

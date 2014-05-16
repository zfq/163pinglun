//
//  Content.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"
#import "NSString+Html.h"

@interface Content : NSObject <JSONSerializable>

@property (nonatomic,strong) NSString *user;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *time;

@end

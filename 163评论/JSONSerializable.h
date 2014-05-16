//
//  JSONSerializable.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONSerializable <NSObject>

@optional
- (void)readFromJSONDictionary:(NSDictionary *)dictionary;
- (void)readFromJSONArray:(NSArray *)array;

@end

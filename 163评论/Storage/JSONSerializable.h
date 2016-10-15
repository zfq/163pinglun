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
- (void)readFromJSONDictionary:(NSDictionary *)dictionary apiVersion:(NSString *)apiVersion;

- (void)readFromJSONArray:(NSArray *)array;
- (void)readFromJSONArray:(NSArray *)array apiVersion:(NSString *)apiVersion;

@end

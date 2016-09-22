//
//  Tag.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Tag.h"

@implementation Tag

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    self.tagID = [[dictionary objectForKey:@"id"] description];
    self.tagName = [dictionary objectForKey:@"name"];
    self.tagSlug = [dictionary objectForKey:@"slug"];
    self.count = [[dictionary objectForKey:@"count"] integerValue];
    //index 在Tags中赋值
}

+ (id)instanceFromFMResultSet:(FMResultSet *)set
{
    NSInteger index = [set intForColumnIndex:1];
    NSString *tagID = [set stringForColumnIndex:0];
    NSString *tagName = [set stringForColumnIndex:2];
    NSInteger count = [set intForColumnIndex:4];
    Tag *tag = [[Tag alloc] init];
    tag.index = index;
    tag.tagID = tagID;
    tag.tagName = tagName;
    tag.count = count;
    return tag;
}

@end

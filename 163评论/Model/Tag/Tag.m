//
//  Tag.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Tag.h"


@implementation Tag

@dynamic index;
@dynamic tagID;
@dynamic tagName;
@dynamic tagSlug;
@dynamic count;

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    self.tagID = [dictionary objectForKey:@"id"];
    self.tagName = [dictionary objectForKey:@"name"];
    self.tagSlug = [dictionary objectForKey:@"slug"];
    self.count = [dictionary objectForKey:@"count"];
    //index 在Tags中赋值
}
@end

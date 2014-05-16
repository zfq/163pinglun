//
//  Tag.m
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Tag.h"

@implementation Tag

- (id)init
{
    self = [super init];
    if (self) {
        _ID = 0;
        _tagName = @"";
        _slug = @"";
        _count = 0;
    }
    return self;
}

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    NSNumber *num = [dictionary objectForKey:@"ID"];
    NSNumber *count = [dictionary objectForKey:@"count"];
    self.ID = [num integerValue];
    self.tagName = [dictionary objectForKey:@"name"];
    self.slug = [dictionary objectForKey:@"slug"];
    self.count = [count integerValue];
}

@end

//
//  Author.m
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Author.h"

@implementation Author

- (id)init
{
    self = [super init];
    if (self) {
        _authorID = 0;
        _authorName = @"阿猫阿狗";
        _authorSlug = @"";
//        _authorAvatar = nil;
    }
    return self;
}

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    if ((NSNull*)dictionary == [NSNull null]) {
        return;
    }
    
    NSNumber *num = [dictionary objectForKey:@"ID"];
    _authorID = num.integerValue;
    _authorName = [dictionary objectForKey:@"name"];
    _authorSlug = [dictionary objectForKey:@"slug"];
    //    _authorAvatar = [dictionary objectForKey:@"avatar"];//这是个url
    
}

@end

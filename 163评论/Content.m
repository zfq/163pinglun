//
//  Content.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Content.h"
#import "JSONSerializable.h"

@implementation Content

- (id)init
{
    self = [super init];
    if (self) {
        _user = @"";
        _email = @"";
        _content = @"";
        _time = @"";
    }
    
    return self;
}

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    _user = [dictionary objectForKey:@"f"];
    _user = [NSString flattenHTMLSpace:_user];
    _email = [dictionary objectForKey:@"u"];
    _content = [dictionary objectForKey:@"b"];
    _content = [NSString replaceBr:_content];
    _time = [dictionary objectForKey:@"t"];
}

@end

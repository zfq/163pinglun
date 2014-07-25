//
//  Author.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Author.h"
#import "Post.h"


@implementation Author

@dynamic authorID;
@dynamic authorName;
@dynamic authorSlug;
@dynamic posts;

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    if ((NSNull*)dictionary == [NSNull null]) {
        return;
    }
    NSNumber *ID = [dictionary objectForKey:@"ID"];
    self.authorID = [NSString stringWithFormat:@"%d",[ID integerValue]];
    self.authorName = [dictionary objectForKey:@"name"];
    self.authorSlug = [dictionary objectForKey:@"slug"];
}

@end

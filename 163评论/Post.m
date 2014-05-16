//
//  Post.m
//  163评论
//
//  Created by zhaofuqiang on 14-4-29.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Post.h"
#import "Author.h"

@implementation Post

- (id)init
{
    self = [super init];
    if (self) {
        _ID = 0;
        _author = [[Author alloc] init];
        _title = @"";
        _excerpt = @"";
        _tag = @"未分类";
        _date = [NSDate date];
    }
    return self;
}

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    NSNumber *idNum = [dictionary objectForKey:@"ID"];
    _ID = idNum.integerValue;
    
    NSDictionary *autDic = [dictionary objectForKey:@"author"];
    [_author readFromJSONDictionary:autDic];
    
    _title = [dictionary objectForKey:@"title"];
    
    NSString *tempStr = [dictionary objectForKey:@"excerpt"];
    NSMutableString *string = [NSMutableString stringWithString:tempStr];
    _excerpt = [self getExcerptFromString:string];
    
    NSDictionary *post_metaDic = [dictionary objectForKey:@"post_meta"];
    NSArray *viewsArray= [post_metaDic objectForKey:@"views"];
    NSString *viewsStr = [viewsArray objectAtIndex:0];
    _views = [viewsStr integerValue];
    
    NSDictionary *termsDic = [dictionary objectForKey:@"terms"];
    NSArray *post_tagArray= [termsDic objectForKey:@"post_tag"];
    if (post_tagArray != nil) {
        NSDictionary *post_tagDic = [post_tagArray objectAtIndex:0];
        _tag = [post_tagDic objectForKey:@"name"];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'-'z':'z";
    _date = [formatter dateFromString:[dictionary objectForKey:@"date"]];
}


- (NSString *)getExcerptFromString:(NSMutableString *)string
{
    if ([string isEqualToString:@""]) {
        return @"";
    } else {
        [string deleteCharactersInRange:NSMakeRange(0, 3)];
        [string deleteCharactersInRange:NSMakeRange(string.length-5, 4)];
        NSRange brRange = [string rangeOfString:@"<br />"];
        if (brRange.length > 0) {
            [string deleteCharactersInRange:brRange];
        }
        
        return string;
    }
}
@end






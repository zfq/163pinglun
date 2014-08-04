//
//  Post.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Post.h"
#import "Author.h"
#import "ItemStore.h"
#import "NSString+Html.h"

@implementation Post

@dynamic postID;
@dynamic tag;
@dynamic title;
@dynamic excerpt;
@dynamic views;
@dynamic date;
@dynamic inAuthor;

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    self.postID = [dictionary objectForKey:@"ID"];
    NSDictionary *autDic = [dictionary objectForKey:@"author"]; //这里的self.author是空的
    
    self.inAuthor = [[ItemStore sharedItemStore] createAuthorWithAuthorID:[autDic objectForKey:@"ID"]];   //在这里判断是否有已经存在的author，if 有，就直接赋值，没有就create
    [self.inAuthor readFromJSONDictionary:autDic];

    NSString *tit = [dictionary objectForKey:@"title"];
    self.title = [tit stringByDecodingHTMLEntities];
    
    NSString *tempStr = [dictionary objectForKey:@"excerpt"];
    NSMutableString *string = [NSMutableString stringWithString:tempStr];
    //最后的删掉\n
    [string deleteCharactersInRange:NSMakeRange(0, 3)];
    [string deleteCharactersInRange:NSMakeRange(string.length-5, 4)];
    self.excerpt = [NSString replaceBr:string];

    NSDictionary *post_metaDic = [dictionary objectForKey:@"post_meta"];
    NSString *viewsStr= [[post_metaDic objectForKey:@"views"] objectAtIndex:0];
    self.views = [NSNumber numberWithInteger:[viewsStr integerValue]];
    
    NSDictionary *termsDic = [dictionary objectForKey:@"terms"];
    NSArray *post_tagArray= [termsDic objectForKey:@"post_tag"];
    if (post_tagArray != nil) {
        NSDictionary *post_tagDic = [post_tagArray objectAtIndex:0];
        self.tag = [post_tagDic objectForKey:@"name"];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'-'z':'z";
    self.date = [formatter dateFromString:[dictionary objectForKey:@"date"]];
}




@end

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

#define kPostValidationDomain @"PostValidationDomain"
#define kPostValidationPostOrExceptCode 1001

@implementation Post

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    self.postID = [NSString stringWithFormat:@"%zi",[dictionary[@"id"] integerValue]];
    
//    NSDictionary *autDic = [dictionary objectForKey:@"author"]; //这里的self.author是空的
//    self.inAuthor = [[ItemStore sharedItemStore] createAuthorWithAuthorID:[autDic objectForKey:@"ID"]];   //在这里判断是否有已经存在的author，if 有，就直接赋值，没有就create
//    [self.inAuthor readFromJSONDictionary:autDic];

    //设置标题
    NSString *tit = dictionary[@"title"][@"rendered"]; //[dictionary objectForKey:@"title"];
    self.title = [tit stringByDecodingHTMLEntities];
    
    //设置摘要
    NSString *tempStr = dictionary[@"excerpt"][@"rendered"]; //[dictionary objectForKey:@"excerpt"];
    if (tempStr) {
        NSMutableString *string = [NSMutableString stringWithString:tempStr];
        //最后的删掉\n
        [string deleteCharactersInRange:NSMakeRange(0, 3)];
        [string deleteCharactersInRange:NSMakeRange(string.length-5, 4)];
        NSString *finalExce = [NSString replaceBr:string];
        self.excerpt = [finalExce stringByDecodingHTMLEntities];
    }

    //设置浏览量
    NSArray<NSString *> *viewsStr = dictionary[@"post_meta"][@"views"];
    self.views = [viewsStr[0] integerValue];
    
    NSDictionary *termsDic = dictionary[@"terms"];
    NSArray *post_tagArray= termsDic[@"tages"];
    if (post_tagArray && post_tagArray.count > 0) {
        self.tag = post_tagArray[0];
    }
    
    NSDictionary *nextPostDict = dictionary[@"next_post"];
    if (nextPostDict && [nextPostDict isKindOfClass:[NSDictionary class]]) {
        NSNumber *tempNumObj = nextPostDict[@"ID"];
        if (tempNumObj && [tempNumObj isKindOfClass:[NSNull class]] == NO) {
            self.prevPostID = [NSString stringWithFormat:@"%zi",tempNumObj.integerValue];
        }
    }
    NSDictionary *prevPostDict = dictionary[@"prev_post"];
    if (prevPostDict && [prevPostDict isKindOfClass:[NSDictionary class]]) {
        NSNumber *tempNumObj = prevPostDict[@"ID"];
        if (tempNumObj && [tempNumObj isKindOfClass:[NSNull class]] == NO) {
            self.nextPostID = [NSString stringWithFormat:@"%zi",tempNumObj.integerValue];
        }
    }
    
    NSString *originDateStr = [dictionary objectForKey:@"modified"];
    NSString *firstStr = [originDateStr substringWithRange:NSMakeRange(0, 18)];
    NSString *finalStr = [firstStr stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@" "];
    
    self.date =  [NSString stringWithFormat:@"最后更新于%@ by %@",[self postTimeFromTime:finalStr],self.inAuthor.authorName];
}

///老版本的接口
- (void)readFromJSONDictionary1:(NSDictionary *)dictionary
{
    self.postID = [dictionary objectForKey:@"ID"];
    NSDictionary *autDic = [dictionary objectForKey:@"author"]; //这里的self.author是空的
    
//    self.inAuthor = [[ItemStore sharedItemStore] createAuthorWithAuthorID:[autDic objectForKey:@"ID"]];   //在这里判断是否有已经存在的author，if 有，就直接赋值，没有就create
    [self.inAuthor readFromJSONDictionary:autDic];
    
    NSString *tit = [dictionary objectForKey:@"title"];
    self.title = [tit stringByDecodingHTMLEntities];
    
    NSString *tempStr = [dictionary objectForKey:@"excerpt"];
    if (tempStr) {
        NSMutableString *string = [NSMutableString stringWithString:tempStr];
        //最后的删掉\n
        [string deleteCharactersInRange:NSMakeRange(0, 3)];
        [string deleteCharactersInRange:NSMakeRange(string.length-5, 4)];
        NSString *finalExce = [NSString replaceBr:string];
        self.excerpt = [finalExce stringByDecodingHTMLEntities];
    }
    
    NSDictionary *post_metaDic = [dictionary objectForKey:@"post_meta"];
    NSString *viewsStr= [[post_metaDic objectForKey:@"views"] objectAtIndex:0];
    self.views = [viewsStr integerValue];
    
    NSDictionary *termsDic = [dictionary objectForKey:@"terms"];
    NSArray *post_tagArray= termsDic[@"tages"];
    if (post_tagArray && post_tagArray.count > 0) {
        NSDictionary *post_tagDic = [post_tagArray objectAtIndex:0];
        self.tag = [post_tagDic objectForKey:@"name"];
    }
    
    NSString *originDateStr = [dictionary objectForKey:@"modified"];
    NSString *firstStr = [originDateStr substringWithRange:NSMakeRange(0, 18)];
    NSString *finalStr = [firstStr stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@" "];
    
    self.date =  [NSString stringWithFormat:@"最后更新于%@ by %@",[self postTimeFromTime:finalStr],self.inAuthor.authorName];
}

- (NSString *)postTimeFromTime:(NSString *)time
{
    NSString *postTime = nil;
    NSDate *currDate = [NSDate date];
    
    //-------------将time转换为NSDate----------
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:time];
    
    NSTimeInterval interval = [currDate timeIntervalSinceDate:date];
    
    NSInteger oneDay = 24 * 60 * 60;
    NSInteger oneHour = 60 * 60;
    NSInteger oneMinute = 60;
    if (interval < 2*oneDay)
    {
        if (interval < oneDay)
        {
            if (interval < oneHour)
            {
                if (interval < oneMinute)
                    postTime = @"刚刚";
                else
                {
                    postTime = [NSString stringWithFormat:@"%ld分钟前",(long)(interval/oneMinute)];
                }
            }
            else
            {
                formatter.dateFormat = @"HH:mm";
                NSString *todayDateStr = [formatter stringFromDate:date];
                postTime = [NSString stringWithFormat:@"今天 %@",todayDateStr];
            }
        }
        else
        {
            formatter.dateFormat = @"HH:mm";
            NSString *oldDateStr = [formatter stringFromDate:date];
            postTime = [NSString stringWithFormat:@"昨天 %@",oldDateStr];;
        }
    }
    else
    {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *dateStr = [formatter stringFromDate:date];
        postTime = dateStr;
    }
    
    return postTime;
}

- (BOOL)validateTitleOrExpert:(NSError **)outError
{
    if ((self.title.length ==0) && (self.excerpt.length == 0)) {
        if (outError != NULL) {
            NSString *errorStr = NSLocalizedString(@"标题和摘要不能为空", @"标题和摘要不能为空");
            NSDictionary *userInfoDic = @{NSLocalizedDescriptionKey:errorStr};
            NSError *error = [[NSError alloc] initWithDomain:kPostValidationDomain code:kPostValidationPostOrExceptCode userInfo:userInfoDic];
            *outError = error;
        }
        return NO;
    } else {
        return YES;
    }
}

+ (id)instanceFromFMResultSet:(FMResultSet *)set
{
    NSString *pId= [set stringForColumnIndex:0];
    NSString *nId= [set stringForColumnIndex:1];
    NSString *preId= [set stringForColumnIndex:2];
    NSString *date= [set stringForColumnIndex:3];
    NSString *excerpt= [set stringForColumnIndex:4];
    NSString *tag= [set stringForColumnIndex:5];
    NSString *title= [set stringForColumnIndex:6];
    NSInteger views = [set intForColumnIndex:7];
    
    Post *p = [[Post alloc] init];
    
    p.postID = pId;
    p.nextPostID = nId;
    p.prevPostID = preId;
    p.date = date;
    p.excerpt = excerpt;
    p.tag = tag;
    p.title = title;
    p.views = views;
    
    return p;
}

@end

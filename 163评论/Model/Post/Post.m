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
    NSString *finalExce = [NSString replaceBr:string];
    self.excerpt = [finalExce stringByDecodingHTMLEntities];

    NSDictionary *post_metaDic = [dictionary objectForKey:@"post_meta"];
    NSString *viewsStr= [[post_metaDic objectForKey:@"views"] objectAtIndex:0];
    self.views = [NSNumber numberWithInteger:[viewsStr integerValue]];
    
    NSDictionary *termsDic = [dictionary objectForKey:@"terms"];
    NSArray *post_tagArray= [termsDic objectForKey:@"post_tag"];
    if (post_tagArray != nil) {
        NSDictionary *post_tagDic = [post_tagArray objectAtIndex:0];
        self.tag = [post_tagDic objectForKey:@"name"];
    }
    
    NSString *originDateStr = [dictionary objectForKey:@"date"];
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

- (BOOL)validateForInsert:(NSError *__autoreleasing *)error
{
    BOOL result = [super validateForInsert:error];
    if (result) {
         return [self validateTitleOrExpert:error];
    } else {
        return result;
    }
}

@end

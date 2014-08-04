//
//  Content.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-21.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Content.h"
#import "ItemStore.h"
#import "NSString+Html.h"

@implementation Content

@dynamic user;
@dynamic email;
@dynamic content;
@dynamic time;
@dynamic postID;

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    self.user = [[dictionary objectForKey:@"f"] stringByConvertingHTMLToPlainText];
    self.email = [dictionary objectForKey:@"u"];
    self.content = [NSString replaceBr:[dictionary objectForKey:@"b"]];
    self.time = [self postTimeFromTime:[dictionary objectForKey:@"t"]];
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

@end

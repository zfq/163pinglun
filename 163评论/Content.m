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
//    _time = [dictionary objectForKey:@"t"];
    _time = [self postTimeFromTime:[dictionary objectForKey:@"t"]];
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
                    postTime = [NSString stringWithFormat:@"%d分钟前",(NSInteger)(interval/oneMinute)];
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
            postTime = @"昨天";
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







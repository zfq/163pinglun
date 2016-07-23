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
@dynamic groupID;
@dynamic floorIndex;
@dynamic preAllRows;
@dynamic currRows;

- (void)readFromJSONDictionary:(NSDictionary *)dictionary
{
    self.user = [[dictionary objectForKey:@"f"] stringByConvertingHTMLToPlainText];
    self.email = [dictionary objectForKey:@"u"];
    self.content = [NSString replaceBr:[dictionary objectForKey:@"b"]];
    self.time = [self postTimeFromTime:[dictionary objectForKey:@"t"]];
    //postID和contentID floorIndex在contents中初始化
}

- (void)readFromJSONDictionary:(NSDictionary *)dictionary apiVersion:(NSString *)apiVersion
{
    NSDictionary *userDic = dictionary[@"user"];
    NSString *user = userDic[@"nickname"];
    if ((userDic == nil) || [user isKindOfClass:[NSNull class]] || user.length == 0) {
        NSString *sn = dictionary[@"siteName"];
        NSString *loc = userDic[@"location"];
        NSString *u = nil;
        if (sn.length > 0) {
            u = sn;
            if (loc.length > 0) {
                u = [sn stringByAppendingFormat:@"%@网友",loc];
            }
        }
        self.user = u;
    } else {
        self.user = user;
    }
    self.email = @"";
    self.content = [NSString replaceBr:dictionary[@"content"]];
    self.time = [self postTimeFromTime:[dictionary objectForKey:@"createTime"]];
}

- (NSString *)postTimeFromTime:(NSString *)time
{
    if (!time || [time isKindOfClass:[NSNull class]]) {
        return @"昨天";
    }
    NSString *postTime = nil;
    NSDate *currDate = [NSDate date];
    
    //-------------将time转换为NSDate----------
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:time];
    
    static NSCalendar *calendar = nil;
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *currDateComps = [calendar components:unitFlags fromDate:currDate];
    NSInteger currYear=[currDateComps year];
    NSInteger currMonth = [currDateComps month];
    NSInteger currDay = [currDateComps day];
    
    NSDateComponents *sDateComps = [calendar components:unitFlags fromDate:date];
    NSInteger sYear=[sDateComps year];
    NSInteger sMonth = [sDateComps month];
    NSInteger sDay = [sDateComps day];
    
    if ((currYear != sYear) || (currMonth != sMonth)) {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *dateStr = [formatter stringFromDate:date];
        postTime = dateStr;
    } else {
        NSTimeInterval interval = [currDate timeIntervalSinceDate:date];
        
        NSInteger oneHour = 3600;   //60 * 60
        NSInteger oneMinute = 60;
        
        if (currDay == sDay) {
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
        } else {
            if (currDay == sDay+1) {
                formatter.dateFormat = @"HH:mm";
                NSString *oldDateStr = [formatter stringFromDate:date];
                postTime = [NSString stringWithFormat:@"昨天 %@",oldDateStr];
            } else {
                postTime = time;
            }
            
        }
    }
    
    return postTime;
}

@end

//
//  TagStoreTest.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ItemStore.h"
#import "Tags.h"
#import "Tag.h"
@interface TagStoreTest : XCTestCase

@end

@implementation TagStoreTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
   // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
   /*
//    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //  [dateFormat setTimeZone:[NSTimeZone systemTimeZone]]; //systemTimeZone
//    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];//[NSTimeZone timeZoneForSecondsFromGMT:0]
    //   [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'-'zz':'zz"]; //@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'-'zz':'zz"
    //   [dateFormat setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
//    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    
    NSDate *date = [dateFormat dateFromString:@"2010-09-09T13:14:56-08:00"]; //表示的是北京-8即
    NSString *r =[date debugDescription];
    NSLog(@"%@",r);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600*8]];
    formatter.dateFormat =  @"yyyy-MM-dd hh:mm:ss zzz";
    NSLog(@"时间为：%@",[formatter stringFromDate:date]);
    */
    [[ItemStore sharedTagStore] fetchTagsWithCompletion:^(Tags *tags, NSError *error) {
        if (error) {
            NSLog(@"请求出错");
        } else {
            NSArray *a = tags.tagItems;
            for (Tag *t in a) {
                NSLog(@"%@",t.tagName);
            }
            NSLog(@"%@",tags.tagItems);
        }
    }];
}

@end

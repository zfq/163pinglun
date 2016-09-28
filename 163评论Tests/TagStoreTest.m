//
//  TagStoreTest.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "ItemStore.h"
//#import "Tags.h"
//#import "Tag.h"
#import "NSString+Addition.h"

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

- (void)test1
{
    [NSString SinglLineTextSizeWithAttrStr:nil preferWidth:200];
}

- (void)testExample
{
   // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
  
    //-------------获取日期----------
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:@"2013-5-16 15:46:23"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    
    comps = [calendar components:unitFlags fromDate:date];
    int year=[comps year];
    int week = [comps weekday];
    int month = [comps month];
    int day = [comps day];
    int hour = [comps hour];
    int min = [comps minute];
    int sec = [comps second];
    NSLog(@"111111");
    ZFQLog(@"%d-%d-%d %d:%d:%d",year,month,day,hour,min,sec);
    
}

- (void)test222
{
    NSString *str1 = @"地瓜地瓜，我是土豆\n";
    
//    [str1 string]
}

@end

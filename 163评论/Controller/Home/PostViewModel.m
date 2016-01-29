//
//  PostViewModel.m
//  163pinglun
//
//  Created by _ on 16/1/29.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "PostViewModel.h"
#import "MacroDefinition.h"

@interface PostViewModel()
{
    NSInteger _currPageIndex;
    NSInteger _homePageIndex;
}
@end

@implementation PostViewModel

#pragma mark - getter setter方法
- (NSInteger)homePageIndex
{
    NSNumber *currPage = [[NSUserDefaults standardUserDefaults] objectForKey:CURR_HOME_PAGE];
    //如果不存在就创建
    if (currPage == nil || currPage.integerValue == 0) {
        currPage = [NSNumber numberWithInteger:1];
        [[NSUserDefaults standardUserDefaults] setObject:currPage forKey:CURR_HOME_PAGE];
    }
    _homePageIndex = [currPage integerValue];
    return _homePageIndex;
}

- (void)setHomePageIndex:(NSInteger)homePageIndex
{
    NSNumber *currPage = [NSNumber numberWithInteger:homePageIndex];
    [[NSUserDefaults standardUserDefaults] setObject:currPage forKey:CURR_HOME_PAGE];
    _homePageIndex = homePageIndex;
}

- (NSString *)postUrlWithTagName:(NSString *)tagName headRefreshing:(BOOL)headRefreshing
{
    NSString *urlStr;
    if (tagName != nil) {
        if (headRefreshing)
            _currPageIndex = 1;
        else
            _currPageIndex ++;
        urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&filter[tag]=%@&page=%zi",tagName,_currPageIndex];
    } else {
        if (headRefreshing) {
            urlStr = @"http://163pinglun.com/wp-json/posts";
        } else {
            //设置当前页数
            self.homePageIndex += 1;
            urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&page=%zi",self.homePageIndex];
        }
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return urlStr;

}
@end

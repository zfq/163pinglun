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
@synthesize tagName = _tagName;

#pragma mark - getter setter方法

- (NSString *)tagName
{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"tagName"];
    if (name == nil || [name isEqualToString:@""]) {
        return nil;
    } else {
        return name;
    }
}

- (void)setTagName:(NSString *)tagName
{
    if (tagName == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tagName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults]  setObject:tagName forKey:@"tagName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _tagName = tagName;
}

- (NSInteger)homePageIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *currPage = [userDefaults objectForKey:CURR_HOME_PAGE];
    //如果不存在就创建
    if (currPage == nil || currPage.integerValue == 0) {
        currPage = [NSNumber numberWithInteger:1];
        [userDefaults setObject:currPage forKey:CURR_HOME_PAGE];
        [userDefaults synchronize];
    }
    _homePageIndex = [currPage integerValue];
    return _homePageIndex;
}

- (void)setHomePageIndex:(NSInteger)homePageIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSNumber *currPage = [NSNumber numberWithInteger:homePageIndex];
    [userDefaults setObject:currPage forKey:CURR_HOME_PAGE];
    [userDefaults synchronize];
    
    _homePageIndex = homePageIndex;
}

- (NSString *)postUrlWithHeadRefreshing:(BOOL)headRefreshing
{
    NSString *urlStr;
    if (self.tagName != nil) {
        if (headRefreshing)
            _currPageIndex = 1;
        else
            _currPageIndex ++;
        /*
        urlStr = [NSString stringWithFormat:@"%@/index.php?json_route=/posts&filter[tag]=%@&page=%zi",HOSTURL,self.tagName,_currPageIndex];
         */
        urlStr = [NSString stringWithFormat:@"%@/wp-json/wp/v2/posts?filter[tag]=%@&page=%zi",HOSTURL,self.tagName,_currPageIndex];
    } else {
        if (headRefreshing) {
            urlStr = [NSString stringWithFormat:@"%@/wp-json/wp/v2/posts",HOSTURL]; //  @"http://163pinglun.com/wp-json/posts";
            if (self.latestPostRefreshBlk) {
                self.latestPostRefreshBlk();
            }
        } else {
            //设置当前页数
            self.homePageIndex += 1;
            urlStr = [NSString stringWithFormat:@"%@/wp-json/wp/v2?page=%zi",HOSTURL,self.homePageIndex];
        }
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ZFQLog(@"%@",urlStr);
    return urlStr;

}
@end

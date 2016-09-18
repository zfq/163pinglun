//
//  PostViewModel.m
//  163pinglun
//
//  Created by _ on 16/1/29.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "HomeViewModel.h"
#import "MacroDefinition.h"
#import "ItemStore.h"

@interface HomeViewModel()
{
    NSInteger _tagPageIndex;
    NSInteger _homePageIndex;
}
@end

@implementation HomeViewModel
@synthesize tagName = _tagName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _homePageIndex = 1;
    }
    return self;
}
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
        [[NSUserDefaults standardUserDefaults] setObject:tagName forKey:@"tagName"];
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

- (NSMutableArray<Post *> *)postItems
{
    if (!_postItems) {
        _postItems = [[NSMutableArray alloc] init];
    }
    return _postItems;
}

- (NSString *)postUrlWithHeadRefreshing:(BOOL)headRefreshing
{
    NSString *urlStr;
    if (self.tagName != nil) {
        if (headRefreshing)
            _tagPageIndex = 1;
        else
            _tagPageIndex ++;
        urlStr = [NSString stringWithFormat:@"%@/wp-json/wp/v2/posts?filter[tag]=%@&page=%zi",HOSTURL,self.tagName,_tagPageIndex];
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
    return urlStr;
}

- (void)settingPageIndex
{
    if (_tagName != nil) {
        if (_headRefreshing)
            _tagPageIndex = 1;
        else
            _tagPageIndex ++;
    } else {
        if (_headRefreshing) {
            
        } else {
            //设置当前页数
            _homePageIndex += 1;
        }
    }
}

- (void)fetchPostsWithCompletion:(void (^)(NSArray<Post *> *postItems,NSError *error))completionBlk
{
    [self settingPageIndex];
    
    ZFQPostRequest *postReq = [[ZFQPostRequest alloc] init];
    postReq.headRefreshing = self.headRefreshing;
    postReq.tagName = self.tagName;
    postReq.tagPageIndex = _tagPageIndex;
    postReq.homePageIndex = _homePageIndex;
    
    [[ZFQRequestObj sharedInstance] sendRequest:postReq successBlk:^(ZFQBaseRequest *request, id responseObject) {
        ZFQPostRequest *req = (ZFQPostRequest *)request;
        
        if (req.headRefreshing == YES) {
//            if (!self.postItems) {
//                self.postItems = [[NSMutableArray alloc] initWithArray:req.postItems];
//            }
        }
        
        if (!_postItems) {
            _postItems = [[NSMutableArray alloc] init];
        }
        //保存数据
        [ItemStore savePost:req.postItems originAllPosts:self.postItems];
        
        if (self.homePageIndex == 1) {
            [self.postItems removeAllObjects];
        }
        
        //从数据库读出第homePageIndex页的10条 即筛选 从第homePageIndex * 10 到 （homePageIndex + 1） * 10行的数据
        NSArray *dbPosts = [ItemStore readPostsFromIndex:((self.homePageIndex - 1) * 10) toIndex:(self.homePageIndex * 10)];
        [self.postItems addObjectsFromArray:dbPosts];
        
        if (completionBlk) {
            completionBlk(self.postItems,nil);
        }
    } failureBlk:^(ZFQBaseRequest *request, NSError *error) {
        if (completionBlk) {
            completionBlk(nil,error);
        }
    }];
}

@end

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
#import "ZFQURLOperationManager.h"

@interface HomeViewModel()
{
    NSInteger _tagPageIndex;
    NSInteger _homePageIndex;
    NSString *_tagName;
}
@end

@implementation HomeViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
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

- (void)settingPageIndex
{
    if (_tagName != nil) {
        if (_headRefreshing)
            _tagPageIndex = 1;
        else
            _tagPageIndex ++;
    } else {
        if (_headRefreshing) {
            self.homePageIndex = 1;
        } else {
            //设置当前页数
            self.homePageIndex += 1;
        }
    }
}

- (void)fetchPostsWithCompletion:(void (^)(NSArray<Post *> *postItems,NSArray<Post *> *increasedPostItems,NSError *error))completionBlk
{
    //设置当前页数
    [self settingPageIndex];
    
    ZFQPostRequest *postReq = [[ZFQPostRequest alloc] init];
    postReq.headRefreshing = self.headRefreshing;
    postReq.tagName = self.tagName;
    postReq.tagPageIndex = _tagPageIndex;
    postReq.homePageIndex = _homePageIndex;
    
    [[ZFQRequestObj sharedInstance] sendRequest:postReq successBlk:^(ZFQBaseRequest *request, id responseObject) {
        ZFQPostRequest *req = (ZFQPostRequest *)request;
        
        //保存数据,更新旧的，保存新增的
        [ItemStore savePost:req.postItems originAllPosts:self.postItems];
        
        NSArray *increasedItems = nil;
        //如果是下拉刷新就删除内存中所有的postItem
        if (self.tagName == nil) {
            NSArray *dbPosts = nil;
            if (self.homePageIndex == 1) {
                [self.postItems removeAllObjects];
                //从数据库中读出所有的post
                dbPosts = [ItemStore readPostsFromIndex:0 toIndex:0];
            } else {
                //从数据库读出第homePageIndex页的10条 即筛选 从第homePageIndex * 10 到 （homePageIndex + 1） * 10行的数据
                dbPosts = [ItemStore readPostsFromIndex:((self.homePageIndex - 1) * 10) toIndex:(self.homePageIndex * 10)];
            }
            
            //建立前后链接关系，用于加载上一篇和下一篇
            [self linkItemInArray:dbPosts];
            if (self.postItems.count > 0 && dbPosts.count > 0) {
                self.postItems.lastObject.nextPostID = [(Post *)dbPosts[0] postID];
                [(Post *)dbPosts[0] setPrevPostID:self.postItems.lastObject.postID];
            }
            
            [self.postItems addObjectsFromArray:dbPosts];
            increasedItems = dbPosts;
        } else {
            if (self.tagPageIndex == 1) {
                [self.postItems removeAllObjects];
            }
            
            //建立前后链接关系，用于加载上一篇和下一篇
            [self linkItemInArray:req.postItems];
            NSArray *tmpArray = req.postItems;
            if (self.postItems.count > 0 && tmpArray.count > 0) {
                self.postItems.lastObject.nextPostID = [(Post *)tmpArray[0] postID];
                [(Post *)tmpArray[0] setPrevPostID:self.postItems.lastObject.postID];
            }
            [self.postItems addObjectsFromArray:req.postItems];
            increasedItems = req.postItems;
        }
        
        if (completionBlk) {
            completionBlk(self.postItems,increasedItems,nil);
        }
        
        //尝试离线下载所有的跟帖
        [self downloadAllPosts];
    } failureBlk:^(ZFQBaseRequest *request, NSError *error) {
        if (completionBlk) {
            completionBlk(nil,nil,error);
        }
    }];
}

//设置prePostID和nextPostID
- (void)linkItemInArray:(NSArray *)items
{
    for (NSInteger i = 0; i < items.count; i++) {
        Post *p = items[i];
        if (i >= 0 && i <= items.count - 1) {
            if (i != 0)
                p.prevPostID = [(Post *)items[i-1] postID];
            if (i != (items.count - 1))
                p.nextPostID = [(Post *)items[i+1] postID];
        }
    }
}

/**
 *  离线下载所有的帖子
 */
- (void)downloadAllPosts
{
    //只下载数据库中不存在的comment
    NSArray *postIDs = [ItemStore allExistComment];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger i = 0,j = 0;
    NSInteger count = _postItems.count;
    NSString *str1,*str2;
    while (i < count) {
        str1 = _postItems[i].postID;
        if (j < postIDs.count) {
            str2 = postIDs[j];
        } else {
            //添加
            [array addObject:(_postItems[i].postID)];
            i++;
        }
        
        NSComparisonResult result = [str1 compare:str2];
        if (result == NSOrderedAscending) {  //str1 < str2
            j++;
        } else if (result == NSOrderedSame) {
            i++;
            j++;
        } else {
            //添加
            [array addObject:(_postItems[i].postID)];
            i++;
        }
    }
    
    if (array.count == 0) {
        ZFQLog(@"已全部下载");
        return;
    }
    
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *postID in array) {
        
        ZFQCommentRequest *postReq = [[ZFQCommentRequest alloc] init];
        postReq.postID = postID;
        
        NSString *url = [NSString stringWithFormat:@"%@/%@",HOSTURL,[postReq pathURL]];
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        ZFQURLConnectionOperation *operation = [[ZFQURLConnectionOperation alloc] initWithRequest:req successBlk:^(ZFQURLConnectionOperation *tmpOperation, NSData *data) {
            
            //解析数据
            NSString *postId = tmpOperation.userInfo[@"postId"];
            //保存Comment
            [ItemStore insertOrReplaceComments:data postID:postId];
            
            ZFQLog(@"完成:%@",postId);
        } failureBlk:^(ZFQURLConnectionOperation *operation, NSError *error) {
            
        }];
        operation.userInfo = @{@"postId":postID};
        [operations addObject:operation];
    }
    
    [ZFQURLOperationManager startBatchOfOperations:operations progressBlk:^(NSInteger numberOfFinishedOperations, NSInteger numberOfOperations) {
        CGFloat progress = numberOfFinishedOperations/(float)numberOfOperations;
        ZFQLog(@"已完成%f",progress);
        if (self.downloadProgressBlk) {
            self.downloadProgressBlk(progress);
        }
    } completionBlk:^{
        ZFQLog(@"全部完成");
        if (self.downloadProgressBlk) {
            self.downloadProgressBlk(1);
        }
    }];
}

@end

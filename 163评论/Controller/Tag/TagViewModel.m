//
//  TagViewModel.m
//  163pinglun
//
//  Created by _ on 16/9/20.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "TagViewModel.h"
#import "ZFQRequest.h"
#import "ItemStore.h"

#define CheckTagInterval 4  //每过4天后同步一次tag

@implementation TagViewModel

- (void)fetchTagsWithCompletion:(void (^)(NSArray<Tag *> *tags,NSError *error))completionBlk
{
    //每隔4天同步一次tag
    if (![self showSynchronizeTag]) {
        [self saveTagTime];
        NSArray<Tag *> *tags = [ItemStore readTagsFromDB];
        if (completionBlk) {
            completionBlk(tags,nil);
        }
        return;
    }
    
    //从网络拉取
    PLTagRequest *req = [[PLTagRequest alloc] init];
    [[ZFQRequestObj sharedInstance] sendRequest:req successBlk:^(ZFQBaseRequest *request, id responseObject) {
        [self saveTagTime];
        
        PLTagRequest *tempReq = (PLTagRequest *)request;
        [ItemStore saveTags:tempReq.tags];
        if (completionBlk) {
            completionBlk(tempReq.tags,nil);
        }
    } failureBlk:^(ZFQBaseRequest *request, NSError *error) {
        if (completionBlk) {
            completionBlk(nil,error);
        }
    }];
}

- (BOOL)showSynchronizeTag
{
    NSString *key = @"lastTagTime";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *time = [userDefaults objectForKey:key];
    if (time == nil || [time isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:time];
    return (interval < CheckTagInterval * 24 * 3600) ? NO : YES;
}

- (void)saveTagTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastTagTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

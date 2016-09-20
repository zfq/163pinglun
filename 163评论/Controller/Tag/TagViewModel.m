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

@implementation TagViewModel

- (void)fetchTagsWithCompletion:(void (^)(NSArray<Tag *> *tags,NSError *error))completionBlk
{
    PLTagRequest *req = [[PLTagRequest alloc] init];
    [[ZFQRequestObj sharedInstance] sendRequest:req successBlk:^(ZFQBaseRequest *request, id responseObject) {
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

@end

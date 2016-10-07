//
//  RandomPostViewModel.m
//  163pinglun
//
//  Created by _ on 16/10/7.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "RandomPostViewModel.h"
@interface RandomPostViewModel()
@property (nonatomic,copy,readwrite) NSArray<RandomPost *> *randomPosts;
@end
@implementation RandomPostViewModel

- (void)fetchRandomPostWithCompletion:(void (^)(NSArray<RandomPost *> *randomPosts,NSError *error))completionBlk
{
    PLRandomPostRequest *req = [[PLRandomPostRequest alloc] init];
    [[ZFQRequestObj sharedInstance] sendRequest:req successBlk:^(ZFQBaseRequest *request, id responseObject) {
        PLRandomPostRequest *tmpReq = (PLRandomPostRequest *)request;
        self.randomPosts = tmpReq.randomPosts;
        if (completionBlk) {
            completionBlk(tmpReq.randomPosts, nil);
        }
    } failureBlk:^(ZFQBaseRequest *request, NSError *error) {
        if (completionBlk) {
            completionBlk(nil,error);
        }
    }];
}

@end

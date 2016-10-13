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
@property (nonatomic,copy,readwrite) NSArray<Post *> *posts;

@end

@implementation RandomPostViewModel

- (void)fetchRandomPostWithCompletion:(void (^)(NSArray<RandomPost *> *randomPosts,NSError *error))completionBlk
{
    PLRandomPostRequest *req = [[PLRandomPostRequest alloc] init];
    [[ZFQRequestObj sharedInstance] sendRequest:req successBlk:^(ZFQBaseRequest *request, id responseObject) {
        PLRandomPostRequest *tmpReq = (PLRandomPostRequest *)request;
        self.randomPosts = tmpReq.randomPosts;
        self.posts = [self createPostWithRandomPosts:tmpReq.randomPosts];
        if (completionBlk) {
            completionBlk(tmpReq.randomPosts, nil);
        }
    } failureBlk:^(ZFQBaseRequest *request, NSError *error) {
        if (completionBlk) {
            completionBlk(nil,error);
        }
    }];
}

- (NSArray<Post *> *)createPostWithRandomPosts:(NSArray<RandomPost *> *)randomPosts
{
    NSMutableArray *posts = [[NSMutableArray alloc] initWithCapacity:randomPosts.count];
    
    for (NSInteger i = 0; i < randomPosts.count; i++) {
        RandomPost *randomP = randomPosts[i];
        Post *p = [[Post alloc] init];
        p.title = randomP.title;
        p.postID = randomP.postID;
        
        if (i >= 0 && i <= randomPosts.count - 1) {
            if (i != 0)
                p.prevPostID = randomPosts[i-1].postID;
            if (i != (randomPosts.count - 1))
                p.nextPostID = randomPosts[i+1].postID;
        }
        
        [posts addObject:p];
    }
    
    return posts;
}

@end

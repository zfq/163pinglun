//
//  CommViewModel.m
//  163pinglun
//
//  Created by _ on 16/9/12.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "CommViewModel.h"
#import "ZFQRequest.h"

@interface CommViewModel()
@property (nonatomic,copy,readwrite) NSArray<NSArray *> *contentItems;
@end

@implementation CommViewModel

- (void)fetchCommentsWithPostID:(NSString *)postID completion:(void (^)(NSArray<NSArray *> *contents,NSError *error))completionBlk
{
    ZFQCommentRequest *commentReq = [[ZFQCommentRequest alloc] init];
    commentReq.postID = postID;
    
    [[ZFQRequestObj sharedInstance] sendRequest:commentReq successBlk:^(ZFQBaseRequest *request, id responseObject) {
        ZFQCommentRequest *req = (ZFQCommentRequest *)request;
        self.contentItems = req.contentsItems;
        if (completionBlk) {
            completionBlk(self.contentItems,nil);
        }
    } failureBlk:^(ZFQBaseRequest *request, NSError *error) {
        if (completionBlk) {
            completionBlk(nil,error);
        }
    }];
}
@end

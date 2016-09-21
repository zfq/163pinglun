//
//  CommViewModel.m
//  163pinglun
//
//  Created by _ on 16/9/12.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "CommViewModel.h"
#import "ZFQRequest.h"
#import "ItemStore.h"

@interface CommViewModel()
@property (nonatomic,copy,readwrite) NSArray<NSArray *> *contentItems;
@end

@implementation CommViewModel

- (void)fetchCommentsWithPostID:(NSString *)postID completion:(void (^)(NSArray<NSArray *> *contents,NSError *error))completionBlk
{
    ZFQCommentRequest *commentReq = [[ZFQCommentRequest alloc] init];
    commentReq.postID = postID;
    
    //先从数据库中读取,数据库中不存在的话再从网络中加载
    NSString *jsonStr = [ItemStore readCommentsFromDBWithPostID:postID];
    if (jsonStr.length > 0) {
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        [commentReq response:jsonData];
        //回调
        self.contentItems = commentReq.contentsItems;
        if (commentReq.contentsItems.count > 0) {
            if (completionBlk) {
                completionBlk(commentReq.contentsItems,nil);
            }
            return;
        }
    }

    //数据不存在，从网络拉取
    [[ZFQRequestObj sharedInstance] sendRequest:commentReq successBlk:^(ZFQBaseRequest *request, id responseObject) {
        
        //保存jsonStr到数据库中
        NSString *jsonStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [ItemStore saveComments:jsonStr postID:postID];
        
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

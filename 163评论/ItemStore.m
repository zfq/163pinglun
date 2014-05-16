//
//  ItemStore.m
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "ItemStore.h"
#import "FQConnection.h"
#import "Tags.h"
#import "Posts.h"
#import "Contents.h"

@implementation ItemStore

+ (ItemStore*)sharedTagStore
{
    static ItemStore *sharedTagStore = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedTagStore = [[ItemStore alloc] init];
    });
    return sharedTagStore;
}

- (void)fetchTagsWithCompletion:(void(^)(Tags * tags,NSError *error))block
{
    NSString *requestString = @"http://163pinglun.com/wp-json/posts/types/post/taxonomies/post_tag/terms";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    Tags *t = [[Tags alloc] init];
    FQConnection *connection = [[FQConnection alloc] initWithRequest:request];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:t];
    [connection start];
}

- (void)fetchPostsWithCompletion:(void (^)(Posts *posts,NSError *error))block
{
    NSString *requestString = @"http://163pinglun.com/wp-json/posts";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    Posts *posts = [[Posts alloc] init];
    FQConnection *connection = [[FQConnection alloc] initWithRequest:request];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:posts];
    connection.isDictionary = NO;
    [connection start];
}

- (void)fetchContentsWithCompletion:(void (^)(Contents *contents,NSError *error))block
{
    NSString *requestString = _cotentsURL;
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    Contents *contents = [[Contents alloc] init];
    FQConnection *connection = [[FQConnection alloc] initWithRequest:request];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:contents];
    connection.isDictionary = NO;
    [connection start];
}
@end



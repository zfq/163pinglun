//
//  RandomPostViewModel.h
//  163pinglun
//
//  Created by _ on 16/10/7.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFQRequest.h"

@interface RandomPostViewModel : NSObject

@property (nonatomic,copy,readonly) NSArray<RandomPost *> *randomPosts;

/**
 *  将RandomPost数组转换为Post数组
 */
@property (nonatomic,copy,readonly) NSArray<Post *> *posts;

- (void)fetchRandomPostWithCompletion:(void (^)(NSArray<RandomPost *> *randomPosts,NSError *error))completionBlk;

/**
 *  将randomPost转换为post
 *
 *  @param randomPosts randomPost数组
 *
 *  @return post数组
 */
- (NSArray<Post *> *)createPostWithRandomPosts:(NSArray<RandomPost *> *)randomPosts;

@end

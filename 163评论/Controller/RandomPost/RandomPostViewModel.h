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

- (void)fetchRandomPostWithCompletion:(void (^)(NSArray<RandomPost *> *randomPosts,NSError *error))completionBlk;

@end

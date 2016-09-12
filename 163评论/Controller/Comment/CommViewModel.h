//
//  CommViewModel.h
//  163pinglun
//
//  Created by _ on 16/9/12.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Content.h"

@interface CommViewModel : NSObject

@property (nonatomic,copy,readonly) NSArray<NSArray *> *contentItems;

- (void)fetchCommentsWithPostID:(NSString *)postID completion:(void (^)(NSArray<NSArray *> *contents,NSError *error))completionBlk;

@end

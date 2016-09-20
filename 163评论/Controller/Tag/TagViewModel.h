//
//  TagViewModel.h
//  163pinglun
//
//  Created by _ on 16/9/20.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface TagViewModel : NSObject

- (void)fetchTagsWithCompletion:(void (^)(NSArray<Tag *> *tags,NSError *error))completionBlk;

@end

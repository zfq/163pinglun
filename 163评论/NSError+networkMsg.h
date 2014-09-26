//
//  NSError+networkMsg.h
//  163评论
//
//  Created by zhaofuqiang on 14-9-25.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (networkMsg)

+ (NSString *)urlErrorDesciptionForCode:(NSInteger)code;
@end

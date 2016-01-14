//
//  NSError+networkMsg.m
//  163评论
//
//  Created by zhaofuqiang on 14-9-25.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "NSError+networkMsg.h"

@implementation NSError (networkMsg)

+ (NSString *)urlErrorDesciptionForCode:(NSInteger)code
{
    switch (code) {
        case -1009: return @"没有连接到互联网";
        case -1004: return @"无法连接到服务器";
        case -1003: return @"找不到服务器";
        case -1002: return @"无效的链接";
        case -1001: return @"连接超时";
            
            
        default:
            break;
    }
    
    return @"其他网络错误";
}
@end

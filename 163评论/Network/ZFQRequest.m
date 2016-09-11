//
//  ZFQRequest.m
//  163pinglun
//
//  Created by _ on 16/9/8.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQRequest.h"
#import "MacroDefinition.h"
/*
@implementation Author
@end

@implementation Post
@end
*/

@implementation ZFQPostRequest

- (NSString *)pathURL
{
    NSString *urlStr = nil;
    if (_tagName.length > 0) {
        urlStr = [NSString stringWithFormat:@"/wp-json/wp/v2/posts?filter[tag]=%@&page=%zi",_tagName,_currPageIndex];
    } else {
        if (_headRefreshing) {
            urlStr = @"/wp-json/wp/v2/posts";
        } else {
            urlStr = [NSString stringWithFormat:@"/wp-json/wp/v2?page=%zi",_homePageIndex];
        }
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return urlStr;
}

- (NSString *)httpMethod
{
    return @"GET";
}

- (NSDictionary *)requestParam
{
    return nil;
}

- (void)response:(id)responseObj
{
    if (!responseObj) {
        return;
    }
    
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
    NSMutableArray<Post *> *multArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        Post *p = [[Post alloc] init];
        [p readFromJSONDictionary:dict];
        [multArray addObject:p];
    }];
    
    self.postItems = multArray;
}

@end

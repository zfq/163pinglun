//
//  ZFQRequest.m
//  163pinglun
//
//  Created by _ on 16/9/8.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQRequest.h"
#import "MacroDefinition.h"
#import "GTMNSString+HTML.h"

@implementation ZFQPostRequest

- (NSString *)pathURL
{
    NSString *urlStr = nil;
    if (_tagName.length > 0) {
        urlStr = [NSString stringWithFormat:@"wp-json/wp/v2/posts?filter[tag]=%@&page=%zi",_tagName,_tagPageIndex];
    } else {
        urlStr = [NSString stringWithFormat:@"wp-json/wp/v2/posts?page=%zi",_homePageIndex];
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

@implementation ZFQCommentRequest

- (NSString *)pathURL
{
    return [NSString stringWithFormat:@"wp-json/wp/v2/comments?post=%@",_postID];;
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
    
    BOOL isNewAPI = (self.postID.integerValue > kSeparatorPostID) ? YES : NO;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
    NSMutableArray<NSArray *> *multArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    NSInteger preAllRows = 0;
    for (NSInteger i = 0; i < array.count; i++)
    {
        NSDictionary *dict = array[i];
        
        NSArray *comments = nil;
        id tmpObj = dict[@"content"];
        if ([tmpObj isKindOfClass:[NSArray class]]) {
            comments = tmpObj;
        } else {
            comments = [self arrayFromDict:tmpObj];
        }
        
        NSNumber *postID = dict[@"post"];
        NSNumber *groupID = isNewAPI ? dict[@"id"] : dict[@"ID"];
        if (groupID == nil) groupID = dict[@"id"];
        
        NSInteger count = comments.count;
         
        NSInteger currRows = 0;
        if (count > 0) currRows = (count == 1) ? 1 : (count+1);
        NSMutableArray<Content *> *tempArray = [[NSMutableArray alloc] initWithCapacity:array.count];
        
        for (NSInteger j = 0; j < count; j++) {
            Content *c = [[Content alloc] init];
            if (isNewAPI)
                [c readFromJSONDictionary:comments[j] apiVersion:nil];
            else
                [c readFromJSONDictionary:comments[j]];
            c.postID = postID;
            c.groupID = groupID;
            c.floorIndex = [NSNumber numberWithInteger:(j+1)];
            c.currRows = [NSNumber numberWithInteger:currRows];
            c.preAllRows = [NSNumber numberWithInteger:preAllRows];
            [tempArray addObject:c];
         }
        
        [multArray addObject:tempArray];
        preAllRows += currRows;
    }

    self.contentsItems = multArray;
}

- (NSArray *)arrayFromDict:(NSDictionary *)dict
{
    NSArray *array = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *key in array) {
        [mutArray addObject:dict[key]];
    }
        
    return [mutArray copy];
}

@end

@implementation PLTagRequest

- (NSString *)pathURL
{
    return @"/wp-json/wp/v2/tags?page=1&per_page=100";
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
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        Tag *t = [[Tag alloc] init];
        t.index = idx;
        [t readFromJSONDictionary:dic];
        [tempArray addObject:t];
    }];
    self.tags = tempArray;
}

@end

@implementation RandomPost
@end
@implementation PLRandomPostRequest

- (NSString *)pathURL
{
    return @"/wp-json/163pinglun/v1/random_posts";
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
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
    for (NSDictionary *dic in array) {
        RandomPost *post = [[RandomPost alloc] init];
        post.title = [[dic objectForKey:@"post_title"] gtm_stringByUnescapingFromHTML];
        NSString *idStr = [NSString stringWithFormat:@"%@",dic[@"ID"]];
        post.postID = idStr;
        [tempArray addObject:post];
    }
    
    self.randomPosts = tempArray;
}

@end

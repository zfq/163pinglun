//
//  Contents.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Contents.h"
#import "Content.h"

@implementation Contents

- (id)init
{
    self = [super init];
    if (self) {
        _contentItems = [[NSMutableArray alloc] init];
        _title = @"";
        _subhead = @"";
        _views = 0;
    }
    return self;
}

- (void)readFromJSONArray:(NSArray *)array
{
    for (NSDictionary *dic in array) {
        NSDictionary *comments = [dic objectForKey:@"content"];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i=1;i<=comments.count;i++) {
            NSString *indexstr = [NSString stringWithFormat:@"%d",i];
            NSDictionary *dic = [comments objectForKey:indexstr];
            Content *c = [[Content alloc] init];
            [c readFromJSONDictionary:dic];
            [tempArray addObject:c];
        }
        [_contentItems addObject:tempArray];
    }
    
}

@end

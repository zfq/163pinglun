//
//  Contents.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Contents.h"
#import "Content.h"
#import "ItemStore.h"

@implementation Contents

- (id)init
{
    return [self initWithContents:nil];
}

- (instancetype)initWithContents:(NSArray *)contents
{
    self = [super init];
    if (self) {
        if (_contentItems == nil)
            _contentItems = [NSMutableArray array];
        else
            _contentItems = [NSMutableArray arrayWithArray:contents];
    }
    return self;
}

- (void)readFromJSONArray:(NSArray *)array
{
    for (NSDictionary *dic in array) {
        NSDictionary *comments = [dic objectForKey:@"content"];
        NSNumber *postID = [dic objectForKey:@"ID"];
        NSMutableArray *tempArray = [NSMutableArray array];
        
        //从数据库中删除postID的所有content,再把新的content添加进去
        [[ItemStore sharedItemStore] deleteAllContentByPostID:postID];
        for (int i=1;i<=comments.count;i++) {
            NSString *indexstr = [NSString stringWithFormat:@"%d",i];
            NSDictionary *dic = [comments objectForKey:indexstr];
            Content *c = [[ItemStore sharedItemStore] createContent];
            [c readFromJSONDictionary:dic];
            c.postID = postID;
            [tempArray addObject:c];
        }
        
        [_contentItems addObject:tempArray];
        [[ItemStore sharedItemStore] saveContext];
    }
    
}

@end

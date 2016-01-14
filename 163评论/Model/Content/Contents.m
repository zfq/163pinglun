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
        if (contents == nil)
            _contentItems = [NSMutableArray array];
        else
            _contentItems = [NSMutableArray arrayWithArray:contents];
    }
    return self;
}

- (void)readFromJSONArray:(NSArray *)array
{
    BOOL isDel = NO;
    NSInteger preAllRows = 0;
    
    for (NSInteger i=array.count-1;i>=0;i--) {
        NSDictionary *dic = [array objectAtIndex:i];
        NSDictionary *comments = [dic objectForKey:@"content"];
        NSNumber *postID = [dic objectForKey:@"post"];
        NSNumber *groupID = [dic objectForKey:@"ID"];
        NSMutableArray *tempArray = [NSMutableArray array];
        
        //从数据库中删除postID的所有content,再把新的content添加进去
        if (isDel == NO) {
            [[ItemStore sharedItemStore] deleteAllContentByPostID:postID];
            isDel = YES;
        }
        
        NSInteger currRows = 0;
        if (comments.count > 0)
            currRows = (comments.count == 1) ? 1 : (comments.count+1);
        
        for (int i=1;i<=comments.count;i++) {
            NSString *indexstr = [NSString stringWithFormat:@"%d",i];
            NSDictionary *dic = [comments objectForKey:indexstr];
            Content *c = [[ItemStore sharedItemStore] createContent];
            [c readFromJSONDictionary:dic];
            c.postID = postID;
            c.groupID = groupID;
            c.floorIndex = [NSNumber numberWithInt:i];
            c.currRows = [NSNumber numberWithInteger:currRows];
            c.preAllRows = [NSNumber numberWithInteger:preAllRows];
            [tempArray addObject:c];
        }
        
        [_contentItems addObject:tempArray];
        [[ItemStore sharedItemStore] saveContext];  //这里的保存可不可以放在外面？？
        
        preAllRows += currRows;
    }
        
}

@end

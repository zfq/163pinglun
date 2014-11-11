//
//  Tags.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-1.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "Tags.h"
#import "Tag.h"
#import "ItemStore.h"

@implementation Tags

- (id)init
{
    self = [super init];
    if (self) {
        _tagItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)readFromJSONArray:(NSArray *)array
{
    if (array == nil || array.count == 0) {
        return;
    } else {
        //先删除所有tags
        [[ItemStore sharedItemStore] deleteAllTags];
    }
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        Tag *t = [[ItemStore sharedItemStore] createTag];
        t.index = @(idx);
        [t readFromJSONDictionary:dic];
        [_tagItems addObject:t];
    }];

}
@end

//
//  CommCell.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kCommCellTypeOnlyOne;
extern NSString *const kCommCellTypeTop;
extern NSString *const kCommCellTypeMiddle;
extern NSString *const kCommCellTypeBottom;

@class Content;

@interface CommCell : UITableViewCell
{
    Content *_content;
}

- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount height:(CGFloat *)height;

@end

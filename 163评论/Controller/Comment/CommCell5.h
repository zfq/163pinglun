//
//  CommCell2.h
//  163评论
//
//  Created by wecash on 15/8/18.
//  Copyright (c) 2015年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kCommCellTypeOnlyOne;
extern NSString *const kCommCellTypeTop;
extern NSString *const kCommCellTypeMiddle;
extern NSString *const kCommCellTypeBottom;

@class Content;

@interface CommCell5 : UITableViewCell
{
    Content *_content;
    NSInteger _floorCount;
    BOOL _fontSizeChanged;
}

@property (nonatomic) UIColor *hightlightColor;
@property (nonatomic,copy) void (^hightlightBlk)(Content *content,CGRect contentFrame);

- (NSString *)content;

//- (void)copyContentToPasteboard;
//- (UIImage *)contentSnapshoot;

- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount fontSizeChanged:(BOOL)isChanged;

//计算高度
- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount forHeight:(CGFloat *)height fontSizeChanged:(BOOL)isChanged;

@end

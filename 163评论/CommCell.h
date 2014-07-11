//
//  CommCell.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contents;

@interface CommCell : UITableViewCell
{
    Contents *_contents;
    NSMutableArray *_contentItems;
    CGFloat _height;
}

@property (nonatomic,weak) IBOutlet UILabel *userLabel;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;

@property (nonatomic,strong) NSMutableArray *commModel;

- (CGFloat)height;

@end

//
//  PostCell.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-12.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Post;

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *views;
@property (weak, nonatomic) IBOutlet UILabel *excerpt;
@property (nonatomic) BOOL isFlip;
@property (nonatomic,strong) Post *post;

- (void)flip:(CALayer *)animLayer;
@end

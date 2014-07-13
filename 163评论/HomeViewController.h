//
//  HomeViewController.h
//  163评论
//
//  Created by zhaofuqiang on 14-7-12.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Posts;

@interface HomeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) Posts *posts;

@end

//
//  CommViewController.h
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQBaseViewController.h"
#import "Contents.h"
#import "Post.h"

@interface CommViewController : FQBaseViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) NSString *myTitle;
@property (nonatomic,strong) Contents *contents;
@property (nonatomic,strong) Post *post;

@end

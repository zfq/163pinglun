//
//  FQBaseViewController.m
//  PopPush
//
//  Created by zhaofuqiang on 14-10-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FQBaseViewController.h"

#define FQ_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface FQBaseViewController ()

@end

@implementation FQBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 添加导航view
    UIImage *navBcgImg = [UIImage imageNamed:@"navigationbar_background"];
    _navView = [[UIImageView alloc] initWithImage:navBcgImg];
    _navView.frame = CGRectMake(0, 0, SCREEN_WIDTH, navBcgImg.size.height);
    _navView.userInteractionEnabled = YES;
    [self.view addSubview:_navView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
    UIView *bcgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FQ_SCREEN_WIDTH, 64)];
    bcgView.backgroundColor = [UIColor colorWithRed:0.129 green:0.160 blue:0.172 alpha:0.9];
    [bcgView addSubview:self.navView];
    [self.view addSubview:bcgView];

    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (UIImageView *)navView
{
    if (!_navView) {
        UIImage *navBcgImg = [UIImage imageNamed:@"navigationbar_background"];
        _navView = [[UIImageView alloc] initWithImage:navBcgImg];
        _navView.frame = CGRectMake(0, 0, SCREEN_WIDTH, navBcgImg.size.height);
        _navView.userInteractionEnabled = YES;
    }
    return _navView;
}

- (UILabel *)myTitleLabel
{
    if (!_myTitleLabel) {
        CGFloat width = 80;
        CGFloat height = 35;
        _myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-width)/2, 20+(44-height)/2, width, height)];
        _myTitleLabel.textAlignment = NSTextAlignmentCenter;
        _myTitleLabel.font = [UIFont systemFontOfSize:20];
        _myTitleLabel.textColor = TITLE_COLOR;
        [self.navView addSubview:_myTitleLabel];
    }
    return _myTitleLabel;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

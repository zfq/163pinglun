//
//  FQBaseViewController.m
//  PopPush
//
//  Created by zhaofuqiang on 14-10-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FQBaseViewController.h"
#import "MacroDefinition.h"

#define FQ_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface FQBaseViewController ()

@end

@implementation FQBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //添加导航view
    UIView *bcgView = [[UIView alloc] init];
    bcgView.backgroundColor = [UIColor colorWithRed:0.129 green:0.160 blue:0.172 alpha:0.85];
    [self.view addSubview:bcgView];
    
    //为bcgView添加约束
    bcgView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *nameMap = @{@"navView":self.navView,@"bcgView":bcgView};
    NSLayoutConstraint *bcgViewW = [NSLayoutConstraint constraintWithItem:bcgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.view addConstraint:bcgViewW];
    NSArray *bcgViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bcgView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *bcgViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bcgView(64)]" options:0 metrics:nil views:nameMap];
    [self.view addConstraints:bcgViewV];
    [self.view addConstraints:bcgViewH];
    
    //对navView添加约束
    UIImage *navBcgImg = [UIImage imageNamed:@"navigationbar_background"];
    self.navView.image = navBcgImg;
    [bcgView addSubview:self.navView];
    self.navView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *navViewW = [NSLayoutConstraint constraintWithItem:self.navView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:bcgView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [bcgView addConstraint:navViewW];
    NSArray *navViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[navView]-0-|" options:0 metrics:nil views:nameMap];
    NSString *vfV = [NSString stringWithFormat:@"V:|-0-[navView(%f)]",navBcgImg.size.height];
    NSArray *navViewV = [NSLayoutConstraint constraintsWithVisualFormat:vfV options:0 metrics:nil views:nameMap];
    [bcgView addConstraints:navViewH];
    [bcgView addConstraints:navViewV];
   
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (UIImageView *)navView
{
    if (!_navView) {
        _navView = [[UIImageView alloc] init];
        _navView.userInteractionEnabled = YES;
    }
    return _navView;
}

- (UILabel *)myTitleLabel
{
    if (!_myTitleLabel) {
        CGFloat width = 80;
        CGFloat height = 35;
        _myTitleLabel = [[UILabel alloc] init];
        _myTitleLabel.textAlignment = NSTextAlignmentCenter;
        _myTitleLabel.font = [UIFont systemFontOfSize:20];
        _myTitleLabel.textColor = [[UINavigationBar appearance] tintColor];
        [self.navView addSubview:_myTitleLabel];
        //为titleLabel添加约束
        NSDictionary *nameMap = @{@"myTitle":_myTitleLabel};
        _myTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *consW = [NSLayoutConstraint constraintWithItem:_myTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.navView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.navView addConstraint:consW];
        NSString *vfH = [NSString stringWithFormat:@"H:[myTitle(%f)]",width];
        NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:vfH options:0 metrics:nil views:nameMap];
        NSString *vfV = [NSString stringWithFormat:@"V:|-%f-[myTitle(%f)]",20+(44-height)/2,height];
        NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:vfV options:0 metrics:nil views:nameMap];
        [self.navView addConstraints:consH];
        [self.navView addConstraints:consV];
    }
    return _myTitleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

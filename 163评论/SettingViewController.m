//
//  SettingViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-10-19.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "SettingViewController.h"
#import "ItemStore.h"
#import "FontSetViewController.h"
#import "GeneralService.h"
@interface SettingViewController ()
{
    UITableView *settingTableView;
}
@property (nonatomic,strong) NSArray *settingItems;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 22, 60, 40);
    [backBtn setImage:[UIImage imageNamed:@"navgation_back"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:RGBCOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
    //添加tableView
    CGFloat navHeght = 64;
    if (!settingTableView) {
        settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeght, SCREEN_WIDTH, SCREEN_HEITHT-navHeght)
                                                        style:UITableViewStyleGrouped];
        settingTableView.dataSource = self;
        settingTableView.delegate = self;
    }
    
    [self.view addSubview:settingTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [settingTableView reloadData];
}

- (void)back:(UIButton *)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)settingItems
{
    if (!_settingItems) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
        _settingItems = [[NSArray alloc] initWithContentsOfFile:path];
    }
    return _settingItems;
}

#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.settingItems objectAtIndex:section];
    return array.count; //
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        backgroundView.backgroundColor = RGBCOLOR(51,153,255,1.0f); //RGBCOLOR(51,153,255,1.0f)
        cell.selectedBackgroundView = backgroundView;
    }
    NSArray *array = [self.settingItems objectAtIndex:indexPath.section];
    NSDictionary *dic = (NSDictionary *)[array objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    cell.textLabel.text = title;
    if ([title isEqualToString:@"字号大小"]) {
        cell.detailTextLabel.text = [GeneralService fontSizeName];
    }
    else if (![title isEqualToString:@"去App store评分"]) {
        cell.detailTextLabel.text = [dic objectForKey:@"content"];
    }
    
    return cell;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    NSArray *array = [self.settingItems objectAtIndex:indexPath.section];
    NSDictionary *dic = (NSDictionary *)[array objectAtIndex:indexPath.row];
    
    switch (indexPath.section) {
        case 0: //推送
            
            break;
        case 1: {//字号大小
            FontSetViewController *fontVC = [[FontSetViewController alloc] init];
            fontVC.myTitleLabel.text = @"设置";
            [self.navigationController pushViewController:fontVC animated:YES];
        } break;
        case 2: //清理缓存
            [[ItemStore sharedItemStore] deleteAllContents];
            break;
        case 3: {//评分
            NSString *appURL = [dic objectForKey:@"content"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
        } break;
        case 4: //意见 关于
            
            break;
    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _settingItems = nil;
    if (self.view.superview == nil && self.view.window==nil) {
        settingTableView = nil;
    }
}
@end

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
#import "MacroDefinition.h"
#import "UIButton+menuItem.h"

NSString * const k163ActionChangeFontSize = @"163ActionChangeFontSize";
NSString * const k163ActionClearCache = @"163ActionClearCache";
NSString * const k163ActionFeedback = @"163ActionFeedback";
NSString * const k163ActionAbout = @"163ActionAbout";

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
    UIColor *tintColor = [[UINavigationBar appearance] tintColor];
    UIButton *backBtn = [UIButton backTypeBtnWithTintColor:tintColor];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
    //添加tableView
    CGFloat navHeght = 64;
    if (!settingTableView) {
        settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeght, SCREEN_WIDTH, SCREEN_HEIGHT-navHeght)
                                                        style:UITableViewStyleGrouped];
        settingTableView.dataSource = self;
        settingTableView.delegate = self;
        settingTableView.backgroundColor = RGBCOLOR(232, 233, 232, 1);
        settingTableView.separatorColor = RGBCOLOR(209, 209, 209, 1);
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
    return array.count;
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
        cell.textLabel.textColor = RGBCOLOR(38, 38, 38, 1);
        cell.detailTextLabel.textColor = RGBCOLOR(38, 38, 38, 1);
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        backgroundView.backgroundColor = RGBCOLOR(51,153,255,1.0f); //RGBCOLOR(51,153,255,1.0f)
        cell.selectedBackgroundView = backgroundView;
        cell.backgroundColor = RGBCOLOR(254, 254, 254, 1);
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
    
    NSString *actionName = dic[@"action"];
    
    if ([actionName isEqualToString:k163ActionChangeFontSize]) {
        
        FontSetViewController *fontVC = [[FontSetViewController alloc] init];
        fontVC.myTitleLabel.text = @"设置";
        [self.navigationController pushViewController:fontVC animated:YES];
        
    } else if ([actionName isEqualToString:k163ActionClearCache]) {
        
//        [[ItemStore sharedItemStore] deleteAllContents];
        
    } else if ([actionName isEqualToString:k163ActionFeedback]) {
        
    } else if ([actionName isEqualToString:k163ActionAbout]) {
        
    } else {
        
    }
    
//    NSString *appURL = [dic objectForKey:@"content"];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
    
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

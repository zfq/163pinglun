//
//  HomeViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-12.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "HomeViewController.h"
#import "CommViewController.h"
#import "PostCell.h"
#import "Posts.h"
#import "Post.h"
#import "ItemStore.h"
#import "MJRefresh.h"
#import "Reachability.h"
#import "GeneralService.h"
#import "RandomPostViewController.h"
#import "MenuView.h"
#import "MenuItem.h"
#import "SettingViewController.h"
#import "FQNavigationController.h"

@interface HomeViewController ()
{
    NSInteger _currPage;
    UITableViewCell *_prototypeCell;
    NSMutableDictionary *_cellsHeightDic;
    
    MenuView *menu;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //添加更多btn
    UIImage *moreImg = [UIImage imageNamed:@"more1"];
    CGFloat height = 40;
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-50,20+(44-height)/2, 50, height);
    [moreButton setImage:moreImg forState:UIControlStateNormal];
    moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 50-moreImg.size.width-30, 0, 0);
    [moreButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
//    moreButton.backgroundColor = [UIColor redColor];
    [self.navView addSubview:moreButton];
    
    //添加logo
    UIImage *logImg = [UIImage imageNamed:@"logo"];
    UIImageView *logImgView = [[UIImageView alloc] initWithImage:logImg];
    CGRect logImgFrame = logImgView.frame;
    logImgFrame.origin = CGPointMake(15, 30);
    logImgView.frame = logImgFrame;
    [self.navView addSubview:logImgView];

    //注册cell
    UINib *cellNib = [UINib nibWithNibName:@"PostCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"PostCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!_prototypeCell) {
        _prototypeCell  = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    }
    
    
    //集成刷新控件
    [self setupRefresh];
    [self fetchPostFromDatabase];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
#pragma mark - 显示菜单
- (void)showMenu:(UIButton *)button
{
    if (!menu) {
        CGRect frame = CGRectMake(157, 65, 157, 87+44);
        CGFloat btnHeight = 43;

        MenuItem *tagItem = [[MenuItem alloc] initWithTitle:@"标签" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0) frame:CGRectMake(0, 0,frame.size.width, btnHeight) target:self action:@selector(showTag:)];
        MenuItem *lookItem = [[MenuItem alloc] initWithTitle:@"随便看看" titleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0) imageName:@"menu_look_around" imageEdgeInset:UIEdgeInsetsMake(0, -40, 0, 0) frame:CGRectMake(0, 0,frame.size.width, btnHeight) target:self action:@selector(showLookAround:)];
        MenuItem *settingItem = [[MenuItem alloc] initWithTitle:@"设置" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0) frame:CGRectMake(0, 0,frame.size.width, btnHeight) target:self action:@selector(showSetting:)];
        menu = [[MenuView alloc] initWithFrame:frame menuItems:@[tagItem,lookItem,settingItem]];
       
    }
    [menu showMenuView];
}

- (void)showTag:(UIButton *)button
{
    
}

- (void)showLookAround:(UIButton *)button
{
    RandomPostViewController *vc = [[RandomPostViewController alloc] init];
    [self addChildViewController:vc];
    [vc showRandomPostView];
}

- (void)showSetting:(UIButton *)button
{
    SettingViewController *sVC = [[SettingViewController alloc] init];
    FQNavigationController *nVC = [[FQNavigationController alloc] initWithRootViewController:sVC];
    
    [self presentViewController:nVC animated:YES completion:nil];
}
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark - fetch posts

- (void)fetchPostFromDatabase
{
    NSArray *postArray = [[ItemStore sharedItemStore] fetchPostsFromDatabase];
    _posts = [[Posts alloc] initWithPosts:postArray];
    _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:postArray.count];
    [self.tableView reloadData];   
}

- (void)removeAllPostsFromDatabase
{
    if (_posts.postItems.count > 0) {
        for (Post *p in _posts.postItems) {
            [[ItemStore sharedItemStore].managedObjectContext deleteObject:p];
        }
        [[ItemStore sharedItemStore] saveContext];
    }
}

#pragma mark - 开始进入刷新状态
- (void)headerRereshing
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {
            //设置网络可用
            [GeneralService setNetworkReachability:YES];
            //再从网络获取数据
            
            [ItemStore sharedItemStore].cotentsURL = @"http://163pinglun.com/wp-json/posts";
            [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
                //先删除数据库中的所有post
                if (posts != nil && (posts.postItems.count > 0)) {
                    [self removeAllPostsFromDatabase];
                    _posts = posts;
                    _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:posts.postItems.count];
                    [self.tableView reloadData];
                }

                [self.tableView headerEndRefreshing];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
            _currPage = 1;
            [self saveCurrPage];
        } else {
            [self.tableView headerEndRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            //提示网络不可用
            [GeneralService setNetworkReachability:NO];
            [GeneralService showHUDWithTitle:@"网络不可用！" andDetail:@"" image:@"MBProgressHUD.bundle/error"];
        }
    }];
}

- (void)footerRereshing
{
    if ([[Reachability reachabilityWithHostName:HOST_NAME] currentReachabilityStatus] != NotReachable) {
        //设置网络可用
        [GeneralService setNetworkReachability:YES];
        
        //获取当前页数
        NSNumber *currPage = [[NSUserDefaults standardUserDefaults] objectForKey:CURR_PAGE];
        _currPage = [currPage integerValue];
        _currPage++;
        NSString *urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&page=%ld",(long)_currPage];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [ItemStore sharedItemStore].cotentsURL = urlStr;
        [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
            if (posts != nil && (posts.postItems.count > 0)) {
                [_posts addPostItems:posts.postItems];
                //保存当前为第几页
                [self saveCurrPage];
                [self.tableView reloadData];
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.tableView footerEndRefreshing];
        }];

    } else {
        [self.tableView footerEndRefreshing];
        
        //提示网络不可用
        [GeneralService setNetworkReachability:NO];
        [GeneralService showHUDWithTitle:@"网络不可用！" andDetail:@"" image:@"MBProgressHUD.bundle/error"];
    }
}

- (void)saveCurrPage
{
    NSNumber *currPage = [NSNumber numberWithInteger:_currPage];
    [[NSUserDefaults standardUserDefaults] setObject:currPage forKey:CURR_PAGE];
}

#pragma mark - tableView dateSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_posts == nil)
		return 0;
	else
        return _posts.postItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:nil  options:nil][0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    backgroundView.backgroundColor = RGBCOLOR(51,153,255,1.0f); //RGBCOLOR(51,153,255,1.0f)
    cell.selectedBackgroundView = backgroundView;
    
    cell.post = [_posts.postItems objectAtIndex:indexPath.row]; //indexPath.row
        
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *row = [NSNumber numberWithInteger:indexPath.row];
    NSNumber *height = [_cellsHeightDic objectForKey:row];
    if (height != nil) {
        return height.floatValue;
    } else {
        Post *tempPost = [_posts.postItems objectAtIndex:indexPath.row];
        PostCell *tempCell = (PostCell *)_prototypeCell;
        tempCell.excerpt.text = tempPost.excerpt;
        CGSize size = [tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [_cellsHeightDic setObject:[NSNumber numberWithFloat:(size.height+1)] forKey:row];
        return size.height+1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *tempPost = [_posts.postItems objectAtIndex:indexPath.row];
    CommViewController *cVC = [[CommViewController alloc] init];
    cVC.postID = tempPost.postID;
    cVC.myTitleLabel.text = @"跟帖";
    [self.navigationController pushViewController:cVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (self.view.superview == nil && self.view.window == nil) {
        self.view = nil;
    }
    
    menu = nil;
}

@end



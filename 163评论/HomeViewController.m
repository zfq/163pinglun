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
#import "UIDeviceHardware.h"

@interface HomeViewController ()
{
    NSInteger _currPage;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"帖子";
        _currPage = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *cellNib = [UINib nibWithNibName:@"PostCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"PostCell"];
    
    //集成刷新控件
    [self setupRefresh];
    [self fetchPostFromDatabase];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark - fetch posts
//- (void)fetchPostFromNetwork
//{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    NSString *urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&page=%d",_currPage];
//    [ItemStore sharedItemStore].cotentsURL = urlStr;
//    [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
//        _posts = posts;
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [self.tableView reloadData];
//        _currPage++;
//        //结束刷新状态
//        if (_currPage > 1) {
//            [self.tableView footerEndRefreshing];
//        } else {
//            [self.tableView headerEndRefreshing];
//        }
//        
//    }];
//
//}

- (void)fetchPostFromDatabase
{
    NSArray *postArray = [[ItemStore sharedItemStore] fetchPostsFromDatabase];
    _posts = [[Posts alloc] initWithPosts:postArray];
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

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    if ([[Reachability reachabilityWithHostName:HOST_NAME] currentReachabilityStatus] != NotReachable) {
        
        //先删除数据库中的所有post
        [self removeAllPostsFromDatabase];
        
        //再从网络获取数据
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [ItemStore sharedItemStore].cotentsURL = @"http://163pinglun.com/wp-json/posts";
        [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
            _posts = posts;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.tableView reloadData];
            [self.tableView headerEndRefreshing];
        }];
        
    } else {
        [self.tableView headerEndRefreshing];
        //提示网络不可用
        [UIDeviceHardware showHUDWithTitle:@"网络不可用！" andDetail:@"" image:@"MBProgressHUD.bundle/error"];
    }
}

- (void)footerRereshing
{
    if ([[Reachability reachabilityWithHostName:HOST_NAME] currentReachabilityStatus] != NotReachable) {
        _currPage++;
        NSString *urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&page=%ld",(long)_currPage];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [ItemStore sharedItemStore].cotentsURL = urlStr;
        [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
            
            [_posts addPostItems:posts.postItems];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.tableView reloadData];
            [self.tableView footerEndRefreshing];
        }];

    } else {
        [self.tableView footerEndRefreshing];
        //提示网络不可用
        [UIDeviceHardware showHUDWithTitle:@"网络不可用！" andDetail:@"" image:@"MBProgressHUD.bundle/error"];
    }
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
        cell = [[PostCell alloc] init];
    }
    cell.post = [_posts.postItems objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *tempPost = [_posts.postItems objectAtIndex:indexPath.row];
    PostCell *heightCell = [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil][0];
    //这是cell还没有加载，所以能够得到它的原来的高度
    [heightCell setPost:tempPost];
    
    return [heightCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView = backgroundView;
    cell.selectedBackgroundView.backgroundColor = RGBCOLOR(255, 0, 0, 1);
    
    Post *tempPost = [_posts.postItems objectAtIndex:indexPath.row];
    CommViewController *cVC = [[CommViewController alloc] init];
    cVC.postID = tempPost.postID;
    
    [self.navigationController pushViewController:cVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _posts = nil;
}

@end



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
#import "RandomPostViewController.h"

@interface HomeViewController ()
{
    NSInteger _currPage;
    UITableViewCell *_prototypeCell;
    NSMutableDictionary *_cellsHeightDic;
    
    UIControl *menu;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"帖子";

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //添加更多
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"]
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
	self.navigationItem.rightBarButtonItem = moreButton;
    
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(15, 12, 68, 23)];
    blueView.backgroundColor = RGBCOLOR(0, 160, 233, 1);
    [self.navigationController.navigationBar addSubview:blueView];
//    CALayer *navBarShadow = [CALayer layer];
//    navBarShadow.frame = CGRectMake(0, 30, self.navigationController.navigationBar.frame.size.width, 1);
//    navBarShadow.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
//    [self.navigationController.navigationBar.layer addSublayer:navBarShadow];
    
    UINib *cellNib = [UINib nibWithNibName:@"PostCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"PostCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _prototypeCell  = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    //集成刷新控件
    [self setupRefresh];
    [self fetchPostFromDatabase];
}

- (void)showMenu:(UIBarButtonItem *)barItem
{
    //移除menuView
    if (menu != nil) {
        [menu removeFromSuperview];
        menu = nil;
        return;
    }
    
    //显示menuView
    UIView *_menuView = [[UIView alloc] init];
    _menuView.frame = CGRectMake(157, 65, 157, 87);
    _menuView.backgroundColor = RGBCOLOR(239, 239, 239, 1.0); //
    _menuView.layer.shadowColor = RGBCOLOR(109, 109, 109, 0.4).CGColor;
    _menuView.layer.shadowOpacity = 1.0;
    _menuView.layer.shadowOffset = CGSizeMake(1,1);
    _menuView.layer.shadowRadius = 1.0;
   
    //添加分割线
    CALayer *seperatorLine = [CALayer layer];
    CGFloat seperatorLineY = (_menuView.frame.size.height-1)/2;
    seperatorLine.frame = CGRectMake(0, seperatorLineY, _menuView.frame.size.width, 1);
    seperatorLine.backgroundColor = RGBCOLOR(109, 109, 109, 0.1).CGColor;
    [_menuView.layer addSublayer:seperatorLine];

    UIButton *tagBtn = [self buttomWithTitle:@"标签" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0)
                                       imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0)
                                       frame:CGRectMake(0, 0,_menuView.frame.size.width, seperatorLineY) action:@selector(showTag:)];
    UIButton *lookBtn = [self buttomWithTitle:@"随便看看" titleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)
                                        imageName:@"menu_look_around" imageEdgeInset:UIEdgeInsetsMake(0, -40, 0, 0)
                                        frame:CGRectMake(0, seperatorLineY+1,_menuView.frame.size.width, seperatorLineY) action:@selector(showLookAround:)];
    [_menuView addSubview:tagBtn];
    [_menuView addSubview:lookBtn];
    

    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (menu == nil) {
        menu = [[UIControl alloc] initWithFrame:topWindow.bounds];
        [menu addTarget:self action:@selector(dismissMenuView:) forControlEvents:UIControlEventTouchDown];
        menu.backgroundColor = [UIColor clearColor];
        [menu addSubview:_menuView];
    }
    
    [topWindow.rootViewController.view addSubview:menu];
}

- (void)dismissMenuView:(UIControl *)mask
{
    [mask removeFromSuperview];
    mask = nil;
    menu = nil;
}

- (UIButton *)buttomWithTitle:(NSString *)title image:(UIImage *)image frame:(CGRect)frame action:(SEL)action
{
    //添加按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"button_select_background"] forState:UIControlStateHighlighted];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.frame = CGRectMake(8, (frame.size.height-image.size.height)/2, image.size.width, image.size.height);
    imgView.tag = 6;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(CGRectGetMaxX(imgView.frame), 0, frame.size.width-image.size.width, frame.size.height);
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.tag = 5;
    [btn addSubview:titleLabel];
    [btn addSubview:imgView];
  
    return btn;
}

- (UIButton *)buttomWithTitle:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
                        imageName:(NSString *)imageName imageEdgeInset:(UIEdgeInsets)imageEdgeInsets
                        frame:(CGRect)frame action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"button_select_background"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_pressed",imageName]] forState:UIControlStateHighlighted];
    btn.tintColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.titleEdgeInsets = titleEdgeInsets;
    btn.imageEdgeInsets = imageEdgeInsets;
    
    return btn;
}

- (void)showTag:(UIButton *)button
{
    [menu removeFromSuperview];
    menu = nil;
    
}

- (void)showLookAround:(UIButton *)button
{
    [menu removeFromSuperview];
    menu = nil;
    RandomPostViewController *vc = [[RandomPostViewController alloc] init];
    [vc showRandomPostView];
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

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {
            //再从网络获取数据
            
            [ItemStore sharedItemStore].cotentsURL = @"http://163pinglun.com/wp-json/posts";
            [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
                //先删除数据库中的所有post
                [self removeAllPostsFromDatabase];
                _posts = posts;
                _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:posts.postItems.count];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.tableView reloadData];
                [self.tableView headerEndRefreshing];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];

        } else {
            [self.tableView headerEndRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            //提示网络不可用
            [UIDeviceHardware showHUDWithTitle:@"网络不可用！" andDetail:@"" image:@"MBProgressHUD.bundle/error"];
        }
    }];
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
        cell = [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:nil  options:nil][0];
    }
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



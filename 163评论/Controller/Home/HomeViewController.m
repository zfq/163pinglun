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
#import "Post.h"
#import "ItemStore.h"
#import "MJRefresh.h"
#import "MJRefreshHeaderView.h"
#import "Reachability.h"
#import "GeneralService.h"
#import "RandomPostViewController.h"
#import "MenuView.h"
#import "MenuItem.h"
#import "ZFQHUD.h"
#import "SettingViewController.h"
#import "FQNavigationController.h"
#import "TagViewController.h"
#import "PlaceholderView.h"
#import "MacroDefinition.h"
#import "HomeViewModel.h"
#import "ItemStore.h"

@interface HomeViewController () <TagViewControllerDelegate>
{
    NSInteger _homePageIndex;
    NSInteger tagPageIndex;
    MenuView *menu;                     //菜单
}
@property (nonatomic) HomeViewModel *viewModel;
@property (nonatomic,strong) NSMutableDictionary *cellsHeightDic; //所有cell的高度
@property (nonatomic,strong) PostCell *prototypeCell; //预留一个用来计算高度
@end

@implementation HomeViewController

#pragma mark - LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        tagPageIndex = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _viewModel = [[HomeViewModel alloc] init];
    _viewModel.latestPostRefreshBlk = ^(){
        [TagViewController  clearTagKey];
    };
    
    //添加更多btn
    UIImage *moreImg = [UIImage imageNamed:@"more1"];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:moreImg forState:UIControlStateNormal];
    moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 50-moreImg.size.width-30, 0, 0);
    [moreButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.navView addSubview:moreButton];
    
    //为moreBtn添加约束
    NSDictionary *nameMap = @{@"moreBtn":moreButton};
    NSArray *moreBtnConsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[moreBtn(40)]" options:0 metrics:nil views:nameMap];
    NSArray *moreBtnConsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[moreBtn(50)]-0-|" options:0 metrics:nil views:nameMap];
    [self.navView addConstraints:moreBtnConsV];
    [self.navView addConstraints:moreBtnConsH];
    
    //添加logo
    UIImage *logImg = [UIImage imageNamed:@"logo"];
    UIImageView *logImgView = [[UIImageView alloc] initWithImage:logImg];
    CGRect logImgFrame = logImgView.frame;
    logImgFrame.origin = CGPointMake(15, 30);
    logImgView.frame = logImgFrame;
    [self.navView addSubview:logImgView];
    
    //注册cell
    [self.tableView registerClass:[PostCell class] forCellReuseIdentifier:@"PostCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!_prototypeCell) {
        _prototypeCell  = (PostCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    }
    self.cellsHeightDic = [[NSMutableDictionary alloc] init];
    
    //初始化数据库
    [ItemStore initDB];
    
    //集成刷新控件
    [self setupRefresh];
    
    //优先从数据库中获取数据
    [self fetchPostFromDatabase];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 显示菜单
- (void)showMenu:(UIButton *)button
{
    if (!menu) {
        CGFloat menuWidth = 157;
        CGFloat rightMargin = 6;
        CGFloat btnHeight = 43;
        
        MenuItem *homeItem = [[MenuItem alloc] initWithTitle:@"今日评论" titleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -40, 0, 0) frame:CGRectMake(0, 0,menuWidth, btnHeight) target:self action:@selector(showTodayPost:)];
        MenuItem *tagItem = [[MenuItem alloc] initWithTitle:@"标签" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0) frame:CGRectMake(0, 0,menuWidth, btnHeight) target:self action:@selector(showTag:)];
        MenuItem *lookItem = [[MenuItem alloc] initWithTitle:@"随便看看" titleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0) imageName:@"menu_look_around" imageEdgeInset:UIEdgeInsetsMake(0, -40, 0, 0) frame:CGRectMake(0, 0,menuWidth, btnHeight) target:self action:@selector(showLookAround:)];
        MenuItem *settingItem = [[MenuItem alloc] initWithTitle:@"设置" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0) frame:CGRectMake(0, 0,menuWidth, btnHeight) target:self action:@selector(showSetting:)];
        
        NSArray *items = @[homeItem,tagItem,lookItem,settingItem];
        NSUInteger itemNum = items.count;
        CGRect frame = CGRectMake(SCREEN_WIDTH-menuWidth-rightMargin, 65, menuWidth, itemNum * btnHeight + (itemNum-1));

        menu = [[MenuView alloc] initWithFrame:frame menuItems:items];
    }
    [menu showMenuView];
}

//今日评论
- (void)showTodayPost:(UIButton *)button
{
    //开始下拉刷新
    self.viewModel.tagName = nil;
    [self.tableView headerBeginRefreshing];
}

//标签
- (void)showTag:(UIButton *)button
{
    TagViewController *tVC = [[TagViewController alloc] init];
    tVC.tvcDelegate = self;
    [self addChildViewController:tVC];
    [tVC showTagView];
}

//随便看看
- (void)showLookAround:(UIButton *)button
{
    RandomPostViewController *rVC = [[RandomPostViewController alloc] init];
    [self addChildViewController:rVC];
    [rVC showRandomPostView];
}

//设置
- (void)showSetting:(UIButton *)button
{
    SettingViewController *sVC = [[SettingViewController alloc] init];
    sVC.myTitleLabel.text = @"设置";
    [self.navigationController pushViewController:sVC animated:YES];
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
    NSArray *dbPost = [ItemStore readPostsFromIndex:0 toIndex:0];
    [self.viewModel.postItems addObjectsFromArray:dbPost];

    //如果数据库中没有想要数据，就从网络加载
    if (self.viewModel.postItems.count > 0) {
        [self caculateCellHeight:NO originItemCount:0 increasedItems:nil];
    } else {
        [self.tableView headerBeginRefreshing];
    }
}

- (void)caculateCellHeight:(BOOL)footerRefresh originItemCount:(NSInteger)originItemCount increasedItems:(NSArray<Post *> *)items
{
    //对于上拉加载，只计算新增的cell的高度就行了
    if (footerRefresh) {
        for (NSInteger i = 0 ; i < items.count ; i++) {
            self.prototypeCell.post = items[i];
            CGFloat height = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
            NSString *key = [NSString stringWithFormat:@"%lu",i + items.count];
            [self.cellsHeightDic setObject:@(height) forKey:key];
        }
        return;
    }
    
    //下拉刷新,cell的高度全部重新计算
    __weak typeof(self) weakSelf = self;
    NSArray *array = self.viewModel.postItems;

    [array enumerateObjectsUsingBlock:^(Post *p, NSUInteger idx, BOOL * _Nonnull stop) {
        weakSelf.prototypeCell.post = p;
        CGFloat height = [weakSelf.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
        NSString *key = [NSString stringWithFormat:@"%lu",idx];
        [weakSelf.cellsHeightDic setObject:@(height) forKey:key];
    }];
}

#pragma mark - 开始进入刷新状态
- (void)headerRereshing
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    HomeViewController * __weak weakSelf = self;
    self.viewModel.headRefreshing = YES;
    
    [self.viewModel fetchPostsWithCompletion:^(NSArray<Post *> *postItems,NSArray<Post *> *increasedPostItems,NSError *error) {
        [weakSelf.tableView headerEndRefreshing];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            ZFQLog(@"失败:%@",error);
        } else {
            if (postItems.count > 0) {
                [weakSelf caculateCellHeight:NO originItemCount:0 increasedItems:nil];
                weakSelf.tableView.tableHeaderView = nil;
                [weakSelf.tableView reloadData];
            }
        }
    }];

}

- (void)footerRereshing
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    HomeViewController * __weak weakSelf = self;
    self.viewModel.headRefreshing = NO;
    NSInteger originItemCount = self.viewModel.postItems.count;
    [self.viewModel fetchPostsWithCompletion:^(NSArray<Post *> *postItems,NSArray<Post *> *increasedPostItems, NSError *error) {
        [weakSelf.tableView footerEndRefreshing];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            ZFQLog(@"失败:%@",error);
        } else {
            if (postItems.count > 0) {
                [weakSelf caculateCellHeight:YES originItemCount:originItemCount increasedItems:increasedPostItems];
                weakSelf.tableView.tableHeaderView = nil;
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

#pragma mark - tableView dateSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_viewModel.postItems == nil)
		return 0;
	else
        return _viewModel.postItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    if (cell == nil) {
        cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PostCell"];
    }

    cell.post = [_viewModel.postItems objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%ld",indexPath.row];
    NSNumber *height = [_cellsHeightDic objectForKey:key];
    return height.floatValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *tempPost = [_viewModel.postItems objectAtIndex:indexPath.row];
    CommViewController *cVC = [[CommViewController alloc] initWithPostItems:_viewModel.postItems beginIndex:indexPath.row];
    cVC.title = tempPost.title;
    cVC.myTitleLabel.text = @"跟帖";
    [self.navigationController pushViewController:cVC animated:YES];
}

#pragma mark - tagScrollView Delegate 标签视图代理
- (void)didSelectTagView:(TagView *)tagView controller:(TagViewController *)tVC
{
    [tVC dismissTagViewWithAnimation:YES];
    self.viewModel.tagName = tagView.postTag.tagName;

    //开始下拉刷新
    [self.tableView headerBeginRefreshing];
}

@end



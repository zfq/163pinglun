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
#import "MJRefreshHeaderView.h"
#import "Reachability.h"
#import "GeneralService.h"
#import "RandomPostViewController.h"
#import "MenuView.h"
#import "MenuItem.h"
#import "SettingViewController.h"
#import "FQNavigationController.h"
#import "TagViewController.h"
#import "PlaceholderView.h"

@interface HomeViewController () <TagViewControllerDelegate>
{
    NSInteger _homePageIndex;
    UITableViewCell *_prototypeCell;        //预留一个用来计算高度
    NSMutableDictionary *_cellsHeightDic;   //所有cell的高度
   
    
    NSString *_tagName;
    NSInteger tagPageIndex;
    
    MenuView *menu;                     //菜单
    RandomPostViewController *randomVC; //随便看看
}

@property (nonatomic,assign) NSInteger homePageIndex;
@property (nonatomic,strong) NSString *tagName;
@end

@implementation HomeViewController
@synthesize homePageIndex = _homePageIndex;
@synthesize tagName = _tagName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tagPageIndex = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    //添加searchbar
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
//    searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    [self.tableView setTableHeaderView:view];
//    [self.tableView addSubview:searchBar];
    
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
    
    //优先从数据库中获取数据
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
        CGFloat menuWidth = 157;
        CGFloat rightMargin = 6;
        CGFloat btnHeight = 43;
        CGRect frame = CGRectMake(SCREEN_WIDTH-menuWidth-rightMargin, 65, menuWidth, 3 * btnHeight + (3-1));
        
        MenuItem *tagItem = [[MenuItem alloc] initWithTitle:@"标签" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0) frame:CGRectMake(0, 0,frame.size.width, btnHeight) target:self action:@selector(showTag:)];
        MenuItem *lookItem = [[MenuItem alloc] initWithTitle:@"随便看看" titleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0) imageName:@"menu_look_around" imageEdgeInset:UIEdgeInsetsMake(0, -40, 0, 0) frame:CGRectMake(0, 0,frame.size.width, btnHeight) target:self action:@selector(showLookAround:)];
        MenuItem *settingItem = [[MenuItem alloc] initWithTitle:@"设置" titleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0) imageName:@"menu_tag" imageEdgeInset:UIEdgeInsetsMake(0, -68, 0, 0) frame:CGRectMake(0, 0,frame.size.width, btnHeight) target:self action:@selector(showSetting:)];
        menu = [[MenuView alloc] initWithFrame:frame menuItems:@[tagItem,lookItem,settingItem]];
       
    }
    [menu showMenuView];
}

- (void)showTag:(UIButton *)button
{
    TagViewController *tVC = [[TagViewController alloc] init];
    tVC.tvcDelegate = self;
    [self addChildViewController:tVC];
    [tVC showTagView];
}

- (void)showLookAround:(UIButton *)button
{
    if (randomVC == nil) {
        randomVC = [[RandomPostViewController alloc] init];
    }
    
    [self addChildViewController:randomVC];
    [randomVC showRandomPostView];
}

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
    NSArray *postArray = [[ItemStore sharedItemStore] fetchAllPostsFromDatabase];
    
    if (postArray == nil || postArray.count==0) {   //如果数据库中没有想要数据，就从网络加载
        [self.tableView headerBeginRefreshing];
    } else {
        _posts = [[Posts alloc] initWithPosts:postArray];
        _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:postArray.count];
        Post *firstP = _posts.postItems.firstObject;
        if (firstP.title != nil) {
            self.tableView.tableHeaderView = nil;
            [self.tableView reloadData];
        } 
    }
}

#pragma mark 删除旧的post数据
- (void)removeAllOldPostsFromDatabase
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
        if (isReachable) {  //网络可用
            [ItemStore sharedItemStore].cotentsURL = [self urlStringWithHeadRefreshing:YES tagName:self.tagName];
            [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
                //先删除数据库中的所有post
                if (error == nil)
                {
                    if (posts != nil && (posts.postItems.count > 0))
                    {
                        [self removeAllOldPostsFromDatabase];
                        _posts = posts;
                        _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:posts.postItems.count];
                        self.tableView.tableHeaderView = nil;
                        [self.tableView reloadData];
                        
                        if (self.tagName != nil)
                            self.tagName = nil;  //以便下拉返回首页
                    }
                } //end if(error == nil)
                
                [self.tableView headerEndRefreshing];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
            self.homePageIndex = 1;
            //显示footer
            [self.tableView setFooterHidden:NO];
            
        } else {    //网络不可用
            
            [self.tableView headerEndRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (_posts==nil || _posts.postItems.count ==0) {
                //添加站位提示view
                PlaceholderView *pView = [[PlaceholderView alloc] initWithFrame:self.tableView.bounds content:@"网络不可用\n下拉刷新试试" fontSize:24.0f];
                self.tableView.tableHeaderView = pView;
            }
            [self.tableView setFooterHidden:YES];
            //提示网络不可用
            [GeneralService showHUDWithTitle:@"网络不可用！" andDetail:@"" image:@"MBProgressHUD.bundle/error"];
        }
    }];
    
}

- (void)footerRereshing
{
    if ([[Reachability reachabilityWithHostName:HOST_NAME] currentReachabilityStatus] != NotReachable) {
        //设置网络可用
        [GeneralService setNetworkReachability:YES];
       
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [ItemStore sharedItemStore].cotentsURL = [self urlStringWithHeadRefreshing:NO tagName:self.tagName];
        
        [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
            if (posts != nil && (posts.postItems.count > 0))
            {
                [_posts addPostItems:posts.postItems];
                if (self.tagName == nil)
                {
//                    [self saveCurrHomePage];
                }//保存当前为第几页
                else
                    tagPageIndex ++;
              
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

- (NSInteger)homePageIndex
{
    NSNumber *currPage = [[NSUserDefaults standardUserDefaults] objectForKey:CURR_HOME_PAGE];
    //如果不存在就创建
    if (currPage == nil || currPage.integerValue == 0) {
        currPage = [NSNumber numberWithInteger:1];
        [[NSUserDefaults standardUserDefaults] setObject:currPage forKey:CURR_HOME_PAGE];
    }
    _homePageIndex = [currPage integerValue];
    return _homePageIndex;
}

- (void)setHomePageIndex:(NSInteger)homePageIndex
{
    NSNumber *currPage = [NSNumber numberWithInteger:homePageIndex];
    [[NSUserDefaults standardUserDefaults] setObject:currPage forKey:CURR_HOME_PAGE];
    _homePageIndex = homePageIndex;
}

- (NSString *)tagName
{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"tagName"];
    if (name == nil || [name isEqualToString:@""]) {
        return nil;
    } else {
        return name;
    }
}

- (void)setTagName:(NSString *)tagName
{
    if (tagName == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tagName"];
    } else {
        [[NSUserDefaults standardUserDefaults]  setObject:tagName forKey:@"tagName"];
    }
    _tagName = tagName;
}

- (NSString *)urlStringWithHeadRefreshing:(BOOL)headRefreshing tagName:(NSString *)tag
{
    NSString *urlStr;
    if (tag != nil) {
        if (headRefreshing)
            tagPageIndex = 1;
        else
            tagPageIndex ++;
        urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&filter[tag]=%@&page=%zi",tag,tagPageIndex];
    } else {
        if (headRefreshing) {
            urlStr = @"http://163pinglun.com/wp-json/posts";
        } else {
            //设置当前页数
            self.homePageIndex += 1;
            urlStr = [NSString stringWithFormat:@"http://163pinglun.com/index.php?json_route=/posts&page=%zi",self.homePageIndex];
        }
    }
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return urlStr;
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
    cVC.title = tempPost.title;
    cVC.myTitleLabel.text = @"跟帖";
    [self.navigationController pushViewController:cVC animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40;
//}
#pragma mark - tagScrollView Delegate 标签视图代理
- (void)didSelectTagView:(TagView *)tagView controller:(TagViewController *)tVC
{
    [tVC dismissTagViewWithAnimation:YES];
    self.tagName = tagView.postTag.tagName;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.tableView headerBeginRefreshing];
    
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



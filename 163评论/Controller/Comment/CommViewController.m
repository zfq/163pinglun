//
//  CommViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommViewController.h"
#import "ItemStore.h"
#import "Content.h"
#import "Reachability.h"
#import "ShareView.h"
#import "ShareItem.h"
#import "SocialSharing.h"
#import "CommCell5.h"
#import "ZFQMenuObject.h"

@interface CommViewController () <ShareViewDeleage,UITableViewDataSource,UITableViewDelegate>
{
    NSInteger cellCount;
    BOOL isChanged;
    
    NSMutableArray *_cellsHeight;
    NSMutableDictionary *_contentInfoDic;
    
    CommCell5 *_assistCell;
}

@property (nonatomic,strong) NSMutableDictionary *cellsHeightDic;
@property (nonatomic,strong) NSMutableDictionary *cellsDic;
@property (nonatomic,strong) ZFQMenuObject *menuObject;

@end

@implementation CommViewController

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

    //1. 添加返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 22, 60, 40);
    [backBtn setImage:[UIImage imageNamed:@"navgation_back"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:RGBCOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
    //2.添加分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [shareBtn setTitleColor:RGBCOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:shareBtn];
    NSDictionary *nameMap = @{@"shareBtn":shareBtn};
    shareBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[shareBtn(60)]-5-|" options:0 metrics:nil views:nameMap];
    NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[shareBtn(40)]" options:0 metrics:nil views:nameMap];
    [self.navView addConstraints:consH];
    [self.navView addConstraints:consV];
    
	//3. 设置tableView
	self.tableView.allowsSelection = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _contentInfoDic = [[NSMutableDictionary alloc] init];
    
    //4.获取跟帖
	[self fetchComment];
    
    //5.注册设置字体大小通知
    isChanged = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged:) name:FontSizeChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //取消请求
    [[ItemStore sharedItemStore] cancelCurrentRequtest];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//#pragma mark - getter setter

#pragma mark - action
- (void)back:(UIButton *)backButton
{
    if ([self.presentingViewController isKindOfClass:[UIViewController class]])
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)share:(UIButton *)shareButton
{
    ShareView *shareView = [[ShareView alloc] init]; //WithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    shareView.shareViewDelegate = self;
    [self.view addSubview:shareView];
    
    //为shareView添加约束
    NSDictionary *nameMap = @{@"shareView":shareView};
    shareView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *shareViewConsW = [NSLayoutConstraint constraintWithItem:shareView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *shareViewConsH = [NSLayoutConstraint constraintWithItem:shareView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[shareView]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[shareView]-0-|" options:0 metrics:nil views:nameMap];
    [self.view addConstraints:@[shareViewConsW,shareViewConsH]];
    [self.view addConstraints:consH];
    [self.view addConstraints:consV];
    
    [shareView showShareView];
}

#pragma mark - share delegate
- (void)didTapedShareItem:(ShareItem *)shareItem
{
    NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/archives/%zi",self.postID.integerValue];
    if ([shareItem.title isEqualToString:@"新浪微博"]) {
        NSString *text = [self.myTitle stringByAppendingString:url];
        UIImage *img = [UIImage imageNamed:@"AppIcon57x57"];
        [[SocialSharing sharedInstance] sendWeiboWithText:text image:img completion:^(BOOL success) {
            if (success) {  //这个success也可能是取消的success
//                NSLog(@"成功");
            }
        }];
    } else if ([shareItem.title isEqualToString:@"QQ空间"]) {
        UIImage *img = [UIImage imageNamed:@"AppIcon57x57"];
        [[SocialSharing sharedInstance] sendQQShareWithTitle:self.myTitle description:nil image:img url:url];
    }
   
}
#pragma mark - 设置字体
- (void)fontSizeChanged:(NSNotification *)notification
{
    isChanged = YES;
    [_cellsHeightDic removeAllObjects];
    [self.tableView reloadData];
}

- (void)fetchComment
{
    //如果网络可用，就从网络中获取数据
    //在保存之前先把数据库里面的关于该post的content删掉，，然后保存到数据库中，
    //否则就从数据库里去取
    
    //添加等待view
//    __block UIActivityIndicatorView *activityView = [self addActivityViewInView:self.tableView];
    CommViewController *__weak weakSelf = self;
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {  //网络可用
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#if TEST_163_LOSS
//            NSString *url = @"http://163pinglun.com/wp-json/posts/8484/comments";  //8484:多段 字多 10798:多段 16458：长
            NSString *url = @"http://www.biying.com";
#else
            NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/wp-json/posts/%@/comments",[NSString stringWithFormat:@"%zi",[_postID integerValue]]];
#endif
            [ItemStore sharedItemStore].cotentsURL = url;
            
            [[ItemStore sharedItemStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
                weakSelf.contents = contents;
                weakSelf.cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:contents.contentItems.count];
                weakSelf.cellsDic = [NSMutableDictionary dictionaryWithCapacity:contents.contentItems.count];
                
                [weakSelf caculatorHeight];
                
                //更新UI
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                weakSelf.tableView.tableHeaderView=nil;
//                [weakSelf removeActivityView:activityView];
                [weakSelf.tableView reloadData];
            }];
        } else {    //网络不可用
#if TEST_163_LOSS
            _postID = [NSNumber numberWithInteger:10798];
#endif
            [[ItemStore sharedItemStore] fetchContentsFromDatabaseWithPostID:_postID completion:^(NSArray *contents) {
                //移除等待view
//                [weakSelf removeActivityView:activityView];
                //处理数据
                if (contents.count > 0) {
                    weakSelf.contents = [[Contents alloc] initWithContents:contents];
                    
                    weakSelf.cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:weakSelf.contents.contentItems.count];
                    weakSelf.cellsDic = [NSMutableDictionary dictionaryWithCapacity:weakSelf.contents.contentItems.count];
                    
                    [weakSelf caculatorHeight];
                    
                    [weakSelf.tableView reloadData];
                } else {
                    [weakSelf addNoNetworkView];
                }
            }];
        }
    }];
}

- (CGFloat)cellHeightForRow:(NSInteger)row
{
    NSInteger count = 0;
    Content *content = nil;
    NSInteger preCount = 0;
    NSInteger temp = 0;
    
    for (NSArray *array in _contents.contentItems) {
        preCount = count;
        if (array.count == 0)
            temp = 0;
        else
            temp = array.count > 1 ? (array.count+1) : 1;
        count += temp;
        if ((row+1) <= count) {
            NSInteger tempIndex = row+1-preCount; //preCount为之前所有栋的总行数，tempIndex是当前这一栋的第几行
            if (tempIndex == 1 && array.count>1) {  //如果是这一栋的第一行
                content = [array lastObject];
                break;
            } else if (array.count == 1){   //表示只有一层
                content = [array objectAtIndex:0];
                break;
            } else if (tempIndex == 1){
                content = [array lastObject];
                break;
            } else {
                content = [array objectAtIndex:tempIndex-2];
                break;
            }
            
        }
    }
    
    NSString *cellID;
    NSInteger currRows,preAllRows;
    currRows = content.currRows.integerValue;
    preAllRows = content.preAllRows.integerValue;
    if (currRows == 1)
        cellID = kCommCellTypeOnlyOne;
    else {
        if ( ( (row+1) == (preAllRows+1)))
            cellID = kCommCellTypeTop;
        else if ((row+1) == currRows+preAllRows)
            cellID = kCommCellTypeBottom;
        else
            cellID = kCommCellTypeMiddle;
    }
    CommCell5 *cell = [_tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CommCell5 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    CGFloat cellHeight;
    NSInteger floorCount =0;
    if (currRows >0)
        floorCount = currRows > 1?currRows-1:1;
    
    NSString *key = [NSString stringWithFormat:@"%zi",row];
    NSArray *array = @[content,@(floorCount),cellID];
    [_contentInfoDic setObject:array forKey:key];
    
    [cell bindContent:content floorCount:floorCount forHeight:&cellHeight fontSizeChanged:isChanged];
    
    return cellHeight;
}

- (void)caculatorHeight
{
    [_cellsHeight removeAllObjects];
    
    NSInteger numOfCell = [self tableView:_tableView numberOfRowsInSection:0];
    _cellsHeight = [[NSMutableArray alloc] initWithCapacity:numOfCell];
    for (NSInteger i = 0; i < numOfCell; i++) {
        CGFloat h = [self cellHeightForRow:i];
        [_cellsHeight addObject:@(h)];
    }
}

#pragma mark - 指示视图
- (UIActivityIndicatorView *)addActivityViewInView:(UIView *)view
{
    //如果往scrollView上添加subView,则对于8.0以下的系统要使用frame，不能使用autolayout
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:activityView];
    
    NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *vConstraint = [NSLayoutConstraint constraintWithItem:activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.view addConstraints:@[hConstraint,vConstraint]];
    
    [activityView startAnimating];
    return activityView;
}

- (void)removeActivityView:(UIActivityIndicatorView *)activityView
{
    [activityView stopAnimating];
    [activityView removeFromSuperview];
    activityView = nil;
}

- (void)addNoNetworkView
{
    UIControl *noNetworkView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    noNetworkView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [noNetworkView addTarget:self action:@selector(reloadContents:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加提示label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:24];
    label.textColor = RGBCOLOR(153, 153, 153, 1);
    label.text = @"网络不可用\n点击屏幕重新加载";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(noNetworkView.frame.size.width/2,noNetworkView.frame.size.height/2-64);
    [noNetworkView addSubview:label];   //别忘添加logo图片
    
    self.tableView.tableHeaderView= noNetworkView;
    self.tableView.scrollEnabled = NO;
}

#pragma mark - 显示菜单
- (ZFQMenuObject *)menuObject
{
    if (!_menuObject) {
        _menuObject = [[ZFQMenuObject alloc] init];
    }
    return _menuObject;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copyContent) || action == @selector(shareContent) || action == @selector(snapshootContent)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)copyContent
{
    [_assistCell copyContentToPasteboard];
}

- (void)snapshootContent
{
    NSLog(@"快照");
}

- (void)shareContent
{
    NSLog(@"分享");
}

#pragma mark - 重新加载
- (void)reloadContents:(UIControl *)control
{
    __block UIControl *weakControl = control;
    CommViewController *__weak weakSelf = self;
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {  //网络可用
            //更新UI
            weakSelf.tableView.tableHeaderView = nil;
            weakSelf.tableView.scrollEnabled = YES;
            weakControl = nil;
            UIActivityIndicatorView *activityView = [self addActivityViewInView:self.tableView];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#if TEST_163_LOSS
            NSString *url = @"http://163pinglun.com/wp-json/posts/10798/comments";
#else
            NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/wp-json/posts/%@/comments",[NSString stringWithFormat:@"%zi",[_postID integerValue]]];
#endif
            [ItemStore sharedItemStore].cotentsURL = url;
            [[ItemStore sharedItemStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
                weakSelf.contents = contents;
                weakSelf.cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:contents.contentItems.count];
                weakSelf.cellsDic = [NSMutableDictionary dictionaryWithCapacity:contents.contentItems.count];
                
                //更新UI
                [weakSelf removeActivityView:activityView];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf.tableView reloadData];
            }];
        }
    }];
   
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_contents == nil)
		return 0;
    else {
        //cell行数
        int count = 0;
        for (NSArray *arry in _contents.contentItems) {
            if (arry.count == 1)
                count += 1;
            else if (arry.count > 1)
                count += (arry.count+1);
        }
        cellCount = count;
        return count;
    }
}

- (NSString *)cellIDWithFloorCount:(NSInteger)floorCount floorIndex:(NSInteger)floorIndex
{
    NSString *cellID = nil;
    if (floorCount == 0)
        return cellID;
    
    if (floorCount == 1) {
        cellID = kCommCellTypeOnlyOne;
    } else {
        if (floorCount == 1)
            cellID = kCommCellTypeBottom;
        else if(floorIndex == floorCount)  //这里floorindex=1应有top和bottom类型
            cellID = kCommCellTypeTop;
        else
            cellID = kCommCellTypeMiddle;
    }
        
    return cellID;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%zi",indexPath.row];
    NSArray *arry = [_contentInfoDic objectForKey:key];
    Content *content = arry[0];
    NSNumber *floorCountNum = arry[1];
    NSString *cellID = arry[2];
    CommCell5 *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CommCell5 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell bindContent:content floorCount:floorCountNum.integerValue fontSizeChanged:isChanged];

    //显示菜单
    _assistCell = cell;
    CommViewController * __weak weakSelf = self;
    cell.hightlightBlk = ^(NSString *content,CGRect contentFrame) {
        weakSelf.menuObject.content = content;
        weakSelf.menuObject.contentFrame = contentFrame;
        weakSelf.menuObject.hostView = weakSelf.view;
        [weakSelf.view becomeFirstResponder];
        [weakSelf.menuObject showMenu];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *cellHeightNum = [_cellsHeight objectAtIndex:indexPath.row];
    return cellHeightNum.floatValue;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.view.window==nil && self.view.superview==nil) {
        self.view = nil;
        [_cellsDic removeAllObjects];
        _cellsDic = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FontSizeChangeNotification object:nil];
    DNSLog(@"释放 commentVC");
}
@end

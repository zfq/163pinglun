//
//  CommViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommViewController.h"
#import "CommCell.h"
#import "ItemStore.h"
#import "Contents.h"
//#import "MBProgressHUD.h"
#import "Reachability.h"

static NSString * const CellIdentifier = @"CommCell";

@interface CommViewController ()
{
    NSMutableDictionary *_cellsHeightDic;
    NSMutableDictionary *_cellsDic;
}
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
    
	// 设置tableView
	self.tableView.allowsSelection = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"CommCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    //获取跟帖
	[self fetchComment];
    
    //注册设置字体大小通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[ItemStore sharedItemStore] cancelCurrentRequtest];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
#pragma mark - 设置字体
- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [_cellsHeightDic removeAllObjects];
    [self.tableView reloadData];
}

- (void)fetchComment
{
    //如果网络可用，就从网络中获取数据
    //在保存之前先把数据库里面的关于该post的content删掉，，然后保存到数据库中，
    //否则就从数据库里去取
    
    //添加等待view
    __block UIActivityIndicatorView *activityView = [self addActivityViewInView:self.tableView];
    
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {  //网络可用
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/wp-json/posts/%@/comments",[NSString stringWithFormat:@"%d",[_postID integerValue]]];
            [ItemStore sharedItemStore].cotentsURL = url;
            [[ItemStore sharedItemStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
                _contents = contents;
                _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                _cellsDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                
                //更新UI
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self removeActivityView:activityView];
                [self.tableView reloadData];
            }];
        } else {    //网络不可用
            
            [[ItemStore sharedItemStore] fetchContentsFromDatabaseWithPostID:_postID completion:^(NSArray *contents) {
                //移除等待view
                [self removeActivityView:activityView];
                
                //处理数据
                if (contents.count > 0) {
                    _contents = [[Contents alloc] initWithContents:contents];
                    _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                    _cellsDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                    [self.tableView reloadData];
                } else {
                    [self addNoNetworkView];
                }
            }];
        }
    }];
}

#pragma mark - 指示视图
- (UIActivityIndicatorView *)addActivityViewInView:(UIView *)view
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ([view isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)view;
        
        activityView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2-NAV_HEIGHT(self)-STATUSBAR_HEIGHT); 
        [tableView addSubview:activityView];
    } else {
        activityView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        [view addSubview:activityView];
    }
    
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.tableView.frame, 30, 30)];
    label.font = [UIFont systemFontOfSize:24];
    label.textColor = RGBCOLOR(153, 153, 153, 1);
    label.text = @"网络不可用\n点击屏幕重新加载";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(self.tableView.frame.size.width/2,self.tableView.frame.size.height/2-self.tableView.contentInset.top);
    [noNetworkView addSubview:label];   //别忘添加logo图片
    self.tableView.tableHeaderView = noNetworkView;
    self.tableView.scrollEnabled = NO;
}

#pragma mark - 重新加载
- (void)reloadContents:(UIControl *)control
{
    __block UIControl *weakControl = control;
    
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {  //网络可用
            //更新UI
            self.tableView.tableHeaderView = nil;
            self.tableView.scrollEnabled = YES;
            weakControl = nil;
            __block UIActivityIndicatorView *activityView = [self addActivityViewInView:self.tableView];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            //加载数据
            NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/wp-json/posts/%@/comments",[NSString stringWithFormat:@"%d",[_postID integerValue]]];
            [ItemStore sharedItemStore].cotentsURL = url;
            [[ItemStore sharedItemStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
                _contents = contents;
                _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                _cellsDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                
                //更新UI
                [self removeActivityView:activityView];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.tableView reloadData];
            }];
        }
    }];
   
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_contents == nil)
		return 0;
	else
		return _contents.contentItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[CommCell alloc] init];
	} else {
        //删除所有添加的子视图，除xib内的几个之外
		@autoreleasepool
        {
            NSArray *subViews = cell.contentView.subviews;
            [subViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *subView = (UIView *)obj;
                NSInteger tag = subView.tag;
                if (tag != 50 && tag != 51) {
                    [subView removeFromSuperview];
                    subView = nil;
                }
            }];
		}
	}
    
    [cell setCommModel:[_contents.contentItems objectAtIndex:(_contents.contentItems.count - indexPath.row - 1)]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *row = [NSNumber numberWithInteger:indexPath.row];
    NSNumber *height = [_cellsHeightDic objectForKey:row];
    return height.floatValue;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *row = [NSNumber numberWithInteger:indexPath.row];
    NSNumber *height = [_cellsHeightDic objectForKey:row];
    if (height != nil) {
        return height.floatValue;
    } else {
        CommCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        CGFloat cellHeight = [cell heightWithCommModel:[_contents.contentItems objectAtIndex:(_contents.contentItems.count - indexPath.row - 1)]];
        [_cellsHeightDic setObject:[NSNumber numberWithFloat:cellHeight] forKey:row];
        return cellHeight;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_cellsHeightDic removeAllObjects];
    _cellsHeightDic = nil;
    [_cellsDic removeAllObjects];
    _cellsDic = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}
@end

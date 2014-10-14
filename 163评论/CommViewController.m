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
#import "Content.h"
//#import "MBProgressHUD.h"
#import "Reachability.h"

static NSString * const CellIdentifier = @"CommCell";

@interface CommViewController ()
{
    NSMutableDictionary *_cellsHeightDic;
    NSMutableDictionary *_cellsDic;
    NSInteger cellCount;
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
    
    // 添加返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.backgroundColor = [UIColor redColor];
    backBtn.frame = CGRectMake(10, 22, 60, 40);
    [backBtn setImage:[UIImage imageNamed:@"navgation_back"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:RGBCOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
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

- (void)back:(UIButton *)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
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
            [ItemStore sharedItemStore].cotentsURL = @"http://163pinglun.com/wp-json/posts/1197/comments";
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
        //tableView.frame.size.height/2-NAV_HEIGHT(self)-STATUSBAR_HEIGHT
        activityView.center = CGPointMake(tableView.frame.size.width/2, tableView.frame.size.height/2);
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:24];
    label.textColor = RGBCOLOR(153, 153, 153, 1);
    label.text = @"网络不可用\n点击屏幕重新加载";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(noNetworkView.frame.size.width/2,noNetworkView.frame.size.height/2-64);
    [noNetworkView addSubview:label];   //别忘添加logo图片
    
    [self.tableView addSubview:noNetworkView];
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
            
            //加载数据 1197
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
    NSInteger count = 0;    //帖子总数
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
        if ((indexPath.row+1) <= count ) {
            NSInteger tempIndex = indexPath.row+1-preCount; //preCount为行数 tempIndex为content在当前块中所在的行
            if (tempIndex == 1 && array.count>1) {
                content = [array lastObject];
                break;
            } else if (array.count == 1){
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
        if ((indexPath.row+1) == (preAllRows+1))
            cellID = kCommCellTypeTop;
        else if ((indexPath.row+1) == currRows+preAllRows)
            cellID = kCommCellTypeBottom;
        else
            cellID = kCommCellTypeMiddle;
    }
    
    CommCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
		cell = [[CommCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
    
    [cell bindContent:content floorCount:count height:NULL];
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
        
        NSInteger count = 0;
        Content *content = nil;
        NSInteger preCount = 0;
//        BOOL isFind = NO;
        NSInteger temp = 0;
        /*
        NSInteger arraySize = _contents.contentItems.count;
        for (NSInteger i=arraySize-1; i>=0; i--) {
            NSArray *array = [_contents.contentItems objectAtIndex:i];
            preCount = count;
            count += array.count;
            if ((indexPath.row) <= count ) {
                NSInteger tempIndex = indexPath.row-preCount;
                if (tempIndex == 0 && array.count>1) {
                    content = [array lastObject];
                    break;
                } else {
                    if (array.count == 0)
                        content = [array objectAtIndex:0];
                    else
                        content = [array objectAtIndex:tempIndex-1];
                    break;
                }
                
            }
            
        }
         */
      
        for (NSArray *array in _contents.contentItems) {
            preCount = count;
            if (array.count == 0)
                temp = 0;
            else
                temp = array.count > 1 ? (array.count+1) : 1;
            count += temp;
            if ((indexPath.row+1) <= count) {
                NSInteger tempIndex = indexPath.row+1-preCount; //preCount为之前块的行数
                if (tempIndex == 1 && array.count>1) {
                    content = [array lastObject];
                    break;
                } else if (array.count == 1){
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
//        if (count > 1 &&  ((indexPath.row+1) == cellCount))    //最后一行一定是bottom类型
//            cellID = kCommCellTypeBottom;
//        else
//            cellID = [self cellIDWithFloorCount:count floorIndex:content.floorIndex.integerValue];
        NSInteger currRows,preAllRows;
        currRows = content.currRows.integerValue;
        preAllRows = content.preAllRows.integerValue;
        if (currRows == 1)
            cellID = kCommCellTypeOnlyOne;
        else {
            if ( ( (indexPath.row+1) == (preAllRows+1)))
                cellID = kCommCellTypeTop;
            else if ((indexPath.row+1) == currRows+preAllRows)
                cellID = kCommCellTypeBottom;
            else
                cellID = kCommCellTypeMiddle;
        }
        CommCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[CommCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        CGFloat cellHeight;
        [cell bindContent:content floorCount:count height:&cellHeight];
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

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
	// Do any additional setup after loading the view from its nib.
	self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[CommCell class] forCellReuseIdentifier:CellIdentifier];
	[self fetchComment];
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
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)fetchComment
{
    //如果网络可用，就从网络中获取数据
    //在保存之前先把数据库里面的关于该post的content删掉，，然后保存到数据库中，
    //否则就从数据库里去取
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {  //网络可用
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/wp-json/posts/%@/comments",  //2708 1 2935 @"http://163pinglun.com/wp-json/posts/2390/comments"
                             [NSString stringWithFormat:@"%d",[_postID integerValue]]];
            [ItemStore sharedItemStore].cotentsURL = url; // 2935 10617 12402 12404 7785 2708 //多层 多cell2390 无10316
            [[ItemStore sharedItemStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
                _contents = contents;
                _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                _cellsDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.tableView reloadData];
            }];
        } else {    //网络不可用
            NSArray *contentArray = [[ItemStore sharedItemStore] fetchContentsFromDatabaseWithPostID:_postID];
            if (contentArray.count > 0) {
                _contents = [[Contents alloc] initWithContents:contentArray];
                _cellsHeightDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                _cellsDic = [NSMutableDictionary dictionaryWithCapacity:_contents.contentItems.count];
                [self.tableView reloadData];
            }
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
        CGFloat height = [cell heightWithCommModel:[_contents.contentItems objectAtIndex:(_contents.contentItems.count - indexPath.row - 1)]];
        [_cellsHeightDic setObject:[NSNumber numberWithFloat:height] forKey:row];
        return height;
    }
}

@end

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
#import "MBProgressHUD.h"

@interface CommViewController ()
{
    
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
	UINib *cellNib = [UINib nibWithNibName:@"CommCell" bundle:nil];
	[self.tableView registerNib:cellNib forCellReuseIdentifier:@"CommCell"];
	[self fetchComment];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
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
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *url = [NSString stringWithFormat:@"http://163pinglun.com/wp-json/posts/%@/comments",_postID];
	[ItemStore sharedTagStore].cotentsURL = url; // 2935 10617 12402 12404 7785
	[[ItemStore sharedTagStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
	    _contents = contents;
	    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	    [self.tableView reloadData];
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
	CommCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommCell"];

	if (cell == nil) {
		cell = [[CommCell alloc] init];
	}
	else { //删除所有添加的子视图，除xib内的几个之外
		@autoreleasepool {
            NSEnumerator *subviews = [cell.contentView.subviews reverseObjectEnumerator];
			for (UIView *v in subviews) {
				if (v.tag != 50 && v.tag != 51)
                    [v removeFromSuperview];
			}
		}
	}
    cell.commModel = [_contents.contentItems objectAtIndex:(_contents.contentItems.count - indexPath.row - 1)];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommCell *cell = [[NSBundle mainBundle] loadNibNamed:@"CommCell" owner:self options:nil][0];
    [cell setCommModel:[_contents.contentItems objectAtIndex:(_contents.contentItems.count - indexPath.row - 1)]];
    return [cell height];
}

@end

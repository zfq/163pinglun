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

@interface HomeViewController ()
{
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
    // Do any additional setup after loading the view from its nib.
    UINib *cellNib = [UINib nibWithNibName:@"PostCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"PostCell"];
    
    [self fetchPost];
//    self.tableView.contentOffset = CGPointMake(0, -40.0f);
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - fetch posts
- (void)fetchPost
{
    NSArray *postArray = [[ItemStore sharedItemStore] fetchPostsFromDatabase];
    if (postArray.count == 0) {     //fetch posts from network
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [ItemStore sharedItemStore].cotentsURL = @"http://163pinglun.com/wp-json/posts";
        [[ItemStore sharedItemStore] fetchPostsWithCompletion:^(Posts *posts, NSError *error) {
            _posts = posts;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            [self.tableView reloadData];
        }];
    } else {        //fetch posts from database
        _posts = [[Posts alloc] initWithPosts:postArray];
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
    Post *tempPost = [_posts.postItems objectAtIndex:indexPath.row];
    CommViewController *cVC = [[CommViewController alloc] init];
    cVC.postID = [NSString stringWithFormat:@"%d",[tempPost.postID integerValue]];
    
    [self presentViewController:cVC animated:YES completion:nil];
}
@end



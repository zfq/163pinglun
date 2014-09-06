//
//  LookAroundViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-8-31.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "RandomPostViewController.h"
#import "RandomPostView.h"
#import "ItemStore.h"
#import "RandomPosts.h"
#import "RandomPost.h"

static NSString *randomCellIdentifier = @"randomCell";

@interface RandomPostViewController ()
{
    UIView *maskView;
    
    CGFloat marginLeft;
    CGFloat beginTapX;
    CGFloat originAlpha;
}
@end

@implementation RandomPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    RandomPostView *view = [[RandomPostView alloc] initWithFrame:[UIScreen mainScreen].bounds]; //[UIScreen mainScreen].bounds
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    originAlpha = 0.7;
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEITHT)];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [self.view addSubview:maskView];
    
    //添加tableView
    marginLeft = 55;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 65, SCREEN_WIDTH-marginLeft, SCREEN_HEITHT-65) style:UITableViewStylePlain];
    tableView.dataSource = self;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [tableView addGestureRecognizer:panGesture];
    [self.view addSubview:tableView];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = tableView.frame;
        rect.origin.x = marginLeft;
        tableView.frame = rect;
        maskView.alpha = originAlpha;
    } completion:nil];
    
    //加载数据
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ItemStore sharedItemStore] fetchRandomPostsWithCompletion:^(RandomPosts *randomPosts, NSError *error) {
        _posts = randomPosts.randomPosts;
        [tableView reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showRandomPostView
{
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    [keywindow.rootViewController.view addSubview:self.view];
}

- (void)dismissRandomPostView
{
    [self.view removeFromSuperview];
    
}

#pragma mark - tableView datasource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_posts == nil)
        return 0;
    else
        return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"randomCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"randomCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    RandomPost *post = [_posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.title;
    return cell;
}

#pragma mark - pan gesture
- (void)move:(UIPanGestureRecognizer *)gesture
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGFloat x = [gesture locationInView:keyWindow].x;
    UIView *gestureView = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginTapX = x;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if ((x-beginTapX+marginLeft) <= marginLeft) {
            [self moveView:gestureView toX:marginLeft];
            maskView.alpha = originAlpha;
        } else {
            [self moveView:gestureView toX:(x-beginTapX+marginLeft)];
            maskView.alpha = originAlpha - originAlpha*(x-beginTapX)/(x-beginTapX+marginLeft);
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        CGFloat deltaX = x - beginTapX;
        if (deltaX > 50) {  //移除marskView
            [UIView animateWithDuration:0.3 animations:^{
                [self moveView:gestureView toX:SCREEN_WIDTH];
                maskView.alpha = 0;
            } completion:^(BOOL finished) {
                [gestureView removeFromSuperview];
                [maskView removeFromSuperview];
                [self.view removeFromSuperview];
                
                //取消当前请求
                [[ItemStore sharedItemStore] cancelCurrentRequtest];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveView:gestureView toX:marginLeft];
                maskView.alpha = originAlpha;
            }];
        }
    }
}

- (void)moveView:(UIView *)view toX:(CGFloat)x
{
    CGFloat width = SCREEN_WIDTH;
    x = (x > width ? width : x);
    x = (x < 0 ? 0 : x);
    CGRect originFrame = view.frame;
    originFrame.origin.x = x;
    view.frame = originFrame;
}
@end

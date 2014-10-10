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
    UITableView *postTableView;
    
    UIPanGestureRecognizer *panGesture;
    CGFloat marginLeft;
    CGFloat beginTapX;
    CGFloat originAlpha;
    
    CGPoint beginTapPoint;
    CGPoint currTapPoint;
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
    RandomPostView *view = [[RandomPostView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat navHeight = 64;
    originAlpha = 0.7;
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, SCREEN_WIDTH, SCREEN_HEITHT-navHeight)];
    maskView.backgroundColor = [UIColor blackColor]; //blackColor
    maskView.alpha = 0;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [maskView addGestureRecognizer:tapGesture];
    [self.view addSubview:maskView];
    
    //添加tableView
    marginLeft = 55;
    
    postTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, navHeight, SCREEN_WIDTH-marginLeft, SCREEN_HEITHT-navHeight) style:UITableViewStylePlain]; //65
    postTableView.dataSource = self;
    postTableView.delegate = self;
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.delegate = self;
    [postTableView addGestureRecognizer:panGesture];
    [self.view addSubview:postTableView];
    
    //添加nav阴影
    UIImage *navImg = [UIImage imageNamed:@"navigationbar_background"];
    UIImageView *navImgView = [[UIImageView alloc] initWithImage:navImg];
    navImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, navImg.size.height);
    [self.view addSubview:navImgView];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = postTableView.frame;
        rect.origin.x = marginLeft;
        postTableView.frame = rect;
        maskView.alpha = originAlpha;
    } completion:nil];
    
    //加载数据
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ItemStore sharedItemStore] fetchRandomPostsWithCompletion:^(RandomPosts *randomPosts, NSError *error) {
        _posts = randomPosts.randomPosts;
        [postTableView reloadData];
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
    [postTableView removeFromSuperview];
    [maskView removeFromSuperview];
    postTableView = nil;
    maskView = nil;
    
    self.posts = nil;
    self.view = nil;
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

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    panGesture.enabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    panGesture.enabled = YES;
}
#pragma mark - tap gesture
- (void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.3 animations:^{
        [self moveView:postTableView toX:SCREEN_WIDTH];
        maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [gesture.view removeGestureRecognizer:gesture];
        [self dismissRandomPostView];
        [[ItemStore sharedItemStore] cancelCurrentRequtest];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];

    gesture = nil;
}

#pragma mark - pan gesture
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    currTapPoint = [gesture locationInView:keyWindow];
    CGFloat x = currTapPoint.x;
    UIView *gestureView = gesture.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginTapX = x;
        beginTapPoint = currTapPoint;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {

        //修复panGesture冲突问题
        currTapPoint = [gesture locationInView:keyWindow];
        CGPoint translation = CGPointMake(currTapPoint.x-beginTapPoint.x, currTapPoint.y-beginTapPoint.y);
        if (fabsf(translation.x) <= fabsf(translation.y) && (fabsf(translation.y)>=4))
        {
            return ;
        }
        
        
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
        if (deltaX > gestureView.frame.size.width/2) {  //移除marskView
            
            [UIView animateWithDuration:0.3 animations:^{
                [self moveView:gestureView toX:SCREEN_WIDTH];
                maskView.alpha = 0;
            } completion:^(BOOL finished) {
                [self dismissRandomPostView];
                //取消当前请求
                [[ItemStore sharedItemStore] cancelCurrentRequtest];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
            //移除pan手势
            [gesture.view removeGestureRecognizer:gesture];
            gesture = nil;
            
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

#pragma mark - UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)dealloc
{
    [postTableView removeGestureRecognizer:panGesture];
    panGesture = nil;
    postTableView = nil;
    maskView = nil;
}

@end

//
//  LookAroundViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-8-31.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "RandomPostViewController.h"
#import "ItemStore.h"
#import "RandomPosts.h"
#import "RandomPost.h"
#import "CommViewController.h"
#import "UITableView+SmoothMove.h"
#import "PlaceholderView.h"
//#import "RandomPostCell.h"

static NSString *reuseId = @"RandomPostCell";

@interface RandomPostViewController ()
{
    UIControl *maskView;
    UITableView *postTableView;
    UIView *postFooterView;
    UIPanGestureRecognizer *panGesture;
    CGFloat marginLeft;
    CGFloat beginTapX;
    CGFloat originAlpha;
    
    CGPoint beginTapPoint;
    CGPoint currTapPoint;
    
    BOOL hasLoaded;
    BOOL resetPostTableViewPositon;
    NSRegularExpression *reg;
}
@end

@implementation RandomPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hasLoaded = NO;
        resetPostTableViewPositon = YES;
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //添加maskView
    originAlpha = 0.7;
    maskView = [[UIControl alloc] init];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [maskView addTarget:self action:@selector(tapMaskView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:maskView];

    //添加tableView
    postTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    postTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    postTableView.dataSource = self;
    postTableView.delegate = self;
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.delegate = self;
    [postTableView addGestureRecognizer:panGesture];
    
    [self.view addSubview:postTableView];
    [postTableView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
    /*
//    [self.view insertSubview:postTableView aboveSubview:maskView];
    
    
    //为postTableView添加约束
//    marginLeft = (55 * (self.view.frame.size.width))/320.0f;
    marginLeft = 55;
    NSDictionary *nameMap1 = @{@"postTable":postTableView};
    postTableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *tableViewConsH = [NSLayoutConstraint constraintWithItem:postTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-64];
//    NSLayoutConstraint *tableViewConsW = [NSLayoutConstraint constraintWithItem:postTableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-marginLeft];
//    [self.view addConstraints:@[tableViewConsH,tableViewConsW]];
    [self.view addConstraint:tableViewConsH];
    NSString *vfH = [NSString stringWithFormat:@"H:|-%f-[postTable(>=0)]-0-|",marginLeft];
    NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:vfH options:0 metrics:nil views:nameMap1];
    NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[postTable]" options:0 metrics:nil views:nameMap1];
    [self.view addConstraints:consH];
    [self.view addConstraints:consV];
    
    //添加nav阴影
    UIImage *navImg = [UIImage imageNamed:@"navigationbar_background"];
    UIImageView *navImgView = [[UIImageView alloc] initWithImage:navImg];
    [self.view addSubview:navImgView];
    
    //为maskView和navImgView添加约束
    NSDictionary *nameMap2 = @{@"mask":maskView,@"navImg":navImgView};
    maskView.translatesAutoresizingMaskIntoConstraints = NO;
    navImgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *maskViewConsH = [NSLayoutConstraint constraintWithItem:maskView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-64];//-64
    [self.view addConstraint:maskViewConsH];
    NSArray *maskConsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mask(>=0)]-0-|" options:0 metrics:nil views:nameMap2];
    NSArray *maskConsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mask]-0-|" options:0 metrics:nil views:nameMap2];
    [self.view addConstraints:maskConsH];
    [self.view addConstraints:maskConsV];
    
    //设置maskView透明度渐变及tableView的滑入
   
    CGRect originRect = postTableView.frame;
    originRect.origin.x = self.view.frame.size.width;
    postTableView.frame = originRect;
   
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = postTableView.frame;
        rect.origin.x = marginLeft;
        postTableView.frame = rect;
        maskView.alpha = originAlpha;
    } completion:nil];
    
    //加载数据
    [self loadRandomPostData];
     */
    //注册cell
//    UINib *nib = [UINib nibWithNibName:@"RandomPostCell" bundle:nil];
//    [postTableView registerNib:nib forCellReuseIdentifier:reuseId];
}

- (void)loadRandomPostData
{
    //加载数据
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_posts removeAllObjects];
    [[ItemStore sharedItemStore] fetchRandomPostsWithCompletion:^(RandomPosts *randomPosts, NSError *error) {
        if (error == nil) {
            _posts = randomPosts.randomPosts;
            if (_posts.count >0) {
                postTableView.tableHeaderView = nil;
                [postTableView setTableFooterView:[self randomPostFooterView]];
                [postTableView beginSmoothMoveAnimationWithCount:_posts.count];
//                [postTableView reloadData];
            }
        } else {
            //添加占位符
            UIView *pView = [[PlaceholderView alloc] initWithFrame:postTableView.bounds content:@"网络不可用\n请检查网络" fontSize:20];
            postTableView.tableHeaderView = pView;
        }
    
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [postTableView deselectRowAtIndexPath:[postTableView indexPathForSelectedRow]  animated:YES];
    
    //如果已经加载过了且postTableView已经在预定的位置
    if ( (hasLoaded == YES) && (resetPostTableViewPositon == NO) ) {
        return;
    }
    
    if (hasLoaded == NO) {
        //为postTableView添加约束
        marginLeft = (55 * (self.view.frame.size.width))/320.0f;
        NSDictionary *nameMap1 = @{@"postTable":postTableView};
        postTableView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *tableViewConsH = [NSLayoutConstraint constraintWithItem:postTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-64];
        NSLayoutConstraint *tableViewConsW = [NSLayoutConstraint constraintWithItem:postTableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-marginLeft];
        [self.view addConstraints:@[tableViewConsH,tableViewConsW]];
        
        NSString *vfH = [NSString stringWithFormat:@"H:|-%f-[postTable]",marginLeft];
        NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:vfH options:0 metrics:nil views:nameMap1];
        NSArray *consV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[postTable]" options:0 metrics:nil views:nameMap1];
        [self.view addConstraints:consH];
        [self.view addConstraints:consV];
        
        //添加nav阴影
        UIImage *navImg = [UIImage imageNamed:@"navigationbar_background"];
        UIImageView *navImgView = [[UIImageView alloc] initWithImage:navImg];
        [self.view addSubview:navImgView];
        
        //为maskView和navImgView添加约束
        NSDictionary *nameMap2 = @{@"mask":maskView,@"navImg":navImgView};
        maskView.translatesAutoresizingMaskIntoConstraints = NO;
        navImgView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *maskViewConsH = [NSLayoutConstraint constraintWithItem:maskView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-64];//-64
        [self.view addConstraint:maskViewConsH];
        NSArray *maskConsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mask(>=0)]-0-|" options:0 metrics:nil views:nameMap2];
        NSArray *maskConsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mask]-0-|" options:0 metrics:nil views:nameMap2];
        [self.view addConstraints:maskConsH];
        [self.view addConstraints:maskConsV];
    }
    
    //设置maskView透明度渐变及tableView的滑入
    if (resetPostTableViewPositon == YES) {
        CGRect originRect = postTableView.frame;
        originRect.origin.x = self.view.frame.size.width;
        postTableView.frame = originRect;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = postTableView.frame;
        rect.origin.x = marginLeft;
        postTableView.frame = rect;
        maskView.alpha = originAlpha;
    } completion:nil];
    
    //加载数据
    [self loadRandomPostData];
    
    hasLoaded = YES;
    resetPostTableViewPositon = NO;
    
}

- (void)showRandomPostView
{
    [self willMoveToParentViewController:self.parentViewController];
    
    [_posts removeAllObjects];
    postTableView.tableFooterView = nil;
    [self.parentViewController.view addSubview:self.view];
    
    //为self.view添加约束
    NSDictionary *nameMap = @{@"viewSelf":self.view};
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *viewConsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[viewSelf(>=0)]-0-|" options:0 metrics:nil views:nameMap];
    NSArray *viewConsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[viewSelf(>=0)]-0-|" options:0 metrics:nil views:nameMap];
    [self.parentViewController.view addConstraints:viewConsH];
    [self.parentViewController.view addConstraints:viewConsV];
    
    [self didMoveToParentViewController:self.parentViewController];

    resetPostTableViewPositon = YES;
}

- (void)dismissRandomPostView
{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    [postTableView removeGestureRecognizer:panGesture];
    [[ItemStore sharedItemStore] cancelCurrentRequtest];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dismissRandomPostViewWithAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self moveView:postTableView toX:SCREEN_WIDTH];
            maskView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self dismissRandomPostView];
            }
        }];
    } else {
        [self dismissRandomPostView];
    }
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
//    RandomPostCell *cell = (RandomPostCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
    RandomPost *post = [_posts objectAtIndex:indexPath.row];
//    cell.myContentLabel.text = post.title;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"randomCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"randomCell"];
    }
    cell.textLabel.text = post.title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RandomPost *post = [_posts objectAtIndex:indexPath.row];
    CommViewController *cVC = [[CommViewController alloc] init];
    NSString *postID = [self postIDFromURL:post.postURL];
    cVC.postID = [NSNumber numberWithInteger:[postID integerValue]];
    [self.parentViewController.navigationController pushViewController:cVC animated:YES];
}

#pragma mark - footer view
- (UIView *)randomPostFooterView
{
    if (postFooterView == nil) {
        postFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, postTableView.frame.size.width, 50)];
        postFooterView.backgroundColor = [UIColor clearColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"换一组" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [button setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0]];
        button.layer.borderWidth = 1;
        button.layer.borderColor = SEPARATOR_COLOR.CGColor;
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(loadNewPosts:) forControlEvents:UIControlEventTouchUpInside];
        [postFooterView addSubview:button];
        //为btn添加约束
        button.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *btnConsW = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:100];
        NSLayoutConstraint *btnConsH = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:44];
        [button addConstraints:@[btnConsW,btnConsH]];
        NSLayoutConstraint *btnConsCenterX = [NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:postFooterView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0];
        NSLayoutConstraint *btnConsCenterY = [NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:postFooterView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0 constant:0];
        [postFooterView addConstraints:@[btnConsCenterX,btnConsCenterY]];
        
    }
    return postFooterView;
}

- (void)loadNewPosts:(UIButton *)button
{
    [self loadRandomPostData];
}

- (NSString *)postIDFromURL:(NSString *)postURL
{
    if (reg == nil) {
        NSString *regularStr = @"(\\d+?)$";
        NSError *error = nil;
        reg = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
        if (error != nil) {
            DNSLog(@"正则表达式出错:%@",NSStringFromSelector(_cmd));
            return nil;
        }
    }
    
    NSArray *results = [reg matchesInString:postURL options:NSMatchingReportCompletion range:NSMakeRange(0, postURL.length)];
    NSTextCheckingResult *checkResult = [results firstObject];
    
    return [postURL substringWithRange:[checkResult range]];
}

#pragma mark - tap action
- (void)tapMaskView
{
    [self dismissRandomPostViewWithAnimation:YES];
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
        postTableView.userInteractionEnabled = NO;
        currTapPoint = [gesture locationInView:keyWindow];
        CGFloat temp = (x-beginTapX+marginLeft);
        [self moveView:gestureView toX:temp];
        if (temp <marginLeft) {
            maskView.alpha = originAlpha;
        } else {
            maskView.alpha = originAlpha - originAlpha*(x-beginTapX)/temp;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        
        if (x - beginTapX > 100) {  //移除marskView
            
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
            
            [UIView animateWithDuration:0.2f animations:^{
                [self moveView:gestureView toX:marginLeft];
                maskView.alpha = originAlpha;
            } completion:^(BOOL finished) {
                if (finished) {
                    postTableView.userInteractionEnabled = YES;
                }
            }];
            
        }
        
    }
}

- (void)moveView:(UIView *)view toX:(CGFloat)x
{
    CGFloat width = SCREEN_WIDTH;
    x = (x > width ? width : x);
    x = (x < marginLeft ? marginLeft : x);

    CGRect originFrame = view.frame;
    originFrame.origin.x = x;
    view.frame = originFrame;
}

-(NSTimeInterval)animationDurationForDistance:(CGFloat)distance{
    NSTimeInterval duration = MAX(distance/840.f,0.20);
    return duration;
}

#pragma mark - UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    switch (postTableView.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            panGesture.enabled = NO;
        }break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            panGesture.enabled = YES;
        }break;
        default:
            break;
    }
    
}

- (void)dealloc
{
    [postTableView removeGestureRecognizer:panGesture];
    [postTableView removeObserver:self forKeyPath:@"panGestureRecognizer.state" context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.parentViewController == nil) {
        [postTableView removeGestureRecognizer:panGesture];
        [self.view removeFromSuperview];
        self.view = nil;
    }
    reg = nil;
}
@end

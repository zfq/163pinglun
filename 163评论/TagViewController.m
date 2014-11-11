//
//  TagViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "TagViewController.h"
#import "TagScrollView.h"
#import "ItemStore.h"
#import "Tag.h"
#import "Tags.h"
#import "Reachability.h"

@interface TagViewController () <TagScrollViewDelegate>
{
    UIControl *maskView;
    TagScrollView *tagScrollView;
    
    UIPanGestureRecognizer *panGesture;
    
    CGFloat marginLeft;
    CGFloat beginTapX;
    CGFloat beginTapY;
    CGFloat originAlpha;
    
    CGPoint beginTapPoint;
    CGPoint currTapPoint;
    
    BOOL isSuccessLoadedTag;  //判断tag是否成功加载出来
}
@end

@implementation TagViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    //添加maskView
    CGFloat navHeight = 64;
    originAlpha = 0.7;
    maskView = [[UIControl alloc] initWithFrame:CGRectMake(0, navHeight, SCREEN_WIDTH, SCREEN_HEIGHT-navHeight)];
    maskView.backgroundColor = [UIColor blackColor]; //blackColor
    maskView.alpha = 0;
    [maskView addTarget:self action:@selector(tapMaskView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:maskView];
    
    //添加scrollView
    marginLeft = 55;
    tagScrollView = [[TagScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 64, SCREEN_WIDTH-marginLeft, SCREEN_HEIGHT-64)];
    tagScrollView.backgroundColor = RGBCOLOR(254, 254, 254, 1);
    tagScrollView.leftMargin = 3;
    tagScrollView.rightMargin = 3;
    tagScrollView.topMargin = 3;
    tagScrollView.horizontalPadding = 3;
    tagScrollView.verticalPadding = 3;
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.delegate = self;
    [tagScrollView addGestureRecognizer:panGesture];
    [self.view addSubview:tagScrollView];
    
    [tagScrollView addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
    //添加nav阴影
    UIImage *navImg = [UIImage imageNamed:@"navigationbar_background"];
    UIImageView *navImgView = [[UIImageView alloc] initWithImage:navImg];
    navImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, navImg.size.height);
    [self.view addSubview:navImgView];
    
    //设置maskView透明度渐变及tableView的滑入
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = tagScrollView.frame;
        rect.origin.x = marginLeft;
        tagScrollView.frame = rect;
        maskView.alpha = originAlpha;
    } completion:nil];
    
    //加载数据 添加tagViews
    isSuccessLoadedTag = NO;
    [self loadTagData];
    
}

- (void)loadTagData
{
    //获取数据
    [Reachability isReachableWithHostName:HOST_NAME complition:^(BOOL isReachable) {
        if (isReachable) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [[ItemStore sharedItemStore] fetchTagsWithCompletion:^(Tags *tags, NSError *error) {
                if (tags.tagItems.count > 0) {
                    isSuccessLoadedTag = YES;
                    [self createTagViewsWithTags:tags.tagItems];
                } else {
                    isSuccessLoadedTag = NO;
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
            
        } else {
            NSArray *tagItems = [[ItemStore sharedItemStore] fetchTagsFromDatabase];
            [self createTagViewsWithTags:tagItems];
        }
    }];
    
}

#pragma mark - 创建tagViews
- (void)createTagViewsWithTags:(NSArray *)tagItems
{
    NSDictionary *colors = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tagColor" ofType:@"plist"]];
    NSMutableArray *tagViews = [NSMutableArray arrayWithCapacity:tagItems.count];
    //创建tagView
    __block Tag *tag = nil;
    [tagItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        tag = (Tag *)obj;
        TagView *view = [[TagView alloc] initWithTag:tag]; //tag.tagName
        NSDictionary *dic = [colors objectForKey:[tag.tagID stringValue]];
        NSString *colorName = [dic objectForKey:@"color"];
        if (colorName == nil) {
            view.tagLabel.textColor = [UIColor blackColor];
        }else {
            view.tagLabel.textColor = [self colorFromHexStr:colorName];
        }
        view.frame = CGRectMake(0, 0, view.frame.size.width+10, 50);
        view.centerVertically = YES;
        [view addTarget:self action:@selector(tapTagView:) forControlEvents:UIControlEventTouchUpInside];
        [tagViews addObject:view];
    }];
    
    tagScrollView.tagViews = tagViews;
}

#pragma mark - 辅助函数
- (UIColor *)colorFromHexStr:(NSString *)hexStr
{
    NSString *prefix = @"0x";
    NSString *r = [hexStr substringWithRange:NSMakeRange(0, 2)];
    NSString *g = [hexStr substringWithRange:NSMakeRange(2, 2)];
    NSString *b = [hexStr substringWithRange:NSMakeRange(4, 2)];
    
    unsigned int R = 0;
    unsigned int G = 0;
    unsigned int B = 0;
    
    [[NSScanner scannerWithString:[prefix stringByAppendingString:r]] scanHexInt:&R];
    [[NSScanner scannerWithString:[prefix stringByAppendingString:g]] scanHexInt:&G];
    [[NSScanner scannerWithString:[prefix stringByAppendingString:b]] scanHexInt:&B];
    
    return [UIColor colorWithRed:(float)R/255.0f green:(float)G/255.0f blue:(float)B/255.0f alpha:1.0];
}

- (void)showTagView
{
    [self.parentViewController.view addSubview:self.view];
    [self didMoveToParentViewController:self.parentViewController];
}

- (void)dismissTagView
{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    [tagScrollView removeGestureRecognizer:panGesture];
    self.view = nil;
}

- (void)dismissTagViewWithAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self moveView:tagScrollView toX:SCREEN_WIDTH];
            maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissTagView];
            if (isSuccessLoadedTag == NO) {
                 [[ItemStore sharedItemStore] cancelCurrentRequtest]; //这个仅仅是取消对tag的请求
            }
           
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    } else {
        [self dismissTagView];
    }
}

#pragma mark - tap gesture
- (void)tapMaskView
{
    [self dismissTagViewWithAnimation:YES];
}

#pragma mark - pan gesture
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    currTapPoint = [gesture locationInView:keyWindow];
    CGFloat x = currTapPoint.x;
    UIView *gestureView = gesture.view;

    //这里应禁止tagScrollView滚动
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginTapX = x;
        beginTapY = currTapPoint.y;
        beginTapPoint = currTapPoint;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        tagScrollView.userInteractionEnabled = NO;
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
                [self dismissTagView];
                //取消当前对tag的请求
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
                tagScrollView.userInteractionEnabled = YES;
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

#pragma mark - UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(NSTimeInterval)animationDurationForDistance:(CGFloat)distance{
    NSTimeInterval duration = MAX(distance/840.f,0.20);
    return duration;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    switch (tagScrollView.panGestureRecognizer.state) {
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

#pragma mark - tagView tap action
- (void)tapTagView:(TagView *)tagView
{
    [tagView tapTagView:tagView completion:^{
        if ([_tvcDelegate respondsToSelector:@selector(didSelectTagView: controller:)]) {
            [_tvcDelegate didSelectTagView:tagView controller:self];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (self.parentViewController == nil) {
        [tagScrollView removeGestureRecognizer:panGesture];
        tagScrollView.tagScrollViewDelegate = nil;
        [self.view removeFromSuperview];
        self.view = nil;
    }
}

- (void)dealloc
{
    [tagScrollView removeGestureRecognizer:panGesture];
    [tagScrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state" context:nil];
    tagScrollView.tagScrollViewDelegate = nil;
    self.tvcDelegate = nil;
}
@end

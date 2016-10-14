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
#import "Reachability.h"
#import "MacroDefinition.h"
#import "TagViewModel.h"

NSString * const k163TagIndex = @"preTagViewIndex";

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
//    NSInteger preTagViewIndex;  //前一个被选中的tagView的索引
    UIView *_panGestureView;    //仅仅用于防止滑动时tagScrollView也能滚动.
}
@property (nonatomic,strong) TagViewModel *viewModel;
@end

@implementation TagViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.view = view;
}

- (void)viewDidLoad
{
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
    marginLeft = (55 * SCREEN_WIDTH)/320.0f;
    CGRect gestureViewFrame = CGRectMake(SCREEN_WIDTH, navHeight, SCREEN_WIDTH-marginLeft, SCREEN_HEIGHT-navHeight);
    _panGestureView = [[UIView alloc] initWithFrame:gestureViewFrame];
    
    tagScrollView = [[TagScrollView alloc] initWithFrame:CGRectMake(0, 0, gestureViewFrame.size.width, gestureViewFrame.size.height)];
    tagScrollView.backgroundColor = RGBCOLOR(254, 254, 254, 1);
    tagScrollView.leftMargin = 3;
    tagScrollView.rightMargin = 3;
    tagScrollView.topMargin = 3;
    tagScrollView.horizontalPadding = 3;
    tagScrollView.verticalPadding = 3;
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    
    [_panGestureView addGestureRecognizer:panGesture];
    [_panGestureView addSubview:tagScrollView];
    [self.view addSubview:_panGestureView];
    
    //添加nav阴影
    UIImage *navImg = [UIImage imageNamed:@"navigationbar_background"];
    UIImageView *navImgView = [[UIImageView alloc] initWithImage:navImg];
    navImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, navImg.size.height);
    [self.view addSubview:navImgView];
    
    //设置maskView透明度渐变及tableView的滑入
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = _panGestureView.frame;
        rect.origin.x = marginLeft;
        _panGestureView.frame = rect;
        maskView.alpha = originAlpha;
    } completion:nil];

    //加载数据 添加tagViews
    isSuccessLoadedTag = NO;
//    preTagViewIndex = -1;
    [self loadTagData];
}

- (TagViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[TagViewModel alloc] init];
    }
    return _viewModel;
}

- (void)loadTagData
{
    //获取数据
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.viewModel fetchTagsWithCompletion:^(NSArray<Tag *> *tags, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (!error) {
            isSuccessLoadedTag = YES;
            [self createTagViewsWithTags:tags];
        } else {
            isSuccessLoadedTag = NO;
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
        NSDictionary *dic = [colors objectForKey:tag.tagID];
        NSString *colorName = [dic objectForKey:@"color"];
        if (colorName == nil) {
            view.tagLabel.textColor = [UIColor blackColor];
        }else {
            view.tagLabel.textColor = [self colorFromHexStr:colorName];
        }
        view.frame = CGRectMake(0, 0, view.frame.size.width+10, 50);
        view.centerVertically = YES;
        if ([self preTagViewIndex] != -1 && idx == [self preTagViewIndex]) {
            view.selected = YES;
        }
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
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
//                 [[ItemStore sharedItemStore] cancelCurrentRequtest]; //这个仅仅是取消对tag的请求
            }
           
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    } else {
        [self dismissTagView];
    }
}

+ (void)clearTagKey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:k163TagIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        tagScrollView.userInteractionEnabled = NO;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        

        currTapPoint = [gesture locationInView:keyWindow];
        CGFloat temp = (x-beginTapX+marginLeft);
        [self moveView:gestureView toX:temp];
        if (temp < marginLeft) {
            maskView.alpha = originAlpha;
        } else {
            maskView.alpha = originAlpha - originAlpha*(x-beginTapX)/temp;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        _panGestureView.userInteractionEnabled = YES;
        tagScrollView.scrollEnabled = YES;
        self.view.userInteractionEnabled = YES;
        if (x - beginTapX > 100) {  //移除marskView
            
            [UIView animateWithDuration:0.3 animations:^{
                [self moveView:gestureView toX:SCREEN_WIDTH];
                maskView.alpha = 0;
            } completion:^(BOOL finished) {
                [self dismissTagView];
                //取消当前对tag的请求
//                [[ItemStore sharedItemStore] cancelCurrentRequtest];
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

- (NSTimeInterval)animationDurationForDistance:(CGFloat)distance {
    NSTimeInterval duration = MAX(distance/840.f,0.20);
    return duration;
}

- (NSInteger)preTagViewIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *preIndex = [userDefaults objectForKey:k163TagIndex];
    if (preIndex == nil ) {
        preIndex = [NSNumber numberWithInteger:-1];
        [userDefaults setObject:preIndex forKey:k163TagIndex];
        [userDefaults synchronize];
    }
    return preIndex.integerValue;
}

- (void)setPreTagViewIndex:(NSInteger)preIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:@(preIndex) forKey:k163TagIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - tagView tap action
- (void)tapTagView:(TagView *)tagView
{
    NSInteger preIndex = [self preTagViewIndex];
    if (preIndex != -1) {
        //取消前一个的选中状态
        TagView *tv = [tagScrollView.tagViews objectAtIndex:preIndex];
        tv.selected = NO;
    }
    //设置当前的为选中状态
    tagView.selected = YES;
    [self setPreTagViewIndex: [tagScrollView.tagViews indexOfObject:tagView]];
    
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
    ZFQLog(@"释放tagVC");
}
@end

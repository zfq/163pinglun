//
//  FontSetViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-10-20.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "FontSetViewController.h"
#import "GeneralService.h"

@interface FontSetViewController () <UIPickerViewDataSource,UIPickerViewDelegate>
{
    CGFloat currContentFontSize;
    CGFloat currSubtitleFontSize;
    
    UIScrollView *scrollView;
    UILabel *previewLabel;
    UILabel *topUserLabel;
    UILabel *topTimeLabel;
    UILabel *middUserLabel;
    UILabel *middLabel;
    UILabel *floorLabel;
    UILabel *bottomLabel;
    
    UIImage *wallImg;
    UIImageView *roofImgView;
    UIImageView *wallImgView;
    UIImageView *bottomImgView;
    UILabel *separatorLabel;
    
    BOOL fontSizeIsChanged;
    NSNumber *fontSizeStyleIndex;
}
@end

@implementation FontSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0];
    
    //添加返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 22, 60, 40);
    [backBtn setImage:[UIImage imageNamed:@"navgation_back"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:RGBCOLOR(0, 160, 233, 1) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(40, SCREEN_HEITHT-200, SCREEN_WIDTH-80, 80)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.backgroundColor = scrollView.backgroundColor;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [pickerView selectRow:[self fontIndex] inComponent:0 animated:NO];
    [self.view addSubview:pickerView];
    
    //初始化
    fontSizeIsChanged = NO;
    currContentFontSize = [GeneralService currContentFontSize];
    currSubtitleFontSize = [GeneralService currSubtitleFontSize];
    
    [self createSubViewsIfNeeded];
}

- (void)createSubViewsIfNeeded
{
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEITHT-64-180)];
        scrollView.alwaysBounceVertical = YES;
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEITHT-64-180);
        scrollView.backgroundColor = self.view.backgroundColor;
        [self.view addSubview:scrollView];
    }
    
    if (!previewLabel) {
        previewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 40, 30)];
        previewLabel.text = @"预览";
        previewLabel.textColor = TITLE_COLOR;
        [scrollView addSubview:previewLabel];
    }
    previewLabel.font = [UIFont systemFontOfSize:currContentFontSize];
 
    CGRect originFrame;
    
    if (!topUserLabel) {
        topUserLabel = [self userLabel];
        originFrame = topUserLabel.frame;
        originFrame.origin = (CGPoint){15,CGRectGetMaxY(previewLabel.frame)};
        topUserLabel.frame = originFrame;
        topUserLabel.text = @"网易湖北省随州市手机网友";
        [scrollView addSubview:topUserLabel];
    }
    topUserLabel.font = [UIFont systemFontOfSize:currSubtitleFontSize];
    
    if (!topTimeLabel) {
        topTimeLabel = [self timeLabel];
        originFrame = topTimeLabel.frame;
        originFrame.origin.y = CGRectGetMaxY(previewLabel.frame);
        topTimeLabel.frame = originFrame;
        topTimeLabel.text = @"今天 10:15";
        [scrollView addSubview:topTimeLabel];
    }
    topTimeLabel.font = [UIFont systemFontOfSize:currSubtitleFontSize];
    
    if (!roofImgView) {
        UIImage *roofImg = [UIImage imageWithContentsOfFile: [self contentURLWithImage:@"comment.bundle/comment_roof_1@2x"]];
        roofImg = [roofImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
        roofImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topUserLabel.frame), SCREEN_WIDTH, roofImg.size.height)];
        roofImgView.image = roofImg;
        [scrollView addSubview:roofImgView];
    }
    
    if (!wallImgView) {
        wallImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [scrollView addSubview:wallImgView];
    }
    
    if (!middUserLabel) {
        middUserLabel = [self userLabel];
        originFrame = middUserLabel.frame;
        originFrame.origin = (CGPoint){20,CGRectGetMaxY(roofImgView.frame)};
        middUserLabel.frame = originFrame;
        middUserLabel.text = @"网易河南省郑州市网友";
        [scrollView addSubview:middUserLabel];
    }
    middUserLabel.font = [UIFont systemFontOfSize:currSubtitleFontSize];
    
    if (!floorLabel) {
        CGFloat FLOOR_WIDTH = 15;
        floorLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-FLOOR_WIDTH,CGRectGetMaxY(roofImgView.frame), FLOOR_WIDTH, 30)];
        floorLabel.font = [UIFont systemFontOfSize:currSubtitleFontSize];
        floorLabel.textAlignment = NSTextAlignmentRight;
        floorLabel.text = @"1";
        [scrollView addSubview:floorLabel];
    }
    floorLabel.font = [UIFont systemFontOfSize:currSubtitleFontSize];
    
    if (!middLabel) {
        middLabel = [self contentLabel];
        middLabel.text = @"网易新闻跟帖不单单只是网友对新闻的简单态度和评议，它还是新闻本身附加值的重要来源。";
        [scrollView addSubview:middLabel];
    }
    middLabel.frame = CGRectMake(20, CGRectGetMaxY(middUserLabel.frame), SCREEN_WIDTH-40, 0);
    middLabel.font = [UIFont systemFontOfSize:currContentFontSize];
    [middLabel sizeToFit];
    
    CGFloat y = CGRectGetMaxY(roofImgView.frame);
    wallImgView.frame = CGRectMake(0, y, SCREEN_WIDTH, CGRectGetMaxY(middLabel.frame)-y+5);
    if (!wallImg)
        wallImg = [UIImage imageWithContentsOfFile:[self contentURLWithImage:@"comment.bundle/comment_wall_1@2x"]];
    wallImg = [wallImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 50) resizingMode:UIImageResizingModeStretch];
    wallImgView.image = wallImg;
    
    //添加groundImg
    if (!bottomImgView) {
        UIImage *groundImg = [UIImage imageWithContentsOfFile:[self contentURLWithImage:@"comment.bundle/comment_ground_1@2x"]];
        bottomImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, groundImg.size.height)];
        groundImg = [groundImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
        bottomImgView.image = groundImg;
        [scrollView addSubview:bottomImgView];
    }
    originFrame = bottomImgView.frame;
    originFrame.origin.y = CGRectGetMaxY(wallImgView.frame);
    bottomImgView.frame = originFrame;
    
    if (!bottomLabel) {
        bottomLabel = [self contentLabel];
        bottomLabel.text = @"有时它甚至会纠正新闻本身信息的单一与偏差，创造更好的新闻视角。";
        [scrollView addSubview:bottomLabel];
    }
    bottomLabel.frame = CGRectMake(15, CGRectGetMaxY(bottomImgView.frame)+5, SCREEN_WIDTH-30, 0);
    bottomLabel.font = [UIFont systemFontOfSize:currContentFontSize];
    [bottomLabel sizeToFit];
    
    if (!separatorLabel) {
        separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        separatorLabel.backgroundColor = TITLE_COLOR;
        [scrollView addSubview:separatorLabel];
    }
    separatorLabel.frame = CGRectMake(0, CGRectGetMaxY(bottomLabel.frame)+5, SCREEN_WIDTH, 1);
}

- (void)back:(UIButton *)backButton
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (fontSizeIsChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FontSizeChangeNotification object:fontSizeStyleIndex];
    }
}

- (NSString *)contentURLWithImage:(NSString *)imageName
{
    return [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [GeneralService fontSizeDic].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *array = [[GeneralService fontSizeDic] objectForKey:[@(row) stringValue]];
    return [array lastObject];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    currContentFontSize = [GeneralService contentFontSizeWithIndex:row];
    currSubtitleFontSize = [GeneralService userFontSizeWithIndex:row];
    
    //保存当前的选择
    [GeneralService saveCurrContentFontSize:currContentFontSize];
    [GeneralService saveCurrSubtitleFontSize:currSubtitleFontSize];
    
    //刷新界面
    [self createSubViewsIfNeeded];
    
    if ([GeneralService fontSizeIsChanged]) {
        fontSizeIsChanged = YES;
        fontSizeStyleIndex = @(row);
        [[NSUserDefaults standardUserDefaults] setObject:@(row) forKey:kFontIndexStyle];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //保存当前字体大小
    [self saveCurrFontSyle];
}

- (NSInteger)fontIndex
{
    NSNumber *fontIndex = [[NSUserDefaults standardUserDefaults] objectForKey:kFontIndexStyle];
    if (fontIndex==nil) {
        fontIndex = @3;
        [[NSUserDefaults standardUserDefaults] setObject:fontIndex forKey:kFontIndexStyle];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return fontIndex.integerValue;
}

- (void)saveCurrFontSyle
{
    [[NSUserDefaults standardUserDefaults] setObject:@(currContentFontSize) forKey:kCurrContentFontSize];
    [[NSUserDefaults standardUserDefaults] setObject:@(currSubtitleFontSize) forKey:kCurrSubtitleFontSize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UILabel *)userLabel
{
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 198, 30)];
    userLabel.font = [UIFont systemFontOfSize:13];
    userLabel.minimumScaleFactor = 0.8;
    userLabel.adjustsFontSizeToFitWidth = YES;
    userLabel.textColor = RGBCOLOR(51,153,255,1.0f);
    return userLabel;
}

- (UILabel *)timeLabel
{
    CGFloat timeLabelWidth = 84;
    CGRect timeLabelFrame = CGRectMake(SCREEN_WIDTH-15-timeLabelWidth, 2, timeLabelWidth, 30);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame: timeLabelFrame];
    timeLabel.font = [UIFont systemFontOfSize:11];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor darkGrayColor];
    return timeLabel;
}

- (UILabel *)contentLabel
{
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    return contentLabel;
}
@end

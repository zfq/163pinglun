//
//  CommCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommCell4.h"
#import "Content.h"
#import "GeneralService.h"
#import "UIFont+Custom.h"

#import "FQDisplayView.h"
#import "FQFrameParserConfig.h"
#import "FQFrameParser.h"

#import "ZFQQueuePool.h"

#define MARGIN_LEFT 15.0f  //指距离屏幕边缘的距离
#define TOP_MARGIN 2.0f
#define PADDING_LEFT 5.0f
#define HEAD_HEIGHT 30 // headLabel的高度

#define MARGIN_BOTTOM 5 //label距离ground的高度
#define FLOOR_WIDTH 15 //显示楼层的label的宽度

NSString *const kCommCellTypeOnlyOne = @"CommCellTypeOnlyOne";
NSString *const kCommCellTypeTop = @"CommCellTypeTop";
NSString *const kCommCellTypeMiddle = @"CommCellTypeMiddle";
NSString *const kCommCellTypeBottom = @"CommCellTypeBottom";

@interface CommCell4()
{
    //只有1层
    UILabel *oneUserLabel;
    UILabel *oneTimeLabel;
    UILabel *oneContentLabel;
    UIView *oneSeparatorView;
    
    //top
    UILabel *topUserLabel;
    UILabel *topTimeLabel;
    UIImageView *roofImgView;
    
    //middle
    UILabel *middUserLabel;
    UILabel *floorLabel;
    FQDisplayView *middContentLabel;
    UIImageView *middBcgImgView;
    
    NSDictionary *midDic;
    NSArray *midAllConsV;       //user content ground vertical
    NSArray *midAllConsH;       //user floor horizon
    NSArray *midContentConsW;   //conten宽度
    
    //bottom
    FQDisplayView *bottomContentLabel;
    CALayer *bottomSeparatorLine;
    
    BOOL drawed;
}
@end
@implementation CommCell4

CGFloat c_labelX(NSInteger floorCount,NSInteger floorIndex);
UIImage * c_roofImg(NSInteger count);
UIImage * c_wallImg(NSInteger count,NSInteger floorIndex);
UIImage * c_groundImg(NSInteger floorCount,NSInteger floorIndex);

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0];
        [self addSubViewsWithId:reuseIdentifier];
        
        drawed = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)addSubViewsWithId:(NSString *)reuseId
{
    if ([reuseId isEqualToString:kCommCellTypeOnlyOne]) {
        
        oneUserLabel = [self userLabel];
        [self.contentView addSubview:oneUserLabel];
        oneTimeLabel = [self timeLabel];
        oneTimeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:oneTimeLabel];
        oneContentLabel = [self contentLabel];
        [self.contentView addSubview:oneContentLabel];
        oneSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
        oneSeparatorView.backgroundColor = SEPARATOR_COLOR;
        [self.contentView addSubview:oneSeparatorView];
        
    } else if ([reuseId isEqualToString:kCommCellTypeTop]) {
        
        topUserLabel = [self userLabel];
        [self.contentView addSubview:topUserLabel];
        topTimeLabel = [self timeLabel];
        topTimeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:topTimeLabel];
        roofImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:roofImgView];
        
    } else if ([reuseId isEqualToString:kCommCellTypeMiddle]) {
        UIView *contentView = self.contentView;
        middBcgImgView = [[UIImageView alloc] init];
        [contentView addSubview:middBcgImgView];
        
        middUserLabel = [self userLabel];
        floorLabel = [self userLabel];
        middContentLabel = [[FQDisplayView alloc] initWithFrame:CGRectZero];
        middContentLabel.canBeSelected = YES;
        middUserLabel.backgroundColor = [UIColor clearColor];
        floorLabel.backgroundColor = [UIColor clearColor];
        middContentLabel.backgroundColor = [UIColor clearColor];
        
        [contentView addSubview:middUserLabel];
        [contentView addSubview:floorLabel];
        [contentView addSubview:middContentLabel];
        
//        middContentLabel.layer.drawsAsynchronously = YES;
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        bottomContentLabel = [[FQDisplayView alloc] initWithFrame:CGRectZero];
        bottomContentLabel.backgroundColor = [UIColor clearColor];
        bottomContentLabel.canBeSelected = YES;
        
        [self.contentView addSubview:bottomContentLabel];
        
        bottomSeparatorLine = [CALayer layer];
        bottomSeparatorLine.backgroundColor = SEPARATOR_COLOR.CGColor;
        [self.contentView.layer addSublayer:bottomSeparatorLine];
        
//        bottomContentLabel.layer.drawsAsynchronously = YES;
    }
}

///仅仅用于计算高度
- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount forHeight:(CGFloat *)height fontSizeChanged:(BOOL)isChanged
{
    if (content == nil)
        return;
    
    _content = content;
    
    CGFloat separatorHeight = 1;
    CGFloat marginTop = 10;
    CGFloat userMarginLeft = 15;
    CGFloat timeHeight = 30;
    CGFloat minGap = 20;
    CGFloat sw = SCREEN_WIDTH;
    
    //获得当前的楼层为第几层
    NSInteger floorIndex = content.floorIndex.integerValue;
    NSString *reuseId = self.reuseIdentifier;
    if ([reuseId isEqualToString:kCommCellTypeOnlyOne]) {
        if (isChanged)
            oneUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        oneUserLabel.text = content.user;
        
        oneTimeLabel.text = content.time;
        if (isChanged)
            oneTimeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        oneContentLabel.text = content.content;
        if (isChanged)
            oneContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        
        //计算高度
        CGFloat timeWidth = 100;   //timeLabel的最大宽度为100
        CGSize timeSize = [oneTimeLabel sizeThatFits:CGSizeMake(timeWidth, timeHeight)];
        CGFloat maxUserLabelWidth = sw - 2 * userMarginLeft - timeSize.width - minGap;
        CGSize userLabelSize = [oneUserLabel sizeThatFits:CGSizeMake(maxUserLabelWidth, timeHeight)];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        //计算frame --oneUserLabel
        CGRect originFrame = oneUserLabel.frame;
        originFrame.origin = CGPointMake(userMarginLeft, marginTop);
        originFrame.size = userLabelSize;
        oneUserLabel.frame = originFrame;
        
        //--oneTimeLabel
        originFrame = oneTimeLabel.frame;
        originFrame.size = timeSize;
        originFrame.origin = CGPointMake(sw - userMarginLeft - timeSize.width, marginTop);
        oneTimeLabel.frame = originFrame;
        
        //--oneContentLabel
        CGSize maxContentLabelSize = CGSizeMake(sw - 2 * userMarginLeft, HUGE_VALF);
        CGSize contentLabelSize = [oneContentLabel sizeThatFits:maxContentLabelSize];
        originFrame = oneContentLabel.frame;
        originFrame.origin = CGPointMake(userMarginLeft, CGRectGetMaxY(oneUserLabel.frame) + marginTop);
        originFrame.size = contentLabelSize;
        oneContentLabel.frame = originFrame;
        
        //--oneSeparatorView
        oneSeparatorView.frame = CGRectMake(0, CGRectGetMaxY(oneContentLabel.frame), sw, separatorHeight);
        
        if (height != nil)
            *height = CGRectGetMaxY(oneSeparatorView.frame);
        
    } else if ([reuseId isEqualToString:kCommCellTypeTop]) {
        
        topUserLabel.text = content.user;
        if (isChanged)
            topUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        topTimeLabel.text = content.time;
        if (isChanged)
            topTimeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        UIImage *roofImg = c_roofImg(floorCount);
        roofImgView.image = roofImg;
        
        CGFloat timeWidth = 100;   //timeLabel的最大宽度为100
        CGSize timeSize = [topTimeLabel sizeThatFits:CGSizeMake(timeWidth, timeHeight)];
        CGFloat maxUserLabelWidth = sw - 2 * userMarginLeft - timeSize.width - minGap;
        CGSize userLabelSize = [topUserLabel sizeThatFits:CGSizeMake(maxUserLabelWidth, timeHeight)];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        //计算frame --topUserLabel
        CGRect originFrame = topUserLabel.frame;
        originFrame.origin = CGPointMake(userMarginLeft, marginTop);
        originFrame.size = userLabelSize;
        topUserLabel.frame = originFrame;
        
        //--topTimeLabel
        originFrame = topTimeLabel.frame;
        originFrame.size = timeSize;
        originFrame.origin = CGPointMake(sw - userMarginLeft - timeSize.width, marginTop);
        topTimeLabel.frame = originFrame;
        
        //--roofImgView
        roofImgView.frame = CGRectMake(0, CGRectGetMaxY(topUserLabel.frame) + marginTop, sw, roofImg.size.height);
        if (height != nil)
            *height = CGRectGetMaxY(roofImgView.frame);
        
    } else if ([reuseId isEqualToString:kCommCellTypeMiddle]) {
        
        CGFloat fontSize = [GeneralService currContentFontSize];
        CGFloat subTitleFontSize = [GeneralService currSubtitleFontSize];
        //1.设置 midUserLabel
        CGFloat labelX = c_labelX(floorCount,floorIndex);
        middUserLabel.text = content.user;
        middUserLabel.font = [UIFont systemFontOfSize:subTitleFontSize];
        floorLabel.text = content.floorIndex.description;
        //计算坐标 --floorLabel
        CGSize maxFloorSize = CGSizeMake(40, timeHeight);
        CGSize floorSize = [floorLabel sizeThatFits:maxFloorSize];
        
        //--middUserLabel
        CGFloat maxUserLabelWidth = sw - 2 * labelX - minGap - floorSize.width;
        CGSize maxUserLabelSize = CGSizeMake(maxUserLabelWidth, timeHeight);
        CGSize userLabelSize = [middUserLabel sizeThatFits:maxUserLabelSize];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        CGRect middUserFrame = CGRectMake(labelX, marginTop, userLabelSize.width, userLabelSize.height);
        
        
        //3.设置midContent
        FQFrameParserConfig *contentConfig = [[FQFrameParserConfig alloc] init];
        contentConfig.fontSize = fontSize;
        
        UIImage *groundImg = c_groundImg(floorCount, floorIndex);
        
        //--middContentLabel
        CGSize maxContentLabelSize = CGSizeMake(sw - 2 * labelX, HUGE_VALF);
        contentConfig.maxWidth = maxContentLabelSize.width;
        contentConfig.fontSize = fontSize;
        FQCoreTextData *contentData = [FQFrameParser parseContent:content.content config:contentConfig];
        CGRect contentFrame = CGRectMake(labelX, CGRectGetMaxY(middUserFrame) + marginTop, contentData.width, contentData.height);
        
        //--wallImgView
        CGRect wallImgFrame = CGRectMake(0, 0, sw, CGRectGetMaxY(contentFrame) + marginTop);
        
        //--groundImgView
        CGRect groundImgFrame = CGRectMake(0, CGRectGetMaxY(wallImgFrame), sw, groundImg.size.height);
        
        if (height != nil)
            *height = CGRectGetMaxY(groundImgFrame);
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        FQFrameParserConfig *config = [[FQFrameParserConfig alloc] init];
        config.fontSize = [GeneralService currContentFontSize];
        
        //--bottomContentLabel
        CGSize maxBottomContentLabelSize = CGSizeMake(sw - 2 * userMarginLeft, HUGE_VALF);
        config.maxWidth = maxBottomContentLabelSize.width;
        FQCoreTextData *contentData = [FQFrameParser parseContent:content.content config:config];
        CGSize bottomContentLabelSize = CGSizeMake(contentData.width, contentData.height);
        CGRect contentFrame = CGRectMake(userMarginLeft, marginTop, bottomContentLabelSize.width, bottomContentLabelSize.height);
        
        if (height != nil)
            *height = CGRectGetMaxY(contentFrame) + marginTop;
        
    }
    
}

///用于绑定数据 显示cell时使用
- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount fontSizeChanged:(BOOL)isChanged
{
    if (content == nil)
        return;
    
    _content = content;
    
    CGFloat separatorHeight = 1;
    CGFloat marginTop = 10;
    CGFloat userMarginLeft = 15;
    CGFloat timeHeight = 30;
    CGFloat minGap = 20;
    CGFloat sw = SCREEN_WIDTH;
    
    //获得当前的楼层为第几层
    NSInteger floorIndex = content.floorIndex.integerValue;
    NSString *reuseId = self.reuseIdentifier;
    if ([reuseId isEqualToString:kCommCellTypeOnlyOne]) {
        if (isChanged)
            oneUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        oneUserLabel.text = content.user;
        
        oneTimeLabel.text = content.time;
        if (isChanged)
            oneTimeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        oneContentLabel.text = content.content;
        if (isChanged)
            oneContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        
        //计算高度
        CGFloat timeWidth = 100;   //timeLabel的最大宽度为100
        CGSize timeSize = [oneTimeLabel sizeThatFits:CGSizeMake(timeWidth, timeHeight)];
        CGFloat maxUserLabelWidth = sw - 2 * userMarginLeft - timeSize.width - minGap;
        CGSize userLabelSize = [oneUserLabel sizeThatFits:CGSizeMake(maxUserLabelWidth, timeHeight)];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        //计算frame --oneUserLabel
        CGRect originFrame = oneUserLabel.frame;
        originFrame.origin = CGPointMake(userMarginLeft, marginTop);
        originFrame.size = userLabelSize;
        oneUserLabel.frame = originFrame;
        
        //--oneTimeLabel
        originFrame = oneTimeLabel.frame;
        originFrame.size = timeSize;
        originFrame.origin = CGPointMake(sw - userMarginLeft - timeSize.width, marginTop);
        oneTimeLabel.frame = originFrame;
        
        //--oneContentLabel
        CGSize maxContentLabelSize = CGSizeMake(sw - 2 * userMarginLeft, HUGE_VALF);
        CGSize contentLabelSize = [oneContentLabel sizeThatFits:maxContentLabelSize];
        originFrame = oneContentLabel.frame;
        originFrame.origin = CGPointMake(userMarginLeft, CGRectGetMaxY(oneUserLabel.frame) + marginTop);
        originFrame.size = contentLabelSize;
        oneContentLabel.frame = originFrame;
        
        //--oneSeparatorView
        oneSeparatorView.frame = CGRectMake(0, CGRectGetMaxY(oneContentLabel.frame), sw, separatorHeight);
        
    } else if ([reuseId isEqualToString:kCommCellTypeTop]) {
        
        topUserLabel.text = content.user;
        if (isChanged)
            topUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        topTimeLabel.text = content.time;
        if (isChanged)
            topTimeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        UIImage *roofImg = c_roofImg(floorCount);
        roofImgView.image = roofImg;
        
        CGFloat timeWidth = 100;   //timeLabel的最大宽度为100
        CGSize timeSize = [topTimeLabel sizeThatFits:CGSizeMake(timeWidth, timeHeight)];
        CGFloat maxUserLabelWidth = sw - 2 * userMarginLeft - timeSize.width - minGap;
        CGSize userLabelSize = [topUserLabel sizeThatFits:CGSizeMake(maxUserLabelWidth, timeHeight)];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        //计算frame --topUserLabel
        CGRect originFrame = topUserLabel.frame;
        originFrame.origin = CGPointMake(userMarginLeft, marginTop);
        originFrame.size = userLabelSize;
        topUserLabel.frame = originFrame;
        
        //--topTimeLabel
        originFrame = topTimeLabel.frame;
        originFrame.size = timeSize;
        originFrame.origin = CGPointMake(sw - userMarginLeft - timeSize.width, marginTop);
        topTimeLabel.frame = originFrame;
        
        //--roofImgView
        roofImgView.frame = CGRectMake(0, CGRectGetMaxY(topUserLabel.frame) + marginTop, sw, roofImg.size.height);
        
    } else if ([reuseId isEqualToString:kCommCellTypeMiddle]) {
        
        CGFloat fontSize = [GeneralService currContentFontSize];
        CGFloat subTitleFontSize = [GeneralService currSubtitleFontSize];
        //1.设置 midUserLabel
        CGFloat labelX = c_labelX(floorCount,floorIndex);
        middUserLabel.text = content.user;
        middUserLabel.font = [UIFont systemFontOfSize:subTitleFontSize];
        floorLabel.text = content.floorIndex.description;
        //计算坐标 --floorLabel
        CGSize maxFloorSize = CGSizeMake(40, timeHeight);
        CGSize floorSize = [floorLabel sizeThatFits:maxFloorSize];
        CGRect floorFrame = CGRectMake(sw - labelX - floorSize.width, marginTop, floorSize.width, floorSize.height);
        floorLabel.frame = floorFrame;
        
        //--middUserLabel
        CGFloat maxUserLabelWidth = sw - 2 * labelX - minGap - floorSize.width;
        CGSize maxUserLabelSize = CGSizeMake(maxUserLabelWidth, timeHeight);
        CGSize userLabelSize = [middUserLabel sizeThatFits:maxUserLabelSize];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        CGRect middUserFrame = CGRectMake(labelX, marginTop, userLabelSize.width, userLabelSize.height);
        middUserLabel.frame = middUserFrame;
        
        //3.设置midContent
        FQFrameParserConfig *contentConfig = [[FQFrameParserConfig alloc] init];
        contentConfig.fontSize = fontSize;
        contentConfig.textColor = [UIColor blackColor];
        
        UIImage *wallImg = c_wallImg(floorCount,floorIndex);
        UIImage *groundImg = c_groundImg(floorCount, floorIndex);

        
        //--middContentLabel
        CGSize maxContentLabelSize = CGSizeMake(sw - 2 * labelX, HUGE_VALF);
        contentConfig.maxWidth = maxContentLabelSize.width;
        contentConfig.fontSize = fontSize;
        
        
        //目的为了使wallImg和groundImg合成一张图片
        
        dispatch_async(ZFQGetQueue(), ^{
            
            FQCoreTextData *contentData = [FQFrameParser parseContent:content.content config:contentConfig];
            CGRect contentFrame = CGRectMake(labelX, CGRectGetMaxY(middUserFrame) + marginTop, contentData.width, contentData.height);
             
            //--wallImgView
            CGRect wallImgFrame = CGRectMake(0, 0, sw, CGRectGetMaxY(contentFrame) + marginTop);
             
            //--groundImgView
            CGRect groundImgFrame = CGRectMake(0, CGRectGetMaxY(wallImgFrame), sw, groundImg.size.height);
            CGSize imgSize = CGSizeMake(sw, CGRectGetMaxY(groundImgFrame));
            UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
            //1.先draw wallImg
            [wallImg drawInRect:CGRectMake(0, 0, sw, wallImgFrame.size.height)];
            //2.draw groundImg
            [groundImg drawInRect:groundImgFrame];
            
            UIImage *comBcgImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            middContentLabel.data = contentData;
            middContentLabel.frame = contentFrame;
            middBcgImgView.frame = CGRectMake(0, 0, sw,CGRectGetMaxY(groundImgFrame));
            
            dispatch_async(dispatch_get_main_queue(), ^{
                middBcgImgView.image = comBcgImg;
                [middContentLabel setNeedsDisplay];
            });
        });
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        FQFrameParserConfig *config = [[FQFrameParserConfig alloc] init];
        config.fontSize = [GeneralService currContentFontSize];
        config.textColor = [UIColor blackColor];
        
        //--bottomContentLabel
        dispatch_async(ZFQGetQueue(), ^{
            CGSize maxBottomContentLabelSize = CGSizeMake(sw - 2 * userMarginLeft, HUGE_VALF);
            config.maxWidth = maxBottomContentLabelSize.width;
            FQCoreTextData *contentData = [FQFrameParser parseContent:content.content config:config];
            CGSize bottomContentLabelSize = CGSizeMake(contentData.width, contentData.height);
            CGRect contentFrame = CGRectMake(userMarginLeft, marginTop, bottomContentLabelSize.width, bottomContentLabelSize.height);
            
            CGSize imgSize = CGSizeMake(sw, CGRectGetMaxY(contentFrame) + marginTop);
            
            bottomContentLabel.data = contentData;
            bottomContentLabel.frame = contentFrame;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                bottomSeparatorLine.bounds = CGRectMake(0, 0, sw, 1);
                bottomSeparatorLine.position = CGPointMake(sw/2, imgSize.height - 1);
                
                [bottomContentLabel setNeedsDisplay];
            });
        });
        
        
       
    }
    
}

#pragma mark - 创建label
- (UILabel *)userLabel
{
    UILabel *userLabel = [[UILabel alloc] init];
    userLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
    
    userLabel.textColor = LABEL_COLOR;
    return userLabel;
}

- (UILabel *)timeLabel
{
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor darkGrayColor];
    return timeLabel;
}

- (UILabel *)contentLabel
{
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
    //    contentLabel.font = [UIFont customYouYuanFontWithSize:[GeneralService currContentFontSize]];
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    //设置选中的背景色
    //    contentLabel.tom_red = 0.2;
    //    contentLabel.tom_green = 0.6;
    //    contentLabel.tom_blue = 1;
    //    contentLabel.tom_alpha = 0.3;
    
    return contentLabel;
}

#pragma mark - 辅助函数
CGFloat c_labelX(NSInteger floorCount,NSInteger floorIndex)
{
    CGFloat paddingLeft = 0.0f;
    NSInteger maxFloor = 5;
    if (floorCount > maxFloor) { //大于5层
        if (floorIndex <= floorCount - maxFloor)
            paddingLeft = maxFloor * PADDING_LEFT + MARGIN_LEFT;
        else
            paddingLeft = (floorCount - floorIndex) * PADDING_LEFT + MARGIN_LEFT;
    }
    else if (floorCount <= maxFloor && floorCount >= 2) //<=5层
        paddingLeft = (floorCount - floorIndex) * PADDING_LEFT + MARGIN_LEFT;
    else //只有1层
        paddingLeft = MARGIN_LEFT;
    
    return paddingLeft;
    return 3;
}

UIImage * c_roofImg(NSInteger count)
{
    UIImage *roofImg = nil;
    if (count >= 2) {
        NSString *roofImgName = nil;
        if (count > 5)
            roofImgName = @"comment.bundle/comment_roof_5";
        else
            roofImgName = [NSString stringWithFormat:@"comment.bundle/comment_roof_%zi", count - 1];
        
        roofImg = [UIImage imageNamed:roofImgName];
        //拉伸
        roofImg = [roofImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
    }
    
    return roofImg;
}

UIImage * c_wallImg(NSInteger count,NSInteger floorIndex)
{
    NSInteger maxFloor = 5;
    UIImage *wallImg = nil;
    if (count > 1)
    {
        NSString *wallImgName = nil;
        if (count >= maxFloor+1)
        {
            if (floorIndex < count - maxFloor)
            {
                wallImgName = @"comment.bundle/comment_wall_5";
            }
            else
            {
                wallImgName = [NSString stringWithFormat:@"comment.bundle/comment_wall_%zi",count - floorIndex];
            }
        }
        else
        {
            wallImgName = [NSString stringWithFormat:@"comment.bundle/comment_wall_%zi",count - floorIndex];
        }
        
        wallImg = [UIImage imageNamed:wallImgName];
        wallImg = [wallImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 50) resizingMode:UIImageResizingModeStretch];
    }
    return wallImg;
}

UIImage * c_groundImg(NSInteger floorCount,NSInteger floorIndex)
{
    UIImage *groundImg = nil;
    NSString *groundImgName = nil;
    NSInteger maxFloor = 5;
    
    if (floorCount > 1)
    {
        if (floorCount >= maxFloor+1)
        {
            if (floorIndex < floorCount - maxFloor)
            {
                groundImgName = @"comment.bundle/comment_ground_5";
            }
            else
            {
                groundImgName = [NSString stringWithFormat:@"comment.bundle/comment_ground_%zi",floorCount - floorIndex];
            }
        }
        else
        {
            groundImgName = [NSString stringWithFormat:@"comment.bundle/comment_ground_%zi",floorCount - floorIndex];
        }
        
        groundImg = [UIImage imageNamed:groundImgName];
        groundImg = [groundImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
    }
    
    return groundImg;
}

- (void)dealloc
{
    //    NSLog(@"r");
}
@end

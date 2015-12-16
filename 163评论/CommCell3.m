//
//  CommCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommCell3.h"
#import "Content.h"
#import "GeneralService.h"
#import "UIFont+Custom.h"

#import "FQDisplayView.h"
#import "FQFrameParserConfig.h"
#import "FQFrameParser.h"

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

@interface CommCell3()
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
    FQDisplayView *middUserLabel;
    FQDisplayView *floorLabel;
    FQDisplayView *middContentLabel;
    
    NSDictionary *midDic;
    NSArray *midAllConsV;       //user content ground vertical
    NSArray *midAllConsH;       //user floor horizon
    NSArray *midContentConsW;   //conten宽度
    
    //bottom
    FQDisplayView *bottomContentLabel;
    
    UIImageView *comBcgImgView;
    BOOL drawed;
}
@end
@implementation CommCell3

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0];
        [self addSubViewsWithId:reuseIdentifier];
        
        comBcgImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView insertSubview:comBcgImgView atIndex:0];
        
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
        
        middUserLabel = [[FQDisplayView alloc] initWithFrame:CGRectZero];
        floorLabel = [[FQDisplayView alloc] initWithFrame:CGRectZero];
//        floorLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
//        floorLabel.textAlignment = NSTextAlignmentRight;
        middContentLabel = [[FQDisplayView alloc] initWithFrame:CGRectZero];
//        middUserLabel.backgroundColor = [UIColor redColor];
//        floorLabel.backgroundColor = [UIColor redColor];
//        middContentLabel.backgroundColor = [UIColor redColor];
        middUserLabel.backgroundColor = [UIColor clearColor];
        floorLabel.backgroundColor = [UIColor clearColor];
        middContentLabel.backgroundColor = [UIColor clearColor];
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        bottomContentLabel = [[FQDisplayView alloc] initWithFrame:CGRectZero];
        bottomContentLabel.backgroundColor = [UIColor clearColor];
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
        
        UIImage *roofImg = [self roofImgWithFloorCount:floorCount];
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
        CGFloat labelX = [self labelXWithFloorCount:floorCount floorIndex:floorIndex];
        FQFrameParserConfig *midConfig = [[FQFrameParserConfig alloc] init];
        midConfig.fontSize = subTitleFontSize;

        midConfig.lineBreakMode = kCTLineBreakByTruncatingTail;
        midConfig.textColor = LABEL_COLOR;
        
        //2.设置floorLabel
        FQFrameParserConfig *floorConfig = [[FQFrameParserConfig alloc] init];
        floorConfig.textAlignment = kCTTextAlignmentRight;
        floorConfig.fontSize = subTitleFontSize;
        FQCoreTextData *floorData = [FQFrameParser parseContent:content.floorIndex.description config:floorConfig];

        //3.设置midContent
        FQFrameParserConfig *contentConfig = [[FQFrameParserConfig alloc] init];
        contentConfig.fontSize = fontSize;
        
        UIImage *groundImg = [self groundImgWithFloorCount:floorCount floorIndex:floorIndex];
        
        //计算坐标 --floorLabel
        CGSize maxFloorSize = CGSizeMake(40, timeHeight);
        CGSize floorSize = CGSizeMake(floorData.width, floorData.height);
        
        //--middUserLabel
        CGFloat maxUserLabelWidth = sw - 2 * labelX - minGap - floorSize.width;
        CGSize maxUserLabelSize = CGSizeMake(maxUserLabelWidth, timeHeight);
        midConfig.maxWidth = maxUserLabelWidth;
        FQCoreTextData *midUserData = [FQFrameParser parseContent:content.user config:midConfig];

        CGSize userLabelSize = CGSizeMake(midUserData.width, midUserData.height);
        if (userLabelSize.width > maxUserLabelWidth) {
            midConfig.maxWidth = maxUserLabelWidth;
            midUserData = [FQFrameParser parseContent:content.user config:midConfig];
        }
        CGRect middUserFrame = CGRectMake(labelX, marginTop, userLabelSize.width, userLabelSize.height);
        
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

///用于绑定数据
- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount height:(CGFloat *)height fontSizeChanged:(BOOL)isChanged
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
        
        UIImage *roofImg = [self roofImgWithFloorCount:floorCount];
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
        CGFloat labelX = [self labelXWithFloorCount:floorCount floorIndex:floorIndex];
        FQFrameParserConfig *midUserConfig = [[FQFrameParserConfig alloc] init];
        midUserConfig.fontSize = subTitleFontSize;
        midUserConfig.lineBreakMode = kCTLineBreakByTruncatingTail;
        midUserConfig.textColor = LABEL_COLOR;
        
        //2.设置 floorLabel
        FQFrameParserConfig *floorConfig = [[FQFrameParserConfig alloc] init];
        floorConfig.fontSize = subTitleFontSize;
        floorConfig.textColor = LABEL_COLOR;
        
        //3.设置midContent
        FQFrameParserConfig *contentConfig = [[FQFrameParserConfig alloc] init];
        contentConfig.fontSize = fontSize;
        contentConfig.textColor = [UIColor blackColor];
     
        UIImage *wallImg = [self wallImgWithFloorCount:floorCount floorIndex:floorIndex];
        UIImage *groundImg = [self groundImgWithFloorCount:floorCount floorIndex:floorIndex];
        
        //计算坐标 --floorLabel
        CGSize maxFloorSize = CGSizeMake(40, timeHeight);
        FQCoreTextData *floorData = [FQFrameParser parseContent:content.floorIndex.description config:floorConfig];
        floorConfig.maxWidth = maxFloorSize.width;
        CGRect floorFrame = CGRectMake(sw - labelX - floorData.width, marginTop, floorData.width, floorData.height);
        
        //--middUserLabel
        CGFloat maxUserLabelWidth = sw - 2 * labelX - minGap - floorData.width;
        midUserConfig.maxWidth = maxUserLabelWidth;
        FQCoreTextData *midUserData = [FQFrameParser parseContent:content.user config:midUserConfig];
        if (midUserData.width > maxUserLabelWidth) {
            midUserConfig.maxWidth = maxUserLabelWidth;
            midUserData = [FQFrameParser parseContent:content.user config:midUserConfig];
        }
        CGRect middUserFrame = CGRectMake(labelX, marginTop, midUserData.width, midUserData.height);
        
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
        
        middUserLabel.data = midUserData;
        middUserLabel.frame = middUserFrame;
        floorLabel.data = floorData;
        floorLabel.frame = floorFrame;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //
            
            CGSize imgSize = CGSizeMake(sw, CGRectGetMaxY(groundImgFrame));
            UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            //1.先draw wallImg
            [wallImg drawInRect:CGRectMake(0, 0, sw, wallImgFrame.size.height)];
            
            //2.draw userLabel
            [middUserLabel.layer renderInContext:context];
            //3.draw floorLabel
            [floorLabel.layer renderInContext:context];
            //4.draw groundImg
            [groundImg drawInRect:groundImgFrame];
            
            UIImage *comBcgImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                middUserLabel.data = midUserData;
//                middUserLabel.frame = middUserFrame;
//                floorLabel.data = floorData;
//                floorLabel.frame = floorFrame;
                middContentLabel.data = contentData;
                middContentLabel.frame = contentFrame;
                
                comBcgImgView.frame = CGRectMake(0, 0, sw,CGRectGetMaxY(groundImgFrame));
                comBcgImgView.image = nil;
                comBcgImgView.image = comBcgImg;
                
                if (middContentLabel.superview == nil) {
//                    [self.contentView addSubview:middUserLabel];
//                    [self.contentView addSubview:floorLabel];
                    [self.contentView addSubview:middContentLabel];
                } else {
//                    [middUserLabel setNeedsDisplay];
//                    [floorLabel setNeedsDisplay];
                    [middContentLabel setNeedsDisplay];
                }
            });
        });
        
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        FQFrameParserConfig *config = [[FQFrameParserConfig alloc] init];
        config.fontSize = [GeneralService currContentFontSize];
        config.textColor = [UIColor blackColor];
     
        //--bottomContentLabel
        CGSize maxBottomContentLabelSize = CGSizeMake(sw - 2 * userMarginLeft, HUGE_VALF);
        config.maxWidth = maxBottomContentLabelSize.width;
        FQCoreTextData *contentData = [FQFrameParser parseContent:content.content config:config];
        CGSize bottomContentLabelSize = CGSizeMake(contentData.width, contentData.height);
        CGRect contentFrame = CGRectMake(userMarginLeft, marginTop, bottomContentLabelSize.width, bottomContentLabelSize.height);
        
        if (height != nil)
            *height = CGRectGetMaxY(contentFrame) + marginTop;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            CGSize imgSize = CGSizeMake(sw, CGRectGetMaxY(contentFrame) + marginTop);
            UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            //1.draw backgroundColor
            [[UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0] setFill];
            CGContextFillRect(context, CGRectMake(0, 0, imgSize.width, imgSize.height));

            //3.draw separatorLine
            CGContextSetStrokeColorWithColor(context, SEPARATOR_COLOR.CGColor);
            CGContextMoveToPoint(context, 0, imgSize.height - 1);
            CGContextAddLineToPoint(context, sw, imgSize.height);
            CGContextStrokePath(context);
            UIImage *comBcgImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                
                bottomContentLabel.data = contentData;
                bottomContentLabel.frame = contentFrame;
                comBcgImgView.frame = CGRectMake(0, 0, sw,imgSize.height);
                comBcgImgView.image = nil;
                comBcgImgView.image = comBcgImg;
                
                if (bottomContentLabel.superview == nil) {
                    [self.contentView addSubview:bottomContentLabel];
                } else {
                    [bottomContentLabel setNeedsDisplay];
                }
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
- (CGFloat)labelXWithFloorCount:(NSInteger)count floorIndex:(NSInteger)floor
{
    CGFloat paddingLeft = 0.0f;
    NSInteger maxFloor = 5;
    if (count > maxFloor) { //大于5层
        if (floor <= count - maxFloor)
            paddingLeft = maxFloor * PADDING_LEFT + MARGIN_LEFT;
        else
            paddingLeft = (count - floor) * PADDING_LEFT + MARGIN_LEFT;
    }
    else if (count <= maxFloor && count >= 2) //<=5层
        paddingLeft = (count - floor) * PADDING_LEFT + MARGIN_LEFT;
    else //只有1层
        paddingLeft = MARGIN_LEFT;
    
    return paddingLeft;
}

#pragma mark - 获取图片
- (UIImage *)roofImgWithFloorCount:(NSInteger)count
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

- (UIImage *)wallImgWithFloorCount:(NSInteger)count floorIndex:(NSInteger)floorIndex
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

- (UIImage *)groundImgWithFloorCount:(NSInteger)floorCount floorIndex:(NSInteger)floorIndex
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

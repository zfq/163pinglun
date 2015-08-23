//
//  CommCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommCell2.h"
#import "Content.h"
#import "GeneralService.h"
#import "UIFont+Custom.h"
#import "TOMSimpleLinkLabel.h"

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

@interface CommCell2()
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
    UILabel *middContentLabel;
    
    NSDictionary *midDic;
    NSArray *midAllConsV;       //user content ground vertical
    NSArray *midAllConsH;       //user floor horizon
    NSArray *midContentConsW;   //conten宽度
    
    //bottom
    UILabel *bottomContentLabel;
    
    UIImageView *comBcgImgView;
    BOOL drawed;
}
@end
@implementation CommCell2

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
        
        middUserLabel = [self userLabel];
        floorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        floorLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        floorLabel.textAlignment = NSTextAlignmentRight;
        middContentLabel = [self contentLabel];
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        bottomContentLabel = [self contentLabel];
    }
}

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
        
        CGFloat labelX = [self labelXWithFloorCount:floorCount floorIndex:floorIndex];
        if (isChanged)
            middUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        middUserLabel.text = content.user;
        
        floorLabel.text = content.floorIndex.description;
        if (isChanged)
            floorLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        middContentLabel.text = content.content;
        if (isChanged)
            middContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        
        UIImage *wallImg = [self wallImgWithFloorCount:floorCount floorIndex:floorIndex];
        UIImage *groundImg = [self groundImgWithFloorCount:floorCount floorIndex:floorIndex];
        
        //计算坐标 --floorLabel
        CGSize maxFloorSize = CGSizeMake(40, timeHeight);
        CGSize floorSize = [floorLabel sizeThatFits:maxFloorSize];
        CGRect floorFrame = CGRectMake(sw - labelX - floorSize.width, marginTop, floorSize.width, floorSize.height);
        
        //--middUserLabel
        CGFloat maxUserLabelWidth = sw - 2 * labelX - minGap - floorSize.width;
        CGSize maxUserLabelSize = CGSizeMake(maxUserLabelWidth, timeHeight);
        CGSize userLabelSize = [middUserLabel sizeThatFits:maxUserLabelSize];
        if (userLabelSize.width > maxUserLabelWidth) {
            userLabelSize.width = maxUserLabelWidth;
        }
        CGRect middUserFrame = CGRectMake(labelX, marginTop, userLabelSize.width, userLabelSize.height);
        
        //--middContentLabel
        CGSize maxContentLabelSize = CGSizeMake(sw - 2 * labelX, HUGE_VALF);
        CGSize contentLabelSize = [middContentLabel sizeThatFits:maxContentLabelSize];
        CGRect contentFrame = CGRectMake(labelX, CGRectGetMaxY(middUserFrame) + marginTop, contentLabelSize.width, contentLabelSize.height);
        
        //--wallImgView
        CGRect wallImgFrame = CGRectMake(0, 0, sw, CGRectGetMaxY(contentFrame) + marginTop);
        
        //--groundImgView
        CGRect groundImgFrame = CGRectMake(0, CGRectGetMaxY(wallImgFrame), sw, groundImg.size.height);
        
        if (height != nil)
            *height = CGRectGetMaxY(groundImgFrame);
        
//        if (drawed) {
//            return;
//        }
//        drawed = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //
            
            CGSize imgSize = CGSizeMake(sw, CGRectGetMaxY(groundImgFrame));
            UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
            //1.先draw wallImg
            [wallImg drawInRect:CGRectMake(0, 0, sw, wallImgFrame.size.height)];
            //2.draw userLabel
            NSDictionary *userAttr = @{
                                       NSFontAttributeName:middUserLabel.font,
                                       NSForegroundColorAttributeName:middUserLabel.textColor
                                       };
            [middUserLabel.text drawInRect:middUserFrame withAttributes:userAttr];
            //3.draw floorLabel
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentLeft;
            NSDictionary *floorAttr = @{
                                        NSFontAttributeName:middUserLabel.font,
                                        NSForegroundColorAttributeName:middUserLabel.textColor,
                                        NSParagraphStyleAttributeName:paragraphStyle
                                        };
            [floorLabel.text drawInRect:floorFrame withAttributes:floorAttr];
            
            NSDictionary *attr = @{
                                   NSFontAttributeName:[UIFont systemFontOfSize:[GeneralService currContentFontSize]]
                                   };
            [middContentLabel.text drawInRect:contentFrame withAttributes:attr];
            //4.draw groundImg
            [groundImg drawInRect:groundImgFrame];
            
            UIImage *comBcgImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                comBcgImgView.frame = CGRectMake(0, 0, sw,CGRectGetMaxY(groundImgFrame));
                comBcgImgView.image = nil;
                comBcgImgView.image = comBcgImg;
            });
        });
        
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        bottomContentLabel.text = content.content;
        if (isChanged)
            bottomContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        
        //--bottomContentLabel
        CGSize maxBottomContentLabelSize = CGSizeMake(sw - 2 * userMarginLeft, HUGE_VALF);
        CGSize bottomContentLabelSize = [bottomContentLabel sizeThatFits:maxBottomContentLabelSize];
        CGRect contentFrame = CGRectMake(userMarginLeft, marginTop, bottomContentLabelSize.width, bottomContentLabelSize.height);
        
        if (height != nil)
            *height = CGRectGetMaxY(contentFrame) + marginTop;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{     //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            CGSize imgSize = CGSizeMake(sw, CGRectGetMaxY(contentFrame) + marginTop);
            UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            //1.draw backgroundColor
            [[UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0] setFill];
            CGContextFillRect(context, CGRectMake(0, 0, imgSize.width, imgSize.height));
            //2.draw content
            NSDictionary *attr = @{
                                   NSFontAttributeName:[UIFont systemFontOfSize:[GeneralService currContentFontSize]],
                                   };
            [bottomContentLabel.text drawInRect:contentFrame withAttributes:attr];
            //3.draw separatorLine
            CGContextSetStrokeColorWithColor(context, SEPARATOR_COLOR.CGColor);
            CGContextMoveToPoint(context, 0, imgSize.height - 1);
            CGContextAddLineToPoint(context, sw, imgSize.height);
            CGContextStrokePath(context);
            UIImage *comBcgImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                comBcgImgView.frame = CGRectMake(0, 0, sw,imgSize.height);
                comBcgImgView.image = nil;
                comBcgImgView.image = comBcgImg;
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

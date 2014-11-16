//
//  CommCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommCell.h"
#import "Content.h"
#import "GeneralService.h"

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

@interface CommCell()
{
    //只有1层
    UILabel *oneUserLabel;
    UILabel *oneTimeLabel;
    UILabel *oneContentLabel;
    UILabel *oneSeparatorLabel;
    
    //top
    UILabel *topUserLabel;
    UILabel *topTimeLabel;
    UIImageView *roofImgView;
    
    //middle
    UILabel *middUserLabel;
    UILabel *floorLabel;
    UILabel *middContentLabel;
    UIImageView *wallImgView;
    UIImageView *groundImgView;
    
    //bottom
    UILabel *bottomContentLabel;
    UILabel *separatorLabel;
}
@end
@implementation CommCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0];
        [self addSubViewsWithId:reuseIdentifier];
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
        oneSeparatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        oneSeparatorLabel.backgroundColor = SEPARATOR_COLOR;
        [self.contentView addSubview:oneSeparatorLabel];
        
        //添加autoLayout
        oneUserLabel.translatesAutoresizingMaskIntoConstraints = NO;
        oneTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *nameMap = @{@"oneUserLabel":oneUserLabel,@"oneTimeLabel":oneTimeLabel};
        //宽度
        NSString *vfH = @"H:|-15-[oneUserLabel(>=192)]-(>=14)-[oneTimeLabel(>=84)]-15-|";
        NSArray *topConsH = [NSLayoutConstraint constraintsWithVisualFormat:vfH options:0 metrics:nil views:nameMap];
        [self.contentView addConstraints:topConsH];
        //高度
        NSArray *oneUserV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[oneUserLabel(>=30)]" options:0 metrics:nil views:nameMap];
        NSArray *oneTimeV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[oneTimeLabel(>=30)]" options:0 metrics:nil views:nameMap];
        [self.contentView addConstraints:oneUserV];
        [self.contentView addConstraints:oneTimeV];
        
    } else if ([reuseId isEqualToString:kCommCellTypeTop]) {
        
        topUserLabel = [self userLabel];
        [self.contentView addSubview:topUserLabel];
        topTimeLabel = [self timeLabel];
        topTimeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:topTimeLabel];
        roofImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:roofImgView];
        
        //添加autoLayout
        topUserLabel.translatesAutoresizingMaskIntoConstraints = NO;
        topTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *nameMap = @{@"topUserLabel":topUserLabel,@"topTimeLabel":topTimeLabel};
        //宽度
        NSString *vfH = @"H:|-15-[topUserLabel(>=192)]-(>=14)-[topTimeLabel(>=84)]-15-|";
        NSArray *topConsH = [NSLayoutConstraint constraintsWithVisualFormat:vfH options:0 metrics:nil views:nameMap];
        [self.contentView addConstraints:topConsH];
        //高度
        NSArray *topUserV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[topUserLabel(>=30)]" options:0 metrics:nil views:nameMap];
        NSArray *topTimeV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[topTimeLabel(>=30)]" options:0 metrics:nil views:nameMap];
        [self.contentView addConstraints:topUserV];
        [self.contentView addConstraints:topTimeV];
        
    } else if ([reuseId isEqualToString:kCommCellTypeMiddle]) {
        
        middUserLabel = [self userLabel];
        floorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        floorLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        floorLabel.textAlignment = NSTextAlignmentRight;
        middContentLabel = [self contentLabel];
        wallImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        groundImgView = [[UIImageView alloc] initWithFrame:CGRectZero];;
        [self.contentView addSubview:wallImgView];
        [self.contentView addSubview:middUserLabel];
        [self.contentView addSubview:floorLabel];
        [self.contentView addSubview:middContentLabel];
        [self.contentView addSubview:groundImgView];
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        bottomContentLabel = [self contentLabel];
        [self.contentView addSubview:bottomContentLabel];
        separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        separatorLabel.backgroundColor = SEPARATOR_COLOR;
        [self.contentView addSubview:separatorLabel];
    }
}

- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount height:(CGFloat *)height fontSizeChanged:(BOOL)isChanged
{
    if (content == nil)
        return;
    
    _content = content;
    //获得当前的楼层为第几层
    NSInteger floorIndex = content.floorIndex.integerValue;
    NSString *reuseId = self.reuseIdentifier;
    if ([reuseId isEqualToString:kCommCellTypeOnlyOne]) {
//        CGFloat timeLabelWidth = 92;
//        oneUserLabel.frame = CGRectMake(MARGIN_LEFT, 2, SCREEN_WIDTH-MARGIN_LEFT-timeLabelWidth-5, HEAD_HEIGHT);
        if (isChanged)
            oneUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        oneUserLabel.text = content.user;
        
//        oneTimeLabel.frame = CGRectMake(SCREEN_WIDTH-MARGIN_LEFT-timeLabelWidth, 2, timeLabelWidth, HEAD_HEIGHT);
        oneTimeLabel.text = content.time;
        if (isChanged)
            oneTimeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        oneContentLabel.frame = CGRectMake(MARGIN_LEFT, CGRectGetMaxY(oneUserLabel.frame), SCREEN_WIDTH-2*MARGIN_LEFT, 0);
        oneContentLabel.text = content.content;
        if (isChanged)
            oneContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        [oneContentLabel sizeToFit];
        
        oneSeparatorLabel.frame = CGRectMake(0, CGRectGetMaxY(oneContentLabel.frame)+MARGIN_BOTTOM, SCREEN_WIDTH, 1);
        
        if (height != nil)
            *height = CGRectGetMaxY(oneSeparatorLabel.frame);
        
    } else if ([reuseId isEqualToString:kCommCellTypeTop]) {
//        CGFloat timeLabelWidth = 92;
//        topUserLabel.frame = CGRectMake(MARGIN_LEFT, 2, SCREEN_WIDTH-MARGIN_LEFT-timeLabelWidth-5, HEAD_HEIGHT);
        topUserLabel.text = content.user;
        if (isChanged)
            topUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
//        topTimeLabel.frame = CGRectMake(SCREEN_WIDTH-MARGIN_LEFT-timeLabelWidth, 2, timeLabelWidth, HEAD_HEIGHT);
        topTimeLabel.text = content.time;
        if (isChanged)
            topTimeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        UIImage *roofImg = [self roofImgWithFloorCount:floorCount];
        CGRect roofImgFrame = CGRectMake(0, CGRectGetMaxY(topUserLabel.frame), SCREEN_WIDTH, roofImg.size.height);
        roofImgView.frame = roofImgFrame;
        roofImgView.image = roofImg;
        
        if (height != nil)
            *height = CGRectGetMaxY(roofImgView.frame);
        
    } else if ([reuseId isEqualToString:kCommCellTypeMiddle]) {
        
        CGFloat labelX = [self labelXWithFloorCount:floorCount floorIndex:floorIndex];
        middUserLabel.frame = CGRectMake(labelX, 2, SCREEN_WIDTH-2*labelX-FLOOR_WIDTH, HEAD_HEIGHT);
        if (isChanged)
            middUserLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        middUserLabel.text = content.user;
        
        floorLabel.frame = CGRectMake(SCREEN_WIDTH-labelX-FLOOR_WIDTH, 2, FLOOR_WIDTH, HEAD_HEIGHT);
        floorLabel.text = content.floorIndex.description;
        if (isChanged)
            floorLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
        
        middContentLabel.frame = CGRectMake(labelX, CGRectGetMaxY(middUserLabel.frame), SCREEN_WIDTH-2*labelX, 0);
        middContentLabel.text = content.content;
        if (isChanged)
            middContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        [middContentLabel sizeToFit];
        
        UIImage *wallImg = [self wallImgWithFloorCount:floorCount floorIndex:floorIndex];
        wallImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetMaxY(middContentLabel.frame)+MARGIN_BOTTOM);
        wallImgView.image = wallImg;
        
        UIImage *groundImg = [self groundImgWithFloorCount:floorCount floorIndex:floorIndex];
        groundImgView.frame = CGRectMake(0, CGRectGetMaxY(wallImgView.frame), SCREEN_WIDTH, groundImg.size.height);
        groundImgView.image = groundImg;
        
        if (height != nil)
            *height = CGRectGetMaxY(groundImgView.frame);
        
    } else if ([reuseId isEqualToString:kCommCellTypeBottom]) {
        bottomContentLabel.frame = CGRectMake(MARGIN_LEFT, MARGIN_BOTTOM, SCREEN_WIDTH-2*MARGIN_LEFT, 0);
        bottomContentLabel.text = content.content;
        if (isChanged)
            bottomContentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]];
        [bottomContentLabel sizeToFit];
        
        separatorLabel.frame = CGRectMake(0, CGRectGetMaxY(bottomContentLabel.frame)+MARGIN_BOTTOM, SCREEN_WIDTH, 1);
        
        if (height != nil)
            *height = CGRectGetMaxY(separatorLabel.frame);
    }

}

#pragma mark - 创建label
- (UILabel *)userLabel
{
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, 2, 198, HEAD_HEIGHT)];
    userLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
//    userLabel.minimumScaleFactor = 0.8;
//    userLabel.adjustsFontSizeToFitWidth = YES;
    userLabel.textColor = LABEL_COLOR;
    return userLabel;
}

- (UILabel *)timeLabel
{
    CGFloat timeLabelWidth = 84;
    CGRect timeLabelFrame = CGRectMake(SCREEN_WIDTH-MARGIN_LEFT-timeLabelWidth, 2, timeLabelWidth, 30);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame: timeLabelFrame];
    timeLabel.font = [UIFont systemFontOfSize:[GeneralService currSubtitleFontSize]];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor darkGrayColor];
    return timeLabel;
}

- (UILabel *)contentLabel
{
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.font = [UIFont systemFontOfSize:[GeneralService currContentFontSize]]; //preferredFontForTextStyle:UIFontTextStyleSubheadline
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;

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
    
}
@end

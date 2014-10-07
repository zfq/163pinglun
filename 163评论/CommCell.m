//
//  CommCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommCell.h"
#import "Contents.h"
#import "Content.h"

#define MARGIN_LEFT 15.0f  //指距离屏幕边缘的距离
#define PADDING_LEFT 5.0f
#define HEAD_HEIGHT 30 // headLabel的高度
#define MARGIN_TOP 5 // headLabel距离ground的高度
#define MARGIN_BOTTOM 5 //label距离ground的高度
#define FLOOR_WIDTH 15 //显示楼层的label的宽度
#define HEADLABEL_FLOOR 10.0f //headlabel右边距楼层label的距离
#define GROUND_HEIGHT 4 // groundImg高度 4
#define LABEL_FONT 15 // Label的字体大小
#define LABEL_PADDING 0 // Label的上下填充
#define LABEL_COLOR RGBCOLOR(51,153,255,1.0f) // 3399FF

@implementation CommCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.userLabel.adjustsFontSizeToFitWidth = true;
    self.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCommModel:(NSMutableArray *)commModel
{
    _commModel = commModel;
    [self initSubViews];
}

#pragma mark - 添加子视图
- (void)initSubViews
{
    Content *last = [_commModel lastObject];
	_userLabel.text = last.user;
    _timeLabel.text = last.time;
    
	float allLabelHeight = 0;
	float labelOriginY = _userLabel.frame.origin.y + _userLabel.frame.size.height;

    //-----------添加楼层顶部图片---------
    UIImageView *roofImgView = [self roofImgViewWithCount:_commModel.count top:labelOriginY stretch:YES];
	if (roofImgView != nil) {
		[self.contentView addSubview:roofImgView];
		labelOriginY += roofImgView.image.size.height;
	}
    float wallImgOriginY = labelOriginY;
    float finalLabelY = 0;
	float paddingLeft = 0;
	int headlabelCount = 0;
	UIImageView *wallImgView = nil;
    BOOL oneWallImgView = _commModel.count >= 7 ? YES : NO;
	for (int i = 1; i <_commModel.count; i++)
    {
        paddingLeft = [self getPaddingLeftWithCount:_commModel.count floor:i];
		Content *temp = [_commModel objectAtIndex:i - 1];
        
		CGPoint origin = CGPointZero;
		if (i == 1)
			origin = CGPointMake(paddingLeft, labelOriginY + allLabelHeight);
		else
			origin = CGPointMake(paddingLeft, labelOriginY + allLabelHeight + (i - 1) * (HEAD_HEIGHT + GROUND_HEIGHT+MARGIN_BOTTOM));
        
        //----------添加 "网易北京市手机网友的原贴"-------
        float width = self.frame.size.width - 2 * origin.x;
        UILabel *headLabel = nil;
        headLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, width-HEADLABEL_FLOOR, HEAD_HEIGHT)];
        headLabel.font = [UIFont systemFontOfSize:11];
        headLabel.textColor = LABEL_COLOR;
        headLabel.adjustsFontSizeToFitWidth = true;
        headLabel.text = temp.user;

        //----------统计楼层个数---------
        headlabelCount++;
        
        //----------添加floor----------
        float fX = SCREEN_WIDTH - paddingLeft - FLOOR_WIDTH;
        UILabel *floor = [[UILabel alloc] initWithFrame:CGRectMake(fX, origin.y, FLOOR_WIDTH, HEAD_HEIGHT)];
        floor.font = [UIFont systemFontOfSize:11];
        floor.textColor = [UIColor darkGrayColor];
        floor.textAlignment = NSTextAlignmentRight;
        floor.text = [NSString stringWithFormat:@"%d", i];
        
        //----------添加内容背景图片-------
        if (oneWallImgView == YES)
        {
            wallImgView = [self wallImgViewWithCount:_commModel.count floor:i top:wallImgOriginY stretch:YES];
            oneWallImgView = NO;
            if (wallImgView != nil)
                [self.contentView addSubview:wallImgView];

        } else {
            if (_commModel.count <= 6) {    //总楼层数比较小时
                wallImgView = [self wallImgViewWithCount:_commModel.count floor:i top:origin.y stretch:YES];
                if (wallImgView != nil)
                    [self.contentView addSubview:wallImgView];
            } else {
                if (i>=_commModel.count-5) {
                    wallImgView = [self wallImgViewWithCount:_commModel.count floor:i top:origin.y stretch:YES];
                    if (wallImgView != nil)
                        [self.contentView addSubview:wallImgView];
                }
            }
        }
        
        //添加headLabel 和 floor，注意顺序，必须在添加wallImgView后添加
        [self.contentView addSubview:headLabel];
        [self.contentView addSubview:floor];
        
		//--------添加评论内容label-----------
        CGRect rect = self.frame;
        rect.origin = CGPointMake(paddingLeft, headLabel.frame.origin.y + headLabel.frame.size.height);
        CGRect labelFrame = CGRectMake(rect.origin.x, rect.origin.y,SCREEN_WIDTH - 2 * paddingLeft, rect.size.height);
        UILabel *label = [self getLabelWithContent:temp.content fontSize:LABEL_FONT frame:labelFrame];
		CGRect labelRect = label.frame;
		labelRect.size.height += LABEL_PADDING;
		label.frame = labelRect;
        
		allLabelHeight += label.frame.size.height;
        
        if (wallImgView != nil) {
            if (_commModel.count <= 6) {
                wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y, SCREEN_WIDTH, headLabel.frame.size.height + label.frame.size.height+MARGIN_BOTTOM);

            } else {
                if (i < _commModel.count-5)
                    wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y, SCREEN_WIDTH, CGRectGetMaxY(label.frame)-(HEAD_HEIGHT +GROUND_HEIGHT + MARGIN_BOTTOM));
                else
                    wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y-1, SCREEN_WIDTH, headLabel.frame.size.height + label.frame.size.height + MARGIN_BOTTOM);
            }
        }
		
        //添加groundImg
        CGFloat groundY = wallImgView.frame.origin.y+wallImgView.frame.size.height;
        UIImageView *groundImgView = [self groundImgViewWithCount:_commModel.count floor:i frame:CGRectMake(0, groundY, SCREEN_WIDTH, GROUND_HEIGHT) stretch:YES];
        if (groundImgView != nil) {
            [self.contentView addSubview:groundImgView];
            finalLabelY = groundY + GROUND_HEIGHT;
        }

		[self.contentView addSubview:label];
	} // end for
    
    //--------添加第一层楼的评论label（显示在cell最下方）---------
    if (_commModel.count == 1)
        finalLabelY = _userLabel.frame.origin.y+_userLabel.frame.size.height;
    
    CGRect finalLabelFrame = CGRectMake(MARGIN_LEFT,finalLabelY+MARGIN_BOTTOM, SCREEN_WIDTH-2*MARGIN_LEFT, 0);
    UILabel *finalLabel = [self getLabelWithContent:last.content fontSize:LABEL_FONT frame:finalLabelFrame];
    [self.contentView addSubview:finalLabel];
}

- (CGFloat)heightWithCommModel:(NSMutableArray *)model
{
    Content *last = [model lastObject];

	float allLabelHeight = 0;
	float labelOriginY = _userLabel.frame.origin.y + _userLabel.frame.size.height;
    
    //-----------添加楼层顶部图片---------
    UIImageView *roofImgView = [self roofImgViewWithCount:model.count top:labelOriginY stretch:YES];
	if (roofImgView != nil) {
		labelOriginY += roofImgView.image.size.height;
	}
    float wallImgOriginY = labelOriginY;
    float finalLabelY = 0;
	float paddingLeft = 0;
	int headlabelCount = 0;
	UIImageView *wallImgView = nil;
    BOOL oneWallImgView = model.count >= 7 ? YES : NO;
	for (int i = 1; i <model.count; i++)
    {
        paddingLeft = [self getPaddingLeftWithCount:model.count floor:i];
		Content *temp = [model objectAtIndex:i - 1];
        
		CGPoint origin = CGPointZero;
		if (i == 1)
			origin = CGPointMake(paddingLeft, labelOriginY + allLabelHeight);
		else
			origin = CGPointMake(paddingLeft, labelOriginY + allLabelHeight + (i - 1) * (HEAD_HEIGHT + GROUND_HEIGHT+MARGIN_BOTTOM));
        
        //----------添加 "网易北京市手机网友的原贴"-------
        float width = self.frame.size.width - 2 * origin.x;
        UILabel *headLabel = nil;
        headLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, width-HEADLABEL_FLOOR, HEAD_HEIGHT)];
        headLabel.font = [UIFont systemFontOfSize:11];
        
        //----------统计楼层个数---------
        headlabelCount++;
        
        //----------添加内容背景图片-------       
        if (oneWallImgView == YES)
        {
            wallImgView = [self wallImgViewWithCount:model.count floor:i top:wallImgOriginY stretch:YES];
            oneWallImgView = NO;
        } else {
            if (model.count <= 6) {    //总楼层数比较小时
                wallImgView = [self wallImgViewWithCount:model.count floor:i top:origin.y stretch:YES];
            } else {
                if (i>=_commModel.count-5) {
                    wallImgView = [self wallImgViewWithCount:model.count floor:i top:origin.y stretch:YES];
                }
            }
        }

		//--------添加评论内容label-----------
        CGRect rect = self.frame;
        rect.origin = CGPointMake(paddingLeft, headLabel.frame.origin.y + headLabel.frame.size.height);
        CGRect labelFrame = CGRectMake(rect.origin.x, rect.origin.y,SCREEN_WIDTH - 2 * paddingLeft, rect.size.height);
        UILabel *label = [self getLabelWithContent:temp.content fontSize:LABEL_FONT frame:labelFrame];
		CGRect labelRect = label.frame;
		labelRect.size.height += LABEL_PADDING;
		label.frame = labelRect;
        
		allLabelHeight += label.frame.size.height;
        
        if (wallImgView != nil) {
            if (model.count <= 6) {
                wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y, SCREEN_WIDTH, headLabel.frame.size.height + label.frame.size.height+MARGIN_BOTTOM);
                
            } else {
                if (i < model.count-5)
                    wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y, SCREEN_WIDTH, CGRectGetMaxY(label.frame)-(HEAD_HEIGHT + GROUND_HEIGHT+MARGIN_BOTTOM));
                else
                    wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y-1, SCREEN_WIDTH, headLabel.frame.size.height + label.frame.size.height+MARGIN_BOTTOM);
            }
        }
        
        CGFloat groundY = wallImgView.frame.origin.y+wallImgView.frame.size.height;
        UIImageView *groundImgView = [self groundImgViewWithCount:model.count floor:i frame:CGRectMake(0, groundY, SCREEN_WIDTH, GROUND_HEIGHT) stretch:YES];
        if (groundImgView != nil) {
            finalLabelY = groundY + GROUND_HEIGHT;
        }

	} // end for
    
    //--------添加第一层楼的评论label（显示在cell最下方）---------
    if (model.count == 1)
        finalLabelY = _userLabel.frame.origin.y+_userLabel.frame.size.height;
    
    CGRect finalLabelFrame = CGRectMake(MARGIN_LEFT,finalLabelY+MARGIN_BOTTOM, SCREEN_WIDTH-2*MARGIN_LEFT, 0);
    UILabel *finalLabel = [self getLabelWithContent:last.content fontSize:LABEL_FONT frame:finalLabelFrame];
    allLabelHeight += finalLabel.frame.size.height+MARGIN_BOTTOM;
  
    CGFloat cellHeight = 0;
    if (model.count == 1)
		cellHeight = labelOriginY + allLabelHeight+MARGIN_BOTTOM;
	else
    {
		cellHeight = labelOriginY + allLabelHeight + (model.count - 1) * (HEAD_HEIGHT + GROUND_HEIGHT) + model.count*MARGIN_BOTTOM;
    }
    return cellHeight;
}

#pragma mark - 辅助函数
- (CGFloat)getPaddingLeftWithCount:(NSInteger)count floor:(NSInteger)floor
{
    float paddingLeft = 0.0f;
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

- (UIImageView *)roofImgViewWithCount:(NSInteger)count top:(CGFloat)top stretch:(BOOL)stretch
{
    //添加roof图片
    UIImage *roofImg = nil;
    UIImageView *roofImgView = nil;
    if (count >= 2) {
        NSString *roofImgName = nil;
        if (count > 5)
            roofImgName = @"comment.bundle/comment_roof_5";
        else
            roofImgName = [NSString stringWithFormat:@"comment.bundle/comment_roof_%d", count - 1];
        
        roofImg = [UIImage imageNamed:roofImgName];
        if (stretch == YES)
            roofImg = [roofImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
        CGRect roofRect = CGRectMake(0, top,SCREEN_WIDTH, roofImg.size.height);
        roofImgView = [[UIImageView alloc] initWithFrame:roofRect];
        roofImgView.image = roofImg;
    }
    return roofImgView;
}

- (UIImageView *)wallImgViewWithCount:(NSInteger)count floor:(NSInteger)floor top:(float)top stretch:(BOOL)stretch
{
    //添加headlabel 背景和底部图片，最后将其拉伸
    NSString *wallImgName = nil;
    UIImageView *wallImgView = nil;
    NSInteger maxFloor = 5;
    
    if (count > 1)
    {
        if (count >= maxFloor+1)
        {
            if (floor < count - maxFloor)
            {
                wallImgName = @"comment.bundle/comment_wall_5";
            }
            else
            {
                wallImgName = [NSString stringWithFormat:@"comment.bundle/comment_wall_%d",count - floor];
            }
        }
        else
        {
            wallImgName = [NSString stringWithFormat:@"comment.bundle/comment_wall_%d",count - floor];
        }
        
        wallImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, HEAD_HEIGHT)];
        UIImage *wallImg = [UIImage imageNamed:wallImgName];
        if (stretch == YES)
            wallImg = [wallImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 50) resizingMode:UIImageResizingModeStretch];
        wallImgView.image = wallImg;
    }
    
    return wallImgView;
}

- (UIImageView *)groundImgViewWithCount:(NSInteger)count floor:(NSInteger)floor frame:(CGRect)frame stretch:(BOOL)stretch
{
    //添加headlabel 背景和底部图片，最后将其拉伸
    UIImageView *groundImgView = nil;
    NSString *groundImgName = nil;
    NSInteger maxFloor = 5;
    
    if (count > 1)
    {
        if (count >= maxFloor+1)
        {
            if (floor < count - maxFloor)
            {
                groundImgName = @"comment.bundle/comment_ground_5";
            }
            else
            {
                groundImgName = [NSString stringWithFormat:@"comment.bundle/comment_ground_%d",count - floor];
            }
        }
        else
        {
            groundImgName = [NSString stringWithFormat:@"comment.bundle/comment_ground_%d",count - floor];
        }
        
        groundImgView = [[UIImageView alloc] initWithFrame:frame];
        UIImage *groundImg = [UIImage imageNamed:groundImgName];
        if (stretch == YES)
            groundImg = [groundImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 50) resizingMode:UIImageResizingModeStretch];
        groundImgView.image = groundImg;
    }
    groundImgView.backgroundColor = [UIColor grayColor];
    return groundImgView;
}

- (UILabel *)getLabelWithContent:(NSString *)content fontSize:(CGFloat)fontSize frame:(CGRect)rect
{
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    contentLabel.text = content;
    contentLabel.frame = rect;
    [contentLabel sizeToFit];
    
    return contentLabel;
}

- (void)dealloc
{
    _contents = nil;
    _contentItems = nil;    
}
@end

//
//  CommViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-7.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "CommViewController.h"
#import "CommCell.h"
#import "ItemStore.h"
#import "Content.h"
#import "Contents.h"
//#import "UILabel+VerticalAlign.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define MARGIN_LEFT 15.0f  //指距离屏幕边缘的距离
#define PADDING_LEFT 5.0f
#define HEAD_HEIGHT 30 // headLabel的高度
#define MARGIN_TOP 5 // headLabel距离ground的高度
#define MARGIN_BOTTOM 5 //label距离ground的高度
#define FLOOR_WIDTH 15 //显示楼层的label的宽度
#define GROUND_HEIGHT 4 // groundImg高度
#define LABEL_FONT 15 // Label的字体大小
#define LABEL_PADDING 0 // Label的上下填充
#define LABEL_COLOR [UIColor colorWithRed:0.2f green:0.6f blue:1.0f alpha:1.0f]         // 3399FF

@interface CommViewController () {
	Contents *_contents;
}
@end

@implementation CommViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
    
	self.tableView.allowsSelection = NO;
	UINib *cellNib = [UINib nibWithNibName:@"CommCell" bundle:nil];
	[self.tableView registerNib:cellNib forCellReuseIdentifier:@"CommCell"];
	[self fetchComment];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)fetchComment {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[ItemStore sharedTagStore].cotentsURL =
    @"http://163pinglun.com/wp-json/posts/12404/comments"; // 2935 10617 12402
	[[ItemStore sharedTagStore] fetchContentsWithCompletion: ^(Contents *contents, NSError *error) {
	    _contents = contents;
	    [UIApplication sharedApplication].networkActivityIndicatorVisible =
        NO;
	    [self.tableView reloadData];
	}];
}

#pragma mark -
#pragma mark cell的辅助函数

- (NSInteger)   tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
	if (_contents == nil)
		return 0;
	else
		return _contents.contentItems.count; //_contents.contentItems.count
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CommCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommCell"];
	if (cell == nil) {
		cell = [[CommCell alloc] init];
	}
	else { //删除所有添加的子视图，除xib内的几个之外
		@autoreleasepool {
			for (UIView *v in cell.contentView.subviews) {
				if (v.tag != 50)
					if (v.tag != 51) {
						[v removeFromSuperview];
					}
			}
		}
	}
    
	//获取最后一楼，放在第一行显示
	NSArray *array = [_contents.contentItems objectAtIndex:(_contents.contentItems.count - indexPath.row - 1)];
	Content *last = [array lastObject];
	cell.userLabel.text = last.user;
	float allLabelHeight = 0;
	float labelOriginY =
    cell.userLabel.frame.origin.y + cell.userLabel.frame.size.height;
    
	//添加roof图片
	UIImage *roofImg = nil;
	UIImageView *roofImgView = nil;
	if (array.count > 2) {
		NSString *roofImgName = nil;
		if (array.count >= 5)
			roofImgName = @"comment.bundle/comment_roof_5";
		else
			roofImgName = [NSString
			               stringWithFormat:@"comment.bundle/comment_roof_%u", array.count - 1];
        
		roofImg = [UIImage imageNamed:roofImgName];
		CGRect roofRect =
        CGRectMake((SCREEN_WIDTH - roofImg.size.width) / 2.0f, labelOriginY,
                   SCREEN_WIDTH, roofImg.size.height);
		roofImgView = [[UIImageView alloc] initWithFrame:roofRect];
		roofImgView.image = roofImg;
	}
	if (roofImgView != nil) {
		[cell.contentView addSubview:roofImgView];
		labelOriginY += roofImg.size.height;
	}
    
    float finalLabelY = 0;
	//添加headlabel 和 内容label
	int paddingLeft = 0;
	int headlabelCount = 0;
	UIImageView *wallImgView = nil;
	for (int i = 1; i <array.count; i++)
    {
		if (array.count > 5) { //大于5层
			if (i <= array.count - 5)
				paddingLeft = 5 * PADDING_LEFT + MARGIN_LEFT;
			else
				paddingLeft = (array.count - i) * PADDING_LEFT + MARGIN_LEFT;
		}
		else if (array.count <= 5 && array.count >= 2) //<=5层
			paddingLeft = (array.count - i) * PADDING_LEFT + MARGIN_LEFT;
		else //只有1层
			paddingLeft = MARGIN_LEFT;
        
		Content *temp = [array objectAtIndex:i - 1];
        
		//添加用户名label和floor
		CGPoint origin;
		if (i == 1)
			origin = CGPointMake(paddingLeft, labelOriginY + allLabelHeight);
		else
			origin =
            CGPointMake(paddingLeft, labelOriginY + allLabelHeight +
                        (i - 1) * (HEAD_HEIGHT + GROUND_HEIGHT+MARGIN_BOTTOM));
        
		float width = cell.frame.size.width - 2 * origin.x;
		UILabel *headLabel = nil;
		NSString *wallImgName = nil;
		NSString *groundImgName = nil;
        
        headLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, HEAD_HEIGHT)];
        headLabel.font = [UIFont systemFontOfSize:11];
        headLabel.textColor = LABEL_COLOR;
        headLabel.adjustsFontSizeToFitWidth = true;
        headLabel.minimumScaleFactor = 0.6f;
        
        headLabel.text = temp.user;
        //统计headlabel个数
        headlabelCount++;
        
        //添加显示楼层floor
        float fX = SCREEN_WIDTH - paddingLeft - FLOOR_WIDTH;
        UILabel *floor = [[UILabel alloc]
                          initWithFrame:CGRectMake(fX, origin.y, FLOOR_WIDTH, HEAD_HEIGHT)];
        floor.font = [UIFont systemFontOfSize:11];
        floor.textColor = [UIColor darkGrayColor];
        floor.textAlignment = NSTextAlignmentRight;
        floor.text = [NSString stringWithFormat:@"%d", i];
        
        //添加headlabel wall，最后将其拉伸
        float wallY = 0;
        
        if (array.count > 1) {
            if (array.count >= 6) {
                if (i < array.count - 5) {
                    wallImgName = @"comment.bundle/comment_wall_5";
                    groundImgName = @"comment.bundle/comment_ground_5";
                }
                else {
                    wallImgName =
                    [NSString stringWithFormat:@"comment.bundle/comment_wall_%d",
                     array.count - i];
                    groundImgName =
                    [NSString stringWithFormat:@"comment.bundle/comment_ground_%d",
                     array.count - i];
                }
            }
            else {
                wallImgName =
                [NSString stringWithFormat:@"comment.bundle/comment_wall_%d",
                 array.count - i];
                groundImgName =
                [NSString stringWithFormat:@"comment.bundle/comment_ground_%d",
                 array.count - i];
            }
            
            wallY = origin.y;
            wallImgView = [[UIImageView alloc]
                           initWithFrame:CGRectMake(0, wallY, SCREEN_WIDTH, HEAD_HEIGHT)];
            wallImgView.image = [UIImage imageNamed:wallImgName];
        }
        if (wallImgView != nil)
            [cell.contentView addSubview:wallImgView]; //添加headLabel下的wall
        
        [cell.contentView addSubview:floor]; //显示楼层label
        [cell.contentView addSubview:headLabel]; //显示用户名
        
		//添加评论label
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		UIFont *labelFont = [UIFont systemFontOfSize:LABEL_FONT];
		label.font = labelFont;
		label.numberOfLines = 0;
		label.lineBreakMode = NSLineBreakByCharWrapping;
		label.text = temp.content; //[[self class] replaceBr:temp.content]
		//设置label的frame,并为其填充padding
		CGRect rect = CGRectInset(cell.frame, 0, 0); //后面的两个数好像没啥用
        
        rect.origin = CGPointMake(paddingLeft, headLabel.frame.origin.y + headLabel.frame.size.height);
		label.frame = CGRectMake(rect.origin.x, rect.origin.y,SCREEN_WIDTH - 2 * paddingLeft, rect.size.height);
		[label sizeToFit];
		CGRect labelRect = label.frame;
		labelRect.size.height += LABEL_PADDING;
		label.frame = labelRect;
        
		allLabelHeight += label.frame.size.height;
        
        if (wallImgView != nil) {
            wallImgView.frame = CGRectMake(0, wallImgView.frame.origin.y, SCREEN_WIDTH, headLabel.frame.size.height + label.frame.size.height+MARGIN_BOTTOM);
        }
		
		//修改ground图片的y坐标
        CGFloat groundY = wallImgView.frame.origin.y+wallImgView.frame.size.height;
		if (groundImgName != nil) {
			UIImage *groundImg = [UIImage imageNamed:groundImgName];
			UIImageView *groundImgView = [[UIImageView alloc]
			                              initWithFrame:CGRectMake(0, groundY, SCREEN_WIDTH, GROUND_HEIGHT)];
			groundImgView.image = groundImg;
			[cell.contentView addSubview:groundImgView];
            finalLabelY = groundY + GROUND_HEIGHT;
		}
		[cell.contentView addSubview:label];
	} // end for
    
    //设置最后一楼的label
    if (array.count == 1)
        finalLabelY = cell.userLabel.frame.origin.y+cell.userLabel.frame.size.height;
    
    UILabel *finalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *labelFont = [UIFont systemFontOfSize:LABEL_FONT];
    finalLabel.font = labelFont;
    finalLabel.numberOfLines = 0;
    finalLabel.lineBreakMode = NSLineBreakByCharWrapping;
    finalLabel.text = last.content;
    finalLabel.frame = CGRectMake(MARGIN_LEFT,finalLabelY+MARGIN_BOTTOM, SCREEN_WIDTH-2*MARGIN_LEFT, finalLabel.frame.size.height);
    [finalLabel sizeToFit];
    [cell.contentView addSubview:finalLabel];
    
    allLabelHeight += finalLabel.frame.size.height+MARGIN_BOTTOM;
    
	CGPoint cellOrigin = cell.frame.origin;
	float height = 0;
	if (array.count == 1)
		height = labelOriginY + allLabelHeight+MARGIN_BOTTOM;
	else
		height = labelOriginY + allLabelHeight + (array.count - 1) * (HEAD_HEIGHT + GROUND_HEIGHT+MARGIN_BOTTOM) + 10; //10
	cell.frame = CGRectMake(cellOrigin.x, cellOrigin.y, cell.frame.size.width, height); //labelOriginY
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CommCell *cell = (CommCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
	return cell.frame.size.height; //
}

@end

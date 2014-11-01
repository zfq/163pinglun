//
//  TagScrollView.m
//  MyScrollTag
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "TagScrollView.h"

@interface TagScrollView()
{
    CGFloat preOffset;
    CGFloat currOffset;
    
    NSInteger currTopIndex;
    NSInteger preTopIndex;
    NSInteger preBottomIndex;
    NSInteger currBottomIndex;
    
    NSMutableArray *_tagsCountInCell;
    CGFloat cellWidth;
    CGFloat cellHeight;
    
    NSMutableArray *tempArray;
}
@end

@implementation TagScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        cellHeight = 50;
        _horizontalPadding = 10;
        _verticalPadding = 3;
        _rightMargin = 0;
        _leftMargin = 0;
        
        preOffset = 0;
        currOffset = 0;
        preTopIndex = 0;
        
        self.delegate = self;
        self.alwaysBounceVertical = YES;
    }
    return self;
}

- (void)setTagViews:(NSArray *)tagViews
{
    _tagViews = tagViews;
  
    [self initialize];
    [self addVisibleTagView];
}

- (NSArray *)tagsCountInCell
{
    return _tagsCountInCell;
}

- (void)initialize
{
    cellWidth = self.frame.size.width - _leftMargin-_rightMargin;
  
    CGFloat currWidth = 0;
    
    int beginIndexOfCell = 0;//当前行开始的tag索引
    int preIndexOfCell = 0; //前一行的开始的tag索引
    
    //100表示行数 t[3]=4表示第4行有4个tag row=3
    if (_tagsCountInCell == nil) {
        _tagsCountInCell = [[NSMutableArray alloc] init];
    }
    for (int i=0;i<_tagViews.count;i++)
    {
        TagView *view = [_tagViews objectAtIndex:i];
        NSAssert(view.frame.size.width<=cellWidth, @"字符串太长");
        if (i==beginIndexOfCell) {
            currWidth = view.frame.size.width;
        }else {
            currWidth += (view.frame.size.width+_horizontalPadding);
        }
        
        if (currWidth < cellWidth)
        {
            if (i == _tagViews.count-1)
            {
                //说明tags中的所有tagView的宽度和仍<cellWidth
                [_tagsCountInCell addObject:@[@(beginIndexOfCell),@(i - beginIndexOfCell+1)]];
            }
        }
        else
        {
            if (i<_tagViews.count-1)
            {
                //调整前一行各个tagView的frame,使其宽度之和为cellWidth
                currWidth = 0;
                preIndexOfCell = beginIndexOfCell;
                beginIndexOfCell = (i==0 ? 0 : i);
                [_tagsCountInCell addObject: @[@(preIndexOfCell),@(beginIndexOfCell - preIndexOfCell)]]; //第一个表示起始索引，第二个表示个数
                preIndexOfCell = beginIndexOfCell;
                i=i-1;
            }
            else    //恰好加了最后一个才超过边界
            {
                [_tagsCountInCell addObject:@[@(beginIndexOfCell),@(i - preIndexOfCell)]];
                [_tagsCountInCell addObject:@[@(i),@1]];
            }
            
        }
    } //end for
    
    //设置contentsize
    CGFloat height = _tagsCountInCell.count * (cellHeight + _verticalPadding) + _topMargin + _bottomMargin;
    self.contentSize = CGSizeMake(self.frame.size.width, height);
}

- (void)addVisibleTagView
{
    //设置可见view的frame
    NSInteger topIndex = [self topIndex:self.contentOffset.y];
    NSInteger bottomIndex = [self bottomIndex:self.contentOffset.y];
    for (NSInteger i=topIndex; i<=bottomIndex; i++) {
        //计算宽度和
        NSArray *array = [_tagsCountInCell objectAtIndex:i];
        NSInteger beginIndex = ((NSNumber*)(array.firstObject)).integerValue;
        NSInteger length = ((NSNumber*)(array.lastObject)).integerValue;
        NSInteger end = beginIndex + length;
        //计算原始总宽度
        CGFloat originWidth = 0;
       
        for (NSInteger j= beginIndex; j<end; j++) {
            TagView *tagView = [_tagViews objectAtIndex:j];
            originWidth += tagView.frame.size.width;
        }
        originWidth += (length-1)*_horizontalPadding;
        
        //计算拉伸量
        CGFloat widthStretch = (cellWidth-originWidth)/length;
        NSAssert(widthStretch>0,@"行数计算错误");
        //修改frame
        CGRect originFrame = CGRectZero;
        CGFloat originX = 0;
        CGFloat preTagViewMaxX = 0;
        CGFloat originY = i*(cellHeight+_verticalPadding)+_topMargin;
        short count =0;
        TagView *tagView = nil;
        for (NSInteger j=beginIndex;j<end;j++)
        {
            tagView = ((TagView *)[_tagViews objectAtIndex:j]);
            //修改origin坐标
            originFrame = tagView.frame;
            originX = (count==0) ? _leftMargin : (preTagViewMaxX + _horizontalPadding);
            originFrame.origin = (CGPoint){originX,originY};
            originFrame.size = (CGSize){originFrame.size.width+widthStretch,originFrame.size.height};
            tagView.frame = originFrame;
            preTagViewMaxX = tagView.frame.origin.x+tagView.frame.size.width;
            [self addSubview:tagView];
            count ++;
        }
    }
    if (tempArray == nil) {
        tempArray = [[NSMutableArray alloc] init];
    }
}

- (void)layoutTagViewAtIndex:(NSInteger)index inArray:(NSArray *)newArray
{
    NSInteger length = newArray.count;
    CGRect originFrame = CGRectZero;
    __block CGFloat originWidth = 0;
    CGFloat originX = 0;
    CGFloat widthStretch = 0;
    CGFloat preTagViewMaxX = 0;
    short count = 0;
    TagView *tagView=nil;
    //计算宽度和
    [newArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TagView *view = (TagView *)obj;
        originWidth += view.frame.size.width;
    }];

    originWidth += (length-1) * _horizontalPadding;
    
    //计算各个tagView的拉伸量
    tagView = nil;
    widthStretch = (cellWidth-originWidth)/length;
    CGFloat originY = index * (cellHeight + _verticalPadding)+_topMargin;
    for (NSInteger i=0; i < newArray.count; i++) {
        tagView = ((TagView *)[newArray objectAtIndex:i]);
        originFrame = tagView.frame;
        originX = (count==0) ? _leftMargin : (preTagViewMaxX + _horizontalPadding);
        originFrame.origin = (CGPoint){originX,originY};
        originFrame.size = (CGSize){originFrame.size.width+widthStretch,originFrame.size.height};
        tagView.frame = originFrame;
        [self addSubview:tagView];
        preTagViewMaxX = tagView.frame.origin.x+tagView.frame.size.width;
        count ++;
    }
    tagView = nil;
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_tagViews.count == 0) {
        return;
    }
    currOffset = scrollView.contentOffset.y;
    
    if (currOffset > preOffset) {   //向上移动
        //移除最上面
        preTopIndex = currTopIndex;
        currTopIndex = [self topIndex:currOffset];
        if (preTopIndex < currTopIndex) {
            //移除第preTopIndex行
            NSArray *array = [_tagsCountInCell objectAtIndex:preTopIndex];
            NSInteger beginIndex = ((NSNumber *)[array firstObject]).integerValue;
            NSInteger count = ((NSNumber *)[array lastObject]).integerValue;
            NSInteger end = beginIndex+count;
            for (NSInteger i=beginIndex; i < end; i++) {
                TagView *tagView = [_tagViews objectAtIndex:i];
                [tagView removeFromSuperview];
            }
        }
        //添加最下面
        preBottomIndex = currBottomIndex;
        currBottomIndex = [self bottomIndex:currOffset];
        if (preBottomIndex < currBottomIndex) {

            if (currBottomIndex <_tagsCountInCell.count) {
                NSArray *array = [_tagsCountInCell objectAtIndex:currBottomIndex];
                NSInteger beginIndex = ((NSNumber *)[array firstObject]).integerValue;
                NSInteger count = ((NSNumber *)[array lastObject]).integerValue;
                NSInteger end = beginIndex+count;
                [tempArray removeAllObjects];
                for (NSInteger i=beginIndex; i < end; i++) { //_tagviews相当于数据源
                    TagView *originView = [_tagViews objectAtIndex:i];
                    [tempArray addObject:originView];
                }
                //调整frame
                [self layoutTagViewAtIndex:currBottomIndex inArray:tempArray];
            }
            
        }
       
    } else if (currOffset < preOffset){  //向下移动
        //向下移动,在最上面add,在最下面remove
        preTopIndex = currTopIndex;
        currTopIndex = [self topIndex:currOffset];
        if (currTopIndex < preTopIndex) {
            NSArray *array = [_tagsCountInCell objectAtIndex:currTopIndex];
            NSInteger beginIndex = ((NSNumber *)[array firstObject]).integerValue;
            NSInteger count = ((NSNumber *)[array lastObject]).integerValue;
            NSInteger end = beginIndex+count;
            [tempArray removeAllObjects];
            for (NSInteger i=beginIndex; i < end; i++) { //_tagviews相当于数据源
                TagView *originView = [_tagViews objectAtIndex:i];
                [tempArray addObject:originView];
            }
            //调整frame
            [self layoutTagViewAtIndex:currTopIndex inArray:tempArray];
        }
        //最下面,移除pre
        preBottomIndex = currBottomIndex;
        currBottomIndex = [self bottomIndex:currOffset];
        if (preBottomIndex > currBottomIndex) {
            if (preBottomIndex < _tagsCountInCell.count)
            {
                NSArray *array = [_tagsCountInCell objectAtIndex:preBottomIndex];
                NSInteger beginIndex = ((NSNumber *)[array firstObject]).integerValue;
                NSInteger count = ((NSNumber *)[array lastObject]).integerValue;
                NSInteger end = beginIndex+count;
                for (NSInteger i=beginIndex; i < end; i++) {
                    TagView *tagView = [_tagViews objectAtIndex:i];
                    [tagView removeFromSuperview];
                }
            }
        }
    }
    preOffset = currOffset;
}

//假定offsetY都是>0
- (NSInteger)topIndex:(CGFloat)offsetY  //返回最上面可见行的索引
{
    if (offsetY < (_topMargin + cellHeight))
    {
        return 0;
    }
    else
    {
        return floorf((offsetY + _topMargin)/(cellHeight + _verticalPadding));
    }
}

- (NSInteger)bottomIndex:(CGFloat)offsetY
{
    if (offsetY == 0)
    {
        NSInteger count = _tagsCountInCell.count;
        if (count * (cellHeight + _verticalPadding) + _topMargin <= self.frame.size.height) {
            return count-1;
        } else {
            return floorf((offsetY - _topMargin + self.frame.size.height)/(cellHeight + _verticalPadding));
        }
    }
    else
    {
        return floorf((offsetY - _topMargin + self.frame.size.height)/(cellHeight + _verticalPadding));
    }
}


@end





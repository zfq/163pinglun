//
//  ZFQSliderControl.m
//  字体大小控件
//
//  Created by _ on 16/7/24.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQSliderControl.h"
#import "ZFQTumbLayer.h"

@interface ZFQSliderControl()
{
    NSInteger _stageCount;
    
    CGFloat _leftPadding;
    CAShapeLayer *_sliderLayer;   //横线
    ZFQTumbLayer *_thumbLayer;   //圆形按钮
    CGPoint _preLocation;
    CGFloat _averageValue;  //平均值
    NSMutableArray<CATextLayer *> *_numbers;
}
@end
@implementation ZFQSliderControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CALayer *layer = self.layer;
        _sliderLayer = [CAShapeLayer layer];
        _lineColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1];

        [layer addSublayer:_sliderLayer];
        
        CGFloat width = 34;
        _thumbLayer = [ZFQTumbLayer layer];
        _thumbLayer.bounds = CGRectMake(0, 0, width, width);
        _thumbLayer.sliderControl = self;
        _thumbLayer.contentsScale = [UIScreen mainScreen].scale;
        _thumbLayer.rasterizationScale = _thumbLayer.contentsScale;
        [layer addSublayer:_thumbLayer];
        
        _currIndex = 0;
        _stageCount = 2;
        _allowTapToChange = YES;
    }
    return self;
}

- (void)moveThumbToIndex:(NSInteger)index
{
    _currIndex = index;
    _thumbLayer.position = CGPointMake(index * _averageValue, self.bounds.size.height/2);
    
    if ([self.sliderDelegate respondsToSelector:@selector(sliderBarDidMoved:)]) {
        [self.sliderDelegate sliderBarDidMoved:self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //计算平均值
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    if (_stageCount == 1) {
        _averageValue = w;
    } else {
        _averageValue = w/(_stageCount-1);
    }
    
    CGFloat sliderHeight = h;
    CGSize size = self.bounds.size;
    _sliderLayer.bounds = CGRectMake(0, 0, size.width, sliderHeight);
    _sliderLayer.position = CGPointMake(size.width/2, size.height/2);
    [self moveThumbToIndex:_currIndex];
    
    //画刻度
    [self scaleMark];
    
    //更新UI
    if (!_numbers) {
        _numbers = [[NSMutableArray alloc] initWithCapacity:_stageCount];
    }
    
    CATextLayer *tempTextLayer = nil;
    CALayer *layer = self.layer;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    for (NSInteger i = 0; i < _stageCount; i++) {
        if (i>= _numbers.count) {
            CATextLayer *textLayer = [self textLayerWithStr:_numberStrs[i]];
            [_numbers addObject:textLayer];
            [layer addSublayer:textLayer];
        }
        tempTextLayer = _numbers[i];
        //修改位置
        tempTextLayer.string = _numberStrs[i];
        
        tempTextLayer.position = CGPointMake(i * _averageValue, h+tempTextLayer.bounds.size.height/2);
    }
    
    [CATransaction commit];
}

#pragma mark - private

- (CATextLayer *)textLayerWithStr:(NSString *)str
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.fontSize = 14;
    textLayer.string = str;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.bounds = CGRectMake(0, 0, 50, 30);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}

///绘制刻度路径
- (void)scaleMark
{
    CGMutablePathRef path = CGPathCreateMutable();
    NSInteger count = _numberStrs.count;
    CGFloat scaleHeight = 4;
    CGFloat centerY = _sliderLayer.bounds.size.height/2;
    for (NSInteger i = 0; i < count; i++) {
        CGPathMoveToPoint(path, NULL, i * _averageValue, centerY);
        CGPathAddLineToPoint(path, NULL, i * _averageValue, centerY - scaleHeight);
    }
    CGPathMoveToPoint(path, NULL, 0, centerY);
    CGPathAddLineToPoint(path, NULL, _sliderLayer.bounds.size.width, centerY);
    
    _sliderLayer.strokeColor = _lineColor.CGColor;
    _sliderLayer.path = path;
    CGPathRelease(path);
}

#pragma mark - setter

- (void)setCurrIndex:(NSInteger)currIndex
{
    _currIndex = currIndex;
    [self moveThumbToIndex:currIndex];
}

- (void)setNumberStrs:(NSArray<NSString *> *)numberStrs
{
    _numberStrs = [numberStrs copy];
    _stageCount = numberStrs.count;
    
    //先remove所有的CATextLayer
    for (CATextLayer *tempLayer in _numbers) {
        [tempLayer removeFromSuperlayer];
    }
    [_numbers removeAllObjects];
    
    [self setNeedsLayout];
}

- (void)setThumbWidth:(CGFloat)thumbWidth
{
    thumbWidth = (thumbWidth < 0 ? 0 : thumbWidth);
    _thumbWidth = thumbWidth;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _thumbLayer.bounds = CGRectMake(0, 0, _thumbWidth, _thumbWidth);
    _thumbLayer.cornerRadius = thumbWidth/2;
    [CATransaction commit];
    
    [_thumbLayer setNeedsDisplay];
    [_thumbLayer displayIfNeeded];
}

#pragma mark - overwrite

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    if (_stageCount <= 1) {
        return NO;
    }
    _preLocation = [touch locationInView:self];
    
    if (_allowTapToChange) {
        NSInteger currPos = lroundf(_preLocation.x/_averageValue);
        if (currPos < 0 || currPos > _stageCount) {
            return NO;
        }
        if (_currIndex != currPos) {
            [self moveThumbToIndex:currPos];
        }
        return YES;
    } else {
        if (CGRectContainsPoint(_thumbLayer.frame, _preLocation)) {
            _thumbLayer.hightlighted = YES;
        } else {
            _thumbLayer.hightlighted = NO;
        }
        return _thumbLayer.hightlighted;
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    CGPoint currLocation = [touch locationInView:self];
    
    //计算位置
    NSInteger currPos = lroundf(currLocation.x/_averageValue);
    currPos = currPos > _stageCount ? (_stageCount-1) : currPos;
    _preLocation = currLocation;
    
    //移动到新的位置,关闭隐式动画
    if (_currIndex != currPos) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self moveThumbToIndex:currPos];
        [CATransaction commit];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event
{
    _thumbLayer.hightlighted = false;
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
    _thumbLayer.hightlighted = false;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint tapP = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(_thumbLayer.frame, tapP)) {
        _thumbLayer.hightlighted = YES;
    } else {
        _thumbLayer.hightlighted = NO;
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end

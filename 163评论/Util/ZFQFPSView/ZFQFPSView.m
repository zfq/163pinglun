//
//  ZFQFPSView.m
//  163评论
//
//  用于显示帧率
//
//  Created by _ on 15/12/17.
//  Copyright © 2015年 zhaofuqiang. All rights reserved.
//

#import "ZFQFPSView.h"

@interface ZFQFPSView()
{
    NSDictionary *_zfqAttr;
    NSInteger _currFPS;
    NSInteger _count;
    NSTimeInterval _preTime;
    CADisplayLink *_displayLink;
}
@end
@implementation ZFQFPSView

- (instancetype)initWithFrame:(CGRect)frame
{
    //!!一定要使用initWithFrame方法 不然CADisplayLink不会调用方法
    self = [super initWithFrame:frame];
    if (self) {
        _zfqAttr = @{
                     NSForegroundColorAttributeName:[UIColor redColor],
                     NSFontAttributeName:[UIFont boldSystemFontOfSize:14]
                     };
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFPS:)];
        _displayLink.frameInterval = 1;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSString *fps = [NSString stringWithFormat:@"%zi",_currFPS];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:fps attributes:_zfqAttr];
    CGSize size = attrStr.size;
    CGSize originSize = rect.size;
    CGRect frame = CGRectMake((originSize.width - size.width)/2, (originSize.height - size.height)/2, originSize.width, originSize.height);
    [attrStr drawInRect:frame];
}

- (void)updateFPS:(CADisplayLink *)link
{
    if (_preTime == 0) {
        _preTime = link.timestamp;
        return;
    }
    _count ++;
    
    NSTimeInterval delta = link.timestamp - _preTime;
    if (delta < 1) {
        return;
    }
    
    _currFPS = round(_count/delta);
    _count = 0;
    _preTime = link.timestamp;
    
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [_displayLink invalidate];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink = nil;
}
@end

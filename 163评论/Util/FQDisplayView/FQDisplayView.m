//
//  FQDisplayView.m
//  MyCoreTextDemo
//
//  持有FQCoreTextData类的实例，负责将CTFrameRef绘制到界面上
//
//  Created by 163pinglun on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import "FQDisplayView.h"
#import <CoreText/CoreText.h>
#import "FQCoreTextImageData.h"
#import "FQCoreTextUtils.h"
#import "UIView+FrameAdjust.h"
#import "MagnifierView.h"

#define fqDispRGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

typedef NS_ENUM(NSInteger, CTDisplayViewStyle) {
    CTDisplayViewStyleNormal,
    CTDisplayViewStyleTouching,
    CTDisplayViewStyleSelecting
};

@interface FQDisplayView() <UIGestureRecognizerDelegate>
{
    CGPoint _beginTapPoint;
}
@property (nonatomic) NSInteger selectionStartPosition; //字符所在的偏移量
@property (nonatomic) NSInteger selectionEndPosition; //字符所在的偏移量
@property (nonatomic,strong) UIImageView *leftSelectionAnchor;
@property (nonatomic,strong) UIImageView *rightSelectionAnchor;
@property (nonatomic) CTDisplayViewStyle ctDisplayState;
@property (nonatomic,strong) MagnifierView *magnifierView;

//-------手势-----
@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation FQDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _heighlightTextBcgColor = [UIColor blueColor];
        
        _canBeSelected = NO;
    }
    return self;
}

- (void)setCtDisplayState:(CTDisplayViewStyle)ctDisplayState
{
    if (_ctDisplayState == ctDisplayState) {
        return;
    }
    _ctDisplayState = ctDisplayState;
    switch (_ctDisplayState) {
        case CTDisplayViewStyleNormal: {
            _selectionStartPosition = -1;
            _selectionEndPosition = -1;
            _leftSelectionAnchor.tag = 0;
            _rightSelectionAnchor.tag = 0;
            [_leftSelectionAnchor removeFromSuperview];
            [_rightSelectionAnchor removeFromSuperview];
            
            [self removeMagnifierView];
            [self removeMenu];
            break;
        }
        case CTDisplayViewStyleTouching: {
            if (_leftSelectionAnchor == nil || _rightSelectionAnchor) {
                [self setupCursor];
            }
            break;
        }
        case CTDisplayViewStyleSelecting:
            if (_selectionStartPosition != -1 && _selectionEndPosition != -1) {
                [self removeMagnifierView];
                
            }
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)setCanBeSelected:(BOOL)canBeSelected
{
    _canBeSelected = canBeSelected;
    
    if (_canBeSelected == NO) {
        //移除所有手势
        NSArray *gestures = self.gestureRecognizers;
        if (gestures.count == 0) {
            [gestures enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self removeGestureRecognizer:obj];
            }];
        }
    } else {
        //添加手势
        [self setupEvent];
    }
}
#pragma mark - menu
- (void)showMenu
{
    if ([self becomeFirstResponder]) {
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyTextToPasteboard)];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(copyTextToPasteboard)];
        UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(copyTextToPasteboard)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        CGRect rect = [self rectForSelect];
        
        //翻转坐标系
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        transform = CGAffineTransformScale(transform, 1, -1);
        rect = CGRectApplyAffineTransform(rect, transform);
        
        [menu setTargetRect:rect inView:self];
        menu.menuItems = @[item,item2,item3];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (CGRect )rectForSelect
{
    if (_selectionStartPosition < 0 || _selectionEndPosition > self.data.content.length) {
        return CGRectZero;
    }
    
    //注意在这里翻转坐标系无效
    
    //这里只取第一行line的rect
    CFArrayRef lines = CTFrameGetLines(self.data.ctFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.data.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGRect startLineRect = CGRectZero;
    CGFloat rectWidth = 0;
    for (int i = 0; i < lineCount; i++) {
        //判断_selectionStartPosition是否在这一行
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        CGPoint originPoint = lineOrigins[i];
        if ([self isPositon:_selectionStartPosition inRange:range]) {
            //
            CGFloat ascent = 0,descent = 0,leading = 0,width = 0;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGFloat beginOffset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            rectWidth = width - beginOffset;
            startLineRect = CGRectMake(originPoint.x + beginOffset, originPoint.y - descent, rectWidth, ascent + descent);
            if ([self isPositon:_selectionEndPosition inRange:range]) {
                //表明只选中了一行
                CGFloat endOffset = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
                CGRect rect = CGRectMake(originPoint.x + beginOffset, originPoint.y - descent, endOffset - beginOffset, ascent + descent);
                return rect;
            }

        } else if (_selectionStartPosition < range.location && _selectionEndPosition >= range.location) {
            return startLineRect;
        }
        
    }
    
    return CGRectZero;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)copyTextToPasteboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    //获取选取的text
    NSString *text = [self.data.content.string substringWithRange:NSMakeRange(_selectionStartPosition, _selectionEndPosition-_selectionStartPosition)];
    pasteboard.string = text;
}

- (void)removeMenu
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuVisible = NO;
}

#pragma mark - 放大镜
- (MagnifierView *)magnifierView
{
    if (!_magnifierView) {
        _magnifierView = [[MagnifierView alloc] initWithFrame:CGRectZero];
        _magnifierView.viewToMagnify = self.window;
        [self addSubview:_magnifierView];
//        [self bringSubviewToFront:_magnifierView];
    }
    return _magnifierView;
}

- (void)removeMagnifierView
{
    if (_magnifierView) {
        [_magnifierView removeFromSuperview];
        _magnifierView = nil;
    }
}

#pragma mark - 手势
- (void)setupEvent
{
    //添加长按手势
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [self addGestureRecognizer:_longPressGesture];
    }
    
    //添加移动手势
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panGesture.delegate = self;
        [self addGestureRecognizer:_panGesture];
    }
    
    //添加tap手势
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:_tapGesture];
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    NSUInteger selectedCount = 2; //设置默认的选中的字符个数
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        CFIndex index = [FQCoreTextUtils touchContentOffsetInView:self atPoint:point data:self.data];
        if (index != -1 && index < self.data.content.length) {
            _selectionStartPosition = index;
            _selectionEndPosition = index + selectedCount;
            if (_selectionEndPosition > self.data.content.length) {
                _selectionEndPosition = self.data.content.length;
            }
        }
        self.magnifierView.touchPoint = point;
        self.ctDisplayState = CTDisplayViewStyleTouching;
    } else {
        if (_selectionStartPosition >= 0 && _selectionEndPosition <=self.data.content.length && (_selectionEndPosition != _selectionStartPosition)) {
            if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
                self.ctDisplayState = CTDisplayViewStyleSelecting;
                [self showMenu];
            } else {
                self.magnifierView.touchPoint = point;
            }
        } else {
            self.ctDisplayState = CTDisplayViewStyleNormal;
        }
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture
{
    if (self.ctDisplayState == CTDisplayViewStyleNormal) {
        return;
    }
    
    CGPoint point = [gesture locationInView:self];
    //1.先判断选中的是哪个点，判断是leftSelectionAnchor还是rightSelectionAnchor
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_leftSelectionAnchor && CGRectContainsPoint(_leftSelectionAnchor.frame, _beginTapPoint)) {
            _leftSelectionAnchor.tag = 1;
        } else if (_rightSelectionAnchor && CGRectContainsPoint(_rightSelectionAnchor.frame,_beginTapPoint)) {
            _rightSelectionAnchor.tag = 1;
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CFIndex index = [FQCoreTextUtils touchContentOffsetInView:self atPoint:point data:self.data]; //这个函数决定在line外是没选中文本,即便point在leftCursor或rightCursor中
        
        if (index != -1)
        {
            if (_leftSelectionAnchor.tag == 1 && index < _selectionEndPosition) { //表示让left始终小于right,不会跑到right的右边
                _selectionStartPosition = index;
            } else if (_rightSelectionAnchor.tag == 1 && index > _selectionStartPosition) { //&& index > _selectionStartPosition
                _selectionEndPosition = index;
            }
        }
        else
        {
            if (index == -1) //表示没有选中文本,但存在选中到最后的情况
            {
                if (_rightSelectionAnchor.tag == 1 && _selectionStartPosition >=0 && _selectionStartPosition <= self.data.content.length)
                {
                    CGFloat lastLineMaxY = [self lastLineOriginY];
                    if (lastLineMaxY <=0) {
                        return;
                    }
                    if (point.y >= lastLineMaxY) {
                        _selectionEndPosition = self.data.content.length;
                    }
                }
                else
                {
                    return;
                }
            }
        }

        //设置放大镜位置
        self.magnifierView.touchPoint = point;
        [self removeMenu];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        _leftSelectionAnchor.tag = 0;
        _rightSelectionAnchor.tag = 0;
        
        //移除放大镜
        [self removeMagnifierView];
        //显示菜单
        [self showMenu];
    }
    [self setNeedsDisplay];
}

- (CGFloat)lastLineOriginY
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    transform = CGAffineTransformScale(transform,1, -1);
    
    CTFrameRef frame = self.data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(frame);
    if (!lines) {
        return -1;
    }
    CFIndex lineCount = CFArrayGetCount(lines);
    if (lineCount == 0) {
        return -1;
    }
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    CGPoint last = lineOrigins[lineCount - 1];
    last = CGPointApplyAffineTransform(last, transform);
    return last.y;
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (self.ctDisplayState == CTDisplayViewStyleNormal) {
        return;
    }
    
    self.ctDisplayState = CTDisplayViewStyleNormal;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (_ctDisplayState == CTDisplayViewStyleNormal && _otherPanGestureView) {
//        return _otherPanGestureView;
//    } else {
//        return [super hitTest:point withEvent:event];
//    }
//}
#pragma mark gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    _beginTapPoint = [touch locationInView:self];
    
//    NSArray *gestures = touch.gestureRecognizers;
    BOOL notPanGes = [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
    if (_ctDisplayState == CTDisplayViewStyleNormal && notPanGes) {
        return NO;
    }
    return YES;
}

#pragma mark drawRect
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //1.先翻转坐标，保证与UIKit的坐标相同
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height); //先平移,这里就是改变原点位置
    CGContextScaleCTM(context, 1.0, -1.0); //再翻转
    
    //2.先画背景色，再绘制text
    if (self.ctDisplayState == CTDisplayViewStyleTouching || self.ctDisplayState == CTDisplayViewStyleSelecting) {
        //绘制选择区域
        [self drawSelectionArea];
        //设置leftSelectionAnchor和leftSelectionAnchor的位置
        [self setupCursorPosition];
    }
    
    //3.
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
    }
    
    //4.画图片
    for (FQCoreTextImageData * imgData in self.data.imageArray) {
        UIImage *img = [UIImage imageNamed:imgData.name];
        if (img) {
            CGContextDrawImage(context, imgData.imagePostion, img.CGImage);
        }
    }
}

- (void)drawSelectionArea
{
    if (_selectionStartPosition <0 || _selectionEndPosition > self.data.content.length) {
        return;
    }
    
    CTFrameRef textFrame = self.data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    //遍历每一行
    for (int i = 0; i < count; i++) {
        CGPoint lineOriginPoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        //1.如果在同一行,直接弄完break
        if ([self isPositon:_selectionStartPosition inRange:range] && [self isPositon:_selectionEndPosition inRange:range]) {
            //获取要画背景色的矩形
            CGFloat ascent = 0,decent =0,leading = 0,offset = 0,offset2 = 0;
            //1.获取startPostion偏移量
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &decent, &leading);
            CGRect bcgRect = CGRectMake(lineOriginPoint.x + offset, lineOriginPoint.y - decent, offset2 - offset, ascent + decent);
            //2.绘制背景
            [self fillSelectionAreaInRect:bcgRect];
            break;
        }
        
        //2.start和end不再同一行
        //2.1 先绘制start所在的行
        if ([self isPositon:_selectionStartPosition inRange:range]) {
            CGFloat ascent = 0,descent =0,leading = 0,offset = 0,width = 0;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect bcgRect = CGRectMake(lineOriginPoint.x + offset, lineOriginPoint.y - descent, width, ascent + descent);
            [self fillSelectionAreaInRect:bcgRect];
        } else if (_selectionStartPosition < range.location && _selectionEndPosition >= range.location + range.length) {   //end在在这一行尾部或外外，表示至少第二行是被全部选中的
            CGFloat ascent = 0,descent =0,leading = 0,width = 0;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect bcgRect = CGRectMake(lineOriginPoint.x, lineOriginPoint.y - descent, width, ascent + descent);
            [self fillSelectionAreaInRect:bcgRect];
            
        } else if (_selectionStartPosition < range.location && [self isPositon:_selectionEndPosition inRange:range]) {
            CGFloat ascent = 0,descent =0,leading = 0,offset = 0;
            offset = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect bcgRect = CGRectMake(lineOriginPoint.x, lineOriginPoint.y - descent, offset, ascent + descent);
            [self fillSelectionAreaInRect:bcgRect];
            break;
        }

    }
    
}

- (BOOL)isPositon:(NSInteger)position inRange:(CFRange)range
{
    if (position >= range.location && position <= range.location + range.length) {
        return YES;
    } else {
        return NO;
    }
}

- (void)fillSelectionAreaInRect:(CGRect)rect
{
    UIColor *bcgColor = [UIColor colorWithRed:0.8 green:0.86 blue:0.92 alpha:1];
    CGContextRef contenxt = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contenxt, bcgColor.CGColor);
    CGContextFillRect(contenxt, rect);
}

#pragma mark - 选择文本的光标
- (void)setupCursor
{
    if (_leftSelectionAnchor == nil) {
        _leftSelectionAnchor = [self cursorImgViewWithTop:YES];
    }
    if (_leftSelectionAnchor.superview == nil) {
        [self addSubview:_leftSelectionAnchor];
    }
    
    if (_rightSelectionAnchor == nil) {
        _rightSelectionAnchor = [self cursorImgViewWithTop:NO];
    }
    if (_rightSelectionAnchor.superview == nil) {
        [self addSubview:_rightSelectionAnchor];
    }
}

//更新光标的位置
- (void)setupCursorPosition
{
    if (_selectionStartPosition < 0 || _selectionEndPosition > self.data.content.length) {
        return;
    }
    
    CTFrameRef textFrame = self.data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(self.data.ctFrame);
    if (!lines) {
        return;
    }
    
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    transform = CGAffineTransformScale(transform,1, -1);
    
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    for (int i = 0; i < count; i++) {
        CGPoint lineOriginPoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        
        if ([self isPositon:_selectionStartPosition inRange:range]) {
            CGFloat ascent = 0,descent = 0,leading = 0,offset = 0;
            offset = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//            CGPoint origin = CGPointMake(lineOriginPoint.x + offset - 5, lineOriginPoint.y + ascent + 11);
            CGPoint origin = CGPointMake(lineOriginPoint.x + offset - 1, lineOriginPoint.y + ascent + 11);
            origin = CGPointApplyAffineTransform(origin, transform);
//            _leftSelectionAnchor.origin = origin;
            _leftSelectionAnchor.origin = CGPointMake(origin.x - _leftSelectionAnchor.frame.size.width/2, origin.y);
//            _leftSelectionAnchor.center = CGPointMake(origin.x, _leftSelectionAnchor.center.y);
        }
        if ([self isPositon:_selectionEndPosition inRange:range]) {
            CGFloat ascent = 0,descent = 0,leading = 0,offset = 0;
            offset = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGPoint origin = CGPointMake(lineOriginPoint.x + offset - 1, lineOriginPoint.y + ascent + 11);
            origin = CGPointApplyAffineTransform(origin, transform);
//            _rightSelectionAnchor.origin = origin;
            _rightSelectionAnchor.origin = CGPointMake(origin.x - _rightSelectionAnchor.frame.size.width/2, origin.y);
            break;
        }
        
    }
}

- (UIImage *)cursorWithFontHeight:(CGFloat)fontHeight isTop:(BOOL)isTop
{
    UIColor *color = fqDispRGB(28,107,222);
    CGFloat width = 10;
    CGFloat coursorImgWidth = 20;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(coursorImgWidth, fontHeight), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    if (isTop) {
        CGRect circleRect = CGRectMake((coursorImgWidth - width)/2, 0, width, width); //
        CGContextFillEllipseInRect(context, circleRect);
    } else {
        CGRect circleRect = CGRectMake((coursorImgWidth - width)/2, fontHeight-width, width, width);
        CGContextFillEllipseInRect(context, circleRect);
    }
    
    [color setStroke];
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, coursorImgWidth/2, 0);
    CGContextAddLineToPoint(context, coursorImgWidth/2, fontHeight);
    CGContextStrokePath(context);
    
    UIImage *cursor = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cursor;
}

- (UIImageView *)cursorImgViewWithTop:(BOOL)isTop
{
    CGFloat fontHeight = 40;
    
    UIImage *img = [self cursorWithFontHeight:40 isTop:isTop];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(0, 0, img.size.width, fontHeight);
//    imgView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.3];
    return imgView;
}

@end






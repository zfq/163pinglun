//
//  UIImage+Content.m
//  163pinglun
//
//  Created by _ on 16/1/21.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "UIImage+Content.h"
#import <CoreText/CoreText.h>
#import "MacroDefinition.h"
#import "NSString+Addition.h"

@implementation UIImage (Content)

+ (UIImage *)imageWithContent:(Content *)content size:(CGSize)size
{
    CGFloat marginLeft = 20;
    CGFloat offsetY = 20;   //layer距离img顶部或底部的距离
    CGFloat offsetX = 20;   //content距离layer左边的距离
    CGFloat marginTop = 55; //content距离layer上面的距离
    CGFloat marginBottom = 10; //author距离layer底部的距离
    CGFloat layerWidth = size.width - 2 * offsetX;
    CGFloat preferWidth = layerWidth - 2 * marginLeft;
    
    //1.计算content的rect
    UIFont *contentFont = [UIFont systemFontOfSize:14];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.minimumLineHeight = contentFont.lineHeight;
    paraStyle.maximumLineHeight = contentFont.lineHeight;
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.lineSpacing = 5;
    NSDictionary *attr = @{
                           NSForegroundColorAttributeName:[UIColor blackColor],
                           NSFontAttributeName:contentFont,
                           NSParagraphStyleAttributeName:paraStyle
                           };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:content.content attributes:attr];
    CGSize contentSize = [NSString TextSizeWithAttrStr:attrStr preferWidth:preferWidth];
    CGRect contentRect = CGRectMake(marginLeft+offsetX, marginTop+offsetY, contentSize.width, contentSize.height);

    //2.计算author的rect
    CGFloat padding = 10;
    NSDictionary *authorAttr = @{
                                 NSForegroundColorAttributeName:LABEL_COLOR,
                                 NSFontAttributeName:[UIFont systemFontOfSize:DEFAULT_SUBTITLE_FONT_SIZE],
                                 };
    NSString *user = [NSString SubStrFromStr:content.user pattern:@" 的原贴.*$"];
    NSAttributedString *authorAttrStr = [[NSAttributedString alloc] initWithString:user attributes:authorAttr];

    CGFloat urlOriginX = marginLeft+offsetX/2;
//    CGRect userRect = [user boundingRectWithSize:CGSizeMake(preferWidth, HUGE_VALF) options:NSStringDrawingTruncatesLastVisibleLine attributes:authorAttr context:nil];
    CGSize testSize = [NSString SinglLineTextSizeWithAttrStr:&authorAttrStr preferWidth:preferWidth];
    CGRect userRect = CGRectMake(0, 0, testSize.width, testSize.height);
    userRect.origin.x = size.width - urlOriginX - userRect.size.width;
    userRect.origin.y = CGRectGetMaxY(contentRect) + padding;

    //2.根据content的rect和author的rect来设置layer的size
    CGSize layerSize = CGSizeMake(layerWidth, CGRectGetMaxY(userRect)- offsetY + marginBottom);
    CGSize imgSize = CGSizeMake(size.width, layerSize.height + 2 * offsetY);
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CAShapeLayer *bcgLayer = [self customLayerWithContent:nil size:layerSize];
    
    //3.画背景
    CGContextTranslateCTM(context, offsetX, offsetY);
    [bcgLayer renderInContext:context];
    CGContextTranslateCTM(context, -offsetX, -offsetY);
    
    //4.画内容
    [attrStr drawInRect:contentRect];
    //5.画作者
    [authorAttrStr drawInRect:userRect];
    
    //6.画logo 163评论
    UIFont *logoFont = [UIFont systemFontOfSize:14];
    NSDictionary *logoAttr = @{
                               NSForegroundColorAttributeName:LABEL_COLOR,
                               NSFontAttributeName:logoFont,
                               };
    NSAttributedString *logoAttrStr = [[NSAttributedString alloc] initWithString:LOGO attributes:logoAttr];
    CGSize logoSize = [NSString TextSizeWithAttrStr:logoAttrStr preferWidth:layerSize.width];
    CGRect logoRect = CGRectMake(marginLeft+offsetX/2, offsetY * 1.5, logoSize.width, logoSize.height);//
    
    //7.画网址 www.163pinglun.com
    UIFont *urlFont = [UIFont fontWithName:@"Noteworthy-Light" size:10];
    NSDictionary *urlAttr = @{
                               NSForegroundColorAttributeName:LABEL_COLOR,
                               NSFontAttributeName:urlFont,
                               NSKernAttributeName:@2,
                               };
    NSAttributedString *urlAttrStr = [[NSAttributedString alloc] initWithString:HOSTURL attributes:urlAttr];
    CGSize urlSize = [NSString TextSizeWithAttrStr:urlAttrStr preferWidth:layerSize.width];
    CGRect urlRect = CGRectMake(urlOriginX, CGRectGetMaxY(logoRect), urlSize.width, urlSize.height);
    [urlAttrStr drawInRect:urlRect];
    
    logoRect.origin.x += (urlSize.width - logoSize.width)/2;
    [logoAttrStr drawInRect:logoRect];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (CAShapeLayer *)customLayerWithContent:(NSString *)content size:(CGSize)size
{
    NSInteger lp = 6;
    NSInteger mp = 3;
    NSInteger circleCount = 18;
    CGFloat x = 0; //marginLeft
    CGFloat y = 0; //marginTop
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setFillColor:RGBCOLOR(255, 252, 222, 1).CGColor];
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, x, y);
    CGPathAddLineToPoint(path, NULL, x, height - y);
    CGPathAddLineToPoint(path, NULL, width - x, height - y);
    CGPathAddLineToPoint(path, NULL, width - x, y);
    
    CGFloat radius = (width -2 * x - 2 * lp - (circleCount - 1) * mp)/(circleCount * 2);
    CGPathAddLineToPoint(path, NULL, width - lp - x, y);
    
    CGFloat centerX = width -x - lp - radius;
    for (NSInteger i = 1; i <= circleCount; i ++) {
        
        if (i == circleCount) {
            //只画半圆
            CGPathAddArc(path, NULL, centerX, y, radius, 0, -M_PI, NO);
        } else {
            //画半圆和mp
            CGPathAddArc(path, NULL, centerX, y, radius, 0, -M_PI, NO);
            CGPathAddLineToPoint(path, NULL, centerX - mp, y);
        }
        centerX -= (2 * radius + mp);
    }
    
    CGPathCloseSubpath(path);
    
    layer.path = path;
    CGPathRelease(path);
    
    //添加分割线层
    CGFloat margintToCircle = 38;
    CALayer *separatorLayer = [[CALayer alloc] init];
    separatorLayer.bounds = CGRectMake(0, 0, width - 2 * x, 1);
    separatorLayer.position = CGPointMake(width/2, margintToCircle + radius);
    separatorLayer.backgroundColor = RGBCOLOR(219, 199, 137, 0.7).CGColor;
    [layer addSublayer:separatorLayer];
    
    return layer;
}

@end

//
//  ZFQSliderNumLayer.m
//  字体大小控件
//
//  Created by _ on 16/7/26.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQSliderNumLayer.h"
#import <UIKit/UIKit.h>

@implementation ZFQSliderNumLayer

- (void)drawInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    
    CGFloat averageValue = (self.bounds.size.width)/(_numberStrs.count);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    
    //更新下方的数据位置
    CGFloat strLen = 20;
    NSDictionary *attr = @{
                            NSForegroundColorAttributeName:[UIColor blackColor],
                            NSFontAttributeName:[UIFont systemFontOfSize:14]
                            };
     CGFloat numY = 0;
     CGFloat numX = 0;
     for (NSInteger i = 0; i < _numberStrs.count; i++) {
         NSString *num = _numberStrs[i];
         if (i == 0) {
             numX = 0;
         } else {
             numX = i * averageValue + strLen;
         }
         
         if (num.length > 0) {
             [num drawAtPoint:CGPointMake(numX, numY) withAttributes:attr];
         }
     }
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}


@end

//
//  UIFont+Custom.m
//  GuangShengXing
//
//  自定义字体
//
//  Created by 163pinglun on 15/7/29.
//  Copyright (c) 2015年 163pinglun. All rights reserved.
//

#import "UIFont+Custom.h"
#import <CoreText/CoreText.h>

//-------颜色----------
//重要
#define Important_Color_1 RGB(0x00,0x82,0xAA)
#define Important_Color_2 RGB(0xFE,0x8B,0x00)
#define Important_Color_3 RGB(0x53,0x53,0x53)
//一般
#define Common_Color_1  RGB(0x86,0x86,0x86)
#define Common_Color_2  RGB(0xAC,0xAC,0xAC)
#define Common_Color_3  RGB(0xCC,0xCC,0xCC)
//较弱
#define Low_Color_1  RGB(0xD2,0xD2,0xD2)
#define Low_Color_2  RGB(0xE1,0xE1,0xE1)

//-------字体----------
//重要
#define Important_Font_Size_Big 18
#define Important_Font_Size_Small 15
//一般
#define Common_Font_Size_Big 14
#define Common_Font_Size_Small 13
//较弱
#define Low_Font_Size_Big 12
#define Low_Font_Size_Small 11

@implementation UIFont (Custom)

///汉字SourceHanSansCN-Light
+ (UIFont *)customYouYuanFontWithSize:(CGFloat)size
{
    return [self customFontWithName:@"YouYuan" Size:size fontType:@"ttf"];
}

+ (UIFont *)customCNLightFontWithSize:(CGFloat)size
{
    return [self customFontWithName:@"SourceHanSansCN-Light" Size:size fontType:@"otf"];
}

///汉字SourceHanSansCN-Normal
+ (UIFont *)customCNNormalFontWithSize:(CGFloat)size
{
    return [self customFontWithName:@"SourceHanSansCN-Normal" Size:size fontType:@"otf"];
}

///英文字体Lato-Light
+ (UIFont *)customENLightFontWithSize:(CGFloat)size
{
    return [self customFontWithName:@"Lato-Light" Size:size fontType:@"ttf"];
}

///英文字体Lato-Regular
+ (UIFont *)customENRegularFontWithSize:(CGFloat)size
{
    return [self customFontWithName:@"Lato-Regular" Size:size fontType:@"ttf"];
}

+ (UIFont *)customFontWithName:(NSString *)fontName Size:(CGFloat)size fontType:(NSString *)fontType
{
    //1.判断字体是否注册过,注意名字要写对，写不对就会导致字体注册失败,用下面注释部分的方法来获取正确的字体名称
    /*
     NSString *path = [[NSBundle mainBundle] pathForResource:fontName ofType:@"otf"];
     NSURL *fontUrl = [NSURL fileURLWithPath:path];
     CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
     CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
     CGDataProviderRelease(fontDataProvider);
     CTFontManagerRegisterGraphicsFont(fontRef, NULL);
     fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
     CGFontRelease(fontRef);
     */
    if (![UIFont fontWithName:fontName size:size]) {
        //没注册过,去注册字体
        NSString *path = [[NSBundle mainBundle] pathForResource:fontName ofType:fontType];
        NSURL *fontUrl = [NSURL fileURLWithPath:path];
        CFErrorRef error = NULL;
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontUrl, kCTFontManagerScopeProcess, &error);
        if (error) {
            NSString *errorInfo = CFBridgingRelease(CFErrorCopyDescription(error));
            NSLog(@"注册字体失败:%@",errorInfo);
        }
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
}

@end

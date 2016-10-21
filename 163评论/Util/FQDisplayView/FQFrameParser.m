//
//  FQFrameParaser.m
//  MyCoreTextDemo
//
//  用于生成最后绘制的CTFrameRef实例
//
//  Created by 163pinglun on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import "FQFrameParser.h"
#import <CoreText/CoreText.h>
#import "FQCoreTextImageData.h"
#import "FQCoreTextLinkData.h"

@implementation FQFrameParser

+ (NSMutableDictionary *)attributesWithConfig:(FQFrameParserConfig *)config
{
    const CFIndex kNumberOfSetting = 5;
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = config.lineSpace;
    CTTextAlignment alignment = config.textAlignment;
    CTLineBreakMode breakMode = config.lineBreakMode;
    
    CTParagraphStyleSetting theSettings[kNumberOfSetting] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpacing},
        {kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&alignment},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&breakMode}
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSetting);
    
    UIColor *textColor = config.textColor;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
//    dict[NSForegroundColorAttributeName] = textColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    
    /*
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = config.lineSpace;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[UIFont fontWithName:@"ArialMT" size:config.fontSize] forKey:NSFontAttributeName];
    [dict setObject:config.textColor forKey:NSForegroundColorAttributeName];
    [dict setObject:paraStyle forKey:NSParagraphStyleAttributeName];
    */
    return dict;
}

+ (FQCoreTextData *)parseAttributeContent:(NSAttributedString *)attrStr config:(FQFrameParserConfig *)config
{
    //1.创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    
    //2.获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(config.maxWidth, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    
    //3.将生成好的CTFrameRef 实例和计算好的绘制高度保存到FQCoreTextData实例中，最后返回CoreTextData
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:coreTextSize.height];
    FQCoreTextData *data = [[FQCoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = coreTextSize.height;
    data.width = coreTextSize.width;
    data.content = attrStr;
    //4.release
    CFRelease(frame);
    CFRelease(framesetter);
    
    return data;
}

+ (FQCoreTextData *)parseContent:(NSString *)content config:(FQFrameParserConfig *)config
{
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    return [self parseAttributeContent:contentString config:config];
}

+ (FQCoreTextData *)parseTemplateFile:(NSString *)path config:(FQFrameParserConfig *)config
{
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    NSMutableArray *linkArray = [[NSMutableArray alloc] init];
    FQCoreTextData *data = [self parseTemplateFile:path config:config imageArray:imgArray linkArray:linkArray];
    data.imageArray = imgArray;
    data.linkArray = linkArray;
    return data;
}

#pragma mark - 从文件解析
+ (FQCoreTextData *)parseTemplateFile:(NSString *)path
                               config:(FQFrameParserConfig *)config
                           imageArray:(NSMutableArray *)imageArray
                            linkArray:(NSMutableArray *)linkArray
{
    NSAttributedString *content = [self loadTempleteFile:path config:config imageArray:imageArray linkArray:linkArray];
    return [self parseAttributeContent:content config:config];
}

+ (NSAttributedString *)loadTempleteFile:(NSString *)path config:(FQFrameParserConfig *)config imageArray:(NSMutableArray *)imgArray linkArray:(NSMutableArray *)linkArray
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *as = [self parseAttributedContentFromDicationry:dict config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"img"]) {
                    //创建coreTextImageData
                    FQCoreTextImageData *imgData = [[FQCoreTextImageData alloc] init];
                    imgData.name = dict[@"name"];
                    imgData.position = result.length;
                    [imgArray addObject:imgData];
                    //创建空白占位符,并设置它的CTRunDelegate信息
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"link"]) {
                    NSUInteger startPos = result.length;
                    NSAttributedString *as = [self parseAttributedContentFromDicationry:dict config:config];
                    
                    [result appendAttributedString:as];
                    //创建CoreTextLinkData
                    NSUInteger length = result.length - startPos;
                    FQCoreTextLinkData *linkData = [[FQCoreTextLinkData alloc] init];
                    linkData.title = dict[@"content"];
                    linkData.url = dict[@"url"];
                    linkData.range = NSMakeRange(startPos, length);
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    
    return result;
}

#pragma mark callback
static CGFloat ascentCallback(void* ref)
{
    NSNumber *heightNum = [(__bridge NSDictionary *)ref objectForKey:@"height"];
    return heightNum.floatValue;
}

static CGFloat descentCallback(void* ref)
{
    return 0;
}

static CGFloat widthCallback(void* ref)
{
    NSNumber *widthNum = [(__bridge NSDictionary *)ref objectForKey:@"width"];
    return widthNum.floatValue;
}

+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict config:(FQFrameParserConfig *)config
{
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks)); //将callbacks中前sizeof(CTRunDelegateCallbacks)个字节用0代替,是对较大的结构体或数组进行清零操作的一种最快方法
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef ctRunDelegate = CTRunDelegateCreate(&callbacks, (__bridge void* )dict);
    
    //使用0xFFCC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, ctRunDelegate);
    
    CFRelease(ctRunDelegate);
    
    return space;
}

+ (NSAttributedString *)parseAttributedContentFromDicationry:(NSDictionary *)dict config:(FQFrameParserConfig *)config
{
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    //set color
    UIColor *color = [self colorFromTemplete:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    //set font size
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

+ (UIColor *)colorFromTemplete:(NSString *)name
{
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else {
        return nil;
    }
}

#pragma mark - 解析图片

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                        config:(FQFrameParserConfig *)config
                                        height:(CGFloat)height
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.maxWidth, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

@end





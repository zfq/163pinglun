//
//  FQFrameParaser.h
//  MyCoreTextDemo
//
//  用于生成最后绘制的CTFrameRef实例
//
//  Created by 163pinglun on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FQCoreTextData.h"
#import "FQFrameParserConfig.h"

@interface FQFrameParser : NSObject

+ (NSMutableDictionary *)attributesWithConfig:(FQFrameParserConfig *)config;
+ (FQCoreTextData *)parseContent:(NSString *)content config:(FQFrameParserConfig *)config;
+ (FQCoreTextData *)parseAttributeContent:(NSAttributedString *)content config:(FQFrameParserConfig *)config;

+ (FQCoreTextData *)parseTemplateFile:(NSString *)path config:(FQFrameParserConfig *)config;
+ (FQCoreTextData *)parseTemplateFile:(NSString *)path
                               config:(FQFrameParserConfig *)config
                           imageArray:(NSMutableArray *)imageArray
                            linkArray:(NSMutableArray *)linkArray;
@end

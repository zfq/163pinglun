//
//  UIDeviceHardware.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "GeneralService.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "MBProgressHUD.h"
#import "MacroDefinition.h"

#define NETWORK_STATUS @"networkStatus"

@implementation GeneralService

+ (NSString *) platform{
    
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return platform;
    
}

+ (NSString *) platformString{
    
    NSString *platform = [[self class] platform];
    
    NSString *model = [UIDevice currentDevice].model;
    
    if ([model isEqualToString:@"iphone"]) {
        
        if ([platform isEqualToString:@"iPhone1,1"])        return @"iPhone 1G";
        else if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone 3G";
        else if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone 3GS";
        else if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone 4";
        else if ([platform isEqualToString:@"iPhone3,3"])   return @"Verizon iPhone 4";
        else if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
        else if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
        else if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM)";
        else if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5 (GSM+CDMA)";
        else if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c (GSM)";
        else if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c (GSM+CDMA)";
        else if ([platform isEqualToString:@"iPhone6,1"])   return @"iPhone 5s (GSM)";
        else if ([platform isEqualToString:@"iPhone6,2"])   return @"iPhone 5s (GSM+CDMA)";
        
    } else if ([model isEqualToString:@"ipod Touch"]) {
        
        if ([platform isEqualToString:@"iPod1,1"])          return @"iPod Touch 1G";
        else if ([platform isEqualToString:@"iPod2,1"])     return @"iPod Touch 2G";
        else if ([platform isEqualToString:@"iPod3,1"])     return @"iPod Touch 3G";
        else if ([platform isEqualToString:@"iPod4,1"])     return @"iPod Touch 4";
        else if ([platform isEqualToString:@"iPod5,1"])     return @"ipod Touch 5";
        
    } else if ([model isEqualToString:@"ipad"]) {
        
        if ([platform isEqualToString:@"iPad1,1"])           return @"iPad";
        else if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
        else if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
        else if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
        else if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
        else if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
        else if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
        else if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
        else if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
        else if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
        else if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
        else if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (CDMA)";
        else if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
        else if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
        else if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
        else if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
        else if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
        
    }
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])
        return @"Simulator";
    
    return platform;
    
}

+ (void)showHUDWithTitle:(NSString *)title andDetail:(NSString *)detail image:(NSString *)imageName
{
    UIWindow *topWindow = (UIWindow *)[UIApplication sharedApplication].windows.lastObject;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:topWindow];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.labelText = title;
    HUD.detailsLabelText = detail;
    HUD.userInteractionEnabled = NO;
    [topWindow addSubview:HUD];
    [HUD show:YES];
	[HUD hide:YES afterDelay:3];
}

+ (void)showHUDWithTitle:(NSString *)title andDetail:(NSString *)detail image:(NSString *)imageName inView:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.labelText = title;
    HUD.detailsLabelText = detail;
    HUD.userInteractionEnabled = NO;
    [view addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:3];
}
#pragma mark - 设置/读取网络状态
+ (void)setNetworkReachability:(BOOL)isReachable
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isReachable] forKey:NETWORK_STATUS];
}

+ (BOOL)isReachable
{
    NSNumber *isReachable = [[NSUserDefaults standardUserDefaults] objectForKey:NETWORK_STATUS];
    return isReachable.boolValue;
}

#pragma mark - 字体设置
+ (CGFloat)userFontSizeWithIndex:(NSInteger)index
{
    NSArray *array = [[self fontSizeDic] objectForKey:[@(index) stringValue]];
    return ((NSNumber*)array.firstObject).floatValue;
}

+ (CGFloat)contentFontSizeWithIndex:(NSInteger)index
{
    NSArray *array = [[self fontSizeDic] objectForKey:[@(index) stringValue]];
    return ((NSNumber*)[array objectAtIndex:1]).floatValue;
}

+ (NSDictionary *)fontSizeDic
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kFontSizeStyle];
    if (dic==nil || dic.count==0) {
        dic = @{
                @"0":@[@13,@20,@"巨大"],
                @"1":@[@13,@18,@"很大"],
                @"2":@[@12,@17,@"大"],
                @"3":@[@11,@15,@"中"],
                @"4":@[@11,@13,@"小"]
                };
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kFontSizeStyle];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return dic;
}

+ (CGFloat)currContentFontSize
{
    NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrContentFontSize];
    if (fontSize==nil || fontSize.floatValue==0) {
        fontSize = [NSNumber numberWithFloat:[self defaultContentFontSize]];
        [[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:kCurrContentFontSize];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return fontSize.floatValue;
}
+ (void)saveCurrContentFontSize:(CGFloat)fontSize
{
    [[NSUserDefaults standardUserDefaults] setObject:@(fontSize) forKey:kCurrContentFontSize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (CGFloat)currSubtitleFontSize
{
    NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrSubtitleFontSize];
    if (fontSize==nil || fontSize.floatValue==0) {
        fontSize = [NSNumber numberWithFloat:[self defaultSubtitleFontSize]];
        [[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:kCurrSubtitleFontSize];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return fontSize.floatValue;
}
+ (void)saveCurrSubtitleFontSize:(CGFloat)fontSize
{
    [[NSUserDefaults standardUserDefaults] setObject:@(fontSize) forKey:kCurrSubtitleFontSize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (CGFloat)defaultContentFontSize
{
    NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:kDefContentFontSize];
    if (fontSize==nil || fontSize.floatValue==0) {
        fontSize = @(DEFAULT_CONTENT_FONT_SIZE);
        [[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:kDefContentFontSize];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return fontSize.floatValue;
}

+ (CGFloat)defaultSubtitleFontSize
{
    NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:kDefSubtitleFontSize];
    if (fontSize==nil || fontSize.floatValue==0) {
        fontSize = @(DEFAULT_SUBTITLE_FONT_SIZE);
        [[NSUserDefaults standardUserDefaults] setObject:fontSize forKey:kDefSubtitleFontSize];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return fontSize.floatValue;
}

+(NSString *)fontSizeName
{
    NSArray *array = [[self fontSizeDic] objectForKey:[@([self fontIndex]) stringValue]];
    return [array lastObject];
}

+ (NSInteger)fontIndex
{
    NSNumber *fontIndex = [[NSUserDefaults standardUserDefaults] objectForKey:kFontIndexStyle];
    if (fontIndex==nil) {
        fontIndex = @3;
        [[NSUserDefaults standardUserDefaults] setObject:fontIndex forKey:kFontIndexStyle];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return fontIndex.integerValue;
}

@end



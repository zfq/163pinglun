//
//  UIDeviceHardware.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-9.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "MBProgressHUD.h"

@implementation UIDeviceHardware

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

+ (NSString *)urlErrorDesciptionForCode:(NSInteger)code
{
    switch (code) {
        case -1009: return @"没有连接到互联网";
        case -1004: return @"无法连接到服务器";
        case -1003: return @"找不到服务器";
        case -1002: return @"无效的链接";
        case -1001: return @"连接超时";
            
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"错误码:%d",code];
}

+ (void)showHUDWithTitle:(NSString *)title andDetail:(NSString *)detail image:(NSString *)imageName
{
    UIWindow *topWindow = (UIWindow *)[UIApplication sharedApplication].windows.lastObject;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:topWindow];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.labelText = title;
    HUD.detailsLabelText = detail;
    HUD.userInteractionEnabled = YES;
    [topWindow addSubview:HUD];
    [HUD show:YES];
	[HUD hide:YES afterDelay:3];
}
@end



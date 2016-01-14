//
//  FQCoreTextImageData.h
//  MyCoreTextDemo
//
//  Created by wecash on 15/8/24.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FQCoreTextImageData : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *imgUrl;
@property (nonatomic) NSInteger position; //图片所在文本中的起点位置

//此坐标系为core text坐标系，不是UIKit坐标系
@property (nonatomic) CGRect imagePostion;

@end

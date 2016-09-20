//
//  DBSerializable.h
//  163pinglun
//
//  Created by _ on 16/9/20.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@protocol DBSerializable <NSObject>

@optional

/**
 *  根据FMResultSet来创建一个实例
 *
 *  @return 实例
 */
+ (id)instanceFromFMResultSet:(FMResultSet *)set;

@end

//
//  ZFQQueuePool.h
//  163评论
//
//  Created by _ on 16/1/12.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFQQueuePool : NSObject

extern dispatch_queue_t ZFQGetQueue(void);

@end

//
//  ZFQQueuePool.m
//  163评论
//
//  Created by _ on 16/1/12.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQQueuePool.h"
#import <libkern/OSAtomic.h>

const NSInteger ZFQ_MAX_QUEUE_COUNT = 10;
const char *LABEL_PRIORITY_DEFAULT = "com.zfqqueue.default";

@interface ZFQQueuePool()

@end
@implementation ZFQQueuePool

static dispatch_queue_t ZFQQueueCreate(const char *name)
{
    //1.创建一个串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
    
    //2.将上面的串行队列的优先级设置为Default
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_set_target_queue(serialQueue, globalQueue);
    
    return serialQueue;
}

static NSArray* ZFQDispatchQueuePool(void)
{
    static NSMutableArray *queues;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        queues = [[NSMutableArray alloc] initWithCapacity:ZFQ_MAX_QUEUE_COUNT];
        
        for (int i = 0; i < ZFQ_MAX_QUEUE_COUNT; i++) {
            dispatch_queue_t queue = ZFQQueueCreate(LABEL_PRIORITY_DEFAULT);
            [queues addObject:queue];
        }
    });
    return queues;
}

@end

dispatch_queue_t ZFQGetQueue(void)
{
    static int32_t currQueueIndex = 0;
    
    int32_t tempIndex = currQueueIndex;
    
    //1.index++ 使用OSAtomicIncrement32递增保证线程安全
    currQueueIndex = OSAtomicIncrement32(&currQueueIndex);
    currQueueIndex = currQueueIndex % ZFQ_MAX_QUEUE_COUNT;
    
    //2.从数组中取出来一个queue
    NSArray *queues = ZFQDispatchQueuePool();
    
    return queues[tempIndex];
}


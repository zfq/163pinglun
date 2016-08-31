//
//  ZFQURLConnectionOperation.m
//  163pinglun
//
//  Created by _ on 16/8/28.
//  Copyright © 2016年 zhaofuqiang. All rights reserved.
//

#import "ZFQURLConnectionOperation.h"

typedef NS_ENUM(NSInteger, ZFQURLOperationState){
    ZFQURLOperationExecuting = 1,
    ZFQURLOperationFinished,
    ZFQURLOperationCancelled
};

@interface ZFQURLConnectionOperation() <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    BOOL _executing;
    BOOL _finished;
}
@property (nonatomic,strong) NSURLConnection *urlConnection;
@property (nonatomic,strong) NSURLRequest *urlRequest;
@property (nonatomic,assign) ZFQURLOperationState operationState;
@property (nonatomic,strong) NSRecursiveLock *lock;
@property (nonatomic,strong) NSMutableData *receivedData;

@end

@implementation ZFQURLConnectionOperation

- (instancetype)initWithRequest:(NSURLRequest *)request
                     successBlk:(ZFQURLOperationSuccessBlk)successBlk
                     failureBlk:(ZFQURLOperationFailureBlk)failureBlk
{
    self = [super init];
    if (self) {
        //初始化状态
        _executing = NO;
        _finished = NO;
        _lock = [[NSRecursiveLock alloc] init];
        _receivedData = [[NSMutableData alloc] init];
        
        _urlRequest = [request copy];
        _successBlk = [successBlk copy];
        _failureBlk = [failureBlk copy];
    }
    return self;
}

- (NSString *)keyFromOperationState:(ZFQURLOperationState)operationState
{
    switch (operationState) {
        case ZFQURLOperationExecuting: return @"isExecuting";
        case ZFQURLOperationFinished: return @"isFinished";
        case ZFQURLOperationCancelled: return @"isCancelled";
        default: return nil;
    }
}

- (void)setOperationState:(ZFQURLOperationState)operationState
{
    [self.lock lock];
        
    _operationState = operationState;
    
    if (operationState == ZFQURLOperationFinished) {    //完成
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _finished = YES;
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
    } else if (operationState == ZFQURLOperationCancelled) {    //取消
        //KVO
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _finished = YES;
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
    } else if (operationState == ZFQURLOperationExecuting) {    //正在执行
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
        
    [self.lock unlock];
}

#pragma mark - Private
- (void)networkThreadEntryPoint:(id)obj
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"ZFQNetworking"];
        
        /*
         当在其他线程上面执行selector时，目标线程须有一个活动的run loop。
         这里若不调用[runLoop run],这operationStart方法永远不会执行,因为新建的线程默认没有runLoop
         */
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];
    }
}

- (void)operationStart
{
    //如果已经取消了，就直接返回
    if (self.isCancelled) {
        self.operationState = ZFQURLOperationCancelled;
        return;
    }
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:NO];
    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.urlConnection start];
    
    //标记状态为正在执行
    self.operationState = ZFQURLOperationExecuting;
}

- (NSThread *)networkThread
{
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadEntryPoint:) object:nil];
        [thread start];
    });
    
    return thread;
}

- (void)cancelZFQConnection
{
    [self.urlConnection cancel];
    NSDictionary *userInfo = @{@"localizedDescription":@"请求已取消"};
    NSError *error = [[NSError alloc] initWithDomain:@"ZFQNetworking" code:9999 userInfo:userInfo];
    [self connection:self.urlConnection didFailWithError:error];
}

#pragma mark - 子类至少需要重载下面的4个方法
- (void)start
{
    //如果operation没有被取消,就开始执行任务
    NSArray<NSString *> *modes = @[NSRunLoopCommonModes];
    [self performSelector:@selector(operationStart) onThread:[self networkThread] withObject:nil waitUntilDone:NO modes:modes];
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

#pragma mark - 
- (void)cancel
{
    [super cancel];
    
    //取消请求
    self.operationState = ZFQURLOperationCancelled;
    [self cancelZFQConnection];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _receivedData.length = 0;
    self.operationState = ZFQURLOperationFinished;
    if (self.failureBlk) {
        self.failureBlk(error);
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.operationState = ZFQURLOperationFinished;
    if (self.successBlk) {
        self.successBlk(self.receivedData);
    }
}

@end

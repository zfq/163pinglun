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
        //KVO，注意取消时一定要标记finished，不然所有依赖它的其他operation就永远不会执行
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _finished = YES;
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
    } else if (operationState == ZFQURLOperationExecuting) {    //正在执行
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _finished = NO;
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
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
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
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

/**
 operationStart方法是在ZFQNetworking线程中执行的，所以[NSRunLoop currentRunLoop]就是指ZFQNetworking中的runLoop
 
 */
- (void)operationStart
{
    [self.lock lock];
    
    //urlConnection的回调加入到start所在线程的runloop中
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:NO];
    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.urlConnection start];
    
    //标记状态为正在执行
    self.operationState = ZFQURLOperationExecuting;
    
    [self.lock unlock];
}

- (void)cancelZFQConnection
{
    [self.lock lock];
    
    if (self.urlConnection) {
        [self.urlConnection cancel];
    }
    
    //回调错误函数
    NSDictionary *userInfo = @{@"localizedDescription":@"请求已取消"};
    NSError *error = [[NSError alloc] initWithDomain:@"ZFQNetworking" code:NSURLErrorCancelled userInfo:userInfo];
    [self connection:self.urlConnection didFailWithError:error];
    
    [self.lock unlock];
}

#pragma mark - 子类至少需要重载下面的4个方法
- (void)start
{
    //如果已经取消了，就直接返回
    if (self.isCancelled) {
        self.operationState = ZFQURLOperationCancelled;
    } else {
        //如果operation没有被取消,就开始执行任务
        /*
         在子线程调用异步接口（即调用urlConnection的start方法）,那么子线程（即networkThread线程）需要去接收异步回调事件，
         相当于networkThread线程就是用来处理回调的
         */
        NSArray<NSString *> *modes = @[NSRunLoopCommonModes];
        [self performSelector:@selector(operationStart) onThread:[self networkThread] withObject:nil waitUntilDone:NO modes:modes];
    }
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
    
    if (self.isFinished == NO && self.executing == NO) {
        //取消请求
        self.operationState = ZFQURLOperationCancelled;
        
        //放在子线程线程执行
        [self performSelector:@selector(cancelZFQConnection) onThread:[self networkThread] withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.lock lock];
    
    _receivedData.length = 0;
    self.operationState = ZFQURLOperationFinished;
    
    //在主线程回调失败
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.failureBlk) {
            self.failureBlk(self,error);
        }
    });
    
    [self.lock unlock];
}

/**
 如果operation所在的queue为异步的queue,则下面的urlConnection的代理回调在ZFQNetworking线程执行
 */
#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.operationState = ZFQURLOperationFinished;
    
    //根据response返回的状态码来判断是成功还是失败
    NSError *error = nil;
    BOOL validate = [self validateHTTPResponse:self.response data:self.receivedData error:&error];
    
    if (validate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.successBlk) {
                self.successBlk(self,self.receivedData);
            }
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.failureBlk) {
                self.failureBlk(self,error);
            }
        });
    }
}

- (BOOL)validateHTTPResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    BOOL validate = NO;
    NSError *tempError = nil;
    static NSString *zfqErrorDomain = @"com.zfqNetworking.zfq";
    static NSString *zfqErrorDataKey = @"zfqErrorDataKey";
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.response;
    
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if (httpResponse.statusCode == 200) {
            validate = YES;
        } else {
            NSString *desc = [NSString stringWithFormat:@"Request failed (%zi):%@",httpResponse.statusCode,httpResponse.MIMEType];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey:desc,
                                       zfqErrorDataKey:data.description
                                       };
            tempError = [[NSError alloc] initWithDomain:zfqErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
            *error = tempError;
            validate = NO;
        }
    } else {
        NSString *desc = [NSString stringWithFormat:@"unacceptable content-type:%@",httpResponse.MIMEType];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey:desc,
                                   zfqErrorDataKey:data.description
                                   };
        tempError = [[NSError alloc] initWithDomain:zfqErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
        *error = tempError;
        validate = NO;
    }
    
    if (error && tempError) {
        *error = tempError;
    }
    return validate;
}

+ (NSArray<ZFQURLConnectionOperation *> *)batchOfOperations:(NSArray<NSOperation *> *)operations
              progressBlk:(void (^)(NSInteger numberOfFinishedOperations,NSInteger numberOfOperations))progressBlk
            completionBlk:(void (^)(void))completionBlk
{
    dispatch_group_t group = dispatch_group_create();
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completionBlk) {
                completionBlk();
            }
        });
    }];
    
    for (NSOperation *operation in operations) {
        operation.completionBlock = ^(){
            dispatch_group_leave(group);
            
            NSUInteger numberOfFinishedOperations = [[operations indexesOfObjectsPassingTest:^BOOL(id op, NSUInteger __unused idx,  BOOL __unused *stop) {
                return [op isFinished];
            }] count];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlk) {
                    progressBlk(numberOfFinishedOperations, [operations count]);
                }
            });
        };
        
        dispatch_group_enter(group);
        [blockOperation addDependency:operation];
    }
    
    NSArray *finalOperations = [operations arrayByAddingObject:blockOperation];
    
    return finalOperations;
}

@end

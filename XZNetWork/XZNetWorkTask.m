//
//  XZNetWorkTask.m
//  XNetWork
//
//  Created by ZF xie on 2021/4/28.
//

#import "XZNetWorkTask.h"
#import <AFNetworking/AFNetworking.h>
typedef void (^XFailure)(XZNetWorkTask *_Nullable task,NSError * _Nullable error);
typedef void (^XSuccess)(XZNetWorkTask *_Nullable task,id _Nullable responseObject);
typedef void (^XUploadProgress)(NSProgress *uploadProgress);

@interface XZNetWorkTask()
@property (nonatomic, copy) XSuccess success;
@property (nonatomic, copy) XFailure failure;
@property (nonatomic, copy) XUploadProgress uploadProgress;

@property (nonatomic, assign) BOOL cancelRequest;
//@property (nonatomic, assign) BOOL isCanTryRequest;   ///<是否支持才是发起请求  只有当调用start后为YES

///<所有依赖类
@property (nonatomic, strong, readwrite) NSMutableArray <XZNetWorkTask *>*dependencyTasks;

///<请求状态
@property (nonatomic, assign, readwrite) XNetWorkRequestState requestState;

///<配置
@property (nonatomic, strong, readwrite) XZNetWorkTaskConfig *config;

@property (nonatomic, strong,readwrite) NSURLSessionTask *sessionDataTask;///<<#des#>

@end

@implementation XZNetWorkTask
- (AFHTTPSessionManager *)manager {
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        requestSerializer.timeoutInterval = 10.f;
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", nil];
        
    });
    return manager;
}


#pragma mark - init

- (XZNetWorkTask *)netWorkTaskWithProgress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(XZNetWorkTask * _Nullable, id _Nullable))success failure:(void (^)(XZNetWorkTask * _Nullable, NSError * _Nullable))failure {
    self.success = success;
    self.failure = failure;
    self.uploadProgress = uploadProgress;
    if (!self.config.delayStartRequest) {
        [self start];
    }
    return self;

}

+ (XZNetWorkTask *)netWorkTaskWithConfig:(XZNetWorkTaskConfig *)confing
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                                failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure {
    XZNetWorkTask *task = [XZNetWorkTask netWorkTask:confing];
    return [task netWorkTaskWithProgress:uploadProgress success:success failure:failure];
}

+ (XZNetWorkTask *)netWorkTask:(XZNetWorkTaskConfig *)confing {
    XZNetWorkTask *task = [[XZNetWorkTask alloc] init];
    task.config = confing;
    return task;
}

@synthesize requestState = _requestState;
- (void)setRequestState:(XNetWorkRequestState)requestState {
//    [self willChangeValueForKey:@"requestState"];
    _requestState = requestState;
//    [self didChangeValueForKey:@"requestState"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    XZNetWorkTask *task = object;

    switch (task.requestState) {
        case XNetWorkRequestStateCancel:
        case XNetWorkRequestStateFailure:
        case XNetWorkRequestStateSuccess:
            [self removeDependency:object];
//            if (self.isCanTryRequest) {
                [self start];
//            }
            break;
            
        default:
            break;
    }
}


- (void)start {
    self.cancelRequest = NO;
//    self.isCanTryRequest = YES;
    if (![self x_isSupportStart]) {
        return;
    }

    self.requestState = XNetWorkRequestStateRequesting;
    self.sessionDataTask = [self.manager POST:self.config.requestUrl
                                   parameters:self.config.requestParam
                                      headers:self.config.headers
                                     progress:self.uploadProgress
                                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.requestState = XNetWorkRequestStateSuccess;
        self.sessionDataTask = task;
        if (self.success) {
            self.success(self,responseObject);
        }
        if (self.xDelegate && [self.xDelegate respondsToSelector:@selector(requestFinished:)]) {
            [self.xDelegate requestFinished:self];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.requestState = XNetWorkRequestStateFailure;
        self.sessionDataTask = task;
        if (self.failure) {
            self.failure(self, error);
        }
        
        if (self.xDelegate && [self.xDelegate respondsToSelector:@selector(requestFailed:)]) {
            [self.xDelegate requestFailed:self];
        }
    }];
    
}

- (void)stop {
    self.cancelRequest = YES;
    self.failure = nil;
    self.success = nil;
    self.xDelegate = nil;
    if (self.sessionDataTask) {
        [self.sessionDataTask cancel];
    }
    self.requestState = XNetWorkRequestStateCancel;

}

//- (void)readyStart {
//    self.isCanTryRequest = YES;
//}

- (void)addDependency:(XZNetWorkTask *)netWorkTask {
    if ([self x_isSupportDependency:netWorkTask]) {
        NSAssert(![netWorkTask.dependencyTasks containsObject:self], @"存在循环依赖");
        [netWorkTask.dependencyTasks removeObject:self];//移除依赖对象避免循环依赖
        [self.dependencyTasks addObject:netWorkTask];
        [netWorkTask addObserver:self forKeyPath:@"requestState" options:NSKeyValueObservingOptionNew context:nil];
    
        NSLog(@"%@ 监听 %@",self.config.taskName,netWorkTask.config.taskName);
    }
}

- (void)addDependencys:(NSArray <XZNetWorkTask *> *)netWorkTasks {
    [netWorkTasks enumerateObjectsUsingBlock:^(XZNetWorkTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addDependency:obj];
    }];
}

/// 移除约束
- (void)removeDependency:(XZNetWorkTask *)netWorkTask {
    @try {
        [netWorkTask removeObserver:self forKeyPath:@"requestState"];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    [self.dependencyTasks removeObject:netWorkTask];
}


#pragma mark - private
/// 是否支持约束
- (BOOL)x_isSupportDependency:(XZNetWorkTask *)netWorkTask {
    
    if (netWorkTask && !netWorkTask.sessionDataTask && ![self.dependencyTasks containsObject:netWorkTask]) {
        return YES;
    }
    return NO;
}

/// 校验是否支持开始请求
- (BOOL)x_isSupportStart {
    
    if (self.dependencyTasks.count > 0 || !self.config.requestUrl) {
        return NO;
    }
    return YES;
}

- (NSMutableArray<XZNetWorkTask *> *)dependencyTasks {
    if (!_dependencyTasks) {
        _dependencyTasks = [[NSMutableArray alloc] init];
    }
    return _dependencyTasks;
}

- (void)dealloc
{
    for (XZNetWorkTask *netWorkTask in self.dependencyTasks) {
        @try {
            [netWorkTask removeObserver:self forKeyPath:@"requestState"];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    }
    NSLog(@"%@ 请求任务 销毁了",self.config.taskName);
//    NSLog(@"%@",self.config.taskName);
}

- (XZNetWorkTask *(^)(BOOL))delayStart {
    return ^(BOOL isDelayStart) {
        return self;
    };
}
@end

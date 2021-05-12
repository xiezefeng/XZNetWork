//
//  XZNetWorkTaskManager.m
//  XNetWork
//
//  Created by ZF xie on 2021/4/30.
//

#import "XZNetWorkTaskManager.h"
@interface XZNetWorkTaskManager()

@property (nonatomic, strong) NSMutableArray *netWorkTasks;///<<#des#>

@end

@implementation XZNetWorkTaskManager

static XZNetWorkTaskManager *_netWorkTaskManager = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _netWorkTaskManager = [[super allocWithZone:NULL] init];
    });
    return _netWorkTaskManager;
}

// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [self.class shareInstance];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self.class shareInstance];
}

- (NSMutableArray *)netWorkTasks {
    if (!_netWorkTasks) {
        _netWorkTasks = [[NSMutableArray alloc] init];
    }
    return _netWorkTasks;
}


/// 立刻发起请求
/// @param url 地址
/// @param param 参数
/// @param headers 请求头
/// @param success 成功
/// @param failure 失败
+ (XZNetWorkTask *)netWorkTaskWithURL:(NSString *)url
                        requestParam:(NSDictionary *)param
                      requestheaders:(NSDictionary *)headers
                             success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                             failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure {
    return [self netWorkWithURL:url requestParam:param requestheaders:headers delayStartRequest:NO requestTaskName:@"" success:success failure:failure];
}

/// 延迟发起请求 主要用于有依赖关系请求
/// @param url 地址
/// @param param 参数
/// @param headers 请求头
/// @param success 成功
/// @param failure 失败
+ (XZNetWorkTask *)netWorkTaskDelayStartWithURL:(NSString *)url
                                  requestParam:(NSDictionary *)param
                                requestheaders:(NSDictionary *)headers
                                       success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                                       failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure {

    return [self netWorkWithURL:url requestParam:param requestheaders:headers delayStartRequest:YES requestTaskName:@"" success:success failure:failure];
}


+ (XZNetWorkTask *)netWorkWithURL:(NSString *)url
                    requestParam:(NSDictionary *)param
                  requestheaders:(NSDictionary *)headers
               delayStartRequest:(BOOL)delayStart
                 requestTaskName:(NSString *)taskName
                         success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                         failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure {
    
    XZNetWorkTaskConfig *config = [XZNetWorkTaskConfig netWorkTaskConfigWithURL:url requestParam:param requestheaders:headers delayStartRequest:delayStart requestTaskName:taskName];
    XZNetWorkTask *task = [XZNetWorkTask netWorkTaskWithConfig:config progress:nil success:success failure:failure];
    [[XZNetWorkTaskManager shareInstance].netWorkTasks addObject:task];
    [task addObserver:[XZNetWorkTaskManager shareInstance] forKeyPath:@"requestState" options:NSKeyValueObservingOptionNew context:nil];

    return task;
}

+ (XZNetWorkBatch *)netWorkBatchWithRequestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                        success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                        failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure {
    XZNetWorkBatchConfig *config = [XZNetWorkBatchConfig netWorkBatchConfig:YES];
    XZNetWorkBatch *task = [XZNetWorkBatch netWorkBatchTaskConfig:config];
    [task netWorkBatchTaskWithRequestArray:requestArray success:success failure:failure];
    [task addObserver:[XZNetWorkTaskManager shareInstance] forKeyPath:@"requestState" options:NSKeyValueObservingOptionNew context:nil];
    [[XZNetWorkTaskManager shareInstance].netWorkTasks addObject:task];
    [task start];
    return task;

}

+ (XZNetWorkBatch *)netWorkBatchWithNoneedCompleteTotalRequestRequestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                        success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                        failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure {
    XZNetWorkBatchConfig *config = [XZNetWorkBatchConfig netWorkBatchConfig:NO];
    XZNetWorkBatch *task = [XZNetWorkBatch netWorkBatchTaskConfig:config];
    [task netWorkBatchTaskWithRequestArray:requestArray success:success failure:failure];
    [task addObserver:[XZNetWorkTaskManager shareInstance] forKeyPath:@"requestState" options:NSKeyValueObservingOptionNew context:nil];
    [[XZNetWorkTaskManager shareInstance].netWorkTasks addObject:task];
    [task start];
    return task;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    XZNetWorkTask *task = object;
    switch (task.requestState) {
        case XNetWorkRequestStateSuccess: /// 请求成功
        case XNetWorkRequestStateCancel: /// 请求取消
        case XNetWorkRequestStateFailure: /// 请求失败:
            [self.netWorkTasks removeObject:task];
            break;
            
        default:
            break;
    }
}
//+ (void (^)(XZNetWorkTask *))tryStart {
//    return ^(XZNetWorkTask *task) {
//        [task start];
//    };
//}

//+ (void (^)(id))shop {
//    return ^(id task) {
//        if ([task isKindOfClass:[XZNetWorkTask class]]) {
//            XZNetWorkTask *nt = task;
//            [nt stop];
//        }
//    };
//}

+ (void)start:(XZNetWorkTask *)task {
    [task start];
}

+ (void)shop:(XZNetWorkTask *)task {
    [task stop];
}

@end

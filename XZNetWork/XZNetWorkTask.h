//
//  XZNetWorkTask.h
//  XNetWork
//
//  Created by ZF xie on 2021/4/28.
//

#import <Foundation/Foundation.h>
#import "XZNetWorkTask.h"
#import "XZNetWorkTaskConfig.h"

typedef NS_ENUM(NSUInteger, XNetWorkRequestState) {

    XNetWorkRequestStateNone = 0, ///>未发起请求
    XNetWorkRequestStateRequesting, ///请求数据中
    XNetWorkRequestStateSuccess, /// 请求成功
    XNetWorkRequestStateCancel, /// 请求取消
    XNetWorkRequestStateFailure, /// 请求失败
};

NS_ASSUME_NONNULL_BEGIN
@class XZNetWorkTask;
@protocol XRequestDelegate <NSObject>

@optional

- (void)requestFinished:(XZNetWorkTask *)request;

- (void)requestFailed:(XZNetWorkTask *)request;

@end

@interface XZNetWorkTask : NSObject

@property (nonatomic, assign) id  <XRequestDelegate> _Nullable xDelegate;
///<所有依赖类
@property (nonatomic, strong, readonly) NSMutableArray <XZNetWorkTask *>*dependencyTasks;

///<请求状态
@property (nonatomic, assign, readonly) XNetWorkRequestState requestState;

///<配置
@property (nonatomic, strong, readonly) XZNetWorkTaskConfig *config;

///<请求任务
@property (nonatomic, strong,readonly) NSURLSessionTask *sessionDataTask;

/// 准备开始
//- (void)readyStart;

/// 开启网络请求
- (void)start;

/// 停止后将不会有成功失败回调, 无法重新请求
- (void)stop;

/// 添加请求依赖 netWorkTask完成时才会支持开始
- (void)addDependency:(XZNetWorkTask *)netWorkTask;

- (void)addDependencys:(NSArray <XZNetWorkTask *> *)netWorkTasks;

/// 移除依赖请求
- (void)removeDependency:(XZNetWorkTask *)netWorkTask;



#pragma mark - initialize

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

//- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (XZNetWorkTask *)netWorkTask:(XZNetWorkTaskConfig *)confing;

- (XZNetWorkTask *)netWorkTaskWithProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                  success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                                  failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure;

+ (XZNetWorkTask *)netWorkTaskWithConfig:(XZNetWorkTaskConfig *)confing
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                                failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure;


@end

NS_ASSUME_NONNULL_END

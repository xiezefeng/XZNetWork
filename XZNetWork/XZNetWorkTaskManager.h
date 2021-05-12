//
//  XZNetWorkTaskManager.h
//  XNetWork
//
//  Created by ZF xie on 2021/4/30.
//

#import <Foundation/Foundation.h>
#import "XZNetWorkTask.h"
#import "XZNetWorkBatch.h"
NS_ASSUME_NONNULL_BEGIN

@interface XZNetWorkTaskManager : NSObject

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
                             failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure;



/// 延迟发起请求 主要用于有依赖关系请求
+ (XZNetWorkTask *)netWorkTaskDelayStartWithURL:(NSString *)url
                                  requestParam:(NSDictionary *)param
                                requestheaders:(NSDictionary *)headers
                                       success:(void (^_Nullable)(XZNetWorkTask *_Nullable task, id _Nullable responseObject))success
                                       failure:(void (^_Nullable)(XZNetWorkTask *_Nullable task, NSError *_Nullable error))failure;

///  完成所有网络请求
+ (XZNetWorkBatch *)netWorkBatchWithRequestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                        success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                        failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure;
/// 当有一个失败时中断剩下请求
+ (XZNetWorkBatch *)netWorkBatchWithNoneedCompleteTotalRequestRequestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                                                  success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                                                  failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure;

+ (void)start:(XZNetWorkTask *)task;
+ (void)shop:(XZNetWorkTask *)task;



@end

NS_ASSUME_NONNULL_END

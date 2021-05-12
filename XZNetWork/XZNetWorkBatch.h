//
//  XNetWorkBatch.h
//  XNetWork
//
//  Created by ZF xie on 2021/4/28.
//

#import <Foundation/Foundation.h>
#import "XZNetWorkTask.h"
#import "XZNetWorkBatchConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface XZNetWorkBatch : NSObject
@property (nonatomic, strong, readonly) XZNetWorkBatchConfig * config;///<<#des#>
@property (nonatomic, assign) XNetWorkRequestState requestState;   ///<<#des#>
+ (XZNetWorkBatch *)netWorkBatchTaskWithConfig:(XZNetWorkBatchConfig *)config
                                 requestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                      success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                      failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure;


- (XZNetWorkBatch *)netWorkBatchTaskWithRequestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                            success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                            failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure;
- (void)shop;
- (void)start;


#pragma mark - initialize

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

//- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (XZNetWorkBatch *)netWorkBatchTaskConfig:(XZNetWorkBatchConfig *)confing;

@end

NS_ASSUME_NONNULL_END

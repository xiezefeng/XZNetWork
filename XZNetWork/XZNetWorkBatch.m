//
//  XNetWorkBatch.m
//  XNetWork
//
//  Created by ZF xie on 2021/4/28.
//

#import "XZNetWorkBatch.h"
@interface XZNetWorkBatch()<XRequestDelegate>
@property (nonatomic, strong) NSMutableArray <XZNetWorkTask *>*requestArray;///<
@property (nonatomic, assign) BOOL isCompleteAllRequests;   ///<<#des#>
@property (nonatomic, copy, nullable) void (^successCompletionBlock)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests);
@property (nonatomic, copy, nullable) void (^failureCompletionBlock)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask);
@property (nonatomic, strong, readwrite) XZNetWorkBatchConfig * config;///<<#des#>

@end

@implementation XZNetWorkBatch

- (XZNetWorkBatch *)netWorkBatchTaskWithRequestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                            success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                            failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self.requestArray addObjectsFromArray:requestArray];
//    [self start];
    return self;
    
}

+ (XZNetWorkBatch *)netWorkBatchTaskWithConfig:(XZNetWorkBatchConfig *)config
                                 requestArray:(NSArray<XZNetWorkTask *> *)requestArray
                                      success:(nullable void (^)(XZNetWorkBatch *batchRequest,BOOL isCompleteAllRequests))success
                                      failure:(nullable void (^)(XZNetWorkBatch *batchRequest,XZNetWorkTask *failNetWorkTask))failure {
    XZNetWorkBatch *task = [XZNetWorkBatch netWorkBatchTaskConfig:config];
    return [task netWorkBatchTaskWithRequestArray:requestArray success:success failure:failure];
}

+ (XZNetWorkBatch *)netWorkBatchTaskConfig:(XZNetWorkBatchConfig *)config {
    XZNetWorkBatch *task = [[XZNetWorkBatch alloc] init];
    task.config = config;
    return task;
}
- (void)start {
    self.requestState = XNetWorkRequestStateRequesting;
    [self.requestArray enumerateObjectsUsingBlock:^(XZNetWorkTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.xDelegate = self;
        [obj start];
        
    }];
}

- (void)shop {
    if (self.requestArray.count > 0) {
        [self.requestArray enumerateObjectsUsingBlock:^(XZNetWorkTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj stop];
        }];
        
        [self.requestArray removeAllObjects];
        self.successCompletionBlock(self, NO);
    }
    
}

- (void)checkRequestStatus {
    if (self.requestArray.count == 0) {
        self.requestState = XNetWorkRequestStateSuccess;
        self.successCompletionBlock(self, self.isCompleteAllRequests);
    }
}

#pragma mark - XRequestDelegate
- (void)requestFinished:(XZNetWorkTask *)request {
    [self.requestArray removeObject:request];
    [self checkRequestStatus];
}

- (void)requestFailed:(XZNetWorkTask *)request {
    self.failureCompletionBlock(self, request);
    [self.requestArray removeObject:request];
    self.isCompleteAllRequests = NO;
    [self checkRequestStatus];
    if (!self.config.isCompleteTotalRequest) {
        self.requestState = XNetWorkRequestStateFailure;
        [self shop];
    }
}

#pragma mark - lazy
- (NSMutableArray <XZNetWorkTask *> *)requestArray {
    if (!_requestArray) {
        _requestArray = [[NSMutableArray alloc] init];
    }
    return _requestArray;
}

- (void)dealloc
{
    [self.requestArray enumerateObjectsUsingBlock:^(XZNetWorkTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj stop];
    }];
    NSLog(@"XNetWorkBatch 销毁了");
}


@end

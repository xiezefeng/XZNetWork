//
//  XZNetWorkTaskConfig.h
//  XNetWork
//
//  Created by ZF xie on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZNetWorkTaskConfig : NSObject
///<延迟发起请求
@property (nonatomic, assign) BOOL delayStartRequest;

/// 请求地址
@property (nonatomic, copy) NSString *requestUrl;

/// 请求参数
@property (nonatomic, strong) NSDictionary *requestParam;

/// 请求头参数
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *headers;

/// 请求任务名称
@property (nonatomic, strong) NSString *taskName;

+ (instancetype)netWorkTaskConfigWithURL:(NSString *)url
                            requestParam:(NSDictionary *)param
                          requestheaders:(NSDictionary *)headers
                       delayStartRequest:(BOOL)delayStart
                         requestTaskName:(NSString *)taskName;
#pragma mark - initialize

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
@end

NS_ASSUME_NONNULL_END

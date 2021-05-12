//
//  XZNetWorkTaskConfig.m
//  XNetWork
//
//  Created by ZF xie on 2021/4/30.
//

#import "XZNetWorkTaskConfig.h"

@implementation XZNetWorkTaskConfig
+ (instancetype)netWorkTaskConfigWithURL:(NSString *)url
                            requestParam:(NSDictionary *)param
                          requestheaders:(NSDictionary *)headers
                       delayStartRequest:(BOOL)delayStartRequest
                         requestTaskName:(NSString *)taskName {
    XZNetWorkTaskConfig *config = [[XZNetWorkTaskConfig alloc] init];
    config.requestUrl = url;
    config.requestParam = param;
    config.headers = headers;
    config.delayStartRequest = delayStartRequest;
    config.taskName = taskName;
    return config;
}
@end

//
//  XNetWorkBatchConfig.m
//  XNetWork
//
//  Created by ZF xie on 2021/4/30.
//

#import "XZNetWorkBatchConfig.h"

@implementation XZNetWorkBatchConfig
+ (instancetype)netWorkBatchConfig:(BOOL)completeTotalRequest {
    XZNetWorkBatchConfig *config = [[XZNetWorkBatchConfig alloc] init];
    config.isCompleteTotalRequest = completeTotalRequest;
    return config;
}
@end

//
//  XNetWorkBatchConfig.h
//  XNetWork
//
//  Created by ZF xie on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZNetWorkBatchConfig : NSObject
///<是否必须完成所有请求
@property (nonatomic, assign) BOOL isCompleteTotalRequest;
+ (instancetype)netWorkBatchConfig:(BOOL)completeTotalRequest;
@end

NS_ASSUME_NONNULL_END

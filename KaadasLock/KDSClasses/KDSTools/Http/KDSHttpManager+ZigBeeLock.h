//
//  KDSHttpManager+ZigBeeLock.h
//  KaadasLock
//
//  Created by zhaona on 2020/5/15.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSHttpManager (ZigBeeLock)
/**
 *@abstract 查询用户绑定的ZigBee设备信息（密码列表，设备基本信息年、周计划等，数据超级多不知道为啥要这样）。
 *@param gwSN 网关的唯一编号。
 *@param uid 服务器返回的uid(用户ID)。
 *@param zigbeeSN zigBee锁的唯一标示
 *@param success 请求成功执行的回调，status 201表示未绑定，202表示已绑定，412设备注册失败 重复的记录。如果已绑定，account可能为已绑定的账号，否则为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getZigBeeInfoWithGwSN:(NSString *)gwSN uid:(NSString *)uid zigbeeSN:(NSString *)zigbeeSN success:(nullable void(^)(id _Nullable))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

//
//  KDSHttpManager+SmartHanger.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager.h"
#import "KDSSmartHangerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSHttpManager (SmartHanger)

/**
 *@abstract 绑定晾衣机。
 *@param device 设备模型。必须包含wifiSN、productSN、productModel、softwareVersion、functionSet
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)bindSmartHangerDevice:(KDSSmartHangerModel *)device uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
 *@abstract 绑定晾衣机。
 *@param deviceSN 设备SN
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */

- (NSURLSessionDataTask *)bindSmartHangerDeviceSN:(NSString  *)deviceSN uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
 *@abstract 解绑晾衣机设备。
 *@param hanger 晾衣机模型
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)unbindSmartHanger:(KDSDeviceHangerModel *)hanger success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
 *@abstract 用户检查升级。
 *@param hanger 晾衣机模型
 *@param customer 客户。1为凯迪仕，15为小凯智能生活
 *@param success 请求成功执行的回调upgradeTask，需要保存给升级用。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)checkUpdateSmartHanger:(KDSDeviceHangerModel *)hanger customer:(NSUInteger) customer success:(void (^)(NSArray *upgradeTask))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;
/**
 *@abstract 升级晾衣机。
 *@param hanger 晾衣机模型
 *@param upgradeTask 升级任务。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)upgradeSmartHanger:(KDSDeviceHangerModel *)hanger upgradeTask:(NSArray *) upgradeTask success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
 *@abstract 修改晾衣机昵称
 *@param hanger 晾衣机模型
 *@param nickName 新昵称
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)updateSmartHanger:(KDSDeviceHangerModel *)hanger nickName:(NSString *) nickName success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;
@end

NS_ASSUME_NONNULL_END

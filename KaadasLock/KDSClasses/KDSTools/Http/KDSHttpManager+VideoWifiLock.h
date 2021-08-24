//
//  KDSHttpManager+VideoWifiLock.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager.h"
#import "KDSWifiLockAlarmModel.h"
#import "KDSWifiLockModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSHttpManager (VideoWifiLock)

/**
 *@abstract app获取token(讯美授权认证的token)。
 *@param uid 服务器返回的uid(用户ID)。
 *@param success 请求成功执行的回调，"code": "200",标识成功
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)videoWifiLockGetTokenWithUid:(NSString *)uid success:(nullable void(^)(NSString * __nullable token))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 管理员添加XMMediawifi设备。
 *@param device 设备模型。必须包含wifiSN、productSN、productModel、softwareVersion、functionSet
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)bindMediaWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 管理员重新绑定XMMediawifi设备。
 *@param device 设备模型。必须包含wifiSN、productSN、productModel、softwareVersion、functionSet
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateMediaBindWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract app发送绑定失败通知。
 *@param device 设备模型。必须包含wifiSN、productSN、productModel、softwareVersion、functionSet
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param result 操作结果,0:失败，1: 成功.
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)XMMediaBindFailWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid result:(int)result success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 解绑(重置)已绑定的视频锁。
 *@param wifiSN wifi模块SN。
 *@param uid 服务器返回的uid(用户ID)。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)unbindXMMediaWifiDeviceWithWifiSN:(NSString *)wifiSN uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 获取账号下绑定视频锁的报警记录。
 *@param wifiSN    wifi模块SN。
 *@param index 第几页记录，从1(0和1返回的数据是一样的)开始。一页20条数据。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getXMMediaLockBindedDeviceAlarmRecordWithWifiSN:(NSString *)wifiSN index:(int)index success:(nullable void(^)(NSArray<KDSWifiLockAlarmModel *> *models))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 获取账号下绑定视频锁的访客记录（有人按门铃的时候8秒的抓拍缩略图）。
 *@param wifiSN    wifi模块SN。
 *@param index 第几页记录，从1(0和1返回的数据是一样的)开始。一页20条数据。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getXMMediaLockBindedDeviceVisitorRecordWithWifiSN:(NSString *)wifiSN index:(int)index success:(nullable void(^)(NSArray<KDSWifiLockAlarmModel *> *models))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 查询wifi锁设备列表。
 *@param uid    用户ID。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getBindedWifiDeviceListWithUid:(NSString *)uid success:(nullable void(^)(NSArray<KDSWifiLockModel *> *models))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 检查wifi锁/模块是否需要升级

 @param deviceName WIFI设备SN
 @param customer 客户代号，1：凯迪仕 、2：小凯 、3：桔子物联、 4：飞利浦
 @param version 蓝牙版本号
 @param devNum 升级编号。1为WIFI模块，2为WIFI锁，3为人脸模组，4为视频模组，5为视频模组微控制器。
 @param success 请求成功执行的回调
 @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
 @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
 @return 当前的请求任务
 */
-(NSURLSessionDataTask *)checkXMWiFiOTAWithSerialNumber:(NSString *)deviceName withCustomer:(int)customer withVersion:(NSString *)version withDevNum:(int)devNum success:(void (^)(id _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
 确认wifi锁/模块升级

 @param deviceName WIFI设备SN
 @param data OTA数据
 @param success 请求成功执行的回调
 @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
 @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
 @return 当前的请求任务
 */

-(NSURLSessionDataTask *)xmWifiDeviceOTAWithSerialNumber:(NSString *)deviceName withOTAData:(NSDictionary *)data success:(nullable void(^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

@end

NS_ASSUME_NONNULL_END

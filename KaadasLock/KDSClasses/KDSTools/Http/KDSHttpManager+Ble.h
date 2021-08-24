//
//  KDSHttpManager+Ble.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSHttpManager.h"
#import "MyDevice.h"
#import "KDSLockPwdInfo.h"
#import "News.h"
#import "KDSPwdListModel.h"
#import "KDSAlarmModel.h"
#import "KDSOperationalRecord.h"
#import "KDSDeviceModelMapping.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSHttpManager (Ble)

/**
 *@abstract 检查蓝牙设备的绑定状态。
 *@param name 蓝牙广播名。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调，status 201表示未绑定，202表示已绑定。如果已绑定，account可能为已绑定的账号，否则为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)checkBleDeviceBindingStatusWithBleName:(NSString *)name uid:(NSString *)uid success:(nullable void(^)(int status, NSString * __nullable account))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 根据蓝牙返回的序列号获取锁的密码1，绑定或者解绑操作鉴权的时候需要。因此，如果绑定操作太快或者网络不好，在没有获取到密码1前就去鉴权是肯定会失败的。
 *@param sn 蓝牙返回的序列号。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getPwd1WithSN:(NSString *)sn success:(nullable void(^)(NSString *pwd1))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 绑定蓝牙。
 *@param device 设备模型。必须包含蓝牙名称、Mac地址(格式XX:XX:XX:XX:XX:XX)、密码1(根据SN服务器返回)、密码2和模型。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)bindBleDevice:(MyDevice *)device uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 解绑(重置)已绑定的蓝牙。
 *@param name 蓝牙广播名。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)unbindBleDeviceWithBleName:(NSString *)name uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 检查开锁权限。
 *@param uid 服务器返回的uid。
 *@param token 登录接口服务器返回的token。
 *@param name 蓝牙广播名。
 *@param admin 是否是主人账户，绑定设备的账户是主人账户，授权的不是。
 *@param newDevice 是否是新蓝牙设备。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)checkUnlockAuthWithUid:(NSString *)uid token:(NSString *)token bleName:(NSString *)name isAdmin:(BOOL)admin isNewDevice:(BOOL)newDevice success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 上报开锁成功，不带时间。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙广播名。
 *@param admin 是否是主人账户，绑定设备的账户是主人账户，授权的不是。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)reportUnlockWithUid:(NSString *)uid bleName:(NSString *)name isAdmin:(BOOL)admin success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;


/**
 *@abstract 获取账号下绑定的设备。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param success 请求成功执行的回调，devices包含所有绑定的设备，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getBindedDeviceListWithUid:(NSString *)uid success:(nullable void(^)(NSArray<MyDevice *> *devices))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取服务器保存的账号下已添加到锁的全部密码编号、昵称信息。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param name 蓝牙广播名。
 *@param success 请求成功执行的回调，infos包含保存的密码信息，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getLockPwdInfoWithUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(NSArray<KDSLockPwdInfo *> *infos))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 在服务器端给账号添加/更新一个密码信息。
 *@param info 密码信息模型，此接口暂时只用到number和nickname2个属性。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param name 蓝牙广播名。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)addLockPwdInfo:(KDSLockPwdInfo *)info withUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 删除账号下绑定的设备。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param name 蓝牙广播名。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)deleteBindedDeviceWithUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改账号下绑定的设备的昵称。
 *@param nickname 昵称，限长度16。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param name 蓝牙广播名。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)alterBindedDeviceNickname:(NSString *)nickname withUid:(NSString *)uid bleName:(NSString *)name  success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取账号下绑定的设备的开锁记录。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param name 蓝牙广播名。
 *@param index 第几页记录，从1开始。一页20条数据。
 *@param success 请求成功执行的回调，news是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getBindedDeviceUnlockRecordWithUid:(NSString *)uid bleName:(NSString *)name index:(int)index success:(nullable void(^)(NSArray<News *> *news))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 上传账号下绑定的设备的开锁记录。
 *@param records 开锁记录。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param device 设备模型。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)uploadBindedDeviceUnlockRecord:(NSArray<News *> *)records withUid:(NSString *)uid device:(MyDevice *)device success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取账号下绑定的设备的报警记录。
 *@param name 设备名(一般是蓝牙广播名)。
 *@param index 第几页记录，从1(0和1返回的数据是一样的)开始。一页20条数据。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getBindedDeviceAlarmRecordWithDevName:(NSString *)name index:(int)index success:(nullable void(^)(NSArray<KDSAlarmModel *> *models))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 上传账号下绑定的设备的报警记录。
 *@param records 报警记录数组，每条记录必须包括设备名、报警类型和报警时间。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)uploadBindedDeviceAlarmRecord:(NSArray<KDSAlarmModel *> *)records success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 Description 获取蓝牙锁下面的用户密码列表

 @param uid 服务器登录接口成功时返回的uid。
 @param name 设备名
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
-(NSURLSessionDataTask *)getBlePwdListWithUid:(NSString *)uid bleName:(NSString *)name pwdType:(KDSServerKeyTpye)type  success:(nullable void(^)(NSArray<KDSPwdListModel *> *pwdlistArray))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 添加密匙信息(密码、卡片、指纹等)，密匙类型和编号是必须的。
 *@param models 密匙信息模型数组。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙名称。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)addBlePwds:(NSArray<KDSPwdListModel *> *)models withUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 设置(修改)服务器记录的密匙信息(密码、卡片、指纹等)。
 *@param model 密匙信息模型。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙名称。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setBlePwd:(KDSPwdListModel *)model withUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 删除服务器记录的密匙信息(密码、卡片、指纹等)。
 *@param array 密匙信息模型。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙名称。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)deleteBlePwd:(NSArray <KDSPwdListModel*>*)array withUid:(NSString *)uid bleName:(NSString *)name success:(nullable void (^)(void))success error:(nullable void (^)(NSError * _Nonnull))errorBlock failure:(nullable void (^)(NSError * _Nonnull))failure;

/**
 同步新的用户密码至服务器

 @param uid 服务器登录接口成功时返回的uid。
 @param name 设备名
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
-(NSURLSessionDataTask *)addNewUserToSeversWithGuest:(NSString *)uid bleName:(NSString *)name pwdarray:(NSArray <KDSPwdListModel*>*)array success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;


/**
 检查蓝牙固件是否需要升级

 @param serialNumber 蓝牙SN号
 @param customer 客户代号，1：凯迪仕 、2：小凯 、3：桔子物联、 4：飞利浦
 @param version 蓝牙版本号
 @param devNum 请求的模块类型,1：主模块  2：算法模块 、3：相机模块（空：默认1）、 4：协议栈
 @param success 请求成功执行的回调
 @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
 @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
 @return 当前的请求任务
 */
-(NSURLSessionDataTask *)checkBleOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersion:(NSString *)version withDevNum:(int)devNum success:(void (^)(NSString * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
设备升级结果上报

@param serialNumber 蓝牙SN号
@param customer 客户代号，1：凯迪仕 、2：小凯 、3：桔子物联、 4：飞利浦
@param version 蓝牙版本号
@param resultCode 升级结果状态码
@param devNum 请求的模块类型,1：主模块  2：算法模块 、3：相机模块（空：默认1）、 4：协议栈
@param success 请求成功执行的回调
@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
@return 当前的请求任务
*/
- (nullable NSURLSessionDataTask *)UpdateResultsBleOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersion:(NSString *)version withResultCode:(NSString *)resultCode withDevNum:(int)devNum success:(void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 修改服务器记录的蓝牙版本。
 *@param version 蓝牙版本。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙名称。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateBleVersion:(int)version withUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改服务器记录的修改功能集。
 *@param functionSet 门锁功能集。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙名称。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateFunctionSet:(NSString *)functionSet withUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 修改设备固件版本

 @param softwareVersion 固件版本
 @param devname 门锁名
 @param user_id 用户ID
 @param deviceSN 设备SN
 @param peripheralId ios蓝牙UUID
 @param success 请求成功执行的回调
 @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
 @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
 @return 当前的请求任务
 */
- (nullable NSURLSessionDataTask *)updateSoftwareVersion:(NSString *)softwareVersion withDevname:(NSString *)devname withUser_id:(NSString *)user_id withDeviceSN:(NSString *)deviceSN withPeripheralId:(NSString *)peripheralId success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;


/**
 *@abstract 上传账号下绑定的设备的操作记录(开锁记录、操作记录)。
 *@param records 操作记录。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param device 设备模型。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)uploadBindedDeviceOperationalRecords:(NSArray<KDSOperationalRecord *> *)records withUid:(NSString *)uid device:(MyDevice *)device success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取账号下绑定的设备的(开锁记录、操作记录)。
 *@param name 蓝牙广播名。
 *@param index 第几页记录，从1开始。一页20条数据。
 *@param success 请求成功执行的回调，news是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getBindedDeviceOperationalRecordsWithBleName:(NSString *)name index:(int)index success:(nullable void(^)(NSArray<KDSOperationalRecord *> *news))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 Description 获取蓝牙锁设备模型映射表
 *@param developmentModel 研发型号（蓝牙锁）
 *@param success 请求成功执行的回调，
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
-(NSURLSessionDataTask *)getDeviceModelMappingWithDevelopmentModel:(NSString *)developmentModel  success:(void(^)(KDSDeviceModelMapping *_Nonnull KDSDeviceModelMapping))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END

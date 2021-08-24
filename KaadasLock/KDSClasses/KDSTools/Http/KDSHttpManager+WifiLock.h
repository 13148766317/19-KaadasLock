//
//  KDSHttpManager+WifiLock.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager.h"
#import "KDSWifiLockModel.h"
#import "KDSAuthMember.h"
#import "KDSWifiLockAlarmModel.h"
#import "KDSWifiLockOperation.h"

NS_ASSUME_NONNULL_BEGIN

/// <#Description#>
@interface KDSHttpManager (WifiLock)

/**
 *@abstract 检查wifi设备的绑定状态。
 *@param name 设备唯一编号。
 *@param uid 服务器返回的uid(用户ID)。
 *@param success 请求成功执行的回调，status 201表示未绑定，202表示已绑定，412设备注册失败 重复的记录。如果已绑定，account可能为已绑定的账号，否则为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)checkWifiDeviceBindingStatusWithDevName:(NSString *)name uid:(NSString *)uid success:(nullable void(^)(int status, NSString * __nullable account))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 管理员添加wifi设备。
 *@param device 设备模型。必须包含wifiSN、productSN、productModel、softwareVersion、functionSet
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)bindWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 管理员重新绑定wifi设备。
 *@param device 设备模型。必须包含wifiSN、productSN、productModel、softwareVersion、functionSet
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateBindWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 解绑(重置)已绑定的wifiLock。
 *@param wifiSN wifi模块SN。
 *@param uid 服务器返回的uid(用户ID)。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)unbindWifiDeviceWithWifiSN:(NSString *)wifiSN uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改账号下绑定的设备的昵称。
 *@param nickname 昵称，限长度16。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)alterWifiBindedDeviceNickname:(NSString *)nickname withUid:(NSString *)uid wifiModel:(KDSWifiLockModel *)wifiModel  success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 设备联动开关昵称修改。
 *@param switchNickname (开关的数组type：1、2、3、4，昵称：1、2、3、4) 昵称，限长度16。
 *@param uid 服务器登录接口成功时返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateSwitchNickname:(NSArray *)switchNickname withUid:(NSString *)uid wifiModel:(KDSWifiLockModel *)wifiModel success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 设置wifi锁开锁推送功能开关。
 *@param open 开启或关闭。推送开关： 1(0默认开启)开启推送 2关闭推送
 *@param uid 服务器返回的uid。
 *@param wifiSN  wifi模块SN。
 *@param success 请求成功执行的回调，open返回开关是否开启。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setUserWifiLockUnlockNotification:(int)open withUid:(NSString *)uid wifiSN:(NSString *)wifiSN completion:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取wifi锁下面的用户密码列表
 *@param uid 服务器登录接口成功时返回的uid(管理员用户ID)。
 *@param wifiSN      wifi模块SN
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
-(NSURLSessionDataTask *)getWifiLockPwdListWithUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(nullable void(^)(NSArray<KDSPwdListModel *> *pwdList, NSArray<KDSPwdListModel *> *fingerprintList,NSArray<KDSPwdListModel *> *cardList,NSArray<KDSPwdListModel *> *faceList, NSArray<KDSPwdListModel *> *pwdNicknameArr, NSArray<KDSPwdListModel *> *fingerprintNicknameArr, NSArray<KDSPwdListModel *> *cardNicknameArr,NSArray<KDSPwdListModel *> *faceNicknameArr, NSArray<KDSPwdListModel *> *pwdDuressArr, NSArray<KDSPwdListModel *> *fingerprintDuressArr))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改密钥胁迫报警属性 --单个胁迫报警开关
 *@param uid 服务器登录接口成功时返回的uid(管理员用户ID)。
 *@param wifiSN    wifi模块SN
 *@param num 密钥编号
 *@param pwdType 密钥类型：1密码 2指纹密码 3卡片密码 4面容识别
 *@param pwdDuressSwitch 密密钥胁迫报警开关编号 0:关闭   1：开启
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setDuressAlarmSinglePwdSwitchWithUid:(NSString *)uid WifiSN:(NSString *)wifiSN PwdType:(KDSServerKeyTpye)pwdType Num:(int)num PwdDuressSwitch:(int)pwdDuressSwitch success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 设置胁迫密钥的接收用户
 *@param uid 服务器登录接口成功时返回的uid(管理员用户ID)。
 *@param wifiSN    wifi模块SN
 *@param num 密钥编号
 *@param pwdType 密钥类型：1密码 2指纹密码 3卡片密码 4面容识别
 *@param accountType  胁迫报警接口账户类型。1 手机号；2 邮箱
 *@param duressAlarmAccount 胁迫报警接口账户
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setDuressAlarmSinglePwdAccountWithUid:(NSString *)uid WifiSN:(NSString *)wifiSN PwdType:(KDSServerKeyTpye)pwdType Num:(int)num AccountType:(int)accountType DuressAlarmAccount:(NSString *)duressAlarmAccount success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改胁迫报警开关
 *@param uid 服务器登录接口成功时返回的uid(管理员用户ID)。
 *@param wifiSN    wifi模块SN
 *@param duressAlarmSwitch  胁迫开关：0 关闭胁迫报警  1 开启胁迫报警
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setDuressAlarmSwitchWithUid:(NSString *)uid WifiSN:(NSString *)wifiSN  DuressAlarmSwitch:(int)duressAlarmSwitch  success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;


/**
 *@abstract 设置(修改)服务器记录的wifi锁的密码昵称(密码、卡片、指纹等)。
 *@param model 密匙信息模型。
 *@param uid 服务器返回的uid。
 *@param wifiSN 设备唯一编号。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setWifiLockPwd:(KDSPwdListModel *)model withUid:(NSString *)uid wifiSN:(NSString *)wifiSN userNickname:(NSString *)userNickname success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 添加wifiLock的被授权用户。
 *@param member 授权成员模型，必须设置被授权账号、权限和起始时间。
 *@param uid 服务器返回的uid。
 *@param wifiSN 设备唯一编号。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。401被授权账号不存在，409该账号已添加，433锁被重置且当前账号不是管理员。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)addWifiLockAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 删除wifiLock已被授权的用户。
 *@param member 授权成员模型，必须设置被授权账号。
 *@param uid 服务器返回的uid。
 *@param wifiSN 设备唯一编号。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)deleteWifiLockAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改wifi锁的被授权用户的昵称。
 *@param member 被授权账号，unickname必须包含新的昵称。
 *@param wifiSN 设备唯一编号。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateWifiLockAuthorizedUserNickname:(KDSAuthMember *)member wifiSN:(NSString *)wifiSN success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取被授权开锁的用户列表。
 *@param uid 服务器返回的uid。
 *@param wifiSN wifi模块SN。
 *@param success 请求成功执行的回调，members：服务器返回的被授权用户，可能为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getWifiLockAuthorizedUsersWithUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(nullable void(^)(NSArray<KDSAuthMember *> * __nullable members))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取账号下绑定的wifi锁的开锁记录。
 *@param wifiSN     wifi模块SN。
 *@param index 第几页记录，从1开始。一页20条数据。
 *@param success 请求成功执行的回调，news是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getWifiLockBindedDeviceOperationWithWifiSN:(NSString *)wifiSN index:(int)index success:(nullable void(^)(NSArray<KDSWifiLockOperation *> * operations))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 获取账号下绑定wifi锁的报警记录。
 *@param wifiSN    wifi模块SN。
 *@param index 第几页记录，从1(0和1返回的数据是一样的)开始。一页20条数据。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getWifiLockBindedDeviceAlarmRecordWithWifiSN:(NSString *)wifiSN index:(int)index success:(nullable void(^)(NSArray<KDSWifiLockAlarmModel *> *models))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;
/**
 *@abstract 获取账号下绑定wifi锁的开锁次数。
 *@param wifiSN    wifi模块SN。
 *@param index 第几页记录，从1(0和1返回的数据是一样的)开始。一页20条数据。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getWifiLockBindedDeviceOperationCountWithUid:(NSString *)uid wifiSN:(NSString *)wifiSN index:(int)index success:(nullable void(^)(int count))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 检查wifi锁/模块是否需要升级

 @param serialNumber 门锁eSN号
 @param customer 客户代号，1：凯迪仕 、2：小凯 、3：桔子物联、 4：飞利浦
 @param version 蓝牙版本号
 @param devNum 请求的模块类型,1：主模块  2：算法模块 、3：相机模块（空：默认1）、 4：协议栈
 @param success 请求成功执行的回调
 @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
 @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
 @return 当前的请求任务
 */
-(NSURLSessionDataTask *)checkWiFiOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersion:(NSString *)version withDevNum:(int)devNum success:(void (^)(id _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;


///检查wifi锁/模块是否需要升级 多固件
/// @param serialNumber 门锁eSN号
/// @param customer 客户代号，1：凯迪仕 、2：小凯 、3：桔子物联、 4：飞利浦
/// @param versions   蓝牙版本号
/// @param success 请求成功执行的回调
/// @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
/// @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的@return 当前的请求任务
// 检查多固件升级
-(NSURLSessionDataTask *)checkWiFiMUOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersions:(NSArray *)versions  success:(void (^)(id _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;
/**
 确认wifi锁/模块升级

 @param serialNumber 门锁eSN号
 @param data OTA数据
 @param success 请求成功执行的回调
 @param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg
 @param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的
 @return 当前的请求任务
 */

-(NSURLSessionDataTask *)wifiDeviceOTAWithSerialNumber:(NSString *)serialNumber withOTAData:(NSDictionary *)data success:(nullable void(^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;

/**
 *@abstract 获取设备联动开关信息。
 *@param wifiSN    wifi模块SN。
 *@param uid 用户标识。
 *@param success 请求成功执行的回调，models是返回的记录数组，有可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getSwitchInfoWithWifiSN:(NSString *)wifiSN userUid:(NSString *)uid success:(nullable void(^)(NSDictionary * obj))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

///  多固件升级确认
/// @param serialNumber  产品号
/// @param data  字典数组
/// @param success   成功时的回调
/// @param errorBlock  错误回调
/// @param failure    失败回调;
-(NSURLSessionDataTask *)wifiDeviceOTAWithSerialNumbermutip:(NSString *)serialNumber withOTAData:(NSDictionary *)data success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure;
@end


NS_ASSUME_NONNULL_END

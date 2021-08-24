//
//  KDSMQTTManager+Server.h
//  KaadasLock
//
//  Created by orange on 2019/7/8.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"
#import "KDSDeviceHangerModel.h"
NS_ASSUME_NONNULL_BEGIN

/// MQTT工具服务器接口分类。
@interface KDSMQTTManager (Server)

/**
 *@brief 绑定网关。第一个绑定网关的账号默认为管理员账号，其它账号再次绑定此网关需要管理员账号同意。
 *@param sn 网关序列号。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(812:通知管理员确认，813:已绑定，814:网关不存在，414:米米网注册失败，946:米米网绑定网关失败，871:服务器异常，401:参数不正确，-1001：请求超时)；error为nil且success为YES表示绑定成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)bindGateway:(NSString *)sn completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 解绑网关。将网关从账户下删除。如果管理员账号删除了网关(实时)，那么其它账号对应下的网关也会删除，但是会有延时。
 *@param gateway The gateway which unbinding。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示解绑成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)unbindGateway:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 测试解绑网关。暂时用做把网关变成网关套装的s方式。
 *@note 重要！解绑成功时服务器只返回了方法和结果，没有返回其它数据。因此连续调用此方法时，并不知道回调解绑的是哪个网关。
 *@param gateway The gateway which unbinding。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示解绑成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)testunbindGateway:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 获取账号下绑定的网关。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；成功时models不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getGatewayList:(nullable void(^)(NSError * __nullable error, NSArray<GatewayModel *> * __nullable models))completion;

/**
 *@brief 获取账号下绑定的网关、网关下绑定的设备和账号下绑定的蓝牙锁。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，819获取失败，其它没有给出错误码)；成功时gws和bles不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getGatewayAndDeviceList:(void (^)(NSError * _Nullable, NSArray<GatewayModel *> * _Nullable, NSArray<MyDevice *> * _Nullable, NSArray<KDSWifiLockModel *> * _Nullable, NSArray<KDSProductInfoList *> * _Nullable, NSArray<KDSDeviceHangerModel *> *hangerList))completion;

/**
 *@brief 网关注册并绑定米米网。
 *@param gateway 要注册并绑定的网关。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(414:不是注册账户，946:绑定失败，711:注册用户失败，401:参数错误，-1001:请求超时)；error为nil且success为YES表示解绑成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gatewayRegisterAndBindMeme:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 获取网关下绑定的设备，包括锁和猫眼等。MQTT服务器接口。
 *@param gateway The gateway which getting binded devices。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；成功时models不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getDeviceListBindToGateway:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, NSArray<GatewayDeviceModel *> * __nullable models))completion;

/**
 *@brief 获取网关锁的开锁次数。
 *@param lock The lock which getting unlock times。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，819失败，其它无)；成功时times是开锁次数。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getUnlockTimesInLock:(GatewayDeviceModel *)lock completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSInteger times))completion;

/**
 *@brief 修改设备昵称。
 *@param device 要修改昵称的设备。此模型的nickName属性必须包含最新的昵称。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；如果error为nil且success为NO表明请求超时了；error为nil且success为YES表示修改成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)updateDeviceNickname:(GatewayDeviceModel *)device completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 获取账号下的审批网关。当前账号首次绑定网关后，其它账号再次绑定相同的网关时需要当前账号审批，此接口即获取其它账号绑定的申请。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；成功时models不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getGatewayApproveList:(nullable void(^)(NSError * __nullable error, NSArray<ApproveModel *> * __nullable models))completion;

/**
 *@brief 管理员审批网关绑定操作。
 *@param model 待审批的网关。
 *@param status 审批状态，2通过，3拒绝。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示修改成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)approveGateway:(ApproveModel *)model status:(int)status completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 获取设备开锁记录。
 *@param device 要获取开锁记录的设备。
 *@param page 记录页数，从1开始，每页20条记录。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；成功时records不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getDeviceUnlockRecords:(GatewayDeviceModel *)device atPage:(int)page completion:(nullable void(^)(NSError * __nullable error, NSArray<KDSGWUnlockRecord *> * __nullable records))completion;
/**
 *@brief 获取设备预警信息记录。
 *@param device 要获取预警信息记录的设备。
 *@param page 记录页数，从1开始，每页20条记录。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；成功时records不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getDeviceAlarmList:(GatewayDeviceModel *)device atPage:(int)page completion:(nullable void(^)(NSError * __nullable error, NSArray<KDSAlarmModel *> * __nullable records))completion;

/**
 *@brief 网关升级。升级结果应该以上报事件为准。
 *@param params 升级的参数，直接传入升级子事件(MQTTSubEventOTA)的参数即可。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示命令成功。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)otaWithParams:(NSDictionary *)params completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 管理员账号获取网关的授权用户。
 *@param gw 网关。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，819获取失败)；成功时users返回用户列表。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getGatewayUsers:(GatewayModel *)gw completion:(nullable void(^)(NSError * __nullable error, NSArray<KDSGWUser *> * __nullable users))completion;

/**
 *@brief 管理员账号删除网关的授权用户。
 *@param user 网关的授权用户
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示命令成功。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)deleteGatewayUser:(KDSGWUser *)user completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 分享/取消分享 设备/修改分享用户昵称（同一个接口不用参数）。
 *@param gw 分享的网关模型
 *@param device 分享的设备模型
 *@param userAccount 被分享的账号（手机号码、邮箱）
 *@param userNickname 分享设备的时候可以为空，修改分享用户的昵称即填写的userNickname，
 *@param shareflag 操作类型：1分享 0删除分享
 *@param type 设备类型：1网关 2网关挂载设备
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示命令成功。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)shareGatewayBindingWithGW:(GatewayModel *)gw device:(GatewayDeviceModel *)device userAccount:(NSString *)userAccount userNickName:(NSString *)userNickname shareFlag:(int)shareflag type:(int)type completion:(nullable void(^)(NSError * __nullable error,BOOL success))completion;

/**
 *@brief 获取设备分享用户列表.
 *@param gw 分享的所在网关模型
 *@param device 网关挂载设备SN
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示命令成功。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)getShareUserListWithGW:(GatewayModel *)gw device:(GatewayDeviceModel *)device completion:(nullable void(^)(NSError * __nullable error, NSArray<KDSAuthCatEyeMember *> * __nullable records))completion;
/**
 *@brief 修改网关昵称
 *@param gw 网关模型
 *@param nickname 网关昵称
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示命令成功。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)updateGwNickNameWithGw:(GatewayModel *)gw nickName:(NSString *)nickname completion:(nullable void(^)(NSError * __nullable error,BOOL success))completion;

/**
 *@brief 修改设备推送开关
 *@param gw 网关模型
 *@param device 网关挂载设备SN
 *@param pushSwitch 推送开关： 1(0默认开启)开启推送 2关闭推送
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code和domain分别是返回的错误码和消息(-1001请求超时，其它没有给出错误码)；error为nil且success为YES表示命令成功。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)updateDevPushSwitchWithGw:(GatewayModel *)gw device:(GatewayDeviceModel *)device pushSwitch:(int)pushSwitch completion:(nullable void(^)(NSError * __nullable error,BOOL success))completion;


@end

NS_ASSUME_NONNULL_END

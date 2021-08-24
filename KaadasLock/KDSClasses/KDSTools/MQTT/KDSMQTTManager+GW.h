//
//  KDSMQTTManager+GW.h
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"

NS_ASSUME_NONNULL_BEGIN

///MQTT工具网关分类。
@interface KDSMQTTManager (GW)

/**
 *@brief 获取网关记录的绑定设备列表。
 *@param gateway The gateway which getting device.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，返回设备列表。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetDeviceListBindToGateway:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable error, NSArray<KDSGWBindedDevice *> * _Nullable devices))completion;

/**
 *@brief 删除网关下绑定的设备。这个方法的结果是网关主动上报删除事件确定的。
 *@param gw The gateway which deleting device.
 *@param device 要删除的设备。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw deleteDevice:(GatewayDeviceModel *)device completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 获取网关的网络设置信息。
 *@param gateway The gateway which getting net setting。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时setting不为nil。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetNetSetting:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, KDSGWNetSetting * __nullable setting))completion;

/**
 *@brief 获取网关的无线设置信息。6030型号网关不支持。
 *@param gateway The gateway which getting WiFi setting.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时无线名称才不为nil。ssid为WiFi名称，pwd为WiFi密码(如果不加密可以为nil?)，encryption为WiFi加密方式(如果不加密可以为nil?)。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetWifiSetting:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, NSString * __nullable ssid, NSString * __nullable pwd, NSString * __nullable encryption))completion;

/**
 *@brief 获取网关协调器的信道，范围11~26。6030型号网关不支持。
 *@param gateway The gateway which getting channel.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，信道的值才有意义。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetChannel:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success, int channel))completion;

/**
 *@brief 获取网关电量，0~100。网关应该不用获取电量？测试时此接口返回405.
 *@param gateway The gateway which getting power.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，电量的值才有意义。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetDevicePower:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success, int power))completion;

/**
 *@brief 获取网关时间。接口有问题，测试返回405.
 *@param gateway The gateway which getting time.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，zone是时区，timestamp是距2000年的秒数。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetTime:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSString * __nullable zone, NSInteger timestamp))completion;

/**
 *@brief 获取网关米米网状态。接口有问题，测试返回405.6030型号网关不支持。
 *@param gateway The gateway which getting meme state。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，状态值表示为：0未知，1准备，2正在连接，3已连接，4已断开连接，5已验证，6未激活，7已激活。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetMemeState:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success, int state))completion;

/**
 *@brief 获取网关的统计信息。6030型号网关不支持。
 *@param gateway The gateway which getting statistic。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时stat不为nil。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetStat:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, KDSGWStat * __nullable stat))completion;

/**
 *@brief 获取pir静默参数。
 *@param gateway The gateway which getting pir。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；success为YES时，后面的参数才有意义。periodtime:监控周期(单位分钟)，threshold:一个周期触发次数，protecttime:保护期(单位分钟)，ust:静默时间(单位分钟)，maxprohibition:静默时间倍增最大次数，enable:是否启用静默策略。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gwGetPir:(GatewayModel *)gateway completion:(nullable void(^)(NSError * __nullable error, BOOL success, int periodtime, int threshold, int protecttime, int ust, int maxprohibition, BOOL enable))completion;

/**
 *@brief 设置网关网络。6030型号网关不支持。
 *@param gw The gateway which setting net setting。
 *@param lan 局域网地址，192.168.xxx.xxx之类。
 *@param mask 局域网子网掩码。255.255.255.0之类。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setNetLan:(NSString *)lan mask:(NSString *)mask completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置网关WiFi名称、密码以及加密方式。6030型号网关不支持。
 *@param gw The gateway which setting wifi setting。
 *@param ssid WiFi名称。
 *@param pwd WiFi密码。
 *@param encryption 加密方式，wpa/wpa2/wep/none。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setWiFiSSID:(NSString *)ssid pwd:(NSString *)pwd encryption:(NSString *)encryption completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置网关是否允许设备入网。锁是否已经入网要以网关上报的锁添加成功事件为准。这个方法有些设备会收到回复，有些设备不会回复。
 *@param gw 设备绑定的网关。
 *@param device 入网设备，zigbee、bluetooth、WiFi三种。v2.2文档只有zigbee一个值了.
 *@param enable 网关接口只有设置允许入网，没有禁止入网，因此此参数暂时被忽略。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setDeviceAccess:(NSString *)device enable:(BOOL)enable completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置网关协调器信道。6030型号网关不支持。
 *@param gw The gateway which setting channel。
 *@param channel 信道值，11~26。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setChannel:(int)channel completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置网关时间。这个接口先不要使用。
 *@param gw The gateway which setting time.
 *@param time 距70年1月1日0时0分0秒的秒数。此参数计算相同时区的时间差即可?
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setTime:(NSInteger)time completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置pir静默参数。这个接口添加时从v2.2文档开始。
 *@param gw The gateway which setting pir。
 *@param enable 是否启用静默策略。
 *@param period 监控周期，单位分钟，1~60。
 *@param threshold 阈值，一个周期内触发次数，1~60.
 *@param ptime 保护期持续时间，表示按下猫眼前面板按键或呼叫按钮或呼叫唤醒了一次，保护期内不限制pir触发，时间单位分钟，1~60。
 *@param ust 静默时间，单位分钟，1~60。
 *@param mprohibit 静默时间倍增最大次数，1~60.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setPirEnable:(BOOL)enable withPeriod:(int)period threshold:(int)threshold protectTime:(int)ptime ust:(int)ust maxProhibit:(int)mprohibit completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

@end

NS_ASSUME_NONNULL_END

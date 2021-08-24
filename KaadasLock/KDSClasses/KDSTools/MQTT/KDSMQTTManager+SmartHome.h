//
//  KDSMQTTManager+SmartHome.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSMQTTManager (SmartHome)

/**
 *@brief 增加/更新一个设备联动（场景）。
 *@param gw 场景所在的网关。
 *@param contion  场景（pushNotification状态，time策略时间，trigger设备唯一标识，conditions，actions）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setTriggerActions:(NSDictionary *)actions time:(NSDictionary *)time trigger:(NSDictionary *)trigger contion:(NSDictionary *)contion completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 删除一个设备联动（场景）。
 *@param gw 场景所在的网关。
 *@param triggerId  场景（要删除的场景的trigger设备唯一标识，）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw delTriggerId:(NSString *)triggerId completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 查询一个设备联动（场景）。
 *@param gw 场景所在的网关。
 *@param triggerId  场景（要删除的场景的trigger设备唯一标识，）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw getTriggerId:(NSString *)triggerId completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 上传一个联动事件（场景）。
 *@param gw 场景所在的网关。
 *@param triggerId  场景（要删除的场景的trigger设备唯一标识，）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw upDataTriggerId:(NSString *)triggerId completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

//----------------------单火开关涉及到的接口------------------------------
/**
*@brief ②　添加锁外围（开关）
*@param wf Wi-Fi锁的模型 。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)addSwitchWithWf:(KDSWifiLockModel *)wf completion:(nullable void(^)(NSError * __nullable error,BOOL success, NSInteger typeValue,NSString * macaddr,NSTimeInterval switchBindTime))completion;
/**
*@brief 锁外围（开关）设置 Wi-Fi锁的外围设备。
*@param stParams 开关（一、二、三、四健）参数的对应数组。
*@param wf Wi-Fi锁的模型 。
*@switchEn  生效设置(策略总开关，on/off)
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setSwitchWithWf:(KDSWifiLockModel *)wf stParams:(NSArray *)stParams switchEn:(int)switchEn completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
*@brief  ①　查询锁外围（开关）
*@param  wf 单火开关相关锁的设备模型。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)getSwitchWithWf:(KDSWifiLockModel *)wf completion:(nullable void(^)(NSError * __nullable error,NSArray<KDSDevSwithModel *> * devSwithModel))completion;


/*
 **********************视频锁相关的服务器下发的接口****************
 */

/**
*@brief  1.设置门锁
*@param  wf 视频视频相关锁的设备模型。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setLockWithWf:(KDSWifiLockModel *)wf completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
*@brief  1.设置门锁语言：中文/英文
*@param  wf 视频视频相关锁的设备模型。
*@param language 门锁语言 zh/en。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setLockLanguageWithWf:(KDSWifiLockModel *)wf language:(NSString *)language completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
*@brief  1.设置门锁通用模式/安全模式
*@param  wf 视频视频相关锁的设备模型。
*@param  safeMode  安全模式：0通用模式 1安全模式。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setLockSafaModeWithWf:(KDSWifiLockModel *)wf safeMode:(int)safeMode completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
*@brief  1.设置门锁语音/静音
*@param  wf 视频视频相关锁的设备模型。
*@param  volume  语音模式：0语音模式 1静音模式。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setLockVolumeWithWf:(KDSWifiLockModel *)wf volume:(int)volume completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
*@brief  1.设置门锁自动模式/手动模式
*@param  wf 视频视频相关锁的设备模型。
*@param  amMode 模式：0自动模式 1手动模式
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setLockAmModeWithWf:(KDSWifiLockModel *)wf amMode:(int)amMode completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
*@brief  设置视频长/短连接：keep_alive_status（长连接状态：0关闭，1开启）snooze_start_time（开始时间）snooze_end_time（结束时间）keep_alive_snooze（重复日期）
*@param  wf 视频视频相关锁的设备模型。
*@param  keep_alive_status 长连接状态(0/1).
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setCameraVideoConnectionSettingsWithWf:(KDSWifiLockModel *)wf alive_time:(NSDictionary *)alive_time keep_alive_status:(int)keep_alive_status completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
*@brief  设置PIR：stay_status（开关状态：0关闭，1开启）stay_time（徘徊时间检测范围10-60秒）pir_sen（PIR灵敏度范围0-100
*@param  wf 视频视频相关锁的设备模型。
*@param  stay_status  徘徊检测开关状态(0/1)。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setCameraPIRSensitivitySettingsWithWf:(KDSWifiLockModel *)wf setPir:(NSDictionary *)setPir stay_status:(int)stay_status completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;


///  设置开门的方向
/// @param wf  wifimodel
/// @param value  参数设置
/// @param completion  完成时的回调
- (KDSMQTTTaskReceipt *)setOpenDirectionWithWf:(KDSWifiLockModel *)wf value:(int)value completion:(void (^)(NSError * _Nullable, BOOL))completion;


///  设置开门力量
/// @param wf  wifimodel
/// @param value  参数设置
/// @param completion 完成回调
- (KDSMQTTTaskReceipt *)setOpenForceWithWf:(KDSWifiLockModel *)wf value:(int)value completion:(void (^)(NSError * _Nullable, BOOL))completion;


///   设置上锁的方式
/// @param wf   设置wifi 的model
/// @param value   上锁方式
/// @param completion  完成的回调
- (KDSMQTTTaskReceipt *)setLockingMethodWithWf:(KDSWifiLockModel *)wf value:(int)value completion:(void (^)(NSError * _Nullable, BOOL))completion;



///   设置人脸徘徊开关
/// @param wf   设置wifi 的model
/// @param hoverAlarm   徘徊报警开关
/// @param hoverAlarmLevel   徘徊报警敏度设置
/// @param completion  完成的回调
- (KDSMQTTTaskReceipt *)setLockWithWf:(KDSWifiLockModel *)wf hoverAlarm:(NSUInteger) hoverAlarm hoverAlarmLevel:(NSUInteger) hoverAlarmLevel completion:(void (^)(NSError * _Nullable, BOOL))completion;

/**
*@brief  设置显示屏亮度
*@param  wf 视频视频相关锁的设备模型。
*@param  brightness  显示屏亮度 , 80 代表高亮，50 代表中等亮度，30 代表低亮
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setScreenBrightnessWithWf:(KDSWifiLockModel *)wf brightness:(int)brightness completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
*@brief  设置门铃呼叫时屏亮开关
*@param  wf 视频视频相关锁的设备模型。
*@param  lightUpSwitch  屏亮开关 , 0 : 关  ，1 ：开
*@param  lightTime  亮屏幕时间 , 单位秒
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setScreenLightWithWf:(KDSWifiLockModel *)wf lightUpSwitch:(int)lightUpSwitch lightTime:(int)lightTime completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
*@brief  设置音量水平
*@param  wf 视频视频相关锁的设备模型。
*@param  voiceLevel  音量水平 , 0 : 静音  ，1 ：中音量 ， 2 ：高音量
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setVoiceLevelWithWf:(KDSWifiLockModel *)wf voiceLevel:(int)voiceLevel completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

@end
NS_ASSUME_NONNULL_END

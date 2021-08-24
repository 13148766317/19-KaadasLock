//
//  KDSMQTTManager+DL.h
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"

NS_ASSUME_NONNULL_BEGIN

///MQTT工具门锁分类。
@interface KDSMQTTManager (DL)

/**
 *@brief 获取锁状态。dl door lock.
 *@param dl the door lock which getting state。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时状态值表示为：0未完全上锁，1已上锁，2未上锁。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetState:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int state))completion;

/**
 *@brief 获取锁密码和RFID基本信息 。dl door lock.
 *@param dl the door lock which getting info。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，info为返回的信息。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetKeyInfo:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, KDSGWLockKeyInfo * __nullable info))completion;

/**
 *@brief 获取锁播报语言。dl door lock.
 *@param dl the door lock which getting language。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时language:zh中文，en英文。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetLanguage:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, NSString * __nullable language))completion;

/**
 *@brief 获取锁播报音量。dl door lock.
 *@param dl the door lock which getting volume。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时volume:0静音，1低音，2高音。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetVolume:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int volume))completion;

/**
 *@brief 获取锁电量，0~100。
 *@param dl The door lock which getting power.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，电量的值才有意义。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetDevicePower:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int power))completion;

/**
 *@brief 获取锁时间。
 *@param dl The door lock which getting time.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，zone是时区(测试时发现返回的是个垃圾值localtime，可以当作是系统所在时区？)，timestamp是距2000年的秒数(标准0时区)。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetTime:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSString * __nullable zone, NSInteger timestamp))completion;


/**
 *@brief 获取锁最大日志条数。dl door lock.
 *@param dl the door lock which getting log number。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时返回最大日志条数。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetMaxLogNumber:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int number))completion;
/**
 *@brief 获取锁中指定索引的日志。dl door lock. See also dlGetMaxLogNumber:completion:
 *@param dl the door lock which getting logs。
 *@param idx1 the logs begin index, must between 1 and maxLogNumber.
 *@param idx2 the logs end index, must between 1 and maxLogNumber, also must equal to or greater than idx1?
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时返回请求的日志。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl getLogsBetweenIndex:(int)idx1 andIndex:(int)idx2 completion:(nullable void(^)(NSError * __nullable error, NSArray<NSString *> * __nullable logs))completion;

/**
 *@brief 获取锁设备参数，包括锁的Mac地址、固件、软件、硬件版本等。dl door lock.
 *@param dl the door lock which getting params。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时param是锁返回的参数模型。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetDeviceParams:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, KDSGWLockParam * __nullable param))completion;

/**
 *@brief 获取锁模式。dl door lock.
 *@param dl the door lock which getting mode。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时模式值表示为：0正常模式，1布防模式，2反锁模式。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetMode:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int mode))completion;

/**
 *@brief 获取锁密码的类型。dl door lock.
 *@param dl the door lock which getting user(password) type。
 *@param pwdNum 密码编号。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时模式值表示为：0永久密码，1年月日计划密码，2周计划密码，3管理员密码，4未授权密码，255等其它暂不支持。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl getPwdType:(int)pwdNum completion:(nullable void(^)(NSError * __nullable error, BOOL success, int type))completion;

/**
 *@brief 获取锁自动/手动上锁状态。dl door lock.
 *@param dl the door lock which getting a-m status。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时automatic表示是否处于自动模式状态(10秒)，否则表示处于手动模式状态。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetAMStatus:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, BOOL automatic))completion;

/**
 *@brief 开/关锁。锁开/关状态要以事件上报为准，回调的成功只是命令执行成功。只支持密码？
 *@param dl the door lock which being operated。
 *@param open YES开锁，NO关锁。
 *@param pwd 开/关锁密码。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl operateLock:(BOOL)open withPwd:(NSString *)pwd completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief set、get、clear keys of door lock. See also dlGetKeyInfo:completion:.
 *@param dl The door lock which keys are being managing。
 *@param action 0 means set, 1 means get, 2 means clear。
 *@param pwd If set and clear PIN, which is the managed password, otherwise can be nil。
 *@param number The password number, starting from 0, must less than maxpwdusernum.
 *@param type The key type. 1:PIN, 2:fingerprint, 3:card. Now only support PIN.
 *status  设置、删除的时候0表示成功，查询的时候0表示没有设置密码，1表示设置了密码
 *userType : 0 永久性密钥 : 1 策略密钥
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code代表：(1)、set:1就是失败了，2内存已满？，3重复，编号或密码已存在？；(2)、get:0编号没有设置密码；(3)、clear:非0删除失败；成功时error为nil且success为YES，v2.2文档已删除pwd参数，这里不作修改，仅标记此为无效参数。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl manageKey:(int)action withPwd:(nullable NSString *)pwd number:(int)number type:(int)type completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSString * __nullable status, NSString * __nullable userType))completion;

/**
 *@brief 设置锁播报语言。dl door lock.
 *@param dl the door lock which setting language。
 *@param language the language, maybe one of "zh", "en".
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setLanguage:(NSString *)language completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置锁播报音量。dl door lock.
 *@param dl the door lock which setting volume。
 *@param volume the volume, maybe one of 0, 1 and 2. 0 means mute, 1 means low volume, 2 means high volume.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setVolume:(int)volume completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置锁时间。
 *@param dl The door lock which setting time.
 *@param time 距70年1月1日0时0分0秒的秒数(需要加上当前时区和0时区的秒差)。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setTime:(NSInteger)time completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置、获取、删除年月日、周计划。设置密码->设置计划->设置用户(密码)类型。这个接口设置和获取都有问题。
 *@param dl The door lock which schedules are being managing。
 *@param action 0 means set, 1 means get, 2 means clear。
 *@param schedule The schedule. When set, all params are required. When get and clear, userId and scheduleId are required.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，当get且成功时schedule返回对应的计划。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl scheduleAction:(int)action withSchedule:(KDSGWLockSchedule *)schedule completion:(nullable void(^)(NSError * __nullable error, BOOL success, KDSGWLockSchedule * __nullable schedule))completion;

/**
 *@brief 设置锁布防模式。dl door lock.
 *@param dl the door lock which setting defence。
 *@param open If YES, open defence mode, otherwise close.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setDefence:(BOOL)open completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置锁布防模式。dl door lock.
 *@param dl the door lock which setting defence。
 *@param automatic If YES, open automatic mode, otherwise open manual mode.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setAutoMode:(BOOL)automatic completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置锁密码类型。dl door lock.v2.5增加。
 *@param dl the door lock which setting user(password) type。
 *@param type 密码类型，0永久密码，1年月日计划密码，2周计划密码，3管理员密码，4未授权访问密码，255等其它暂不支持。
 *@param pwdNum 要设置类型的密码的编号。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setPwdType:(int)type withPwdNum:(int)pwdNum completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 获取锁ZigBee信号强度，强度越接近0信号越好。dl door lock.此方法为测试接口。
 *@param dl The door lock which getting signal strength。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，signal返回信号强度(-100~0)。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)dlGetSignalStrength:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int signal))completion;

@end

NS_ASSUME_NONNULL_END

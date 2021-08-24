//
//  KDSMQTTManager+CY.h
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"

NS_ASSUME_NONNULL_BEGIN

///MQTT工具猫眼分类。
@interface KDSMQTTManager (CY)

/**
 *@brief 获取猫眼设备参数，包括猫眼的IP、Mac地址，MCU、软件、硬件版本等。cy cat eye.
 *@param cy the cat eye which getting params。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时param是锁返回的参数模型。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyGetDeviceParams:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, KDSGWCateyeParam * __nullable param))completion;

/**
 *@brief 获取猫眼设备电量，0~100。cy cat eye.
 *@param cy the cat eye which getting power。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时power是返回猫眼的电量。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyGetDevicePower:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, BOOL success, int power))completion;

/**
 *@brief 获取猫眼时间。
 *@param cy The cat eye which getting time.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，zone是时区，timestamp是距2000年的秒数。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyGetTime:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSString * __nullable zone, NSInteger timestamp))completion;

/**
 *@brief 获取猫眼SD卡状态。v1.4
 *@param cy The cat eye which getting sd card status.
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES，status返回猫眼状态(0表示SD卡不存在，1表示存在)。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyGetSDCardStatus:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, BOOL success, int status))completion;

/**
 *@brief 设置猫眼时间。
 *@param cy The cat eye which setting time.
 *@param time 距70年1月1日0时0分0秒的秒数。此参数计算相同时区的时间差即可?
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setTime:(NSInteger)time completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼铃声。参考cyGetDeviceParams获取到的参数。cy cat eye.
 *@param cy the cat eye which setting bell。
 *@param bell 铃声的编号？
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setBell:(int)bell completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼铃声音量。参考cyGetDeviceParams获取到的参数。cy cat eye.
 *@param cy the cat eye which setting volume。
 *@param volume 0高音，1低音，2正常音，3静音。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setVolume:(NSString*)volume completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼门铃pir功能开/关。cy cat eye.
 *@param cy the cat eye which setting pir function switch。
 *@param enable 1开启，0关闭。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setPirEnable:(NSString*)enable completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼视频分辨率。cy cat eye.目前支持2种分辨率960x540和 1280x720
 *@param cy the cat eye which setting resolution。
 *@param resolution 分辨率，格式形如"1920x1080"。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setResolution:(NSString *)resolution completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼留言功能开/关。cy cat eye.
 *@param cy the cat eye which setting message function switch。
 *@param enable YES开启，NO关闭。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setMessageEnable:(BOOL)enable completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 重启猫眼。cy cat eye.
 *@param cy the cat eye which resetting。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyResetDevice:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 唤醒猫眼。cy cat eye.
 *@param cy the cat eye which waking up。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyWakeup:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 开启猫眼FTP服务。cy cat eye.v2.2的网关文档修改了这个接口。
 *@param cy the cat eye which opening ftp。
 *@param relay 是否启用relay服务器。如果否，网关使用米米网。
 *@param ip relay服务器的ip，可以是域名或者ip地址。如果为空，网关使用默认的地址。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，ip和port返回ftp服务的地址和端口号。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy openFtpRelay:(BOOL)relay withAddress:(nullable NSString *)ip completion:(nullable void(^)(NSError * __nullable error, NSString * __nullable ip, NSInteger port))completion;

/**
 *@brief 设置猫眼铃声次数。cy cat eye.
 *@param cy The cat eye which setting bell times。
 *@param times 铃声的次数。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setBellTimes:(int)times completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼pir徘徊检测频率。猫眼在seconds秒内触发至少times次才拍照上报pir触发事件。cy cat eye. v1.4
 *@param cy The cat eye which setting bell times。
 *@param times 触发的次数，<= senconds * 0.5，硬件系统默认3。
 *@param seconds 触发的时间段，单位秒，3~15之间，硬件系统默认6。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setPirWanderTimes:(int)times inSeconds:(int)seconds completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 设置猫眼的黑白夜视切换模式，
 *@param AutomaticModel  0为自动模式，1为手动切换白天模式，2为手动切换黑夜模式
 *@param photoresistorHacquisition 光敏电阻采集ADC值高于这个值时，且在自动模式下，切换为白天模式
  *@param photoresistorLacquisition 光敏电阻采集ADC值低于这个值时，且在自动模式下，切换为黑夜模式
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setCamInfrared:(int)AutomaticModel photoresistorHAcquisition:(int)photoresistorHacquisition photoresistorLacquisition:(int)photoresistorLacquisition completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
 *@brief 获取猫眼的黑白夜视切换模式，
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)cyGetCamInfrared:(GatewayDeviceModel *)cy completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSString * automaticModel))completion;

@end

NS_ASSUME_NONNULL_END

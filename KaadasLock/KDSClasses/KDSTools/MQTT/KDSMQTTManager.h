//
//  KDSMQTTManager.h
//  KaadasLock
//
//  Created by orange on 2019/4/12.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"
#import "KDSMQTTTask.h"
#import "KDSMQTTOptions.h"
#import "GatewayModel.h"
#import "GatewayDeviceModel.h"
#import "ApproveModel.h"
#import "KDSGWUnlockRecord.h"
#import "KDSAlarmModel.h"
#import "KDSGWBindedDevice.h"
#import "KDSGWNetSetting.h"
#import "KDSGWLockKeyInfo.h"
#import "KDSGWLockParam.h"
#import "KDSGWCateyeParam.h"
#import "KDSGWLockSchedule.h"
#import "KDSGWStat.h"
#import "KDSJoinGWEvent.h"
#import "KDSGWUser.h"
#import "MyDevice.h"
#import "KDSAuthCatEyeMember.h"
#import "KDSWifiLockModel.h"
#import "KDSProductInfoList.h"
#import "KDSDevSwithModel.h"
#import "KDSDeviceHangerModel.h"
FOUNDATION_EXTERN NSString * _Nonnull const KDSHttpTokenExpiredNotification;

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 统一管理MQTT接口的类。
 */
@interface KDSMQTTManager : NSObject

/**
 *@abstract 单例。此类内部功能实现会依赖KDSUserManager单例，登录用户改变会自动创建新的服务器连接，会自动处理前后台状态。
 *@return instance。
 */
+ (instancetype)sharedManager;

///返回MQTT服务器是否已连接，如果没有连接，查询此属性后也会自动连接。
@property (nonatomic, assign, readonly) BOOL connected;
///服务器当前时间，距70年的本地时间秒数。这个属性暂时只有请求MQTT服务器相关接口的时候才会更新。
@property (nonatomic, assign, readonly) NSTimeInterval serverTime;

///连接MQTT服务器，此方法一般不用手动调用。调用其它方法时，如果MQTT服务器还没有连接，则会自动进行连接。
- (void)connect;

///关闭MQTT服务器的连接。
- (void)close;

#pragma mark - MQTT服务器相关接口。
/**
 *@brief 根据服务器功能接口和参数创建一个MQTT任务并执行。中间实现。
 *@param func 请求的功能。
 *@param funcParams 服务器功能接口所需的公共参数外的参数。公共参数(uid、msgId等)在此方法内添加。
 *@param completion 请求结束执行的回调。如果返回码不是200或者字段错误，则出错，否则error应该为空，result为返回的data字段值。
 *@return The task.
 */
- (KDSMQTTTask *)performServerFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams completion:(nullable void(^)(NSError * __nullable error, BOOL success, id __nullable result))completion;

#pragma mark - 网关相关(MQTT服务器直接转发)接口。
/**
 *@brief 根据网关功能和参数创建一个MQTT任务并执行。中间实现。
 *@param gw 请求功能执行的网关。
 *@param func 请求的功能。
 *@param funcParams 网关功能所需的参数。对于GET请求来说一般为空，对于SET请求来说一般不为空。一般为ZigBee文档参数的params字段。
 *@param returnData 一般为空。设置这个参数是因为网关文档其中一个接口参数竟然放到returnData字段了，真是见鬼。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
 *@return The task.
 */
- (KDSMQTTTask *)gw:(GatewayModel *)gw performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;
/**
 *@brief 根据网关功能和参数创建一个MQTT任务并执行。中间实现。
 *@param gw 请求功能执行的网关。
 *@param func 请求的功能。
 *@param funcScene_rule 网关场景所需的参数。。
 *@param returnCode 一般为200。。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
 *@return The task.
 */
- (KDSMQTTTask *)gw:(GatewayModel *)gw performFunc:(NSString *)func withScene_rule:(nullable NSDictionary *)funcScene_rule returnCode:(nullable NSDictionary *)returnCode completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;

/**
 *@brief 根据网关功能和参数创建一个MQTT任务并执行。中间实现。
 *@param gw 请求功能执行的网关。
 *@param func 请求的功能。
 *@param returnCode 一般为200。。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
 *@return The task.
 */
- (KDSMQTTTask *)gw:(GatewayModel *)gw performFuncAndNoScene_rule:(NSString *)func triggerId:(NSString *)triggerId returnCode:(nullable NSDictionary *)returnCode completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;

/**
 *@brief 设置网关是否允许猫眼接入。接入猫眼时，超时时间方法内设置为5分钟。这个接口不按规范把参数放到params字段。结果以事件上报为准。
 *@param gw 设备绑定的网关。
 *@param enable 是否允许猫眼接入。
 *@param sn 猫眼的sn。
 *@param mac 猫眼的Mac。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return The receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setCateyeAccessEnable:(BOOL)enable withCateyeSN:(NSString *)sn mac:(NSString *)mac completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

#pragma mark - 锁相关(MQTT服务器直接转发)接口
/**
 *@brief 根据网关门锁功能和参数创建一个MQTT任务并执行。中间实现。
 *@param dl 请求功能执行的网关门锁。
 *@param func 请求的功能。
 *@param funcParams 网关功能所需的参数。对于GET请求来说一般为空，对于SET请求来说一般不为空。一般为ZigBee文档参数的params字段。
 *@param returnData 一般为空。设置这个参数是因为网关文档其中一个接口参数竟然放到returnData字段了，真是见鬼。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
 *@return The receipt of the task.
 */
- (KDSMQTTTask *)dl:(GatewayDeviceModel *)dl performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;
/**
*@brief 根据Wi-Fi门锁功能和参数创建一个MQTT任务并执行。中间实现。
*@param wf 请求功能执行的Wi-Fi门锁。
*@param func 请求的功能。
*@param funcParams 网关功能所需的参数。对于GET请求来说一般为空，对于SET请求来说一般不为空。一般为ZigBee文档参数的params字段。
*@param returnData 一般为空。设置这个参数是因为网关文档其中一个接口参数竟然放到returnData字段了，真是见鬼。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
*@return The receipt of the task.
*/
- (KDSMQTTTask *)wf:(KDSWifiLockModel *)wf performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;
/**
*@brief 根据Wi-Fi门锁功能和参数创建一个MQTT任务并执行。中间实现。
*@param wf 请求功能执行的Wi-Fi门锁。
*@param func 请求的功能。
*@param funcParams 网关功能所需的参数。对于GET请求来说一般为空，对于SET请求来说一般不为空。一般为ZigBee文档参数的params字段。
*@param returnData 一般为空。设置这个参数是因为网关文档其中一个接口参数竟然放到returnData字段了，真是见鬼。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
*@return The receipt of the task.
*/
- (KDSMQTTTask *)xmMediaWf:(KDSWifiLockModel *)wf performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;

#pragma mark - 猫眼相关(MQTT服务器直接转发)接口。
/**
 *@brief 根据网关猫眼和参数创建一个MQTT任务并执行。中间实现。
 *@param cy 请求功能执行的网关猫眼。
 *@param func 请求的功能。
 *@param funcParams 网关功能所需的参数。对于GET请求来说一般为空，对于SET请求来说一般不为空。一般为ZigBee文档参数的params字段。
 *@param returnData 一般为空。设置这个参数是因为网关文档其中一个接口参数竟然放到returnData字段了，真是见鬼。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为网关返回的returnData字段值。
 *@return The task.
 */
- (KDSMQTTTask *)cy:(GatewayDeviceModel *)cy performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;

#pragma mark 晾衣架接口
/**
 *@brief 根据晾衣机和参数创建一个MQTT任务并执行。中间实现。
 *@param hanger 请求的晾衣机。
 *@param func 请求的功能。
 *@param funcParams 功能所需的参数。
 *@praram enableTimeout 是否开启超时回调，晾衣机设置是没有回复的，可以不启用
 *@param returnData 一般为空。
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil，success为YES，response为返回的returnData字段值。
 *@return The task.
 */
- (KDSMQTTTask *) hanger:(KDSDeviceHangerModel *)hanger  performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams enableTimeout:(BOOL) enableTimeout completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion;

#pragma mark - 删除队列中的MQTT任务。
/**
 *@abstract 根据各个方法返回的凭证删除对应的任务。
 *@param receipt The receipt returned by the method.
 *@return If cancel success return YES, otherwise NO. When NO, generally the receipt is wrong or the task has completed.
 */
- (BOOL)cancelTaskWithReceipt:(KDSMQTTTaskReceipt *)receipt;

#pragma mark - 通知
///MQTT服务器上报/转发网关事件的通知。该通知包含很多子事件，为方便外面统一调用，在userInfo中使用MQTTEventKey获取到不同的子事件值，然后各个页面处理需要处理的子事件。如有需要，使用MQTTEventParamKey或其它key获取子事件的参数，详情参考KDSMQTTOptions.h
FOUNDATION_EXTERN NSString * const KDSMQTTEventNotification;

@end

NS_ASSUME_NONNULL_END

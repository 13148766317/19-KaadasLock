//
//  KDSMQTTTask.h
//  KaadasLock
//
//  Created by orange on 2019/4/12.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTMessage.h>

@class KDSMQTTTaskReceipt;

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract MQTT请求任务。该类由KDSMQTTManager内部创建，一般不从其它地方创建。
 */
@interface KDSMQTTTask : NSObject

///task receipt, which identify different tasks.
@property (nonatomic, strong) KDSMQTTTaskReceipt *receipt;
///task timeout, the task would failed if over timeout, default 25s.
@property (nonatomic, assign) int timeout;
///请求报文的有效载荷，设置时可以为空，获取时不为空。
@property (nonatomic, strong, null_resettable) NSData *payload;
///收到MQTT服务器回应后执行的回调，回调参数result视不同情况为不同的值，如果是直接面向服务器的publish请求，一般为返回的字典的data字段值，留到不同方法中解析。如果超时或者请求失败(ack返回错误)，则为nil。如果因为ack返回错误，则回调参数error是MQTTSection请求封装的错误，或者超时的code为-1001。
@property (nonatomic, copy, nullable) void(^responseBlock)(NSError * __nullable error, id __nullable result);

/**
 * 不使用超时定时器
 */
- (instancetype)initDisableTimer;

@end

/**
 *@abstract 区分每个MQTT请求任务的凭证。该类由KDSMQTTManager内部创建，一般不从其它地方创建。
 */
@interface KDSMQTTTaskReceipt : NSObject

///任务的类型。这里封装后一般只使用3种命令，即MQTTPublish、MQTTSubscribe和MQTTUnsubscribe。
@property (nonatomic, assign, readonly) MQTTCommandType type;
///任务的主题。
@property (nonatomic, strong, readonly) NSString *topic;
///任务的func.
@property (nonatomic, strong, nullable, readonly) NSString *func;
///服务等级，初始化为2。
@property (nonatomic, assign) MQTTQosLevel qos;
///报文标识符，如果需要。packet identifier, if required. See MQTTMessage mid also.
@property (nonatomic, assign) UInt16 pid;
///消息id，区分每一条消息。
@property (nonatomic, assign) NSInteger msgId;

///根据命令类型、主题和功能参数创建一个实例。
- (instancetype)initWithCommand:(MQTTCommandType)cmd topic:(NSString *)topic qos:(MQTTQosLevel)qos func:(nullable NSString *)func NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

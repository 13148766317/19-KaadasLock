//
//  KDSMQTTManager.m
//  KaadasLock
//
//  Created by orange on 2019/4/12.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"
#import <MJExtension/MJExtension.h>
#import <MQTTClient/MQTTClient.h>
#import "KDSDeviceHangerState.h"
#import "KDSUserManager+DeviceStateUpdate.h"

static NSString * const kFunc = @"func";
//wifi id
static NSString * const kHangerWifiId = @"wfId";
//晾衣架设备类型
static NSString * const kHangerDevTypeValue = @"KdsMxchipHanger";
//设备类型
static NSString * const kDevType = @"devtype";
//userid
static NSString * const kUserId = @"userId";

//事件类型字典key
#define kEventType @"eventtype"
//func字段字典key
#define kResultFunc @"func"
//晾衣机上报状态事件
#define kHangerEventHangerState @"HangerState"
//晾衣机上报参数事件
#define kHangerEventHangerInf @"HangerInf"
//晾衣机获取状态功能点
#define kHangerGetAllStatus @"getAllStatus"
//晾衣机回复参数字典key
#define kHangerReplyParams   @"params"

NSString * const KDSMQTTEventNotification = @"KDSMQTTEventNotification";

@interface KDSMQTTManager () <MQTTSessionDelegate>

///mqtt session.
@property (nonatomic, strong) MQTTSession *mqttSession;
///MQTTTask queue。用msgId区分每一个任务，服务器的msgId类型是NSNumber，网关的msgId类型是NSString。
@property (nonatomic, strong) NSMutableArray<KDSMQTTTask *> *tasks;
///uid
@property (nonatomic, strong, readonly) NSString *uid;
///发给网关参数带的消息id，区分每条消息的唯一性。从1开始，每次发送增加1.
@property (nonatomic, assign) NSInteger msgId;
///Indicate whether client has subscribed the topic.
@property (nonatomic, assign) BOOL subscribed;

@end

@implementation KDSMQTTManager

+ (instancetype)sharedManager
{
    static KDSMQTTManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSMQTTManager alloc] init];
        _manager.tasks = [NSMutableArray array];
        _manager.msgId = 1;
        _manager.subscribed = NO;
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    });
    return _manager;
}

- (NSString *)uid
{
     
    return [KDSUserManager sharedManager].user.uid ?: @"";
}

#pragma mark - 内部接口。
///根据KDSUserManager单例user属性连接MQTT服务器。返回是否已连接。
- (BOOL)internalConnect
{
    KDSUser *user = [KDSUserManager sharedManager].user;
    if (!user || !user.token)
    {
        [self internalClose];
        return NO;
    }
    MQTTCFSocketTransport *transport = (MQTTCFSocketTransport *)self.mqttSession.transport;
    /*MQTTCFSocketEncoder *enc = [transport valueForKey:@"encoder"];
     BOOL socketClosed = enc.stream.streamStatus<NSStreamStatusOpening || enc.stream.streamStatus>NSStreamStatusAtEnd;*/
    BOOL connected = self.mqttSession.status == MQTTSessionStatusConnected;
    BOOL connecting = self.mqttSession.status == MQTTSessionStatusConnecting;
    if ((![self.mqttSession.userName isEqualToString:self.uid] || ![self.mqttSession.password isEqualToString:user.token]) || !(connecting || connected))
    {
        connected = NO;
        [self internalClose];
        if (!self.mqttSession)
        {
            self.mqttSession = [[MQTTSession alloc] init];
            transport = [[MQTTCFSocketTransport alloc] init];
            transport.host = [[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigMqttServer];
            transport.port = kMQTTPort;
            self.mqttSession.transport = transport;
            self.mqttSession.keepAliveInterval = 5;
            self.mqttSession.delegate = self;
            [MQTTLog setLogLevel:DDLogLevelDebug];
        }
        self.mqttSession.userName = self.uid;
        self.mqttSession.clientId = [NSString stringWithFormat:@"app:%@", self.uid];
        self.mqttSession.password = user.token;
        [self.mqttSession connect];
    }
    return connected;
}

///关闭MQTT服务器的连接。@note 注意，现时不能统一在这里移除队列任务，否则会造成没有连接前添加的任务全部被移除了。
- (void)internalClose
{
     
    [self.mqttSession disconnect];
    self.subscribed = NO;
}

#pragma mark  通知相关方法。
///进入后台断开MQTT连接。@note 让MQTT库自动管理连接，19.06.28
- (void)appDidEnterBackground:(NSNotification *)noti
{
    //[self internalClose];
}

///激活时连接MQTT。
- (void)appDidBecomeActive:(NSNotification *)noti
{
    [self internalConnect];
}

///网络状态改变的通知。
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    NSNumber *number = noti.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = number.integerValue;
    switch (status)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self internalConnect];
            break;
            
        default:
            break;
    }
}

#pragma mark  创建、执行、处理MQTT任务相关方法。
/**
 *@abstract Create an mqtt task and add it to the queue. Before return, the task has been performed.
 *@param params The task's payload JSON params.
 *@param type The task's type, @see See MQTTCommandType.
 *@param topic The task's topic.
 *@param qos The task's qos. This param is not used now.
 *@return a task.
 */
- (KDSMQTTTask *)createTaskWithParams:(nullable NSDictionary *)params MQTTCommandType:(MQTTCommandType)type topic:(NSString *)topic qos:(MQTTQosLevel)qos
{
    KDSMQTTTask *task = [KDSMQTTTask new];
//    KDSMQTTTaskReceipt *receipt = [[KDSMQTTTaskReceipt alloc] initWithCommand:type topic:topic func:params[kFunc]];
    KDSMQTTTaskReceipt *receipt = [[KDSMQTTTaskReceipt alloc] initWithCommand:type topic:topic qos:qos func:params[kFunc]];
    if ([params[kFunc] isEqualToString:@"setSwitch"] || [params[kFunc] isEqualToString:@"addSwitch"] || [params[kFunc] isEqualToString:@"getSwitch"]) {
        task.timeout = 60;
    }
    if (params)
    {
        id msgId = params[@"msgId"];
        if (!([msgId isKindOfClass:NSString.class] || [msgId isKindOfClass:NSNumber.class]))
        {
            if ([topic isEqualToString:MQTTServerTopic])
            {
                msgId = @([self nextMsgId]);
            }
            else
            {
                msgId = @([self nextMsgId]);
            }
            NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
            mParams[@"msgId"] = msgId;
            params = mParams;
        }
        receipt.msgId = [msgId integerValue];
        task.payload = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    }
    DDLogDebug(@"MQTT的发送到服务器的主题参数:%@",params);
    task.receipt = receipt;
    [self.tasks addObject:task];
    [self performTask:task];
    
    return task;
}

/**
 *@abstract Create an mqtt task and add it to the queue. Before return, the task has been performed.
 *@param params The task's payload JSON params.
 *@param type The task's type, @see See MQTTCommandType.
 *@param topic The task's topic.
 *@param qos The task's qos. This param is not used now.
 *@return a task.
 */
- (KDSMQTTTask *)createDisableTimerTaskWithParams:(nullable NSDictionary *)params MQTTCommandType:(MQTTCommandType)type topic:(NSString *)topic qos:(MQTTQosLevel)qos
{
    KDSMQTTTask *task = [[KDSMQTTTask alloc] initDisableTimer];
//    KDSMQTTTaskReceipt *receipt = [[KDSMQTTTaskReceipt alloc] initWithCommand:type topic:topic func:params[kFunc]];
    KDSMQTTTaskReceipt *receipt = [[KDSMQTTTaskReceipt alloc] initWithCommand:type topic:topic qos:qos func:params[kFunc]];
    if ([params[kFunc] isEqualToString:@"setSwitch"] || [params[kFunc] isEqualToString:@"addSwitch"] || [params[kFunc] isEqualToString:@"getSwitch"]) {
        task.timeout = 60;
    }
    if (params)
    {
        id msgId = params[@"msgId"];
        if (!([msgId isKindOfClass:NSString.class] || [msgId isKindOfClass:NSNumber.class]))
        {
            if ([topic isEqualToString:MQTTServerTopic])
            {
                msgId = @([self nextMsgId]);
            }
            else
            {
                msgId = @([self nextMsgId]);
            }
            NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
            mParams[@"msgId"] = msgId;
            params = mParams;
        }
        receipt.msgId = [msgId integerValue];
        task.payload = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    }
    DDLogDebug(@"MQTT的发送到服务器的主题参数:%@",params);
    task.receipt = receipt;
    //不启用超时回调的task，不需要添加
    //[self.tasks addObject:task];
    [self performTask:task];
    
    return task;
}

/**
 *@abstract Perform a created task if session has been connected and topic has been subscribed, otherwise not. Make sure that the task has been created completely.
 *@note Now only process publish, subscribe and unsubscribe type, others are not supported.
 *@param task The task which would be performed.
 *@return A packet id. Return 0 if the session has not been connected. See MQTTSession for more details.
 */
- (UInt16)performTask:(KDSMQTTTask *)task
{
    if (![self internalConnect] || task.receipt.pid != 0) return 0;
    if (!self.subscribed && task.receipt.type == MQTTPublish)
    {
        [self connected:self.mqttSession];
        return 0;
    }
    __weak typeof(self) weakSelf = self;
    KDSMQTTTaskReceipt *receipt = task.receipt;
    void(^block)(NSError *, id) = ^(NSError *error, id obj){
        
        void(^block)(NSError *, id) = task.responseBlock;
        [weakSelf.tasks removeObject:task];
        task.responseBlock = nil;
        !block ?: block(error, obj);
        
    };
    UInt16 pid = 0;
    switch (receipt.type)
    {
        case MQTTPublish:
        {
            pid = [self.mqttSession publishData:task.payload onTopic:receipt.topic retain:NO qos:task.receipt.qos publishHandler:^(NSError *error) {
                
                if (error) block(error, nil);
            }];
        }
            break;
            
        case MQTTSubscribe:
        {
            pid = [self.mqttSession subscribeToTopic:task.receipt.topic atLevel:task.receipt.qos subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                
                block(error, gQoss);
                
            }];
        }
            break;
            
        case MQTTUnsubscribe:
        {
            pid = [self.mqttSession unsubscribeTopic:task.receipt.topic unsubscribeHandler:^(NSError *error) {
                
                block(error, error ? nil : @[@(pid)]);
                
            }];
        }
            break;
            
        default:
            break;
    }
    task.receipt.pid = pid;
    return pid;
}

/**
 *@brief 递归执行订阅必须的订阅。外面使用时，如果times=0，则执行3次递归，如果1执行2次，大于2时执行1次。
 *@param times 递归执行的次数，大于1(执行一次)或者成功会退出递归。
 *@param completion 收到MQTT服务器回复或超时的回调，参数success表示是否订阅成功。
 */
- (void)subscribeRequiredSubscription:(unsigned)times completion:(void(^)(BOOL success))completion
{
    __weak typeof(self) weakSelf = self;
    KDSMQTTTask *task = [self createTaskWithParams:nil MQTTCommandType:MQTTSubscribe topic:[NSString stringWithFormat:@"/%@/rpc/reply", self.uid] qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        if (!completion) return;
        if (!error && result)
        {
            weakSelf.subscribed = YES;
            completion(YES);
        }
        else if (times > 1)
        {
            completion(NO);
        }
        else
        {
            [weakSelf subscribeRequiredSubscription:times + 1 completion:completion];
        }
    };
}

/**
 *@abstract When receive response for a task from mqtt server, handle it.
 *@param task The response task.
 *@param response The mqtt server response.
 */
- (void)handleTask:(KDSMQTTTask *)task withResponse:(NSDictionary *)response
{
    NSString *code = response[@"code"];
    NSString *msg = response[@"msg"];
    NSString *timestamp = response[@"timestamp"];
    if ([timestamp isKindOfClass:NSString.class] || [timestamp isKindOfClass:NSNumber.class])
    {
        _serverTime = timestamp.integerValue / 1000.0;
    }
    void(^block)(NSError *, NSDictionary *) = task.responseBlock;
    task.responseBlock = nil;
    [self.tasks removeObject:task];
    if (!block)
    {
        return;
    }
    if (!([code isKindOfClass:NSString.class] || [code isKindOfClass:NSNumber.class]) || ![msg isKindOfClass:NSString.class])
    {
        block([NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], nil);
        return;
    }
    if (code.intValue != 200)
    {
        block([NSError errorWithDomain:msg code:code.intValue userInfo:nil], nil);
        return;
    }
    block(nil, response[@"data"]);
}

/**
 *@abstract When receive response for a task that forward from mqtt server, handle it.
 *@param task The response task.
 *@param response The response forward from mqtt server.
 */
- (void)handleForwardTask:(KDSMQTTTask *)task withResponse:(NSDictionary *)response
{
    ///Wi-Fi锁通道返回的是code
    NSLog(@"--kaadas-**The response forward from mqtt server. **-handleForwardTask---response=%@",response);
    NSString *code = response[@"returnCode"] ?: response[@"code"];
    NSDictionary *result = response[@"returnData"] ?:response[@"params"];
    NSLog(@"--kaadas--result=%@",result);
    NSString *func = task.receipt.func ?: task.receipt.topic;
    void(^block)(NSError *, NSDictionary *) = task.responseBlock;
    task.responseBlock = nil;
    [self.tasks removeObject:task];
    if (!block) return;
//    if (![code isKindOfClass:NSString.class] && ![func isEqualToString:@"setCamera"])
//    {
//        block([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil);
//        return;
//    }
    if (!([result isKindOfClass:NSDictionary.class] || [result isKindOfClass:NSNull.class]))
    {
        block([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil);
        return;
    }
    if (code.integerValue != KDSGatewayErrorSuccess)
    {
        block([NSError errorWithDomain:@"网关返回错误" code:code.integerValue userInfo:nil], nil);
        return;
    }
    if ([func isEqualToString:MQTTFuncAllowCateyeJoin] || [func isEqualToString:MQTTFuncEndCateyeJoin])
    {
        block(nil, response);
        return;
    }
    if ([func isEqualToString:@"addSwitch"]) {///添加单火开关的临时写发，后面再优化
        block(nil, response);
        NSLog(@"添加开关成功的返回数据：%@",response);
        return;
    }

    block(nil, [result isKindOfClass:NSDictionary.class] ? result : @{});
}

/**
 *@brief 处理MQTT服务器上报的事件。
 *@param result MQTT服务器上报事件时带的参数。
 */
- (void)handleEventWithResult:(NSDictionary *)result
{
    NSString *func = result[kFunc];
    if (![func isKindOfClass:NSString.class]) return;
    MQTTSubEvent subEvent = nil;
    NSDictionary *param = nil;
    NSLog(@"mqtt服务器上报%@",result);
    if ([func isEqualToString:@"gatewayState"] && [result[@"data"] isKindOfClass:NSDictionary.class])
    {
        NSString *state = result[@"data"][@"state"];
        NSString *uuid = result[@"devuuid"];
        if (![state isKindOfClass:NSString.class] || ![uuid isKindOfClass:NSString.class]) return;
        param = @{@"uuid" : uuid};
        if ([state isEqualToString:@"online"])
        {
            subEvent = MQTTSubEventGWOnline;
        }
        else if ([state isEqualToString:@"offline"])
        {
            subEvent = MQTTSubEventGWOffline;
        }
    }
    else if ([func isEqualToString:@"notifyApprovalBindGW"])
    {
        subEvent = MQTTSubEventJoinGW;
        param = @{@"proposer" : [KDSJoinGWEvent mj_objectWithKeyValues:result]};
    }
    else if ([func isEqualToString:@"replyApprovalBindGW"])
    {
        NSNumber *type = result[@"type"];
        NSString *uuid = result[@"devuuid"];
        if (![type isKindOfClass:NSNumber.class] || ![uuid isKindOfClass:NSString.class]) return;
        subEvent = type.intValue==2 ? MQTTSubEventJoinGWAllow : MQTTSubEventJoinGWRefuse;
        param = @{@"uuid" : uuid};
    }
    else if ([func isEqualToString:@"otaApprovate"])
    {
        subEvent = MQTTSubEventOTA;
        param = result;
    }
    
    if (subEvent)
    {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{MQTTEventKey : subEvent}];
        info[MQTTEventParamKey] = param;
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSMQTTEventNotification object:nil userInfo:info.copy];
    }
}

/**
 *@brief 处理MQTT服务器转发网关上报的事件。
 *@param result MQTT服务器转发网关上报事件时带的参数。
 */
- (void)handleForwardEventWithResult:(NSDictionary *)result
{
    NSLog(@"mqtt消息上报%@",result);
    NSDictionary *eventParams = result[@"eventparams"];
    eventParams = [eventParams isKindOfClass:NSDictionary.class] ? eventParams : @{};
    NSString *event = eventParams[@"event_str"] ?: (eventParams[@"devtype"] ?: eventParams[@"devtype"]);
    NSString * devtype = result[@"devtype"];
    devtype = [devtype isKindOfClass:NSString.class] ? devtype : @"网关返回值错误";
    
    if (event && ![event isKindOfClass:NSString.class]) return;
    NSString *func = result[kFunc];
    if (func && ![func isKindOfClass:NSString.class]) return;
    MQTTSubEvent subEvent = nil;
    NSString *gwId = [result[@"gwId"] isKindOfClass:NSString.class] ? result[@"gwId"] : @"网关返回值错误";
    NSString *devId = [result[@"deviceId"] isKindOfClass:NSString.class] ? result[@"deviceId"] : @"网关返回值错误";
    NSDictionary *param = @{@"gwId":gwId, @"deviceId":devId};
    //共同参数的子事件。
    NSDictionary *events = @{@"delete":MQTTSubEventDevDel, @"lowPower":MQTTSubEventLowPower, @"headLost":MQTTSubEventCYHeadLost, @"doorBell":MQTTSubEventCYBell, @"hostLost":MQTTSubEventCYHostLost,};
    if (events[event])
    {
        subEvent = events[event];
    }
    else if ([event isEqualToString:@"online"] || [event isEqualToString:@"offline"])
    {
        param = [self extractDeviceOn_Off_lineParamFromResult:result eventParams:eventParams gwId:gwId devId:devId event:event];
        if (!param) return;
        if ([event isEqualToString:@"online"]) {
            subEvent = MQTTSubEventDeviceOnline;
        }else{
            subEvent = MQTTSubEventDeviceOffline;
        }
    }
    else if ([event isEqualToString:@"otasuccess"])//未确定
    {
        subEvent = MQTTSubEventOTASuccess;
        param = @{@"gwId":gwId, @"deviceId":devId, @"SW":result[@"SW"], @"macAddr":result[@"macaddr"]};
    }
    else if ([event isEqualToString:@"otafail"])
    {
        subEvent = MQTTSubEventOTAFailed;
        param = @{@"gwId":gwId, @"deviceId":devId, @"SW":result[@"SW"], @"macAddr":result[@"macaddr"]};
    }
    else if ([event isEqualToString:@"pir"])
    {
        subEvent = MQTTSubEventPIRAlarm;
        NSString *url = [eventParams valueForKeyPath:@"devinfo.params.url"];
        url = [url isKindOfClass:NSString.class] ? url : @"网关返回值错误";
        param = @{@"gwId":gwId, @"deviceId":devId, @"url":url};
    }
    else if ([event isEqualToString:@"lockop"])
    {
        if (![result[@"devtype"] isKindOfClass:NSString.class] || ![result[@"devtype"] isEqualToString:@"kdszblock"]) return;
        NSNumber *code = eventParams[@"devecode"];
        if (![code isKindOfClass:NSNumber.class] || !(code.intValue==2 || code.intValue==10)) return;
        if (code.intValue == 2)
        {
            NSNumber *source = eventParams[@"eventsource"], *uid = eventParams[@"userID"];
            source = [source isKindOfClass:NSNumber.class] ? source : @255;
            uid = [uid isKindOfClass:NSNumber.class] ? uid : @255;
            subEvent = MQTTSubEventUnlock;
            param = @{@"gwId":gwId, @"deviceId":devId, @"eventSource":source, @"userId":uid};
        }
        else
        {
            subEvent = MQTTSubEventLock;
        }
    }
    else if ([event isEqualToString:@"wakeup"])
    {
        subEvent = MQTTSubEventCYWakeup;
        NSNumber *code = [eventParams valueForKeyPath:@"devinfo.params.reason"];
        if ([code isKindOfClass:NSNumber.class])
        {
            param = @{@"gwId":gwId, @"deviceId":devId, @"code":code};
        }
    }
    else if ([func isEqualToString:@"gatewayReset"])
    {
        subEvent = MQTTSubEventGWReset;
        param = @{@"uuid" : gwId.length ? gwId : devId};
    }
    else if ([result[@"devtype"] isEqual:@"kdszblock"] && [result[@"eventtype"] isEqual:@"alarm"])
    {
        if ([eventParams[@"alarmCode"] isKindOfClass:NSNumber.class] && [eventParams[@"clusterID"] isKindOfClass:NSNumber.class])
        {
            param = @{@"gwId":gwId, @"deviceId":devId, @"clusterID":eventParams[@"clusterID"], @"alarmCode":eventParams[@"alarmCode"]};
            subEvent = MQTTSubEventDLAlarm;
        }
    }
    else if (([result[@"devtype"] isEqual:@"kdswflock"] || [result[@"devtype"] isEqual:@"xmkdswflock"]) && [result[@"eventtype"] isEqual:@"alarm"]){
        if ([eventParams[@"alarmCode"] isKindOfClass:NSNumber.class] && [eventParams[@"clusterID"] isKindOfClass:NSNumber.class])
        {
            if ([result[@"devtype"] isEqual:@"xmkdswflock"]) {
                ///讯美视频锁报警
                param = @{@"eventId":result[@"eventId"], @"wfId":result[@"wfId"], @"timestamp":result[@"timestamp"], @"clusterID":eventParams[@"clusterID"], @"alarmCode":eventParams[@"alarmCode"]};
            }else{
                param = @{@"lockId":result[@"lockId"], @"wfId":result[@"wfId"], @"timestamp":result[@"timestamp"], @"clusterID":eventParams[@"clusterID"], @"alarmCode":eventParams[@"alarmCode"]};
            }
            
            subEvent = MQTTSubEventWIfiLockAlarm;
        }
    }
    else if (([result[@"devtype"] isEqual:@"kdswflock"] || [result[@"devtype"] isEqual:@"xmkdswflock"]) && [result[@"eventtype"] isEqual:@"record"] && [func isEqualToString:@"wfevent"]){
        if (![result[@"devtype"] isKindOfClass:NSString.class]) return;
        NSNumber *eventCode = eventParams[@"eventCode"];
        NSNumber *eventType = eventParams[@"eventType"];
        if (![eventCode isKindOfClass:NSNumber.class]) return;
        NSNumber *eventSource = eventParams[@"eventsource"] ?: eventParams[@"eventSource"], *uid = eventParams[@"userID"];
        eventSource = [eventSource isKindOfClass:NSNumber.class] ? eventSource : @255;
        uid = [uid isKindOfClass:NSNumber.class] ? uid : @255;
        param = @{@"eventtype":result[@"eventtype"],@"eventType":eventType,@"lockId":result[@"lockId"], @"wfId":result[@"wfId"], @"eventSource":eventSource, @"userId":uid,@"eventCode":eventCode,@"timestamp":result[@"timestamp"]};
        if (eventType.intValue == 1) {
            //devecode
            if (eventCode.intValue == 2)//开锁
            {
                subEvent = MQTTSubEventWifiUnlock;
            }
            else if (eventCode.intValue == 1)//上锁
            {
                subEvent = MQTTSubEventWifiLock;
            }
            else if (eventCode.intValue == 3)//主锁舌伸出
            {
                subEvent = MQTTSubEventWifiLockTongueSticksOut;
            }
        }else if (eventType.intValue == 3){
            //视频锁上报的状态1、自动模式，2、手动模式，3、通用模式，4、安全模式，5、反锁模式，6、布防模式，7、节能模式
            subEvent = MQTTSubEventWifiLockStateChanged;
        }
    }
    else if (([result[@"devtype"] isEqual:@"kdswflock"] || [result[@"devtype"] isEqual:@"xmkdswflock"]) && [result[@"eventtype"] isEqual:@"action"] && [func isEqualToString:@"wfevent"]){
        if (![result[@"devtype"] isKindOfClass:NSString.class]) return;
        NSNumber *defences = eventParams[@"defences"];
        NSNumber *amMode = eventParams[@"amMode"];
        NSNumber * language = eventParams[@"language"];
        NSNumber * operatingMode = eventParams[@"operatingMode"];
        NSNumber * safeMode = eventParams[@"safeMode"];
        NSNumber * powerSave = eventParams[@"powerSave"] ?: @0;
        NSNumber * faceStatus = eventParams[@"faceStatus"] ?: @0;
        NSNumber * volume = eventParams[@"volume"];
        param = @{@"eventtype":result[@"eventtype"],@"lockId":result[@"lockId"], @"wfId":result[@"wfId"], @"defences":defences, @"amMode":amMode, @"language":language, @"operatingMode":operatingMode, @"safeMode":safeMode,@"faceStatus":faceStatus,@"powerSave":powerSave, @"volume":volume,@"timestamp":result[@"timestamp"]};
        subEvent = MQTTSubEventWifiLockStateChanged;
        
    }
    else if ([result[@"devtype"] isEqual:@"kdszblock"] && [event isEqual:@"lockprom"])
    {
        NSDictionary *p = [self extractDLKeyChangedParamFromEventParams:eventParams gwId:gwId devId:devId];
        if (!p) return;
        subEvent = MQTTSubEventDLKeyChanged;
        param = p.copy;
    }else if([devtype isEqualToString:kHangerDevTypeValue]) {
        //晾衣机
        
        if(result[kEventType]) {
            NSString *hangerEvent = result[kEventType];
            
            if ([self hangerEventNameFromEventType:hangerEvent]) {
                [self handleHanger:result];
                subEvent = [self hangerEventNameFromEventType:hangerEvent];
                param = result;
            }
            
        }
    }
    else if ([event isEqualToString:@"lockreport"])
    {
        if ([eventParams[@"attributeID"] isKindOfClass:NSNumber.class] && [eventParams[@"clusterID"] isKindOfClass:NSNumber.class] && [eventParams[@"attributeDataValue"] isKindOfClass:NSArray.class])
        {
            NSArray<NSNumber *> *values = eventParams[@"attributeDataValue"];
            if (![values.firstObject isKindOfClass:NSNumber.class]) return;
            param = @{@"gwId":gwId, @"deviceId":devId, @"clusterID":eventParams[@"clusterID"], @"attributeID":eventParams[@"attributeID"], @"value":values.firstObject};
            subEvent = MQTTSubEventDLInfo;
        }
    }else if ([result[@"devtype"] isEqual:@"xmkdswflock"] && [result[@"eventtype"] isEqual:@"bindInfoNotify"]){
        ///视频锁相关的上报消息
        if (![result[@"devtype"] isKindOfClass:NSString.class] && ![result[@"eventtype"] isKindOfClass:NSString.class]) return;
        param = @{@"randomCode":eventParams[@"randomCode"], @"device_sn":eventParams[@"device_sn"], @"mac":eventParams[@"mac"],@"device_did":eventParams[@"device_did"],@"p2p_password":eventParams[@"p2p_password"],@"wfId":result[@"wfId"]};
        subEvent = MQTTSubEventMdeiaLockBindSucces;
        
    }else if ([result[@"devtype"] isEqual:@"xmkdswflock"] && [result[@"eventtype"] isEqual:@"errorNotify"] && [func isEqualToString:@"wfevent"]){
        ///讯美wifi设备通知app异常信息
        if (![result[@"devtype"] isKindOfClass:NSString.class] && ![result[@"eventtype"] isKindOfClass:NSString.class]) return;
        param = @{@"errorCode":result[@"errorCode"]};
        subEvent = MQTTSubEventMdeiaLockBindErrorNotity;
        
    }else if (([result[@"devtype"] isEqual:@"kdswflock"] || [result[@"devtype"] isEqual:@"xmkdswflock"]) && [result[@"eventtype"] isEqual:@"lockInf"]){
        ///视频锁相关的上报消息
        if (![result[@"devtype"] isKindOfClass:NSString.class] && ![result[@"eventtype"] isKindOfClass:NSString.class]) return;
        param = @{@"wfId":result[@"wfId"],@"eventparams":result[@"eventparams"]};
        //todo 保存设备信息
        [[KDSUserManager sharedManager] updateWifiLockModel:result[@"wfId"] lockInfo:result[@"eventparams"]];
        subEvent = MQTTSubEventLockInf;
        
    }else if (([result[@"devtype"] isEqual:@"kdswflock"] || [result[@"devtype"] isEqual:@"xmkdswflock"]) && [result[@"eventtype"] isEqual:@"lockMultiInfo"]){
        ///视频锁相关的上报消息
        if (![result[@"devtype"] isKindOfClass:NSString.class] && ![result[@"eventtype"] isKindOfClass:NSString.class]) return;
        param = @{@"wfId":result[@"wfId"],@"eventparams":result[@"eventparams"]};
        //todo 保存设备信息
        
        [[KDSUserManager sharedManager] updateWifiLockModel:result[@"wfId"] lockInfo:result[@"eventparams"][@"lockInfo"]];
        
        subEvent = MQTTSubEventLockInf;
        
    }
    
    if (subEvent)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSMQTTEventNotification object:nil userInfo:@{MQTTEventKey:subEvent, MQTTEventParamKey:param}];
    }
}

///从网关返回值中提取设备上下线参数。各参数请参考网关文档。
- (nullable NSDictionary *)extractDeviceOn_Off_lineParamFromResult:(NSDictionary *)result eventParams:(NSDictionary *)eventParams gwId:(NSString *)gwId devId:(NSString *)devId event:(NSString *)event
{
    NSNumber *eventCode = result[@"eventcode"];
    if (!eventCode || ![eventCode isKindOfClass:NSNumber.class] || eventCode.intValue != 1) return nil;
    NSString *mid = result[@"msgid"] ?: result[@"msgId"];//有时是msgid有时是msgId，真是人才。
    NSLog(@"~~~~~~~ioioio==%@",mid);
    
    if (!([mid isKindOfClass:NSString.class] || [mid isKindOfClass:NSNumber.class] || mid.intValue != 0))
    {
        //绑定时连续回几个消息？第一个pid是0？
        return nil;
    }
    NSString *deviceType = result[@"devtype"];
    if (!([deviceType isEqual:@"kdscateye"] || [deviceType isEqual:@"kdszblock"])) return nil;
    GatewayDeviceModel *m = [GatewayDeviceModel new];
    m.deviceId = devId;
    m.event_str = event;
    m.gatewayId = m.gwId = gwId;
    m.SW = eventParams[@"SW"];
    m.macaddr = eventParams[@"macaddr"];
    m.device_type = deviceType;
    return @{@"gwId":gwId, @"deviceId":devId, @"device":m};
}

///从网关返回值中提取锁密匙改变参数。各参数请参考网关文档。
- (nullable NSDictionary *)extractDLKeyChangedParamFromEventParams:(NSDictionary *)eventParams gwId:(NSString *)gwId devId:(NSString *)devId
{
    NSNumber *source = eventParams[@"eventsource"];
    NSNumber *code = eventParams[@"devecode"];
    NSNumber *uid = eventParams[@"userID"];
    if ([source isKindOfClass:NSNumber.class] && [code isKindOfClass:NSNumber.class] && [uid isKindOfClass:NSNumber.class])
    {
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:@{@"gwId":gwId, @"deviceId":devId}];
        KDSPwdListModel *m = [KDSPwdListModel new];
        m.num = [NSString stringWithFormat:@"%02d", uid.intValue];
        p[@"pwd"] = m;
        if (code.intValue==2 || code.intValue==3)
        {
            m.pwdType = (uid.intValue > 4 && uid.intValue < 9) ? KDSServerKeyTpyeTempPIN : KDSServerKeyTpyePIN;
            m.type = KDSServerCycleTpyeForever;
            p[@"action"] = @(code.intValue == 2);
        }
        else if (code.intValue==5 || code.intValue==6)
        {
            m.pwdType = KDSServerKeyTpyeCard;
            p[@"action"] = @(code.intValue == 5);
        }
        else if (code.intValue==7 || code.intValue==8)
        {
            m.pwdType = KDSServerKeyTpyeFingerprint;
            p[@"action"] = @(code.intValue == 7);
        }
        return p[@"action"] ? p : nil;
    }
    return nil;
}

#pragma mark  MQTTSessionDelegate
- (void)connectionRefused:(MQTTSession *)session error:(NSError *)error
{
    switch (error.code)
    {
        case MQTTSessionErrorConnackBadUsernameOrPassword:
        case MQTTSessionErrorConnackNotAuthorized:
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSHttpTokenExpiredNotification object:nil userInfo:nil];
            break;
            
        default:
            break;
    }
}

- (void)connected:(MQTTSession *)session
{
    __weak typeof(self) weakSelf = self;
    [self subscribeRequiredSubscription:0 completion:^(BOOL success) {
        
        if (success)
        {
            for (KDSMQTTTask *task in weakSelf.tasks)
            {
                task.timeout = task.timeout;
                [weakSelf performTask:task];
            }
        }
        else
        {
            [weakSelf internalClose];
        }
        
    }];
}

- (void)connectionClosed:(MQTTSession *)session
{
    self.subscribed = NO;
}

-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    if (eventCode == MQTTSessionEventConnected) {
           NSLog(@"当前MQTT的状态：链接MQTT 成功");
    }else if (eventCode == MQTTSessionEventConnectionRefused) {
               NSLog(@"当前MQTT的状态：MQTT拒绝链接");
    }else if (eventCode == MQTTSessionEventConnectionClosed){
               NSLog(@"当前MQTT的状态：MQTT链接关闭");
    }else if (eventCode == MQTTSessionEventConnectionError){
               NSLog(@"当前MQTT的状态：MQTT 链接错误");
    }else if (eventCode == MQTTSessionEventProtocolError){
               NSLog(@"当前MQTT的状态:MQTT 不可接受的协议");
    }else{//MQTTSessionEventConnectionClosedByBroker
               NSLog(@"当前MQTT的状态:MQTT链接 其他错误");
    }
    if (error) {
           NSLog(@"当前MQTT的状态:链接报错  -- %@",error);
    }
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    KDSLog(@"mqtt result=%@",result);
    //KDSLog(@"mqtt result string =%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    DDLogDebug(@"%@", result);
    
    if (![result isKindOfClass:NSDictionary.class]) return;
    NSNumber *msgId = result[@"msgId"]?:result[@"msgid"];
    NSString *func = [result[kFunc] isKindOfClass:NSString.class] ? result[kFunc] : @"不是字符串";
    KDSMQTTTask *task = nil;
    if ([msgId isKindOfClass:NSNumber.class] || [msgId isKindOfClass:NSString.class])
    {
        for (KDSMQTTTask *_task_ in self.tasks)
        {
            if (_task_.receipt.msgId == msgId.integerValue && [_task_.receipt.func isEqualToString:func])
            {
                task = _task_;
                break;
            }
        }
    }
    if (task)//主动调用的事件回复
    {
        //qos == task.receipt.qos; ??
        if ([task.receipt.topic isEqualToString:MQTTServerTopic])
        {
            NSString *timestamp = [result[@"timestamp"] isKindOfClass:NSString.class] ? result[@"timestamp"] : nil;
            if (timestamp) _serverTime = timestamp.doubleValue / 1000.0;
            [self handleTask:task withResponse:result];
        }
        else
        {
            //处理晾衣机
            if(result[kDevType] && [result[kDevType]  isEqualToString:kHangerDevTypeValue]) {
                [self handleHanger:result];
            }
            [self handleForwardTask:task withResponse:result];
            
            
        }
        return;
    }
    
    //MQTT服务器转发的网关上报的事件
    if ([result[@"msgtype"] isKindOfClass:NSString.class] && [result[@"msgtype"] isEqualToString:@"event"])
    {
        [self handleForwardEventWithResult:result];
        return;
    }
    //剩下的大概就是MQTT服务器上报的事件了。
    [self handleEventWithResult:result];
}

#pragma mark 其它方法
/**
 *@abstract 为网关接口请求添加通用参数。
 *@param param 各个请求方法的特征参数。
 *@return 包含通用参数的参数。
 */
- (NSMutableDictionary *)addRequestPublicParamWithParam:(NSDictionary *)param
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:param];
    mDict[@"msgtype"] = @"request";
    mDict[@"userId"] = self.uid;
    mDict[@"msgId"] = @([self nextMsgId]);
    if (!mDict[@"params"]) mDict[@"params"] = @{};
    mDict[@"returnCode"] = @"0";
    if (!mDict[@"returnData"]) mDict[@"returnData"] = @{};
    mDict[@"timestamp"] = @((long long)(NSDate.date.timeIntervalSince1970 * 1000));
    return mDict;
}
/**
 *@abstract 为网关场景接口请求添加通用参数。
 *@param param 各个请求方法的特征参数。
 *@return 包含通用参数的参数。
 */
- (NSMutableDictionary *)addRequestScenePublicParamWithParam:(NSDictionary *)param
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:param];
    mDict[@"msgtype"] = @"request";
    mDict[@"userId"] = self.uid;
    mDict[@"msgId"] = @([self nextMsgId]);
    if (!mDict[@"scene_rule"]) mDict[@"scene_rule"] = @{};
    mDict[@"returnCode"] = @"0";
    mDict[@"timestamp"] = @((long long)(NSDate.date.timeIntervalSince1970 * 1000));
    return mDict;
}
/**
 *@abstract 为服务器接口请求添加通用参数。
 *@param param 各个请求方法的特征参数。
 *@return 包含通用参数的参数。
 */
- (NSMutableDictionary *)addSeverPublicParamWithParam:(NSDictionary *)param
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:param];
    mDict[@"uid"] = self.uid;
    mDict[@"msgId"] = @([self nextMsgId]);
    return mDict;
}
/**
*@abstract 为Wi-Fi锁接口请求添加通用参数。
*@param param 各个请求方法的特征参数。
*@return 包含通用参数的参数。
*/
- (NSMutableDictionary *)addWiFiLockPublicParamWithParam:(NSDictionary *)param
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:param];
    mDict[@"msgtype"] = @"request";
    mDict[@"userId"] = self.uid;
    mDict[@"msgId"] = @([self nextMsgId]);
    mDict[@"timestamp"] = @((long long)(NSDate.date.timeIntervalSince1970 * 1000));
    return mDict;
}

///获取msgId时加锁。
- (NSInteger)nextMsgId
{
    @synchronized (self) {
        NSInteger mid = self.msgId;
        self.msgId ++;
        return mid;
    }
}

#pragma mark - 对外接口。
#pragma mark 连接和断开。
- (void)connect
{
    [self internalConnect];
}

- (void)close
{
    [self.tasks removeAllObjects];
    [self internalClose];
}

- (BOOL)connected
{
    return [self internalConnect];
}

#pragma mark MQTT服务器相关接口。
- (KDSMQTTTask *)performServerFunc:(NSString *)func withParams:(NSDictionary *)funcParams completion:(void (^)(NSError * _Nullable, BOOL, id _Nullable))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSMutableDictionary *newParam = [NSMutableDictionary dictionaryWithDictionary:funcParams ?: @{}];
    newParam[kFunc] = func;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    newParam = [self addSeverPublicParamWithParam:newParam];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:newParam MQTTCommandType:MQTTPublish topic:MQTTServerTopic qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id  _Nullable result) {
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}

#pragma mark 网关相关接口。
- (KDSMQTTTask *)gw:(GatewayModel *)gw performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *sn = gw.deviceSN ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:sn, @"gwId", sn, @"deviceId", func, kFunc, nil];
    topicParams[@"params"] = funcParams;
    topicParams[@"returnData"] = returnData;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addRequestPublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTGWTopic(sn) qos:MQTTQosLevelExactlyOnce];
    
    // 打印mqtt相关的宏
    NSLog(@"kdszhu MqttTopic ==%@",MQTTGWTopic(sn));
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}

- (KDSMQTTTask *)gw:(GatewayModel *)gw performFunc:(NSString *)func withScene_rule:(NSDictionary *)funcScene_rule returnCode:(NSDictionary *)returnCode completion:(void (^)(NSError * _Nullable, BOOL, NSDictionary * _Nullable))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *sn = gw.deviceSN ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:sn, @"gwId", func, kFunc, nil];
    topicParams[@"scene_rule"] = funcScene_rule;
    topicParams[@"returnCode"] = returnCode;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addRequestScenePublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTGWTopic(sn) qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}

- (KDSMQTTTask *)gw:(GatewayModel *)gw performFuncAndNoScene_rule:(NSString *)func triggerId:(NSString *)triggerId returnCode:(NSDictionary *)returnCode completion:(void (^)(NSError * _Nullable, BOOL, NSDictionary * _Nullable))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *sn = gw.deviceSN ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:sn, @"gwId", func, kFunc, nil];
    topicParams[@"returnCode"] = returnCode;
    topicParams[@"triggerId"] = triggerId;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addRequestScenePublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTGWTopic(sn) qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        
        !completion ?: completion(error, !error && result, result);
    };
    return task;
    
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setCateyeAccessEnable:(BOOL)enable withCateyeSN:(NSString *)sn mac:(NSString *)mac completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSString *gwId = gw.deviceSN ?: @"";
    NSString *func = enable ? MQTTFuncAllowCateyeJoin : MQTTFuncEndCateyeJoin;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"gwId":gwId, kFunc:func, @"sn":sn, @"mac":mac}];
    if (enable) params[@"allowTime"] = @90;
#pragma clang diagnostic pop
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    params = [self addRequestPublicParamWithParam:params];
#pragma clang diagnostic push
    KDSMQTTTask *task = [self createTaskWithParams:params MQTTCommandType:MQTTPublish topic:MQTTGWTopic(gwId) qos:MQTTQosLevelExactlyOnce];
    task.timeout = 300;
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        
        !completion ?: completion(error, !error && result);
    };
    
    return task.receipt;
}

#pragma mark  锁相关接口
- (KDSMQTTTask *)dl:(GatewayDeviceModel *)dl performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *gwId = dl.gatewayId ?: @"";
    NSString *devId = dl.deviceId ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:gwId, @"gwId", devId, @"deviceId", func, kFunc, nil];
    topicParams[@"params"] = funcParams;
    topicParams[@"returnData"] = returnData;
    NSLog(@"mqtttask--------lock==--%@--topicParams==%@",func,topicParams);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addRequestPublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTGWTopic(gwId) qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}
#pragma mark  wifi锁相关接口
- (KDSMQTTTask *)wf:(KDSWifiLockModel *)wf performFunc:(NSString *)func withParams:(NSDictionary *)funcParams returnData:(NSDictionary *)returnData completion:(void (^)(NSError * _Nullable, BOOL, NSDictionary * _Nullable))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *wfId = wf.wifiSN ?: @"";
//    NSString *gwId = wf.wifiSN ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:wfId, @"wfId",func, kFunc, nil];
    topicParams[@"params"] = funcParams;
    topicParams[@"returnData"] = returnData;
    NSLog(@"mqtttask--------lock==--%@--topicParams==%@",func,topicParams);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addWiFiLockPublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTGWTopic(wfId) qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
    
}

- (KDSMQTTTask *)xmMediaWf:(KDSWifiLockModel *)wf performFunc:(NSString *)func withParams:(NSDictionary *)funcParams returnData:(NSDictionary *)returnData completion:(void (^)(NSError * _Nullable, BOOL, NSDictionary * _Nullable))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *wfId = wf.wifiSN ?: @"";
//    NSString *gwId = wf.wifiSN ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:wfId, @"wfId",func, kFunc, nil];
    topicParams[@"params"] = funcParams;
    topicParams[@"returnData"] = returnData;
    NSLog(@"mqtttask--------lock==--%@--topicParams==%@",func,topicParams);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addWiFiLockPublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    NSString * topic = [NSString stringWithFormat:@"/%@/rpc/call",[KDSUserManager sharedManager].user.uid];
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:topic qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}

#pragma mark 猫眼相关接口。
- (KDSMQTTTask *)cy:(GatewayDeviceModel *)cy performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams returnData:(nullable NSDictionary *)returnData completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    NSString *gwId = cy.gatewayId ?: @"";
    NSString *devId = cy.deviceId ?: @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:gwId, @"gwId", devId, @"deviceId", func, kFunc, nil];
    topicParams[@"params"] = funcParams;
    topicParams[@"returnData"] = returnData;
    NSLog(@"mqtttask--------cateye==--%@--topicParams==%@",func,topicParams);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addRequestPublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    KDSMQTTTask *task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTGWTopic(gwId) qos:MQTTQosLevelExactlyOnce];
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}

#pragma mark 晾衣架接口
- (KDSMQTTTask *) hanger:(KDSDeviceHangerModel *)hanger  performFunc:(NSString *)func withParams:(nullable NSDictionary *)funcParams enableTimeout:(BOOL) enableTimeout completion:(nullable void(^)(NSError * __nullable error, BOOL success, NSDictionary * __nullable response))completion
{
    NSAssert(func.length, @"%s__%d__执行的功能不能为空", __FILE__, __LINE__);
    
    NSString *wifiId = hanger.wifiSN ? : @"";
    NSMutableDictionary *topicParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:wifiId,kHangerWifiId,kHangerDevTypeValue, kDevType, func, kFunc, [KDSUserManager sharedManager].user.uid, kUserId, nil];
    topicParams[@"params"] = funcParams;
    
    //KDSLog(@"mqtttask--------hanger==--%@--topicParams==%@",func,topicParams);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    topicParams = [self addWiFiLockPublicParamWithParam:topicParams];
#pragma clang diagnostic pop
    //todo 优化任务定时器：1.更改超时 2.超时队列删除任务
    ESWeakSelf
    
    KDSMQTTTask *task;
    if (enableTimeout) {
        task = [self createTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTHangerTopic([KDSUserManager sharedManager].user.uid) qos:MQTTQosLevelExactlyOnce];
    }else {
        task = [self createDisableTimerTaskWithParams:topicParams MQTTCommandType:MQTTPublish topic:MQTTHangerTopic([KDSUserManager sharedManager].user.uid) qos:MQTTQosLevelExactlyOnce];
    }
    
    
    __weak __typeof(KDSMQTTTask *)weakTask = task;
    task.responseBlock = ^(NSError * _Nullable error, id _Nullable result) {
        //todo 清除队列 call cancelTaskWithReceipt
        if (weakTask) {
            [__weakSelf cancelTaskWithReceipt:weakTask.receipt];
        }
        
        !completion ?: completion(error, !error && result, result);
    };
    
    return task;
}

/**
 * 晾衣机事件名称
 */
-(NSString *) hangerEventNameFromEventType:(NSString *) eventType {
    NSDictionary *hangerEvents = @{kHangerEventHangerState: MQTTSubEventHangerState,
                                   kHangerEventHangerInf:MQTTSubEventHangerInf
    };
    
    return hangerEvents[eventType] ? : nil;
}

/**
 * 从mqtt字典中获取事件类型
 */
-(NSString *) getEventType:(NSDictionary *) eventResult {
    return eventResult[kEventType];
}
/**
 * 从mqtt字典中获取功能点
 */
-(NSString *) getResultFunc:(NSDictionary *) eventResult {
    return eventResult[kResultFunc];
}

/**
 * 从mqtt字典中获取晾衣机设备id
 */
-(NSString *) getHangerWiFiId:(NSDictionary *) eventResult {
    return eventResult[kHangerWifiId];
}
/**
 *  查找晾衣机模型
 */
-(KDSDeviceHangerModel *) findHangerModel:(NSString *) wifiId {
    __block KDSDeviceHangerModel *hanger = nil;
    if (!wifiId) {
        return nil;
    }
    [[KDSUserManager sharedManager].hangers enumerateObjectsUsingBlock:^(KDSDeviceHangerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.wifiSN isEqualToString:wifiId]) {
                hanger = obj;
                *stop = YES;
            }
        }];
    return hanger;
}

#pragma mark - 处理晾衣机相关事件

/**
 * 处理晾衣机相关事件
 */
-(void) handleHanger:(NSDictionary *) eventResult  {
    
    //处理状态与参数事件，查找对应设备模型，进行更新对应值
        
    NSString *hangerWiFiId = [self getHangerWiFiId:eventResult];
    KDSDeviceHangerModel *hanger = [self findHangerModel:hangerWiFiId];
    
    if (!hanger) {
        return;
    }
    if ([[self getEventType:eventResult] isEqualToString:kHangerEventHangerState]) {
        //事件上报
        KDSDeviceHangerState *hangerState = [[KDSDeviceHangerState alloc] initWithDictionary:eventResult];
        
        hanger.status = hangerState.eventparams.status;
        hanger.uV = hangerState.eventparams.uV;
        hanger.airDry = hangerState.eventparams.airDry;
        hanger.baking = hangerState.eventparams.baking;
        hanger.childLock = hangerState.eventparams.childLock;
        hanger.light = hangerState.eventparams.light;
        hanger.loudspeaker = hangerState.eventparams.loudspeaker;
        hanger.motor = hangerState.eventparams.motor;
        hanger.overload = hangerState.eventparams.overload;
        
    }else if ([[self getEventType:eventResult] isEqualToString:kHangerEventHangerInf]) {
        //参数上报
    }else if ([[self getResultFunc:eventResult] isEqualToString:kHangerGetAllStatus]) {
        //获取晾衣机状态
        //KDSDeviceHangerState *hangerState = [[KDSDeviceHangerState alloc] initWithDictionary:eventResult];
        
        KDSDeviceHangerEventparam *param = [[KDSDeviceHangerEventparam alloc] initWithDictionary:eventResult[kHangerReplyParams]];
        
        hanger.status = param.status;
        hanger.uV = param.uV;
        hanger.airDry = param.airDry;
        hanger.baking = param.baking;
        hanger.childLock = param.childLock;
        hanger.light = param.light;
        hanger.loudspeaker = param.loudspeaker;
        hanger.motor = param.motor;
        hanger.overload = param.overload;
    }
    
    
}

#pragma mark 删除队列中的MQTT任务。
- (BOOL)cancelTaskWithReceipt:(KDSMQTTTaskReceipt *)receipt
{
    for (KDSMQTTTask *task in self.tasks)
    {
        if (task.receipt == receipt)
        {
            task.responseBlock = nil;
            [self.tasks removeObject:task];
            return YES;
        }
    }
    return NO;
}

@end

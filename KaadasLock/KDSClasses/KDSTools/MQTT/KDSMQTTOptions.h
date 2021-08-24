//
//  KDSMQTTOptions.h
//  KaadasLock
//
//  Created by orange on 2019/4/12.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

///这个文件只定义一些常量等信息。

typedef NSString * MQTTTopic;
typedef NSString * MQTTFunc;
typedef NSString * MQTTSubEvent;

#define MQTTFixedTime    946684800      //1970-2000年的时间 秒数

#define MQTTTextStarTime 1584588200
#define MQTTTextEndTime 1585452200

#define MQTTGWTopic(gwuuid) [NSString stringWithFormat:MQTTGWTopic, gwuuid]///<发布到网关的主题宏。
#define MQTTHangerTopic(userid) [NSString stringWithFormat:MQTTHangerRequstTopic, userid]///<发布到网关的主题宏。
///发布到MQTT服务器的主题，区别于MQTT服务器转发的主题。
FOUNDATION_EXTERN MQTTTopic const MQTTServerTopic;
///经MQTT服务器转发后发布到网关的主题格式字符串，格式一般为"/type/%@/call"，%@字典填的是相应的网关sn。
FOUNDATION_EXTERN MQTTTopic const MQTTGWTopic;
//经MQTT服务器转发后发布到晾衣架的主题格式字符串，格式一般为"/%@/rpc/call"，%@字典填的是用户id。
FOUNDATION_EXTERN MQTTTopic const MQTTHangerRequstTopic;
///网关允许猫眼接入时执行的方法名称。之所以设置此常量，是因为这个方法的参数和返回值不按照接口规范，需特殊处理。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncAllowCateyeJoin;
///网关拒绝猫眼接入时执行的方法名称。之所以设置此常量，是因为这个方法的参数和返回值不按照接口规范，需特殊处理。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncEndCateyeJoin;
///绑定网关，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncBindGW;
///解绑网关，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncUnbindGW;
///获取账号下绑定的网关列表，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncGWList;
///网关注册并绑定米米网，服务器接口。RB:register and bind.
FOUNDATION_EXTERN MQTTFunc const MQTTFuncRBMeme;
///获取网关下绑定的设备列表，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncDeviceList;
///修改网关下绑定设备的昵称，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncUpdateNickname;
///获取账号下待审批的网关列表，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncApproveList;
///审批网关绑定申请，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncApproveGW;
///获取网关下绑定的设备的开锁记录，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncUnlockRecord;
///获取网关下绑定设备的预警信息记录，服务器接口。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncAlarmList;
/// 设置门锁的方向
FOUNDATION_EXTERN MQTTFunc const MQTTFuncOpenDirection;
///审批网关升级，服务器接口。GW:gateway, OTA:over the air.
FOUNDATION_EXTERN MQTTFunc const MQTTFuncApproveGWOTA;
///...几十个方法，用到常量时待设置。


#pragma mark 通用设备GET、SET接口方法。通用接口方法在网关、锁和猫眼等都是一样的，执行这些方法时，收到返回值后要deviceId和func都一致的情况下才执行相应的任务回调，只根据func有可能执行了错误的任务回调。
///通用设备获取电量方法。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncGetPower;
///通用设备获取时间方法。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncGetTime;
///通用设备设置时间方法。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncSetTime;
///通用删除设备方法。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncDeleteDevice;
///通用设备OTA升级方法。
FOUNDATION_EXTERN MQTTFunc const MQTTFuncOTA;


///在MQTT事件通知的userInfo中，使用此key获取value的值，值是字符串类型，且必须是以下的MQTTSubEvent常量之一。
FOUNDATION_EXTERN NSString * const MQTTEventKey;
///如果通知的子事件包含参数，则在通知的userInfo中使用此key获取value的值，值是字典类型，具体内容参考子事件常量说明。
FOUNDATION_EXTERN NSString * const MQTTEventParamKey;
///网关上线子事件。该子事件由MQTT服务器上报，参数的"uuid"字段值为发生事件的设备的id(一般是网关sn)(NSString)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventGWOnline;
///网关下线子事件。同MQTTSubEventGWOnline。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventGWOffline;
///用户请求绑定管理员名下的网关。该子事件由MQTT服务器上报，参数的"proposer"字段值为申请人资料(KDSJoinGWEventModel类型)
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventJoinGW;
///用户账号请求绑定网关后，网关管理员允许。该子事件由MQTT服务器上报，参数的"uuid"字段值为网关sn(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventJoinGWAllow;
///用户账号请求绑定网关后，网关管理员拒绝。该子事件由MQTT服务器上报，参数的"uuid"字段值为网关sn(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventJoinGWRefuse;
///OTA升级子事件。该子事件由MQTT服务器上报，参数为服务器返回的升级相关参数(NSDictionary)，调用升级接口时直接将此参数传入即可。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventOTA;
///网关重置子事件。由MQTT服务器转发，参数的"uuid"字段值为网关sn(NSString)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventGWReset;
///删除网关下的设备子事件。由(网关上报，下同)MQTT服务器转发，参数的"gwId"字段值为网关id(NSString)，"deviceId"字段值为被删设备的deviceId(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventDevDel;
///设备低电量子事件。由MQTT服务器转发，参数的"gwId"字段值为网关id(NSString)，"deviceId"字段值设备的deviceId(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventLowPower;
///设备OTA升级成功子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为设备deviceId(NSString)，"SW"为固件版本号?(NSString)，"macAddr"为mac地址(NSString,格式xx:xx:xx:xx:xx:xx...)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventOTASuccess;
///设备OTA升级失败子事件(未实现)。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为设备deviceId(NSString)，"SW"为固件版本号?(NSString)，"macAddr"为mac地址(NSString,格式xx:xx:xx:xx:xx:xx...)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventOTAFailed;
///猫眼PIR触发报警子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为报警设备的deviceId(NSString)，"url"字段为照片FTP地址(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventPIRAlarm;
///猫眼猫头被拔子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为猫眼的deviceId(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventCYHeadLost;
///猫眼门铃触发子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为猫眼的deviceId(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventCYBell;
///猫眼机身被拔子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为猫眼的deviceId(NSString).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventCYHostLost;
///开锁子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"eventSource"为开锁类型(NSNumber, 0-键盘开锁，1-RF开锁，2-手工开锁，3-RFID开锁，4-指纹开锁，255-未知方式开锁)，"userId"为结合开锁类型的密匙编号(NSNumber).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventUnlock;
///Wifi开锁子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"eventSource"为开锁类型(NSNumber, 0-键盘开锁，3-RFID开锁，4-指纹开锁，255-未知方式开锁)，"userId"为结合开锁类型的密匙编号(NSNumber).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventWifiUnlock;
///Wifi开锁子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"eventSource"为开锁类型(NSNumber, 0-键盘开锁，3-RFID开锁，4-指纹开锁，255-未知方式开锁)，"userId"为结合开锁类型的密匙编号(NSNumber).
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventWifiLockTongueSticksOut;
///关锁子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventLock;
///wifi关锁子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventWifiLock;
///网关设备上线子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为设备的deviceId(NSString)，且"device"字段值为上线的设备(GatewayDeviceModel，和服务器返回的属性并不完全一样)，绑定新设备时可以根据此子事件确定绑定成功。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventDeviceOnline;
///网关设备下线子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为设备的deviceId(NSString)，"device"字段值为上线的设备(GatewayDeviceModel，和服务器返回的属性并不完全一样)。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventDeviceOffline;
///猫眼唤醒子事件，v2.2文档新增。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"code"字段值为唤醒原因代码(NSNumber，1猫头按键呼叫唤醒，2WiFi唤醒，6前面板按键唤醒，200APP呼叫唤醒)，如果没有code字段，则意味着网关返回值有问题。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventCYWakeup;
///锁由于触发特定条件报警子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"clusterID"为协议簇id(NSNumber)，"alarmCode"为报警代码(NSNumber)。"clusterID"和"alarmCode"组合决定报警事件，具体查看ZigBee协议。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventDLAlarm;
///wifi锁由于触发特定条件报警子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"clusterID"为协议簇id(NSNumber)，"alarmCode"为报警代码(NSNumber)。"clusterID"和"alarmCode"组合决定报警事件，具体查看ZigBee协议。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventWIfiLockAlarm;
///密匙变更子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"pwd"字段值为添加的密码模型(KDSPwdListModel，暂时只分永久和临时密码，胁迫密码归为永久密码)，"action"字段值为变更类型(NSNumber，0删除，1添加)。当删除时，如果密码模型的编号为255，表示删除所有密码。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventDLKeyChanged;
///锁上报相关信息(属性)子事件。由MQTT服务器转发，参数的"gwId"字段值为网关sn(NSString)，"deviceId"字段值为锁的deviceId(NSString)，"clusterID"为协议簇id(NSNumber)，"attributeID"为属性id(NSNumber)，"value"为属性值(NSNumber)。"clusterID"和"attributeID"组合决定信息类型，具体查看ZigBee协议。
FOUNDATION_EXTERN MQTTSubEvent const MQTTSubEventDLInfo;
///wifi锁模式更改相关的上报
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventWifiLockStateChanged;
///视频锁绑定成功上报的讯美的p2p服务的信息
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventMdeiaLockBindSucces;
///视频锁绑定:wifi设备通知app异常信息---1：超时2：其他错误，3~n：可自行扩展
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventMdeiaLockBindErrorNotity;
    
//晾衣架状态事件上报
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventHangerState;
//晾衣架设备参数信息上报
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventHangerInf;
//门锁消息
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventLockInf;
//门锁消息action/list/lockinf
FOUNDATION_EXPORT MQTTSubEvent const MQTTSubEventLockMultiInfo;
/**
 *@brief MQTT网关接口返回的错误类型。
 */
typedef NS_ENUM(NSInteger, KDSGatewayError) {
    ///接口返回值错误，APP定义。
    KDSGatewayErrorInvalid = 9998,
    ///请求MQTT服务器超时，APP定义。
    KDSGatewayErrorRequestTimeout = -1001,
    ///成功。
    KDSGatewayErrorSuccess = 200,
    ///设备未找到。
    KDSGatewayErrorDeviceNotFound = 404,
    ///接口未找到(func参数值)。
    KDSGatewayErrorFuncNotFound = 405,
    ///无效接口参数。
    KDSGatewayErrorInvalidParams = 406,
    ///命令执行超时。
    KDSGatewayErrorExecuteTimeout = 407,
    ///服务器故障。
    KDSGatewayErrorServerMalfuction = 408,
    ///设备故障。
    KDSGatewayErrorDeviceMalfuction = 409,
    ///设备未处理命令。
    KDSGatewayErrorDeviceUntreated = 410,
    ///设备执行中出错。
    KDSGatewayErrorDeviceError = 411,
    ///升级失败。
    KDSGatewayErrorUpdateFailed = 412,
    ///又一个命令执行超时，什么鬼？专为开锁设置的？
    KDSGatewayErrorExecuteTimeout2 = 413,
};

/**
 *@abstract 网关锁操作权限相关的密匙类型。
 */
typedef NS_ENUM(NSInteger, KDSGWKeyType) {
    ///无效值。
    KDSGWKeyTypeInvalid = 0xFF,
    ///保留值。
    KDSGWKeyTypeReserved = 0x0,
    ///PIN(personal indentifier number)码，相当于开门密码，一般6~12位。
    KDSGWKeyTypePIN = 0x1,
    ///指纹，网关协议不支持，留着扩展。
    KDSGWKeyTypeFingerprint = 0x2,
    ///RFID卡片，网关协议不支持，留着扩展。
    KDSGWKeyTypeRFID = 0x3,
    ///管理员密码，网关协议不支持，留着扩展。
    KDSGWKeyTypeAdmin = 0x4,
};

/**
 *@abstract 猫眼报警类型。
 */
typedef NS_ENUM(NSUInteger, KDSDLAlarmType) {
    ///低电量，和蓝牙锁的低电量用的是同样的枚举值。
    KDSDLAlarmTypeLowPower = 16,
    ///门锁堵转。
    KDSDLAlarmTypeJammed = 100001,
    ///锁被恢复出厂设置。
    KDSDLAlarmTypeReset = 100002,
    ///ZigBee协议的2是保留值。
    ///RF模块重启，什么鬼。
    KDSDLAlarmTypeRFCycled = 100004,
    ///3次错误报警。
    KDSDLAlarmTypeWrongLimit = 100005,
    ///前面板被移除。
    KDSDLAlarmTypeFrontEscutcheonRemoved = 100006,
    ///锁被撬开
    KDSDLAlarmTypeForcedOpen = 100007,
    ///暴力撞击
    KDSDLAlarmTypeViolentHit = 100008,
    ///温度过高
    KDSDLAlarmTypeTempTooHigh = 100009,
    ///胁迫密匙开锁
    KDSDLAlarmTypeSOS = 100010,
    ///钥匙遗落锁上
    KDSDLAlarmTypeKeyLeft = 100011,
};

/**
 *@abstract 猫眼报警类型。
 */
typedef NS_ENUM(NSUInteger, KDSCYAlarmType) {
    ///PIR触发。
    KDSCYAlarmTypePir = 200001,
    ///猫头被拔。
    KDSCYAlarmTypeHeadLost = 200002,
    ///门铃触发。
    KDSCYAlarmTypeBell = 200003,
    ///低电量。
    KDSCYAlarmTypeLowPower = 200004,
    ///机身被拔。
    KDSCYAlarmTypeHostLost = 200005,
};

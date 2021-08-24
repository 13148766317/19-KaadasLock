//
//  KDSBleOptions.h
//  lock
//
//  Created by orange on 2018/12/13.
//  Copyright © 2018年 zhao. All rights reserved.
//

#ifndef KDSBleOptions_h
#define KDSBleOptions_h

//该头文件定义凯迪仕蓝牙通信协议所用到的一些常量，数据传输使用小端。

/**特征值UUID*/
#define systemIDUUID    @"2A23"//SystemID
#define modelNumUUID    @"2A24"//ModelNumber
#define seriaLNumUUID   @"2A25"//SerialNumber
#define firmwareUUID    @"2A26"//FirmwareRev
#define hardwareUUID    @"2A27"//HardwareRev
#define softwareUUID    @"2A28"//SoftwareRev
#define mfrNameUUID     @"2A29"//MfrName
#define bleToAppDUUID   @"FFE4"//模块向App发送数据通道
#define batteryDUUID    @"FFB1"//电量
#define bleAndWiFiFunctionSetUUID     @"FFC7"//Wi-Fi锁的功能集
#define wifiLockNotifyUUID  @"FFC6"//蓝牙连接成功发的剩余校验次数
#define bleAndWiFiFFC1UUID @"FFC1"//APP->BLE配网通道
#define DISTRIBUTION_NETWORK_SEND_SERVICE @"FFc0"//APP->BLE配网通道
#define DISTRIBUTION_NETWORK_NOTIFY_SERVICE @"FFc5"//BLE->app配网通道
#define DISTRIBUTION_NETWORK_NOTIFY_CHAR  @"FFc6"
///门锁状态特征UUID FFFo服务
#define kLockStateUUID  @"FFF3"
///锁音量特征UUID FFF0服务
#define kLockVolumeUUID @"FFF5"
///锁语言特征UUID FFF0服务
#define kLockLanguageUUID @"FFF4"
///如果蓝牙包含此特征，则该蓝牙的功能版本至少为3，能支持本APP的新功能。 FFE0服务
#define kFFE1 @"FFE1"
//晾衣机app将数据写入蓝牙
#define kSmartHangerUUID @"FFC1"

/**TI方案*/
#define  OADResetServiceUUID @"F000FFD0-0451-4000-B000-000000000000"//OAD复位服务
#define  OADResetServiceCharacteristicStartOrResetUUID @"F000FFD1-0451-4000-B000-000000000000"//OAD启动Start：1，OAD重置Reset：0
/**
 *@abstract 凯迪仕蓝牙模块OAD服务(FFC0)所含特征。
 */
///OAD服务。
#define  KDSOADService @"F000FFC0-0451-4000-B000-000000000000"
///OAD镜像识别Image Identify，用于向空中发送镜像元数据，以便OAD目标设备能够确定它是否应该接受或拒绝建议的镜像。
#define  KDSOADServiceCharacteristicImageIdentify @"F000FFC1-0451-4000-B000-000000000000"
///OAD镜像块Image Block，发送bin文件。
#define  KDSOADServiceCharacteristicImageBlock @"F000FFC2-0451-4000-B000-000000000000"
///OAD Control，控制OAD过程的各个方面，暂时未使用到
#define  KDSOADServiceCharacteristicControl @"F000FFC5-0451-4000-B000-000000000000"

#define TI_OAD_COUNT                                        @"F000FFC3-0451-4000-B000-000000000000"
#define TI_OAD_STATUS                                       @"F000FFC4-0451-4000-B000-000000000000"

/**P6方案*/
#define  DFUResetServiceUUID @"1802"//DFU复位服务
#define  DFUResetServiceCharacteristicStartOrResetUUID @"2A06"//DFU启动Start：1
/**
 *@abstract 凯迪仕Psoc6平台蓝牙DFU服务(UUID)所含特征。
 */
///DFU服务
#define  KDSDFUService @"00060000-F8CE-11E4-ABF4-0002A5D5C51B"
///DFU服务特征
#define  KDSDFUServiceCharacteristicCommand @"00060001-F8CE-11E4-ABF4-0002A5D5C51B"

/************************************************************************
*       凯迪仕--瑞瀛--合作项目   以下为瑞瀛网关蓝牙协议             *
************************************************************************/
///App发送数据到瑞瀛网关的服务通道。
#define  KDSRYGWBleServiceTunnel @"91BC9BBE-ED4C-4CEE-8E7D-D8516C886547"
///瑞瀛网关配网特征值
#define  KDSRYGWBle2WiFi @"7BA2A753-97AF-4E83-AF8B-7A413F8DBBDD"
//FFE8C9B2-C6A1-4B37-BE7F-89EB4852B2F5

/************************************************************************
*       凯迪仕--瑞瀛--合作项目   以上为瑞瀛网关蓝牙协议             *
************************************************************************/

#define FixedTime    946684800      //1970-2000年的时间 秒数
#define FutureTime   4102444800   //1970 -2100年的时间 秒数

///新协议头的长度
#define kHeaderLength 4
///新协议载荷的长度
#define kPayloadLength 16
///设置用户计划时，最大的计划id，计划id可以从0开始。
#define KDSMaxScheduleId 4

/**
 *@abstract 凯迪仕蓝牙服务，枚举值是对应服务的UUID。
 */
typedef NS_ENUM(NSInteger, KDSBleService) {
    ///模块参数。该服务包含电量和时间2个特征。
    KDSBleServiceModule = 0xFFB0,
    ///设备信息参数。该服务包含设备MAC地址、模块代号、序列号、锁型号、硬件版本、软件版本6个特征。
    KDSBleServiceDevice = 0x180A,
    ///门锁参数。该服务包含锁的类型、功能、状态等特征。
    KDSBleServiceLock = 0xFFF0,
    ///app发送数据到ble模块的服务通道。
    KDSBleServiceApp2BleTunnel = 0xFFE5,
    ///ble模块发送数据到app的服务通道。
    KDSBleServiceBle2AppTunnel = 0xFFE0,
    ///APP->BLE配网通道【服务UUID：0xFFC0】
    KDSApp2BleDisNetworkTunnel = 0xFFC0,
    ///BLE->APP配网通道【服务UUID：0xFFC5】
    KDSBle2AppDisNetworkTunnel = 0xFFC5
    
};

/**
 *@abstract 凯迪仕蓝牙模块服务(FFB0)所含特征，枚举值是对应特征的UUID。
 */
typedef NS_ENUM(NSInteger, KDSBleModuleServiceCharacteristic) {
    ///电池电量，特征值为1个字节。
    KDSBleModuleServiceCharacteristicBattery = 0xFFB1,
    ///设备时间，2000年1月1日~设定日期的秒数，特征值4个字节。
    KDSBleModuleServiceCharacteristicTime = 0xFFB2,
};

/**
 *@abstract 凯迪仕蓝牙设备信息服务(180A)所含特征，枚举值是对应特征的UUID。
 */
typedef NS_ENUM(NSInteger, KDSBleDeviceServiceCharacteristic) {
    ///16进制MAC地址，特征值为8个字节，每字节一个16进制数字，低字节在前。
    KDSBleDeviceServiceCharacteristicBattery = 0x2A23,
    ///模块代号，20字节。
    KDSBleDeviceServiceCharacteristicCode = 0x2A24,
    ///序列号，20字节。
    KDSBleDeviceServiceCharacteristicSerialNumber = 0x2A25,
    ///锁型号，20字节。
    KDSBleDeviceServiceCharacteristicLockType = 0x2A26,
    ///硬件版本，20字节。
    KDSBleDeviceServiceCharacteristicHardwareVer = 0x2A27,
    ///软件版本，20字节。
    KDSBleDeviceServiceCharacteristicSoftwareVer = 0x2A28,
};

/**
 *@abstract 凯迪仕蓝牙门锁参数服务(FFF0)所含特征，详情参考通信协议文档，枚举值是对应特征的UUID。
 */
typedef NS_ENUM(NSInteger, KDSBleLockServiceCharacteristic) {
    ///锁类型，特征值1字节。
    KDSBleLockServiceCharacteristicType = 0xFFF1,
    ///锁功能，4字节。
    KDSBleLockServiceCharacteristicFunc = 0xFFF2,
    ///锁状态，4字节。
    KDSBleLockServiceCharacteristicStatus = 0xFFF3,
    ///锁语言，2字节，ISO 639-1标准。
    KDSBleLockServiceCharacteristicLanguage = 0xFFF4,
    ///锁音量，1字节。0(静音)、1(低音)、2(高音)，3~255保留。
    KDSBleLockServiceCharacteristicHardwareVer = 0xFFF5,
};

/**
 *@abstract 凯迪仕蓝牙通道服务所含特征，特征值(数据通道帧)是20个字节，枚举值是对应特征的UUID。
 */
typedef NS_ENUM(NSInteger, KDSBleTunnelServiceCharacteristic) {
    ///app->ble数据通道。
    KDSBleTunnelServiceCharacteristicApp2Ble = 0xFFE9,
    ///ble->app数据通道。
    KDSBleTunnelServiceCharacteristicBle2App = 0xFFE4,
    ///app->ble配网数据通道。
    KDSDisNetworkTunnelServiceCharacteristicApp2Ble = 0xFFC1,
    ///ble->app配网数据通道。
    KDSDisNetworkTunnelServiceCharacteristicBle2App = 0xFFC6,
    
    
};
/**
 *数据发送时必须收到确认帧(如果只是回复成功与否的命令没有)，否则需要每3秒1次重发最多3次，通道帧格式：
 *|------------------------------------|------------------|
 *|          header: 4bytes            | payload: 16bytes |
 *|------------------------------------|------------------|
 *|  1byte  | 1byte |  1byte   | 1byte |     16bytes      |
 *|------------------------------------|------------------|
 *| control |  tsn  | checksum |  cmd  |     payload      |
 *|------------------------------------|------------------|
 *control: 右起bit0，加密标志位，1加密，0非密，bit1~7保留。
 *tsn: 传输序列号，不能为0，每次发送加1，配对的发送-响应命令序列号相同。
 *checksum: 校验码，payload每个字节的和取低位一个字节。
 *cmd: 命令，见KDSBleTunnelOrder枚举。
 *payload: 载荷，命令数据，不足16字节补0，除确认帧和心跳帧外使用AES128加密。
 *其中，确认帧和心跳帧的header只包含tsn，其它3个字节一般都为0；其它需要返回相关信息的命令接收和发送header必须一样，否则视为失败。
 */

/**
 *@abstract 凯迪仕蓝牙通道服务命令类型。
 *设置时间表计划前要把密码编号设置成时间表用户类型；删除时间表后若还要使用该编号，需设置成00（永久用户）?
 */
typedef NS_ENUM(NSInteger, KDSBleTunnelOrder) {
    ///0  确认帧命令。
    KDSBleTunnelOrderZero = 0,
    ///鉴权命令。
    KDSBleTunnelOrderAuth = 0x1,
    ///锁控制命令。
    KDSBleTunnelOrderControl = 0x2,
    ///密匙管理命令。
    KDSBleTunnelOrderKeyManage = 0x3,
    ///开锁记录查询命令。
    KDSBleTunnelOrderGetUnlockRecord = 0x4,
    ///锁操作上报确认命令。
    KDSBleTunnelOrderLockOperate = 0x5,
    ///锁参数修改命令。
    KDSBleTunnelOrderUpdateLockParam = 0x6,
    ///锁报警上报命令。
    KDSBleTunnelOrderAlarm = 0x7,
    ///加密密钥上报确认命令(入网/退网)。
    KDSBleTunnelOrderEncrypt = 0x8,
    ///用户类型设置命令。
    KDSBleTunnelOrderSetUserType = 0x9,
    ///用户类型查询命令。
    KDSBleTunnelOrderGetUserType = 0xA,
    ///周计划设置命令。一把锁最多支持5个(年月日+周)计划，计划id范围0-4，且锁的所有用户共享。
    KDSBleTunnelOrderSetWeekly = 0xB,
    ///周计划查询命令。一把锁最多支持5个(年月日+周)计划，计划id范围0-4，且锁的所有用户共享。
    KDSBleTunnelOrderGetWeekly = 0xC,
    ///周计划删除命令。一把锁最多支持5个(年月日+周)计划，计划id范围0-4，且锁的所有用户共享。
    KDSBleTunnelOrderDeleteWeekly = 0xD,
    ///年月日计划设置命令。一把锁最多支持5个(年月日+周)计划，计划id范围0-4，且锁的所有用户共享。
    KDSBleTunnelOrderSetYMD = 0xE,
    ///年月日计划查询命令。一把锁最多支持5个(年月日+周)计划，计划id范围0-4，且锁的所有用户共享。
    KDSBleTunnelOrderGetYMD = 0xF,
    ///年月日计划删除命令。一把锁最多支持5个(年月日+周)计划，计划id范围0-4，且锁的所有用户共享。
    KDSBleTunnelOrderDeleteYMD = 0x10,
    ///心跳命令。
    KDSBleTunnelOrderHeartbeat = 0xAA,
    //以下命令为1.1.14版本增加
    ///同步门锁密钥状态，这个命令可以获取指定密匙类型的所有密匙。
    KDSBleTunnelOrderSyncKey = 0x11,
    ///查询门锁基本信息。
    KDSBleTunnelOrderGetLockInfo = 0x12,
    ///app请求绑定命令。
    KDSBleTunnelOrderBind = 0x13,
    //1.1.15新增
    ///锁报警记录查询。
    KDSBleTunnelOrderGetAlarmRecord = 0x14,
    ///锁序列号查询。
    KDSBleTunnelOrderGetSN = 0x15,
    ///开锁次数查询
    KDSBleTunnelOrderGetTimes = 0x16,
    ///锁参数查询，1.1.20beta4新增
    KDSBleTunnelOrderGetParam = 0x17,
    ///锁中记录的操作记录，1.2.0beta1新增
    KDSBleTunnelOrderGetOpRec = 0x18,
    //1.2.4新增---Wi-Fi锁配网指令
    ///APP下发SSID（路由器的SSID）
    KDSBleTunnelOrderSendSSID = 0x90,
    ///APP下发pwd(路由器的密码)
    KDSBleTunnelOrderSendPwd = 0x91,
    ///配网因子响应：0x92（离线密码因子）
    KDSBleTunnelOrderSendCipherFactor = 0x92,
    ///APP查询配网状态
    KDSBleTunnelOrderGetDisNetworkStatus = 0x93,
    ///下发秘钥因子校验结果
    KDSBleAndWiFiCRCCheck = 0x94,
    ///上报剩余校验次数响应:0x95
    KDSReportResponseRemainingTimes = 0x95,
    // APP 下发配网状态:0x96
    KDSReportResponseRemainingTimes96 =0x96,

    //晾衣机项目 1 BLE 上报联网状态响应:0x97  2 BLE 上报联网状态响应:0x97
    KDSReportResponseRemainingTimes97 =0x97,
    };

/**
 *@abstract 凯迪仕蓝牙通道确认帧(app命令发出时只要求蓝牙回复成功与否的命令，4bytes header后的第一个字节)status错误类型。
 */
typedef NS_ENUM(NSInteger, KDSBleError) {
    ///发送命令等待蓝牙回复过程中，超时没有回复。
    KDSBleErrorNoReply = 0xffff,
    ///相邻2条命令重复，或者正在进行鉴权不能进行其它操作，或者队列中命令大于4条。
    KDSBleErrorDuplOrAuthenticating = 0xfffe,
    ///锁处于管理员模式。
    KDSBleErrorAdminMode = 0xfffd,
    
    //下面为蓝牙定义的错误码。
    ///操作成功。
    KDSBleErrorSuccess = 0,
    ///操作失败。
    KDSBleErrorFailure = 1,
    ///没有授权。
    KDSBleErrorNotAuth = 0x7E,
    ///保留区域没有置0.
    KDSBleErrorReservedFieldNotZero = 0x7F,
    ///异常命令。
    KDSBleErrorMalformedCommand = 0x80,
    ///不支持的命令。
    KDSBleErrorUnsupportCommand = 0x81,
    ///某个字段错误。
    KDSBleErrorInvalidField = 0x85,
    ///不支持的属性。
    KDSBleErrorUnsupportAttr = 0x86,
    ///超出范围，或者设置为保留值，或者序号已存在。
    KDSBleErrorInvalidValue = 0x87,
    ///只读属性。
    KDSBleErrorReadOnly = 0x88,
    ///操作空间不够。
    KDSBleErrorSpaceNotEnough = 0x89,
    ///重复存在。
    KDSBleErrorDuplicateExist = 0x8A,
    ///请求的数据没有找到。
    KDSBleErrorNotFound = 0x8B,
    ///数据类型错误
    KDSBleErrorInvalidDataType = 0x8D,
    ///只写属性
    KDSBleErrorWriteOnly = 0x8F,
    ///权限不够。
    KDSBleErrorDenied = 0x93,
    ///超时，蓝牙发送命令给锁，锁没有接收。
    KDSBleErrorTimeout = 0x94,
    ///客户端或服务端退出升级程序。
    KDSBleErrorAbort = 0x95,
    ///无效的image文件。
    KDSBleErrorInvalidImage = 0x96,
    ///服务端无可用数据。
    KDSBleErrorWaitingForData = 0x97,
    ///没有可用的OTA image文件。
    KDSBleErrorNoAvailableImage = 0x98,
    ///客户端需要更多的OTA文件。
    KDSBleErrorRequireMoreImage = 0x99,
    ///命令已经接收且正在处理。
    KDSBleErrorPending = 0x9A,
    ///硬件原因造成的错误。
    KDSBleErrorHardwareFailure = 0xC0,
    ///软件原因造成的错误。
    KDSBleErrorSoftwareFailure = 0xC1,
    ///校验过程出现错误。
    KDSBleErrorCalibrationError = 0xC2,
    ///反锁。
    KDSBleErrorLockInside = 0xC4,
    ///安全模式。
    KDSBleErrorSecurityMode = 0xC5,
    ///锁已经接收到命令，但超时时间内没有处理结果返回。
    KDSBleErrorLockTimeout = 0xFF,
    /**
     KDSBleErrorUnsupGenralCommand = 0x82, //不使用
     KDSBleErrorUnsupManufCommand = 0x83, //不使用
     KDSBleErrorUnsupManufGeneralCommand = 0x84, //不使用
     KDSBleErrorUnreportableAttr = 0x8C, //不使用
     KDSBleErrorInvalidSelector = 0x8E, //不使用
     KDSBleErrorInconsistentStartupState = 0x90, //不使用
     KDSBleErrorDefinedOutOfBand = 0x91, //不使用
     KDSBleErrorInconsistent = 0x92, //不使用
     KDSBleErrorUnsuppotrCluster = 0xC3, //不使用
     */
};

/**
 *@abstract 锁操作权限相关的密匙类型。
 */
typedef NS_ENUM(NSInteger, KDSBleKeyType) {
    ///无效值(蓝牙数据只返回一个字节)。
    KDSBleKeyTypeInvalid = 0xffff,
    ///保留值。
    KDSBleKeyTypeReserved = 0x0,
    ///PIN(personal indentifier number)码，相当于开门密码，6~12位。
    KDSBleKeyTypePIN = 0x1,
    ///指纹。
    KDSBleKeyTypeFingerprint = 0x2,
    ///RFID卡片。4~10位。
    KDSBleKeyTypeRFID = 0x3,
    ///管理员密码。
    KDSBleKeyTypeAdmin = 0x4,
    ///面容识别
    KDSBleKeyTypeFace = 0x5,
};

/**
 *@abstract KDSBleTunnelOrderSetUserType, KDSBleTunnelOrderGetUserType命令的参数枚举。蓝牙时间表相关的流程如下：
 *
 *1、先设置时间表计划；
 *
 *2、再添加一个密码(相当于添加用户，如果密码已存在，此步骤可以省略)；
 *
 *3、最后设置用户类型为时间表用户。
 */
typedef NS_ENUM(NSUInteger, KDSBleSetUserType) {
    ///无效值。
    KDSBleSetUserTypeInvalid = 0xff,
    ///永久用户。
    KDSBleSetUserTypeForerver = 0,
    ///时间表用户(年月日、周计划)。
    KDSBleSetUserTypeSchedule = 1,
    ///胁迫用户。
    KDSBleSetUserTypeForce = 2,
    ///管理员用户。
    KDSBleSetUserTypeAdmin = 3,
    ///无权限（查询权限）用户。
    KDSBleSetUserTypeRightlessness = 4,
    //1.1.14新增
    ///访客。
    KDSBleSetUserTypeCustom = 0xfd,
    ///一次性用户。
    KDSBleSetUserTypeOnce = 0xfe,
};

/**
 *@abstract KDSBleTunnelOrderControl命令的动作和密匙类型参数枚举。
 */
typedef NS_ENUM(NSInteger, KDSBleLockControl) {
    //锁的动作，除了开锁，其它用得好像比较少。3~255保留
    ///开锁。
    KDSBleLockControlActionUnlock = 0x0,
    ///关锁。
    KDSBleLockControlActionLock = 0x1,
    ///开关触发？
    KDSBleLockControlActionToggle = 0x2,
    
    //锁的密匙类型
    ///保留。
    KDSBleLockControlKeyReserved = 0x0,
    ///PIN开锁。
    KDSBleLockControlKeyPIN = 0x1,
    ///RFID卡片开锁。
    KDSBleLockControlKeyRFID = 0x2,
    ///app开锁，锁不鉴权(不需密码)。此命令用于授权模式，app->通过服务器授权另一账号->另一账号(不是管理员)使用04命令开门。
    KDSBleLockControlKeyAPP = 0x4,
};

/**
 *@abstract KDSBleTunnelOrderKeyManage命令的动作类型参数枚举。
 */
typedef NS_ENUM(NSInteger, KDSBleKeyManageAction) {
    ///保留。
    KDSBleKeyManageActionReserved = 0x0,
    ///设置密钥,指纹和RFID。
    KDSBleKeyManageActionSet = 0x1,
    ///查询密钥，管理员密码不支持。
    KDSBleKeyManageActionGet = 0x2,
    ///删除密钥，管理员密码不支持。
    KDSBleKeyManageActionDelete = 0x3,
    ///验证密钥，管理员密码专用。
    KDSBleKeyManageActionVerify = 0x4,
    ///更改密钥，内部处理是先删除再设置。
    KDSBleKeyManageActionAlter = 0xee,
};

/**
 *@abstract 锁报警类型枚举。
 */
typedef NS_ENUM(NSInteger, KDSBleAlarmType) {
    ///无效值(蓝牙数据只返回一个字节)。
    KDSBleAlarmTypeInvalid = 0xffff,
    ///密码、指纹、卡片开锁错误超过10次，锁被锁定。
    KDSBleAlarmTypeLocked = 0x1,
    ///输入防劫持密码、指纹开锁。
    KDSBleAlarmTypeHijack = 0x2,
    ///3次错误报警。
    KDSBleAlarmTypeError = 0x3,
    ///锁被撬开。
    KDSBleAlarmTypePried = 0x4,
    ///机械锁匙开锁。
    KDSBleAlarmTypeMechanic = 0x08,
    ///低电压。
    KDSBleAlarmTypeLowVoltage = 0x10,
    ///锁不上。
    KDSBleAlarmTypeLose = 0x20,
    ///门锁布防。
    KDSBleAlarmTypeDefence = 0x40,
};

/************************************************************************
 *                           以下为旧蓝牙协议                              *
 ************************************************************************/
/**
 *@abstract 凯迪仕旧蓝牙协议命令类型。
 */
typedef NS_ENUM(NSInteger, KDSBleOldCommand) {
    ///无效命令。
    KDSBleOldCommandInvalid = -1,
    
    //智能锁->扩展模块(相当于硬件的蓝牙模块？)
    ///入网/退网命令。
    KDSBleOldCommandInOut = 0xb0,
    ///门锁状态信息通知。
    KDSBleOldCommandLockStatus = 0xb1,
    ///告警通知。
    KDSBleOldCommandAlarm = 0xb2,
    ///睡眠命令。
    KDSBleOldCommandSleep = 0xb3,
    ///状态信息通知。
    KDSBleOldCommandStatus = 0xb4,
    
    //扩展模块->智能锁
    ///模块入网通知。
    KDSBleOldCommandNet = 0xc0,
    ///读取门锁信息。
    KDSBleOldCommandLockInfo = 0xc1,
    ///开锁。
    KDSBleOldCommandUnlock = 0xc2,
    ///获取开锁记录。
    KDSBleOldCommandUnlockRecord = 0xc3,
    ///模式设置。
    KDSBleOldCommandSetting = 0xc4,
    ///时间校正。
    KDSBleOldCommandTimeCalibration = 0xc5,
    ///添加/删除密匙。
    KDSBleOldCommandKeyManage = 0xc6,
    ///读取密匙信息。
    KDSBleOldCommandKeyInfo = 0xc7,
    ///修改密码。
    KDSBleOldCommandChangePwd = 0xc8,
    ///策略添加/修改。
    KDSBleOldCommandTacticUpdate = 0xd0,
    ///策略查询。
    KDSBleOldCommandTacticQuery = 0xd1,
    ///策略删除。
    KDSBleOldCommandTacticDelete = 0xd2,
    ///用户类型设置。
    KDSBleOldCommandSetUserType = 0xd3,
    ///用户类型查询。
    KDSBleOldCommandGetUserType = 0xd4,
    ///开、关锁命令。既然有这个命令，为什么还单独设置一个开锁命令，wtf.
    KDSBleOldCommandOperateLock = 0xd5,
    ///读取门锁扩展信息。
    KDSBleOldCommandLockExtensionInfo = 0xd6,
    ///验证密钥。
    KDSBleOldCommandKeyAuth = 0xd7,
};

/************************************************************************
*       凯迪仕--瑞瀛--合作项目   以下为瑞瀛网关蓝牙协议             *
************************************************************************/
/**
 *@abstract 凯迪仕-瑞瀛蓝牙通道服务命令类型。
 */
typedef NS_ENUM(NSInteger, KDSRYBleOrder) {
    ///传输wifi账户密码。
    KDSRYBle2WiFi
    
};

/************************************************************************
*       凯迪仕--瑞瀛--合作项目   以上为瑞瀛网关蓝牙协议             *
************************************************************************/

#endif /* KDSBleOptions_h */

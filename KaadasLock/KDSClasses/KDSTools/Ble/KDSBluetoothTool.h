//
//  KDSBluetoothTool.h
//  BleTest
//
//  Created by zhaowz on 2017/6/8.
//  Copyright © 2017年 zhaowz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+Extension.h"
#import "NSData+JKEncrypt.h"
#import "KDSBleOptions.h"
#import "KDSBleTunnelTask.h"
#import "KDSBleUnlockRecord.h"
#import "KDSBleUserType.h"
#import "KDSBleYMDModel.h"
#import "KDSBleWeeklyModel.h"
#import "KDSBleAlarmRecord.h"
#import "KDSBleLockInfoModel.h"
#import "KDSBleOpRec.h"

typedef enum : NSUInteger {
    DeviceInfoSystemID,
    DeviceInfoModelNum,
    DeviceInfoSerialNum,
    DeviceInfoFirmWare,
    DeviceInfoHardware,
    DeviceInfoSoftware,
    DeviceInfoMfrName,
    DeviceInfoBattery
} DeviceInfo;

@protocol KDSBluetoothToolDelegate <NSObject>

@optional
/**检测手机蓝牙状态*/
- (void)discoverManagerDidUpdateState:(CBCentralManager *_Nonnull)central;
/**发现蓝牙设备*/
- (void)didDiscoverPeripheral:(CBPeripheral *_Nonnull)peripheral;
/**连接上蓝牙设备*/
- (void)didConnectPeripheral:(CBPeripheral *_Nonnull)peripheral;

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager * __nonnull)central didFailToConnectPeripheral:(CBPeripheral * __nonnull)peripheral error:(nullable NSError *)error;

/**断开连接蓝牙设备*/
- (void)didDisConnectPeripheral:(CBPeripheral *_Nonnull)peripheral;
/**收到服务的特征(writeCharacteristic有值，才会执行该代理)*/
- (void)didReceiveWriteCharacteristic;
/**收到设备入网或者退网的命令，YES：入网 NO：退网*/
- (void)didReceiveInNetOrOutNetCommand:(BOOL )inNet;
/** 搜到设备的电量信息，0-100 */
- (void)didReceiveDeviceElctInfo:(int)elct;
/**获取了开锁记录数组*/
- (void)didReceivedOpenLockRecord:(NSMutableArray<KDSBleUnlockRecord *> *_Nullable)recordArray;
/**获取了设备的SN*/
- (void)didGetDeviceSN:(NSString *_Nonnull)deviceSN;
/**获取到systemID*/
- (void)didGetSystemID:(CBPeripheral *_Nonnull)peripheral;
/**获取到门锁功能集*/
- (void)didGetFunctionSet:(CBPeripheral *_Nonnull)peripheral;
/**没有包含的门锁功能集*/
- (void)noFunctionSet:(NSString *_Nonnull)FunctionSet;
- (void)didGetSoftwareWithPeripheral:(CBPeripheral *_Nonnull)peripheral softwareData:(NSString *_Nonnull)softwareData;
///已停止搜索外设。
- (void)centralManagerDidStopScan:(CBCentralManager *)cm;
///开始DFU传镜像文件
- (void)startDFUProcess;
///开始OAD传镜像文件
- (void)startOADProcess;
///锁蓝牙已进入bootloadm模式
-(void)hasInBootload:(CBPeripheral *_Nonnull)peripheral;
///收到蓝牙发过来的数据后回复ACK给模块
-(void)replyBleAndWiFiACKWithValue:(int)value Cmd:(unsigned char)cmd tsn:(int)tsn;
///收到完整的密码因子
-(void)completeCRCReceived;

/**
 *@abstract 当获取到锁状态特征值(FFF3)时调用，新蓝牙。
 *@param peripheral 外设。
 *@param value 特征值，按协议为4个字节。
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristicOfLockState:(NSData *)value;

/**
 *@abstract 当获取到锁型号特征值(2A26)时调用，新蓝牙。
 *@param peripheral 外设。
 *@param model 特征值，按协议为4个字节。
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristicOfLockModel:(NSString *)model;

@end

NS_ASSUME_NONNULL_BEGIN
@interface KDSBluetoothTool : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, weak) id<KDSBluetoothToolDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *centralManager;
///已经连接上的设备
@property (nonatomic, strong, nullable) CBPeripheral *connectedPeripheral;
/// 已经连接上的蓝牙NSUUID
@property (nonatomic, strong, nullable) NSUUID *connectedPeripheralWithIdentifier;
///要写入到哪个特征
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
///要读哪个特征(设备信息相关,待定)
@property (nonatomic, strong) CBCharacteristic *readCharacteristic;
///启动DFU服务特征值
@property (nonatomic, strong) CBCharacteristic *DFUCharacteristic;
///重启OAD服务特征值
@property (nonatomic, strong) CBCharacteristic *OADCharacteristic;
///DFU服务特征值,用于传镜像文件
@property (nonatomic, strong) CBCharacteristic *DFUTransImageCharacteristic;
///OAD服务特征值,用于传镜像文件
@property (nonatomic, strong) CBCharacteristic *OADTransImageCharacteristic;
///收到的蓝牙数据
@property (nonatomic, strong) NSMutableData   *dataM;
@property (nonatomic, strong) NSMutableData * bleWiFiCRCData;
///区分正在绑定还是重置
@property (nonatomic, assign) BOOL isBinding;
///连接外设绑定时，收到SN后，从服务器请求回来。绑定后从绑定设备列表获得。测试没有上市的蓝牙时，服务器没有值返回，这是使用mac提取。
@property (nonatomic, copy, nullable) NSString  *pwd1;
///用户入网(绑定)的时候生成，锁蓝牙返回的payload数据的1~4字节。
@property (nonatomic, strong, nullable) NSData *pwd2;
///鉴权成功时，锁蓝牙返回的payload数据的1~4字节。
@property (nonatomic, strong, nullable) NSData *pwd3;
///剩余管理员密码校验次数
@property (nonatomic, assign) int checkNum;
@property (nonatomic, assign) int bleAndWiFiLockTsn;
///ble+wifi锁（蓝牙配网次数，5次失败）
@property (nonatomic, assign) int currentBleNetworkNum;
/**
 *@abstract 保存app->ble通道命令任务的可变字典，键是任务的receipt属性，值是命令。一般当收到蓝牙返回值或超时后执行任务的block，然后移除该任务。如果receipt冲突，后面的会替换前面的。(为了分类能使用放到.h文件)。
 *@note 记得执行任务的block后要从此字典中移除任务。
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, KDSBleTunnelTask *> *tasksMDict;
/**
 *@abstract 搜索到的用户列表，这个值会发生变化，如果不支持或者没有记录则为空数组。只有调用了搜索用户和计划方法才会返回有效值。
 *@see startRetrieveUsersAndSchedules.
 */
@property (nonatomic, strong, readonly) NSArray<KDSBleUserType *> *users;
/**
 *@abstract 搜索到的计划列表，这个值会发生变化，如果不支持或者没有记录则为空数组。只有调用了搜索用户和计划方法才会返回有效值。
 *@see startRetrieveUsersAndSchedules.
 */
@property (nonatomic, strong, readonly) NSArray<KDSBleScheduleModel *> *schedules;
///日期格式器，初始化时为默认格式，使用前请先设置需要的格式。
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
///管理员模式执行的提示回调。在管理员模式下所有操作的指令统统不会下发，直接执行失败回调并返回错误码KDSBleErrorAdminMode。
@property (nonatomic, copy) void(^onAdminModeBlock) (void);
///当前连接蓝牙的账号是否是管理员账号，默认否。如果不是管理员账号，不能同步锁时间。
@property (nonatomic, assign) BOOL isAdmin;

- (instancetype)initWithVC:(id<KDSBluetoothToolDelegate>)viewController;
//+ (instancetype)shareInstance;
/**
 *搜索蓝牙设备，该方法在10秒后会自动停止搜索蓝牙。
 */
- (void)beginScanForPeripherals;
/** 停止扫描蓝牙设备 */
- (void)stopScanPeripherals;
/** 开始连接蓝牙设备 */
- (void)beginConnectPeripheral:(CBPeripheral *)peripheral;
/**断开连接蓝牙设备*/
- (void)endConnectPeripheral:(CBPeripheral *)peripheral;
/**断开连接蓝牙设备*/
- (void)endConnectPeripheral;
/**重启OAD服务*/
- (void)resetOAD:(CBPeripheral *)peripheral;
/**重启DFU服务*/
- (void)resetDFU:(CBPeripheral *)peripheral;

#pragma mark - 蓝牙协议相关方法
/**获取电量*/
- (void)getDeviceElectric;
/**获取设备信息*/
- (void)getDeviceInfoWithDevType:(DeviceInfo)type;

/**
 *@abstract 16进制字符串转换为NSData对象。
 *@param str 16进制字符串，例如"b0f33a6"。
 *@return NSData呈现，例如"b0f33a6" -> <0b0f33a6>。参数不是字符串或者长度为0返回长度为0的对象。
 */
//- (NSData *)convertHexStrToData:(NSString *)str;

/**
 *@abstract 当操作绑定/重置功能时，连接蓝牙后，在锁操作完毕加入/退出网络后，蓝牙模块会发送一个命令为8的数据，app接收到此命令数据后，应该在内部统一调用此命令来告知锁蓝牙模块app端已收到。因为要在处理旧协议的分类中调用，所以此方法才暴露到头文件中。
 *@param tsn 数据传输序列号，新蓝牙模块传入ble发送过来的序列号，旧蓝牙模块随便传一个(内部忽略此值)。
 */
- (void)sendResponseInOrOutNet:(int)tsn;

/** 在锁中操作入网/退网后，app将信息告知服务器，服务器返回时调用此方法，发送入网/退网成功确认帧。此方法内部只处理旧蓝牙协议。 */
- (void)sendInOrOutNetSuccessFrame;

/**
 *@abstract 连接蓝牙成功后，蓝牙模块会广播系统ID，当接收到此特征值更新时，根据服务器返回的当前设备的2个密码请求授权。如果被重置，会删除记录的pwd1和pwd2。
 *@param pwd1 当前连接设备的密码1.如果已绑定，则为服务器返回的，否则从MAC提取。
 *@param pwd2 当前连接设备的密码2.如果已绑定，则为服务器返回的字符串，否则从绑定操作成功时蓝牙返回的二进制数据提取。
 *@param completion 收到ble回复数据后执行的回调，参数error参考方法内注释。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)authenticationWithPwd1:(NSString *)pwd1 pwd2:(id)pwd2 completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 调用此方法开始向蓝牙发送命令搜索当前锁中有多少密码和计划，该命令在心跳定时器中发送，返回结果比较慢，因此要提前调用。每当搜索到一个有效结果后，都会通过相应的属性和通知放出搜索到的全部有效结果。
 */
- (void)startRetrieveUsersAndSchedules;

/**
 *@abstract 获取锁中所有密码。这个方法发送的命令是1.1.4版本的协议才增加的
 *@param completion 收到ble回复数据后执行的回调，参数error参考方法内注释。如果成功返回所有用户(不包含用户类型)，否则users为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getAllUsersWithKeyType:(KDSBleKeyType)keyType completion:(void(^ __nullable)(KDSBleError error, NSArray<KDSBleUserType *> * __nullable users))completion;

/**
 *@abstract 以手机当前时间更新锁的系统时间。新蓝牙。
 *@param completion 更新完成的回调，error参考KDSBleError。如果非管理员账号连接的蓝牙，此回调会返回KDSBleErrorNoReply。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)updateLockClock:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的提示语言。新蓝牙。
 *@param language 语言代码，ISO 639-1 标准。汉语"zh"，英语"en"。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockLanguage:(NSString *)language completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的提示语音量。新蓝牙。绝大部分锁只支持静音和低音量。
 *@param volume 音量，1字节，0静音，1低音，2高音，3-255保留。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockVolume:(int)volume completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的自动关门功能。新蓝牙。
 *@param status 1字节，0开启自动关门，1关闭自动关门。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockAutoLockStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的反锁功能。新蓝牙。
 *@param status 1字节，0关闭反锁，1开启反锁。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockLockInsideStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的离家模式功能。新蓝牙。
 *@param status 1字节，0开启离家模式，1关闭离家模式。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockAwayHomeStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的蓝牙开/关功能。新蓝牙。
 *@param status 1字节，0开启蓝牙，1关闭蓝牙。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockBleStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置锁的安全模式开/关。新蓝牙。
 *@param status 1字节，1开启安全模式，0关闭安全模式。
 *@param completion 更新完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setLockSecurityModeStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 获取锁中保存的全部记录。不一定每一条记录都能获取到，使用者应根据回调返回的数据自行判断记录是否获取完毕。
 *@param type 1为开锁记录，2为报警记录(透传蓝牙不支持，新蓝牙1.1.15)，其它参数暂不支持。
 *@param completion 获取到记录后执行的回调，查询全部记录时，每获取到1或20条数据会执行一次回调，因此回调有可能会执行多次。如果error不成功且records为nil，表明遇到了错误，锁没有回复数据；finished表示获取操作是否已结束。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getAllRecord:(int)type completion:(nullable void(^)(BOOL finished, KDSBleError error, NSArray<KDSBleRecord *> * __nullable records))completion;

/**
 *@abstract 获取锁中保存的特定组记录。不一定每一条记录都能获取到，使用者应根据回调返回的数据自行判断记录是否获取完毕。
 *@param type 1为开锁记录，2为报警记录(透传蓝牙不支持，新蓝牙1.1.15)，其它参数暂不支持。
 *@param group 第几组，从0开始，每组20条数据，如果此值处于0~9之间(协议所定)，则返回单组记录，否则返回任务失败。
 *@param completion 获取单组记录后执行的回调。如果error成功，则records返回记录(有可能为空数组)，否则records为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getRecord:(int)type atGroup:(int)group completion:(nullable void(^)(KDSBleError error, NSArray<KDSBleRecord *> * __nullable records))completion;

/**
 *@abstract 获取锁中保存的单条记录。不是所有型号的锁都支持此命令。新蓝牙。
 *@param type 1为开锁记录，2为报警记录(透传蓝牙不支持，新蓝牙1.1.15)，其它参数暂不支持。
 *@param index 第几条，从0开始，此值大于199没有意义。
 *@param completion 收到ble回复数据后执行的回调，如果error成功，有记录则record返回记录，否则record为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getRecord:(int)type atIndex:(int)index completion:(nullable void(^)(KDSBleError error, KDSBleRecord * __nullable record))completion;

/**
 *@abstract 更新指定日期后的记录。获取锁中保存的记录，并对比数据，返回晚于(包含)指定数据的记录。
 *@param type 1为开锁记录，2为报警记录(透传蓝牙不支持，新蓝牙1.1.15)，其它参数暂不支持。
 *@param data 协议返回的20字节转换成的40字节的字符串，由于条数后的数据唯一性比时间好，因此使用此数据替换时间，如果空则查询全部。
 *@param completion 获取新记录后执行的回调，新蓝牙每获取到1或20条数据会执行一次回调，因此回调有可能会执行多次。回调判断是否成功的规则如下：1、如果records为nil，则获取记录失败。2、如果records最后一条记录的数据和data一样(从6字节后开始比较)或者记录总数total=records.count，则获取记录成功。3、如果records元素数量为0，表明没有新数据。4、如果error为成功且不满足2和3条件，则表明这是每20条数据执行的中间回调。5、其它情况由于丢包只获取了一部分数据；finished表示获取操作是否已结束。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)updateRecord:(int)type afterData:(nullable NSString *)data completion:(nullable void(^)(BOOL finished, KDSBleError error, NSArray<KDSBleRecord *> * __nullable records))completion;

/**
 *@abstract 锁控制命令，包括开锁、关锁、触发等，一般都是用于开锁。如果是新模块，调用前请自行判断密码(数字)及长度是否合法。开锁时如果成功会获取电量。旧蓝牙暂时只实现开锁功能。
 *@param pwd 锁的密码，如果是新蓝牙模块一般长度为6~12位数字。旧蓝牙协议会忽略此参数。
 *@param action 控制事件，一般是KDSBleLockControlActionUnlock.旧蓝牙协议会忽略此参数。
 *@param key 密匙类型，一般是KDSBleLockControlKeyPIN.旧蓝牙协议会忽略此参数。
 *@param completion 收到ble回复数据后执行的回调，error参考KDSBleError枚举，如果操作成功peripheral为连接的外设，否则为空。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)operateLockWithPwd:(NSString *)pwd actionType:(KDSBleLockControl)action keyType:(KDSBleLockControl)key completion:(nullable void(^)(KDSBleError error, CBPeripheral * __nullable peripheral))completion;

/**
 *@abstract 设置用户类型，app->ble通道0x9命令。新蓝牙。
 *@param userId 用户编号，一般为00-09，有些设备支持00-19.
 *@param keyType 密匙类型，一般为KDSBleKeyTypePIN，只设置开门密码。
 *@param userType 用户类型。
 *@param completion 收到ble回复数据后执行的回调，参数error = 0x8B时表示用户编号不存在。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)setUserTypeWithId:(NSString *)userId KeyType:(KDSBleKeyType)keyType userType:(KDSBleSetUserType)userType completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 获取用户类型，app->ble通道0x0a命令。新蓝牙。
 *@param userId 用户编号，一般为00-09，有些设备支持00-19.
 *@param keyType 密匙类型，一般为KDSBleKeyType。
 *@param completion 收到ble回复数据后执行的回调，如果error成功的话，user是返回的用户类型，否则为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getUserTypeWithId:(NSString *)userId KeyType:(KDSBleKeyType)keyType completion:(nullable void(^)(KDSBleError error, KDSBleUserType * __nullable user))completion;

/**
 *@abstract 设置用户的年月日开锁计划，即用户在begin - end时间段内才能开锁。起始时间必须小于结束时间。新蓝牙。
 *@param scheduleId 计划编号，不要大于KDSMaxScheduleId。
 *@param userId 用户编号。
 *@param keyType 密匙类型，一般为KDSBleKeyTypePIN。
 *@param begin 开始日期，任意格式，但是必须顺序包含yyyyMMddHHmm，例如2019年01月09日15时42分，不能15时42分，2019年01月09日。
 *@param end 结束日期字符串，任意格式，但是必须顺序包含yyyyMMddHHmm。
 *@param completion 收到ble回复数据后执行的回调，参数error参见KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)scheduleYMDWithScheduleId:(int)scheduleId userId:(int)userId keyType:(KDSBleKeyType)keyType begin:(NSString *)begin end:(NSString *)end completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 根据计划id删除年月日计划。新蓝牙。
 *@param scheduleId 计划编号，不要大于KDSMaxScheduleId。
 *@param completion 删除操作完成执行的回调，error参见KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)deleteYMD:(int)scheduleId completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 设置用户的周开锁开锁计划。用户在指定的日期和时间段内才能开锁。起始时间必须小于结束时间。新蓝牙。
 *@param scheduleId 计划编号，不要大于KDSMaxScheduleId。
 *@param userId 用户编号。
 *@param keyType 密匙类型，一般为KDSBleKeyTypePIN。
 *@param mask 周的位域，从数的小端起按日、一、二、三、四、五、六、保留，总共8位。
 *@param beginHour 起始小时，0~23。
 *@param beginMin 起始分钟，0~59。
 *@param endHour 结束小时，0~23。
 *@param endMin 结束分钟，0~59。
 *@param completion 收到ble回复数据后执行的回调，参数error参见KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)scheduleWeeklyWithScheduleId:(int)scheduleId userId:(int)userId keyType:(KDSBleKeyType)keyType weekMask:(int)mask beginHour:(int)beginHour beginMin:(int)beginMin endHour:(int)endHour endMin:(int)endMin completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 根据计划id删除周计划。新蓝牙。
 *@param scheduleId 计划编号，不要大于KDSMaxScheduleId。
 *@param completion 删除操作完成执行的回调，error参见KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)deleteWeekly:(int)scheduleId completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 获取用户的开锁计划。由于蓝牙返回时并不区分年月日和周计划，按原来的方法，如果查询周计划返回的是年月日计划会导致失败，使用此方法不会导致此种失败，使用者只需判断返回的计划类型即可。
 *@param scheduleId 计划编号，不要大于KDSMaxScheduleId。
 *@param completion 收到ble回复数据后执行的回调，参数error成功时，model包含计划信息，否则为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getScheduleWithScheduleId:(int)scheduleId completion:(nullable void(^)(KDSBleError error, KDSBleScheduleModel * __nullable model))completion;

/**
 *@abstract 管理密钥。包括增删查改。新蓝牙。
 *@param pwd 要管理的密钥。
 *@param userId 密钥对应的用户编号。当为255且action为KDSBleKeyManageActionDelete时，删除所有密码。
 *@param action 事件，增删查改之一。
 *@param keyType 密钥类型，见枚举。当为KDSBleKeyTypeAdmin且action为KDSBleKeyManageActionSet时，内部固定userId为255.
 *@param completion 执行完成的回调，error参考KDSBleError。添加卡片、指纹要以锁操作上报通知返回的数据判断是否已添加成功。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)manageKeyWithPwd:(NSString *)pwd userId:(NSString *)userId action:(KDSBleKeyManageAction)action keyType:(KDSBleKeyType)keyType completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 获取锁信息。此方法和FFF0服务可以获得的参数基本一样。
 *@param completion 执行完成的回调，error参考KDSBleError。成功返回锁信息，否则为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getLockInfo:(nullable void(^)(KDSBleError error, KDSBleLockInfoModel * __nullable infoModel))completion;

/**
 *@abstract app主动发送绑定请求给蓝牙后转给锁。现在是在锁上操作加入蓝牙，app收到相应的命令和状态。
 *@note 此命令要在鉴权命令前发送，且必须已经通过序列号从服务器获取密码1。
 *@param pwd 管理密码。
 *@param completion 执行完成的回调，error参考KDSBleError。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)bindBleWithManagerPassword:(NSString *)pwd completion:(nullable void(^)(KDSBleError error))completion;

/**
 *@abstract 获取序列号。
 *@param completion 收到ble回复数据后执行的回调，如果error成功，则sn返回序列号(17字节)，否则sn为nil。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getSN:(nullable void(^)(KDSBleError error, NSString * __nullable sn))completion;

/**
 *@abstract 获取开锁总次数。1.1.15
 *@param completion 收到ble回复数据后执行的回调，如果error成功，则times返回开锁次数，否则times无意义(负数)。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getUnlockTimes:(nullable void(^)(KDSBleError error, int times))completion;

/**
 *@abstract 获取锁参数。1.1.20beta4
 *@param type 参数类型，1:密匙属性，2:锁型号，3:锁软件版本，4:锁硬件版本，5:电量。
 *@param completion 收到ble回复数据后执行的回调，如果error成功，则value返回参数信息，否则为nil。value对应的参数信息如下：
 *
 *当参数类型type为1时：NSData类型，byte0最大密码数，byte1最大卡片数，byte2最大指纹数，byte3最大人脸数，byte4最大指静脉数，byte    5最大策略个数，byte6最小密码长度，byte7最大密码长度。当不支持某种开锁方式时值为0.
 *
 *当参数类型type为2时：NSString类型，锁型号。新锁有个功能集编号不知道是什么东西，这里不提取了。默认值xxxxxxx。
 *
 *当参数类型type为3时：NSString类型，锁软件版本，有默认值Vx.xx.xxx。
 *
 *当参数类型type为4时：NSString类型，锁硬件版本，bleVersion=3的版本有值，其它为默认值Vx.xx.xx。
 *
 *当参数类型type为5时：NSNumber类型，锁电量，0~100.
 *
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getLockParam:(int)type completion:(nullable void(^)(KDSBleError error, id _Nullable value))completion;

/**
 *@brief 获取锁中保存的操作记录。不一定每一条记录都能获取到，使用者应自行判断记录总数和回调返回的总数是否相等来确定是否每一条记录都成功获取。新蓝牙。
 *@param data 获取指定数据后的操作记录，如果该参数为空，则获取所有操作记录。一般传KDSBleOpRec的hexString值。
 *@param completion 获取到记录后执行的回调，查询全部记录时，每获取到10条数据会执行一次回调，因此回调有可能会执行多次。如果error不成功且records为nil，表明遇到了错误，锁没有回复数据；finished表示获取操作是否已结束。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)getOpRecAfterData:(nullable NSString *)data completion:(nullable void(^)(BOOL finished, KDSBleError error, NSArray<KDSBleOpRec *> * __nullable records))completion;

/**
 *@abstract 根据receipt删除队列中的任务。由于硬件不支持取消命令，实际上只是把当前队列中还没执行的任务删除而已，无法取消命令。
 *@param receipt 任务凭证，@"0"、@"00"、@""、nil等不是有效的凭证。
 */
- (void)cancelTaskWithReceipt:(NSString *)receipt;

/************************************************************************
*       凯迪仕--瑞瀛--合作项目   以下为瑞瀛网关蓝牙协议             *
************************************************************************/
/**
 *@brief 发送wifi账户密码进行路由配网。
 *@param data 获取指定数据后的操作记录，如果该参数为空，则获取所有操作记录。一般传KDSBleOpRec的hexString值。
 *@param completion 返回配网成功或失败。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)sendaccountData:(nullable NSString *)data completion:(nullable void(^)(KDSBleError error))completion;

/************************************************************************
*       凯迪仕--瑞瀛--合作项目   以上为瑞瀛网关蓝牙协议             *
************************************************************************/

/**
     Wi-Fi+BLE门锁配网涉及到的蓝牙协议
 */

/**
*@brief 涉及到0x92、0x93、0x94、0x95指令回复ACK。
*@param control 0：代表Payload没有进行加密处理。
*@param cmd 中控指令具体指向的命令。
*@param value 0:成功、1:失败。
*/
-(void)sendBleAndWiFiResponseInOrOutNet:(int)control tsn:(int)tsn cmd:(int)cmd value:(int)value;
/**
*@brief 发送ssid到mk（分包发送一包14字节内容，最大32字节长度）。
*@param SSID_len SSID总长度
*@param SSID_index 包序号，第N包（从0开始）
*@param ssidData 原始码(14字节)
*@cmd 中控指令
*/
-(void)sendWiFiSSIDWithSSID_len:(int)SSID_len SSID_index:(int)SSID_index cmd:(int)cmd SSIDData:(NSData *)ssidData completion:(nullable void(^)(KDSBleError error))completion;



#pragma mark - 通知相关的通知名字或者方法。
/** 蓝牙断开连接的通知，发出通知时，userInfo的"peripheral"属性附带被断开连接的蓝牙外设 */
FOUNDATION_EXTERN NSString * const KDSBleDidDisconnectNotification;
/** 开锁通知，发出通知时userInfo的"peripheral"属性附带当前正在连接的蓝牙外设 */
FOUNDATION_EXTERN NSString * const KDSLockDidOpenNotification;
/** 关锁通知，发出通知时userInfo的"peripheral"属性附带当前正在连接的蓝牙外设 */
FOUNDATION_EXTERN NSString * const KDSLockDidCloseNotification;
/** 当启动搜索用户列表和计划列表后，每当有新的用户被搜索到就会发出通知，userInfo的"users"属性附带当前搜索到的所有用户。 */
FOUNDATION_EXTERN NSString * const KDSLockUsersDidUpdateNotification;
/** 当启动搜索用户列表和计划列表后，每当有新的计划被搜索到就会发出通知，userInfo的"schedules"属性附带当前搜索到的所有计划。 */
FOUNDATION_EXTERN NSString * const KDSLockSchedulesDidUpdateNotification;
/** 锁鉴权失败/未鉴权的通知，发出通知时userInfo的"peripheral"属性附带当前正在连接的蓝牙外设，code属性附带错误码(NSNumber) */
FOUNDATION_EXTERN NSString * const KDSLockAuthFailedNotification;
/** 锁上报报警信息的通知，发出通知时userInfo的"peripheral"属性为当前连接的蓝牙外设。"data"属性为协议报警数据(NSData20字节) */
FOUNDATION_EXTERN NSString * const KDSLockDidAlarmNotification;
/** 锁操作上报的通知，发出通知时userInfo的"peripheral"属性为当前连接的蓝牙外设。"data"属性为协议报警数据(NSData20字节)，有些操作需要从主动上报的信息确认是否成功，例如开门(用开门通知)、添加卡片和指纹等。 */
FOUNDATION_EXTERN NSString * const KDSLockDidReportNotification;

@end
NS_ASSUME_NONNULL_END

//
//  CBPeripheral+Extension.h
//  BLETest
//
//  Created by zhaowz on 2017/9/13.
//  Copyright © 2017年 zhaowz. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (Extension)

/**给系统的CBPeripheral增加属性：用来保存广播包中的数据*/
@property (nonatomic, copy, nullable)NSString *advDataLocalName;
///mac地址，从advDataLocalName中提取后12位后添加:号，如果advDataLocalName长度小于12，则返回nil。
@property (nonatomic, strong, nullable, readonly) NSString *mac;
///是否是新蓝牙设备。bleVersion：1为旧蓝牙透传协议，2和3为新蓝牙自有协议。
@property (nonatomic, assign) BOOL isNewDevice;
///新蓝牙锁的产品型号，180A服务2A26特征的值，蓝牙协议标注的是FirmwareRev。大写如果包含DB2可以添加20个密码，其它可以添加10个密码。
@property (nonatomic, strong, nullable) NSString *lockModelType;
///新蓝牙锁最大能设置的密码(用户)数，根据lockModelType判断。不失一般性，如果lockModelType属性为nil，返回默认的10个。
@property (nonatomic, assign, readonly) NSUInteger maxUsers;
///新蓝牙模块代号，180A服务的2A24特征的值，如果等于RGBT1761，则开锁时不用密码。
@property (nonatomic, strong, nullable) NSString *lockModelNumber;
///新蓝牙用，根据lockModelNumber是否等于RGBT1761或RGBT1761D判断开锁时是否需要密码。
@property (nonatomic, assign, readonly) BOOL unlockPIN;
///蓝牙锁的序列号，180A服务2A25特征。
@property (nonatomic, strong, nullable) NSString *serialNumber;
///蓝牙锁的硬件版本号，180A服务2A27特征。
@property (nonatomic, strong, nullable) NSString *hardwareVer;
///蓝牙锁的软件版本号，180A服务2A28特征。
@property (nonatomic, strong, nullable) NSString *softwareVer;
///蓝牙锁的电量，FFB0服务FFB1特征，0-100.每次连接和开锁时会更新。工具类会自动赋值，如果没有设置过此值，默认返回负数。
@property (nonatomic, assign) int power;
///锁是否是自动模式，从FFF0服务FFF3特征中提取。连接后首次工具类会自动赋值。
@property (nonatomic, assign) BOOL isAutoMode;
///锁音量，从FFF0服务FFF5特征中提取。0静音，1低音，2高音。连接后首次工具类会自动赋值，如果没有设置过此值，默认返回负数。。
@property (nonatomic, assign) int volume;
///锁语言，从FFF0服务FFF4特征中提取。zh中文，en英文。连接后首次工具类会自动赋值。
@property (nonatomic, strong, nullable) NSString *language;
/**
 *@brief 蓝牙模块功能版本，区分蓝牙是旧的还是新的。如果此值等于1或者2则判断为旧蓝牙，默认为1.
 *
 *1:第一版蓝牙，转发锁的协议，无FFD0或1802服务，即无OAD复位服务则为1，仅支持开门、电量、开锁记录。
 *
 *2:第二版蓝牙，蓝牙自有协议，有服务FFD0或1802服务且无FFE1特征，即有OAD复位服务且没有FFE1特征则为2，仅支持开门、电量、开锁记录、设备信息。
 *
 *3:第三版蓝牙，蓝牙自有协议，有服务FFD0或1802服务且有FFE1特征，即有OAD复位服务且包含FFE1特征则为3。本APP开发的全新功能至少对应于此版本。
 */
@property (nonatomic, assign) int bleVersion;
/// 功能集文件KDSLockOptions.h有详细定义。
@property (nonatomic, strong,nullable) NSString *functionSet;
///蓝牙能否连接
@property (nonatomic,assign)BOOL connectable;
///是否支持菜单绑定
@property (nonatomic,assign)BOOL menuBindable;
///是否支持直接绑定
@property (nonatomic,assign)BOOL directBindable;
///是否为美标锁
@property (nonatomic,assign)BOOL isMeibiaoLock;
///是否支持ble+wifi
@property (nonatomic,assign)BOOL isBleAndWifi;
///锁是否是自动模式，从FFF0服务FFF3特征中提取。连接后首次工具类会自动赋值。
@property (nonatomic, assign) BOOL isAwayModel;

@end

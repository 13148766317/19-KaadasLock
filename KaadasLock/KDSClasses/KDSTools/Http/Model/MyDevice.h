//
//  MyDevice.h
//  kaadas
//
//  Created by ise on 16/9/12.
//  Copyright © 2016年 ise. All rights reserved.
//
#import "KDSCodingObject.h"

/**
 *@abstract 设备型号枚举。
 */
typedef NS_ENUM(NSUInteger, KDSDeviceModel) {
    ///T5
    KDSDeviceModelT5,
    ///X5
    KDSDeviceModelX5,
};

///暂时发现前面16个属性是请求绑定设备列表接口服务器返回的，其余的有些是本地定义的。
@interface MyDevice : KDSCodingObject 

@property (nonatomic ,strong) NSString *_id;
///锁蓝牙密码1，根据锁SN请求服务器返回。
@property (nonatomic, copy) NSString *password1;
///蓝牙密码2，绑定成功后锁返回的data的16进制字符串。
@property (nonatomic, copy) NSString *password2;
///锁的蓝牙昵称
@property (nonatomic, copy) NSString *lockNickName;      //锁的昵称
///1:管理员 0：普通用户
@property (nonatomic, copy) NSString *is_admin;
///开锁策略：1：年月日 2：周 3：默认(只要密码对，随时都可以开)
@property (nonatomic, copy) NSString *open_purview;
///是否打开了自动开锁：2表示打开 0或1表示没有打开
@property (nonatomic, strong) NSString * isAutoLock;
///锁的中心纬度
@property (nonatomic, assign) double center_latitude;
///锁的中心经度
@property (nonatomic, assign) double center_longitude;
/// 半径
@property (nonatomic, assign) double circle_radius;
///锁的蓝牙Mac地址
@property (nonatomic, copy) NSString *devmac;
/** 外设的蓝牙名称(实际上是advDataLocalName) */
@property (nonatomic, copy) NSString *lockName;          //名称(实际上是advDataLocalName)
///锁型号，蓝牙2A26特征返回的值，小凯的包含X5或者T5。
@property (nonatomic, strong) NSString *model;
///锁蓝牙固件版本号，蓝牙2A28特征返回的值。
@property (nonatomic, strong) NSString *softwareVersion;
///锁蓝牙SN序列号，180A服务2A25特征。
@property (nonatomic, strong) NSString *deviceSN;
///锁蓝牙identifier，当蓝牙在boot模式只能靠identifierUUID连接。
@property (nonatomic, strong) NSString *peripheralId;
///绑定时间，距70年的本地时间秒数。
@property (nonatomic, assign) NSTimeInterval createTime;
///服务器当前时间，距70年的本地时间秒数。
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval nowTime;

/**
 *@brief 蓝牙模块功能版本，区分蓝牙是旧的还是新的。如果此值等于1或者2则判断为旧蓝牙，只支持开锁和查开锁记录。
 *
 *1:第一版蓝牙，转发锁的协议，广播名称以KDS或KdsLock开头。
 *
 *2:第二版蓝牙，蓝牙自有协议，广播名称不能以KDS或KdsLock开头，且没有FFE1特征。
 *
 *3:第三版蓝牙，蓝牙自有协议，广播名称不能以KDS或KdsLock开头，且包含FFE1特征。本APP开发的全新功能至少对应于此版本。
 */
@property (nonatomic, strong) NSString *bleVersion;
@property (nonatomic, strong) NSString *macLock;
/// 功能集文件KDSLockOptions.h有详细定义。
@property (nonatomic, strong) NSString *functionSet;

///锁的边缘经度
@property (nonatomic, assign) double edge_longitude;
///锁的边缘纬度
@property (nonatomic, assign) double edge_latitude;
/** 外设的蓝牙人可读的名称，= peripheral.name */
@property (nonatomic, copy) NSString *deviceType;   //设备类型(实际上是外设名:peripheral.name) 为了以后拓展使用
///用户id
@property (nonatomic, copy) NSString *user_id;
///锁的id
@property (nonatomic, copy) NSString *cid;
///开始时间，设置锁的年、月、日、周计划时使用
@property (nonatomic, copy) NSString *datestart;
///结束时间，设置锁的年、月、日、周计划时使用
@property (nonatomic, copy) NSString *dateend;              //结束时间
///重复的周期(周一至周日)，设置锁的年、月、日、周计划时使用
@property (nonatomic, strong) NSArray *items;               //
///锁蓝牙是否是离家状态
@property (nonatomic, assign) BOOL isAwayHome;          // 是否为离家状态
///锁蓝牙是否是高优先级，自动连接蓝牙时使用。
@property (nonatomic, assign) BOOL isHighPriority;
///锁蓝牙是否等待过高优先级2秒
@property (nonatomic, assign) BOOL isWait;              // 是否等待过高优先级2秒
///增加satisfyCount属性 是因为在室内gps定位飘逸，导致用户定位点超出锁范围，而实际并没有超出 如果连续定位10次超出范围，就认为用户的确超出了锁的设置范围
@property (nonatomic, assign) NSInteger satisfyCount;   //用户和锁的距离超过用户设置锁范围的次数
///纬度跨度
@property (nonatomic, copy) NSString *spanLatitude;
///经度跨度
@property (nonatomic, copy) NSString *spanLongitude;


@end

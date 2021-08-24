//
//  KDSWifiLockModel.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockModel : KDSCodingObject
///wifi锁SN
@property (nonatomic,strong)NSString * wifiSN;
///锁SN
@property (nonatomic,strong)NSString * productSN;
///产品型号
@property (nonatomic,strong)NSString * productModel;
///门锁昵称
@property (nonatomic,strong)NSString * lockNickname;
///用户ID
@property (nonatomic,strong)NSString * uid;
///设备软件版本
@property (nonatomic,strong)NSString * softwareVersion;
///wifi锁的功能集
@property (nonatomic,strong)NSString * functionSet;
///1:管理员 0：普通用户
@property (nonatomic, copy)NSString * isAdmin;
///绑定的时候从锁上获取的28字节的随机数
@property (nonatomic,strong)NSString * randomCode;
///wifi名称（设备绑定的wifi名称)
@property (nonatomic,strong)NSString * wifiName;
///设备的唯一ID
@property (nonatomic,strong)NSString * _id;
///设备管理员账号
@property (nonatomic,strong)NSString * adminName;
///主用户的Uid
@property (nonatomic,strong)NSString * adminUid;
///分享用户ID
@property (nonatomic,strong)NSString * appId;
///推送开关： 1(0默认开启)开启推送 2关闭推送
@property (nonatomic,strong)NSString * pushSwitch;
///用户账号
@property (nonatomic,strong)NSString * uname;
///蓝牙版本号
@property (nonatomic,strong)NSString * bleVersion;
///wifi锁固件版本
@property (nonatomic,strong)NSString * lockFirmwareVersion;
///wifi锁设备软件版本
@property (nonatomic,strong)NSString * lockSoftwareVersion;
///mqtt版本号
@property (nonatomic,strong)NSString * mqttVersion;
///wifi版本号
@property (nonatomic,strong)NSString * wifiVersion;
///人脸固件版本
@property (nonatomic,strong)NSString * faceVersion;
///wifi锁的语言：en/zh
@property (nonatomic,strong)NSString * language;
///wifi锁语音模式：0语音模式 1静音模式
@property (nonatomic,strong)NSString * volume;
///模式：0自动模式 1手动模式
@property (nonatomic,strong)NSString * amMode;
///安全模式：0通用模式 1安全模式
@property (nonatomic,strong)NSString * safeMode;
///布防：0撤防 1布防
@property (nonatomic,strong)NSString * defences;
///反锁：0解除反锁1反锁
@property (nonatomic,strong)NSString * operatingMode;
///面容识别模式:0面容识别关闭，1面容识别开启
@property (nonatomic,strong)NSString * faceStatus;
///节能模式:1节能模式开启，0节能模式关闭
@property (nonatomic,strong)NSString * powerSave;
///更新数据的时间距离1970年的秒数
@property (nonatomic,assign)NSTimeInterval updateTime;
///绑定设备的时间距离1970年的秒数
@property (nonatomic,assign)NSTimeInterval createTime;
///服务器当前时间距离1970年的秒数
@property (nonatomic, assign)NSTimeInterval currentTime;
///wifi锁的电量
@property (nonatomic, assign)int power;
///门锁开关状态。1为关锁，2为开锁，3为主锁舌伸出。
@property (nonatomic, assign)int openStatus;
///门锁开关状态更新时间
@property (nonatomic, assign)NSTimeInterval openStatusTime;
///单火开关的json数据
@property (nonatomic, strong)NSDictionary * switchDev;
///单火开关的键位昵称
@property (nonatomic, strong)NSArray * switchNickname;
///配网方式。0为默认（APP不传时存储），1、为WIFI配网，2、为BLE+WIFI配网,3、XMWIFI模组配网
@property (nonatomic, assign)int distributionNetwork;

/************讯美p2p需要的字段*****/
///设备SN/序列号 [ 32 ]
@property (nonatomic, strong)NSString * device_sn;
///mac 地址 [32]
@property (nonatomic, strong)NSString * mac;
///设备DID
@property (nonatomic, strong)NSString * device_did;
///p2p访问连接密码,每次绑定会刷新
@property (nonatomic, strong)NSString * p2p_password;
///视频长连接状态：1是，0否
@property (nonatomic,assign)int keep_alive_status;
///重复日期:[1,2,3,4,5,6,7]
@property (nonatomic,strong)NSArray * keep_alive_snooze;
///开始时间0~86400秒数
@property (nonatomic,assign)int snooze_start_time;
///结束时间0~86400秒数
@property (nonatomic,assign)int snooze_end_time;
///徘徊检测开关状态1是，0否
@property (nonatomic,assign)int stay_status;
///徘徊时间检测范围 10-60 秒
@property (nonatomic,assign)int stay_time;
///PIR 灵敏度范围 0-100
@property (nonatomic,assign)int pir_sen;
///PIR相关的字段（徘徊时间检测范围 10-60 秒：int stay_time,PIR 灵敏度范围 0-100：int pir_sen）
@property (nonatomic, strong)NSDictionary * setPir;
//人脸徘徊报警开关
@property(nonatomic, assign) NSUInteger hoverAlarm;
//人脸徘徊报警灵敏度设置
@property(nonatomic, assign) NSUInteger hoverAlarmLevel;
///P2P视频长连接方式：keep_alive_snooze--array重复日期，snooze_start_time--int 开始时间，snooze_end_time--int 结束时间
@property (nonatomic, strong)NSDictionary * alive_time;
///视频模组版本
@property (nonatomic,strong)NSString * camera_version;
///摄像头硬件版本
@property (nonatomic,strong)NSString * device_model;
///视频模组微控制器版本
@property (nonatomic,strong)NSString * mcu_version;
///讯美Wi-Fi固件版本
@property (nonatomic,strong)NSString * WIFIversion;

//新增wifi锁信息
@property (nonatomic,strong)NSString * RSSI;
@property (nonatomic,assign)NSInteger  wifiStrength;
@property (nonatomic,strong)NSString * lockMac;

// x9 新增信息
///开门方向
@property (nonatomic,assign)int openDirection;
///开门力量
@property (nonatomic,assign)int  openForce;
///上锁方式
@property (nonatomic,assign)int  lockingMethod;
// 新增版本字段
@property (nonatomic,strong)NSString * frontPanelVersion;
@property (nonatomic,strong)NSString * backPanelVersion;

///感应门把手， 0 感应把手关闭；1 感应把手开启
@property (nonatomic,assign)int touchHandleStatus;
///显示屏亮度 , 80 代表高亮，50 代表中等亮度，30 代表低亮
@property (nonatomic,assign)int screenLightLevel;
///亮屏开关
@property (nonatomic,assign)int screenLightSwitch;
///亮屏时间，单位秒
@property (nonatomic,assign)int screenLightTime;
///传感器敏感度，1 高灵敏度，2 中灵敏度，3 低灵敏度，4 关闭传感器
@property (nonatomic,assign)int bodySensor;
///语音设置。 0 静音；1 中音量；2 高音量
@property (nonatomic,assign)int volLevel;
///胁迫报警开关，0:关闭胁迫报警，1:开启胁迫报警
@property (nonatomic,assign)int duressAlarmSwitch;

@end

NS_ASSUME_NONNULL_END

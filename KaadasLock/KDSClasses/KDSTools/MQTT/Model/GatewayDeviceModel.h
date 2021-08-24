//
//  GatewayDeviceModel.h
//  lock
//
//  Created by wzr on 2018/8/1.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "KDSCodingObject.h"

@interface GatewayDeviceModel : KDSCodingObject
@property (nonatomic, copy) NSString *deviceType;//设备类型
@property (nonatomic, copy) NSString *deviceId;//设备id
@property (nonatomic, copy) NSString *jointype;
///入网时间，格式yyyy-MM-dd HH:mm:ss.SSS
@property (nonatomic, copy) NSString *joinTime;//设备入网时间
///服务器当前时间。距70年的秒数，时区无关。
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, copy) NSString *gatewayId;
@property (nonatomic, copy) NSString *gwId;//设备对应的网关

@property (nonatomic, strong) NSString *number;//编号
@property (nonatomic, strong) NSString *nickName;//昵称
    
@property (nonatomic, strong) NSString *macaddr;//mac地址
@property (nonatomic, strong) NSString *SW;//版本号
///kdszblock kdscateye
@property (nonatomic, strong) NSString *device_type;//模块类型
///online offline
@property (nonatomic, strong) NSString *event_str;//状态

@property (nonatomic, assign) int AMAutoRelockTime;//门锁自动上锁 手动上锁

@property (nonatomic, assign) BOOL isAdmin;//主用户或授权用户
///分享设备标记，1是分享设备，0不是分享设备。
@property (nonatomic, assign) int shareFlag;
///锁型号，锁功能集，锁软件版本，锁硬件版本之间是用分号隔开的<8100Z,8100A>
@property (nonatomic, strong) NSString * lockversion;
///网关锁离线时间
@property (nonatomic, strong) NSString * offlineTime;
///网关锁上学时间
@property (nonatomic, strong) NSString * onlineTime;
//推送开关： 1(0默认开启)开启推送 2关闭推送
@property (nonatomic, strong) NSString * pushSwitch;


@end

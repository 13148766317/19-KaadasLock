//
//  KDSBleAndWiFiSendPwdAndSSIDVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleAndWiFiSendPwdAndSSIDVC : KDSBaseViewController

///Wi-Fi锁的数据模型
@property (nonatomic,strong)KDSWifiLockModel * model;
///路由器的账号
@property (nonatomic,strong)NSString * wifiNameStr;
///路由器的mac地址
@property (nonatomic,strong)NSString * bssid;
///路由器的密码
@property (nonatomic,strong)NSString * pwdStr;
///手动编辑Wi-Fi SSID标记
@property (nonatomic,assign) BOOL auto2Hand;
///上个页面创建的蓝牙工具，赋值后请将蓝牙工具的代理设置成本类的对象，否则本类的对象无法接收蓝牙返回的信息，重置、绑定第二步才必须设置。
@property (nonatomic, weak) KDSBluetoothTool *bleTool;

@end

NS_ASSUME_NONNULL_END

//
//  KDSSendPwdAndSSIDVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/3/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSendPwdAndSSIDVC : KDSBaseViewController

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

@end

NS_ASSUME_NONNULL_END

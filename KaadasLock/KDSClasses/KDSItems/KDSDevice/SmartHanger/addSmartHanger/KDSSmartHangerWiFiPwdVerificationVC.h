//
//  KDSSmartHangerWiFiPwdVerificationVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/8.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSBluetoothTool.h"
#import "KDSAMapLocationManager.h"
#import "KDSAddSmartHangerStep2VC.h"
#import "KDSSmartHangerSendSSIDAndPwdVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSmartHangerWiFiPwdVerificationVC : KDSBaseViewController

@property (nonatomic,strong)KDSWifiLockModel * model;

@property (nonatomic, weak) KDSBluetoothTool *bleTool;

@property (nonatomic, strong) CBPeripheral *destPeripheral;

@property (nonatomic, strong) UIButton * connectBtn;

@property (nonatomic, strong) UIView * supView;
///Wi-Fi名称输入框
@property (nonatomic, strong) UITextField * wifiNametf;
///密码输入框
@property (nonatomic, strong) UITextField * pwdtf;
///明文切换的按钮
@property (nonatomic, strong) UIButton * pwdPlaintextSwitchingBtn;

@property (nonatomic, strong) UIView *routerProtocolView;
///手动编辑Wi-Fi SSID标记
@property (nonatomic,assign) BOOL auto2Hand;
///只有是Wi-Fi状态才可以配网
@property (nonatomic,assign) BOOL wifiStatus;
///手动编辑前的wifi的ssid
@property (nonatomic, strong) NSString * wifiNametemp;
///wifi的bssid
@property (nonatomic, strong) NSString * bssidLb;

@end

NS_ASSUME_NONNULL_END

//
//  KDSBleAndWiFiDoorLockVerificationVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleAndWiFiDoorLockVerificationVC : KDSBaseViewController

///管理员密码
@property (nonatomic,strong)NSString * adminPwd;
///密码因子
@property (nonatomic,strong) NSData * crcData;
///上个页面创建的蓝牙工具，赋值后请将蓝牙工具的代理设置成本类的对象，否则本类的对象无法接收蓝牙返回的信息，重置、绑定第二步才必须设置。
@property (nonatomic, weak) KDSBluetoothTool *bleTool;
@property (nonatomic, assign) int tsn;

@end

NS_ASSUME_NONNULL_END

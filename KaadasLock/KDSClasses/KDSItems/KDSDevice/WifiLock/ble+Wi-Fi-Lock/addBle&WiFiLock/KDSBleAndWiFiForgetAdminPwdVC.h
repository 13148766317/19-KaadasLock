//
//  KDSBleAndWiFiForgetAdminPwdVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/21.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleAndWiFiForgetAdminPwdVC : KDSBaseViewController
///上个页面创建的蓝牙工具，赋值后请将蓝牙工具的代理设置成本类的对象，否则本类的对象无法接收蓝牙返回的信息，重置、绑定第二步才必须设置。
@property (nonatomic, weak) KDSBluetoothTool *bleTool;
@end

NS_ASSUME_NONNULL_END

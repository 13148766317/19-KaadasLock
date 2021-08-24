//
//  KDSBleAndWiFiDeviceConnectionStep1VC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/15.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSBluetoothTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleAndWiFiDeviceConnectionStep1VC : KDSBaseViewController <KDSBluetoothToolDelegate>

///上个页面创建的蓝牙工具，赋值后请将蓝牙工具的代理设置成本类的对象，否则本类的对象无法接收蓝牙返回的信息，重置、绑定第二步才必须设置。
@property (nonatomic, weak) KDSBluetoothTool *bleTool;
///要连接的目标外设，重置、绑定第二步才必须设置。
@property (nonatomic, strong) CBPeripheral *destPeripheral;

@end

NS_ASSUME_NONNULL_END

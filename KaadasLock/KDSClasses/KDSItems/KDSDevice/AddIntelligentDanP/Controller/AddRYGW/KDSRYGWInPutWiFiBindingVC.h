//
//  KDSRYGWInPutWiFiBindingVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSRYGWInPutWiFiBindingVC : KDSBaseViewController<KDSBluetoothToolDelegate>

///上个页面创建的蓝牙工具，赋值后请将蓝牙工具的代理设置成本类的对象，否则本类的对象无法接收蓝牙返回的信息。
@property (nonatomic, weak) KDSBluetoothTool *bleTool;
///要连接的目标外设。
@property (nonatomic, strong) CBPeripheral *destPeripheral;
///设备类型。
@property (nonatomic, assign) KDSDeviceModel model;

@end

NS_ASSUME_NONNULL_END

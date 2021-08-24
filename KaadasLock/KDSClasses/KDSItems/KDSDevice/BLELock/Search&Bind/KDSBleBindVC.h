//
//  KDSBleBindVC.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSBluetoothTool.h"
#import "KDSDeviceModelCell.h"
#import "KDSBleSearchTableVC.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleBindVC : KDSBaseViewController <KDSBluetoothToolDelegate>

///上个页面创建的蓝牙工具，赋值后请将蓝牙工具的代理设置成本类的对象，否则本类的对象无法接收蓝牙返回的信息，重置、绑定第二步才必须设置。
@property (nonatomic, weak) KDSBluetoothTool *bleTool;
///要连接的目标外设，重置、绑定第二步才必须设置。
@property (nonatomic, strong) CBPeripheral *destPeripheral;
///是否是已绑定的设备，默认否，重置、绑定第二步才必须设置。
@property (nonatomic, assign) BOOL hasBinded;
///设备类型。
@property (nonatomic, assign) KDSDeviceModel model;
///第几步，如果提示装电池请设置为0，如果搜索界面点绑定进去请设置为1，默认0.
@property (nonatomic, assign) int step;

@end

NS_ASSUME_NONNULL_END

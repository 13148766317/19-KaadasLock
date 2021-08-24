//
//  KDSBleSearchTableVC.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSTableViewController.h"
#import "KDSDeviceModelCell.h"
#import "KDSBluetoothTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleSearchTableVC : KDSTableViewController

///型号。
@property (nonatomic, assign) KDSDeviceModel model;
///蓝牙工具类。
@property (nonatomic, strong, readonly) KDSBluetoothTool *bleTool;

@end

NS_ASSUME_NONNULL_END

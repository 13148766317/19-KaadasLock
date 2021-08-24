//
//  KDSRYGWSearchTableVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSTableViewController.h"
#import "KDSDeviceModelCell.h"
#import "KDSBluetoothTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSRYGWSearchTableVC : KDSTableViewController

///型号。
@property (nonatomic, assign) KDSDeviceModel model;
///蓝牙工具类。
@property (nonatomic, strong, readonly) KDSBluetoothTool *bleTool;

@end

NS_ASSUME_NONNULL_END

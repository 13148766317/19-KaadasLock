//
//  KDSBleAndWiFiSearchBluToothVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"
#import "KDSDeviceModelCell.h"
#import "KDSBluetoothTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleAndWiFiSearchBluToothVC : KDSTableViewController

///型号。
@property (nonatomic, assign) KDSDeviceModel model;

@end

NS_ASSUME_NONNULL_END

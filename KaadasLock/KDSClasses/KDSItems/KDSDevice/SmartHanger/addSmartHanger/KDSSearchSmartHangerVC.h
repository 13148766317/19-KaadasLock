//
//  KDSSearchSmartHangerVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/6.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"
#import "KDSBluetoothTool.h"
#import "KDSSearchSmartHangerCell.h"
#import "KDSHttpManager+Ble.h"
#import "KDSBleAndWiFiDeviceConnectionStep1VC.h"
#import "KDSSmartHangerConnectedVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSearchSmartHangerVC : KDSTableViewController

@property (nonatomic,strong) UIImageView * addSmartHangerlogoImg;
///已绑定的蓝牙，从服务器获取，重新请求时清除。
@property (nonatomic, strong) NSArray<MyDevice *> *devices;
///搜索到的蓝牙，重新搜索时清除数据。
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralsArr;

@property (nonatomic, strong) UILabel *label;

@end

NS_ASSUME_NONNULL_END

//
//  KDSOldBLELockVC.h
//  KaadasLock
//
//  Created by orange on 2019/5/6.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *@brief 旧版本蓝牙锁页面，除开锁、修改昵称、查看蓝牙基本信息、升级外，其它功能都不支持。
 *
 *1:bleVersion为1的老蓝牙模块，转发锁的协议，无FFD0或1802服务，即无OAD复位服务则为1，仅支持开门、电量、开锁记录。
 *
 *2:bleVersion为2的老蓝牙模块，蓝牙自有协议，有服务FFD0或1802服务且无FFE1特征，即有OAD复位服务且没有FFE1特征则为2，仅支持开门、电量、开锁记录、设备信息。
 *
 */
@interface KDSOldBLELockVC : KDSAutoConnectViewController

@end

NS_ASSUME_NONNULL_END

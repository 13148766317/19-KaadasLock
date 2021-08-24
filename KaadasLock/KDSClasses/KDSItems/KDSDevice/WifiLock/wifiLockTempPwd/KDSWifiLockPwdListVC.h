//
//  KDSWifiLockPwdListVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockPwdListVC : KDSBaseViewController

@property (nonatomic,strong) KDSLock * lock;
///密匙类型。授权成员传KDSGWKeyTypeReserved。
@property (nonatomic, assign) KDSBleKeyType keyType;

@end

NS_ASSUME_NONNULL_END

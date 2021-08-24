//
//  KDSWifiLockPwdShareVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockPwdShareVC : KDSAutoConnectViewController

///pin model.
@property (nonatomic, strong) KDSPwdListModel *model;
///密匙类型。授权成员传KDSBleKeyTypeReserved。
@property (nonatomic, assign) KDSBleKeyType keyType;


@end

NS_ASSUME_NONNULL_END

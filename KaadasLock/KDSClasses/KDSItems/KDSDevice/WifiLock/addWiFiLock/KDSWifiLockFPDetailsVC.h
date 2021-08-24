//
//  KDSWifiLockFPDetailsVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/28.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockFPDetailsVC : KDSAutoConnectViewController

///密匙类型。授权成员传KDSBleKeyTypeReserved。
@property (nonatomic, assign) KDSBleKeyType keyType;
///model, KDSPwdListModel or KDSAuthMember object.
@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END

//
//  KDSLockKeyDetailsVC.h
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSLockKeyDetailsVC : KDSAutoConnectViewController

///密匙类型。授权成员传KDSBleKeyTypeReserved。
@property (nonatomic, assign) KDSBleKeyType keyType;
///model, KDSPwdListModel or KDSAuthMember object.
@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END

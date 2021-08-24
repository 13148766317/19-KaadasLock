//
//  KDSGWAddPINPermanentVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/30.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWAddPINPermanentVC : KDSBaseViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///密码类型，0永久、年月日计划，1周计划，2临时，3胁迫。还没做周计划和胁迫。
@property (nonatomic, assign) int type;
///要添加的密匙类型。授权成员传KDSGWKeyTypeReserved。
@property (nonatomic, assign) KDSGWKeyType keyType;

@end

NS_ASSUME_NONNULL_END

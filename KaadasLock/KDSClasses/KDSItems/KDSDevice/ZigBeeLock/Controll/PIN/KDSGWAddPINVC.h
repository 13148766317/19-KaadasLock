//
//  KDSGWAddPINVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

///网关锁添加密码。
@interface KDSGWAddPINVC : KDSBaseViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///密匙类型。授权成员传KDSGWKeyTypeReserved。
@property (nonatomic, assign) KDSGWKeyType keyType;

@end

NS_ASSUME_NONNULL_END

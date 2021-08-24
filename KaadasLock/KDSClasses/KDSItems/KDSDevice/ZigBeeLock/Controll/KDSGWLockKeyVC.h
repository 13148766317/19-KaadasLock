//
//  KDSGWLockKeyVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWLockKeyVC : KDSTableViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///密匙类型。授权成员传KDSGWKeyTypeReserved。
@property (nonatomic, assign) KDSGWKeyType keyType;

@end

NS_ASSUME_NONNULL_END

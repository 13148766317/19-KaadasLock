//
//  KDSGWAddPINProxyVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWAddPINProxyVC : KDSTableViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///密码类型，0永久、年月日计划，1周计划，2临时，3胁迫。设置胁迫密码前，请先检查胁迫密码是否已满。
@property (nonatomic, assign) int type;
///密匙类型。授权成员传KDSGWKeyTypeReserved。
@property (nonatomic, assign) KDSGWKeyType keyType;

@end

NS_ASSUME_NONNULL_END

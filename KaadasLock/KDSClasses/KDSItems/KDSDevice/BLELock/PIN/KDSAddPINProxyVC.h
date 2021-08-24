//
//  KDSAddPINProxyVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddPINProxyVC : KDSTableViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///密码类型，0永久、年月日计划，1周计划，2临时。
@property (nonatomic, assign) int type;
///是否支持20组密码
@property (nonatomic, assign) BOOL isSupport20setsPasswords;

@end

NS_ASSUME_NONNULL_END

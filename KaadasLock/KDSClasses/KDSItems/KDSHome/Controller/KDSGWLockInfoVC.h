//
//  KDSGWLockInfoVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/26.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

///网关锁。
@interface KDSGWLockInfoVC : KDSBaseViewController

///绑定的设备对应的门锁模型，设置此属性前，请确保gwDevice已设置。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

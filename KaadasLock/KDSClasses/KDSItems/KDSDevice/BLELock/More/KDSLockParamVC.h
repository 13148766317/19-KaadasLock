//
//  KDSLockParamVC.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSTableViewController.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

///密码管理->更多设置->锁参数信息。
@interface KDSLockParamVC : KDSTableViewController

///associated lock.
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

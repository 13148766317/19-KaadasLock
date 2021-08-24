//
//  KDSDuressSettingAccountController.h
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDuressSettingAccountController : KDSBaseViewController

//关联的锁。
@property (nonatomic, strong) KDSLock *lock;

//关联数据源
@property (nonatomic, strong) KDSPwdListModel *model;

@end

NS_ASSUME_NONNULL_END

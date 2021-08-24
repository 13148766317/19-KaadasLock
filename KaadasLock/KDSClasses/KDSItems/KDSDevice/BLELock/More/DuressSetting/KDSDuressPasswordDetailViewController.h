//
//  KDSDuressPasswordDetailViewController.h
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSPwdListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDuressPasswordDetailViewController : KDSBaseViewController

//关联的锁。
@property (nonatomic, strong) KDSLock *lock;

//关联数据源
@property (nonatomic, strong) KDSPwdListModel *model;

//定义密码类型 1：密码  2：指纹
@property (nonatomic, assign) int accountType;

@end

NS_ASSUME_NONNULL_END

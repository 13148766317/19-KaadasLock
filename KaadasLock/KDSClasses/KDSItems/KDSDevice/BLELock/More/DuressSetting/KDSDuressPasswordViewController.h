//
//  KDSDuressPasswordViewController.h
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDuressPasswordViewController : KDSBaseViewController

//关联的锁。
@property (nonatomic, strong) KDSLock *lock;

///密匙类型。授权成员传KDSGWKeyTypeReserved。
@property (nonatomic, assign) KDSBleKeyType keyType;


@end

NS_ASSUME_NONNULL_END

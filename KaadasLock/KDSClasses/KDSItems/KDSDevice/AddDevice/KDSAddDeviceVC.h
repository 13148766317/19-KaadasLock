//
//  KDSAddDeviceVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/6/25.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddDeviceVC : KDSBaseViewController

///网关数组
@property (nonatomic,strong)NSArray<KDSGW *> *gateways;

@end

NS_ASSUME_NONNULL_END

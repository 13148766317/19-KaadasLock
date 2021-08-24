//
//  KDSSaveLockVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBindingGatewayVC.h"
#import "KDSMQTT.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSaveLockVC : KDSBaseViewController

///The associated gateway.
@property (nonatomic, strong) KDSGW *gw;
///The device bind to gateway.
@property (nonatomic, strong) GatewayDeviceModel *device;

@end

NS_ASSUME_NONNULL_END

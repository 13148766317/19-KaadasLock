//
//  KDSSaveCatEyeVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/11.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayModel.h"
#import "GatewayDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSaveCatEyeVC : KDSBaseViewController

///绑定猫眼所在的网关
@property (nonatomic,readwrite,strong)GatewayModel * gatewayModel;
///猫眼的设备ID
@property (nonatomic,readwrite,strong)NSString * deviceId;


@end

NS_ASSUME_NONNULL_END

//
//  KDSAddCatEye4VC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayModel.h"
#import "GatewayDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddCatEye4VC : KDSBaseViewController

///是否入网成功
@property (nonatomic,assign)BOOL isSuccess;
///关联的网关
@property (nonatomic,readwrite,strong)GatewayModel * gatewayModel;
///关联的猫眼
@property (nonatomic,readwrite,strong)GatewayDeviceModel * gatewayDeviceModel;
///猫眼的设备ID
@property (nonatomic,readwrite,strong)NSString * deviceId;

@end

NS_ASSUME_NONNULL_END

//
//  KDSCatEyeDetailsVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSCatEye.h"
#import "GatewayModel.h"
#import "GatewayDeviceModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface KDSCatEyeDetailsVC : KDSBaseViewController
///关联的猫眼
@property (nonatomic,readwrite,strong) KDSCatEye * cateye;
///猫眼所在的网关
@property (nonatomic,readwrite,strong) GatewayModel * gatewayModel;
@property (nonatomic,readwrite,strong) GatewayDeviceModel * gatewayDeviceModel;

@end

NS_ASSUME_NONNULL_END

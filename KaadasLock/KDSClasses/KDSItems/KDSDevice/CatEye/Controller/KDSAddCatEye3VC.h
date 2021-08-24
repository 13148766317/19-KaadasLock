//
//  KDSAddCatEye3VC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface KDSAddCatEye3VC : KDSBaseViewController

///扫描的结果
@property (nonatomic,readwrite,strong)NSString * dataString;
///网关所在网段的密码
@property (nonatomic,readwrite,strong)NSString * wifiPwd;
///网关所在的网段名字
@property (nonatomic,readwrite,strong)NSString * gwSid;
///猫眼的设备ID
@property (nonatomic,readwrite,strong)NSString * deviceId;
///添加的设备所在的网关
@property (nonatomic,readwrite,strong)GatewayModel * gatewayModel;

@property (nonatomic,readwrite,strong)NSString * deviceSN;
@property (nonatomic,readwrite,strong)NSString * deviceMac;

@end

NS_ASSUME_NONNULL_END

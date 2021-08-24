//
//  KDSScanGatewayVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/11.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSScanGatewayVC : KDSBaseViewController

///标识是从那个控制器跳转过来的
@property (nonatomic,readwrite,strong)NSString * fromWhereVC;
///网关所在网段的密码
@property (nonatomic,readwrite,strong)NSString * wifiPwd;
///网关所在的网段名字
@property (nonatomic,readwrite,strong)NSString * gwSid;
///网关模型
@property (nonatomic,readwrite,strong)GatewayModel * gatewayModel;

@end

NS_ASSUME_NONNULL_END

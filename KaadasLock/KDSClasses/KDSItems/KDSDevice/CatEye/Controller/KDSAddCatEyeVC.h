//
//  KDSAddCatEyeVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/9.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddCatEyeVC : KDSBaseViewController

///网关所在网段密码
@property (nonatomic,strong)NSString * gwConfigPwd;
///网关所在wifi名称
@property (nonatomic,strong)NSString * gwConfigWifiSsid;
///网关模型
@property (nonatomic,strong)KDSGW * gateway;

@end

NS_ASSUME_NONNULL_END

//
//  KDSAddZigBeeLockVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSMQTT.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddZigBeeLockVC : KDSBaseViewController

///The associated gateway.
@property (nonatomic, strong) KDSGW *gw;

///网关所在网段密码
@property (nonatomic,strong)NSString * gwConfigPwd;
///网关所在wifi名称
@property (nonatomic,strong)NSString * gwConfigWifiSsid;

@end

NS_ASSUME_NONNULL_END

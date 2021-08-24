//
//  KDSAddCatEyeVCStep1.h
//  KaadasLock
//
//  Created by zhaona on 2019/7/2.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddCatEyeVCStep1 : KDSBaseViewController

///网关所在网段密码
@property (nonatomic,strong)NSString * gwConfigPwd;
///网关所在wifi名称
@property (nonatomic,strong)NSString * gwConfigWifiSsid;
///网关本地模型
@property (nonatomic,strong)KDSGW * gateway;

@end

NS_ASSUME_NONNULL_END

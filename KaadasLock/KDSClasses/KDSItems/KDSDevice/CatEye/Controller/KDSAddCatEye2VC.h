//
//  KDSAddCatEye2VC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddCatEye2VC : KDSBaseViewController
///扫描得到的数据
@property(nonatomic,readwrite,strong)NSString * dataStr;
///网关所在网段的密码
@property (nonatomic,readwrite,strong)NSString * wifiPwd;
///网关所在的网段名字
@property (nonatomic,readwrite,strong)NSString * gwSid;
///网关模型
@property (nonatomic,readwrite,strong)KDSGW * gateway;

@end

NS_ASSUME_NONNULL_END

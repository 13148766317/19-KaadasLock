//
//  KDSVideoLockDistributionNetworkVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
//-->正在配网中，请稍后...页面
@interface KDSVideoLockDistributionNetworkVC : KDSBaseViewController

///wifi的账号
@property (nonatomic,strong)NSString * ssid;
///wifi的密码
@property (nonatomic,strong)NSString * pwd;

@end

NS_ASSUME_NONNULL_END

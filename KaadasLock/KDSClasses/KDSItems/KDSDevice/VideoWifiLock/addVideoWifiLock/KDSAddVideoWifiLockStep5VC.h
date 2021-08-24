//
//  KDSAddVideoWifiLockStep5VC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/8.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddVideoWifiLockStep5VC : KDSAutoConnectViewController
///wifi的账号
@property (nonatomic,strong)NSString * ssid;
///wifi的密码
@property (nonatomic,strong)NSString * pwd;
///门锁已联网，重新配网
@property (nonatomic,assign)BOOL  isAgainNetwork;

@end

NS_ASSUME_NONNULL_END

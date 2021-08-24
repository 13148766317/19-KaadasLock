//
//  KDSMediaLockInPutAdminPwdVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSMediaLockInPutAdminPwdVC : KDSBaseViewController

///密码因子:（46个字节）28字节的随机数+4字节CRC+13字节wifiSN+1字节功能集
@property (nonatomic,strong) NSString * crcData;
///wifi锁的模型
@property (nonatomic,strong) KDSWifiLockModel * model;

@end

NS_ASSUME_NONNULL_END

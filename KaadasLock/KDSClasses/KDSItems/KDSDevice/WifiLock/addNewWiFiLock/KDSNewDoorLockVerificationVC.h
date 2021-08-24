//
//  KDSNewDoorLockVerificationVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/3/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSNewDoorLockVerificationVC : KDSBaseViewController

///管理员密码
@property (nonatomic,strong)NSString * adminPwd;
///修改管理员密码后的密码因子
@property (nonatomic,strong)NSString * upDataAdminiContinueStr;

@end

NS_ASSUME_NONNULL_END

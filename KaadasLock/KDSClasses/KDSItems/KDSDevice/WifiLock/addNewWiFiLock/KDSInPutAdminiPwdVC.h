//
//  KDSInPutAdminiPwdVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/3/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSInPutAdminiPwdVC : KDSBaseViewController
///修改管理员密码后重新下发的密码因子
@property (nonatomic,strong)NSString * upDataAdminiContinueStr;

@end

NS_ASSUME_NONNULL_END

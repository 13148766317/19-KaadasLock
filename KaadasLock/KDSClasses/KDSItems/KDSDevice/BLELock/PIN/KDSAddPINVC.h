//
//  KDSAddPINVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddPINVC : KDSAutoConnectViewController

///existed passwords 时效、周期、临时
@property (nonatomic, strong) NSArray<KDSBleUserType *> *existedUsers;
///是否支持20组密码
@property (nonatomic, assign) BOOL isSupport20setsPasswords;

@end

NS_ASSUME_NONNULL_END

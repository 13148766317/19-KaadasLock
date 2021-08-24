//
//  KDSSwitchAddSettingVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/6/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSwitchAddSettingVC : KDSBaseViewController

@property (nonatomic,strong)KDSLock * lock;
///单火开关的json数据(要设置的数据)
@property (nonatomic, strong)NSDictionary * tempSwitchDev;

@end

NS_ASSUME_NONNULL_END

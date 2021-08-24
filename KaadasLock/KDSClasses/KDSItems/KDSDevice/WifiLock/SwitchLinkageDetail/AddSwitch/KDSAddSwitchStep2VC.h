//
//  KDSAddSwitchStep2VC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddSwitchStep2VC : KDSBaseViewController

@property (nonatomic,strong) KDSLock * lock;
///单火开关的json数据(要设置的数据)
@property (nonatomic, strong)NSDictionary * tempSwitchDev;
///表明下一步的动作（设置、添加开关）
@property (nonatomic, strong)NSString * actionSting;

@end

NS_ASSUME_NONNULL_END

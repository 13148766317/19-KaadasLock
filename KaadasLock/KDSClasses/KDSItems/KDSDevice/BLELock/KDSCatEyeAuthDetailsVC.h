//
//  KDSCatEyeAuthDetailsVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/7/1.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSCatEyeAuthDetailsVC : KDSBaseViewController

///被授权的猫眼
@property (nonatomic, strong)KDSCatEye * cateye;
@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END

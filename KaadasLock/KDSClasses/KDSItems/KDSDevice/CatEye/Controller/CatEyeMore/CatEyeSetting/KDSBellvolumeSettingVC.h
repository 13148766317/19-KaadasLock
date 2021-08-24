//
//  KDSBellvolumeSettingVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/5/13.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSCatEye.h"
#import "KDSGWCateyeParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBellvolumeSettingVC : KDSBaseViewController

@property (nonatomic,readwrite,strong)KDSCatEye * cateye;

@property(nonatomic,readwrite,strong)KDSGWCateyeParam * cateyeParam;

@end

NS_ASSUME_NONNULL_END

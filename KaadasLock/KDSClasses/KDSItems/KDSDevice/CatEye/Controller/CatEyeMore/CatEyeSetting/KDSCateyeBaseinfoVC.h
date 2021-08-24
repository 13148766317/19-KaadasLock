//
//  KDSCateyeBaseinfoVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSCatEye.h"
#import "KDSGWCateyeParam.h"

NS_ASSUME_NONNULL_BEGIN

///猫眼基本信息
@interface KDSCateyeBaseinfoVC : KDSBaseViewController

@property(nonatomic,strong)KDSCatEye * cateye;

@property(nonatomic,readwrite,strong)KDSGWCateyeParam * cateyeParam;

@end

NS_ASSUME_NONNULL_END

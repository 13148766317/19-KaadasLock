//
//  CateyePIRSilenceVC.h
//  lock
//
//  Created by zhaona on 2019/4/23.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSGWCateyeParam.h"
#import "KDSCatEye.h"

NS_ASSUME_NONNULL_BEGIN

@interface CateyePIRSilenceVC : KDSBaseViewController

@property(nonatomic,strong)KDSGWCateyeParam * deviceModel;
@property (nonatomic, strong) KDSCatEye * cateye;

@end

NS_ASSUME_NONNULL_END

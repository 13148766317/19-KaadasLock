//
//  KDSGWDetailVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSGW.h"
#import "KDSNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWDetailVC : KDSBaseViewController

@property(nonatomic,readwrite,strong)KDSGW * gateway;

@end

NS_ASSUME_NONNULL_END

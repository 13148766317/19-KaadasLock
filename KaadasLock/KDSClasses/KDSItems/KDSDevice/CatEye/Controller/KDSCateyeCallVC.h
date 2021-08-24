//
//  KDSCateyeCallVC.h
//  KaadasLock
//
//  Created by wzr on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "SIPUACTU.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSCateyeCallVC : KDSBaseViewController <TUDelegate>
@property (nonatomic,readwrite,strong) GatewayDeviceModel * gatewayDeviceModel;
///the transaction user
@property (nonatomic, strong) SIPUACTU *tu;

@end

NS_ASSUME_NONNULL_END

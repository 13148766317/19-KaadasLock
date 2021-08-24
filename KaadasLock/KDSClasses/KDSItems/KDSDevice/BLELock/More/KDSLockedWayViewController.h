//
//  KDSLockedWayViewController.h
//  KaadasLock
//
//  Created by kaadas on 2021/3/1.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSLockedWayViewController : KDSAutoConnectViewController
///上锁方式的回调
@property (nonatomic, copy) void (^lockedModeChangeBlock)(int newLockedMode);

@end


NS_ASSUME_NONNULL_END

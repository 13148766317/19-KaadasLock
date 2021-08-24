//
//  KDSUserManager+DeviceStateUpdate.h
//  KaadasLock
//
//  Created by Apple on 2021/5/20.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSUserManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSUserManager (DeviceStateUpdate)
//更新锁的信息,当前是电量
-(void) updateWifiLockModel:(NSString *) wifiSN  lockInfo:(NSDictionary *) lockInfo;
@end

NS_ASSUME_NONNULL_END

//
//  KDSUserManager+DeviceStateUpdate.m
//  KaadasLock
//
//  Created by Apple on 2021/5/20.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSUserManager+DeviceStateUpdate.h"

@implementation KDSUserManager (DeviceStateUpdate)
//更新锁的信息,当前是电量
-(void) updateWifiLockModel:(NSString *) wifiSN  lockInfo:(NSDictionary *) lockInfo {
    if (wifiSN && lockInfo) {
        KDSWifiLockModel *wifiLockModel = [self findWifiLockModelWithWifiSN:wifiSN];
        if (wifiLockModel) {
            
            NSNumber *power = lockInfo[@"power"];
            
            if (power) {
                wifiLockModel.power = [power unsignedIntValue];
            }
            
        }
        
    }
}
-(KDSWifiLockModel *) findWifiLockModelWithWifiSN:(NSString *)wifiSN {
    __block KDSWifiLockModel *result = nil;
    if (wifiSN) {
        [self.locks enumerateObjectsUsingBlock:^(KDSLock * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.wifiDevice && [obj.wifiDevice.wifiSN isEqualToString:wifiSN]) {
                result = obj.wifiDevice;
                *stop = YES;
            }
        }];
    }
    return result;
}
@end

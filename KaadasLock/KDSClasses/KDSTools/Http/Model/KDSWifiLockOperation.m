//
//  KDSWifiLockOperation.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockOperation.h"

@implementation KDSWifiLockOperation

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSWifiLockOperation *obj = (KDSWifiLockOperation *)object;
    return self.time == obj.time && self.pwdType == obj.pwdType && self.type == obj.type && self.pwdNum == obj.pwdNum && [self._id isEqualToString:obj._id];
    
}

- (NSUInteger)hash
{
    NSString *combine = [NSString stringWithFormat:@"%@%d%d%.6lf", self.wifiSN, self.pwdNum, self.type, self.time];
    return combine.hash;
}

@end

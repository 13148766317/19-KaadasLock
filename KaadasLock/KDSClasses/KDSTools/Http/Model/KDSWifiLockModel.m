//
//  KDSWifiLockModel.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockModel.h"

@implementation KDSWifiLockModel

+(NSDictionary*)mj_replacedKeyFromPropertyName{
    return @{@"switchDev" :@"switch",
             };
}
- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    if (self == object) return YES;
    KDSWifiLockModel *other = object;
    return [self.wifiSN isEqualToString:other.wifiSN] && [self._id isEqualToString:other._id] && self.isAdmin.boolValue == other.isAdmin.boolValue;
}

- (NSUInteger)hash
{
    return self.wifiSN.hash  + self.isAdmin.boolValue;
}

@end

//
//  KDSWifiLockAlarmModel.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockAlarmModel.h"

@implementation KDSWifiLockAlarmModel

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSWifiLockAlarmModel *model = object;
    return  self.type==model.type && self.time==model.time && [self.wifiSN isEqualToString:model.wifiSN];
}

- (NSUInteger)hash
{
    NSString *combine = [NSString stringWithFormat:@"%d%.6lf", self.type, self.time];
    NSUInteger hash = [self.wifiSN stringByAppendingString:combine].hash;
    return hash;
}

@end

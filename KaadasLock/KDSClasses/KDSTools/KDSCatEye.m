//
//  KDSCatEye.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/24.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEye.h"

@implementation KDSCatEye

- (instancetype)init
{
    self = [super init];
    if (self) {
     self.powerDidrequest = NO;
    }
    return self;
}
- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSCatEye *catEye = object;
    if (catEye.gatewayDeviceModel && self.gatewayDeviceModel) return [catEye.gatewayDeviceModel isEqual:self.gatewayDeviceModel];
    return NO;
}
- (NSString *)name
{
    return self.gatewayDeviceModel.nickName;
}

- (BOOL)online
{
    return self.gw.online && [self.gatewayDeviceModel.event_str isEqualToString:@"online"];
}

@end

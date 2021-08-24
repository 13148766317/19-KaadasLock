//
//  GatewayDeviceModel.m
//  lock
//
//  Created by wzr on 2018/8/1.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "GatewayDeviceModel.h"
#import <MJExtension/MJExtension.h>

@implementation GatewayDeviceModel

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    GatewayDeviceModel *m = object;
    return self.deviceId && [m.deviceId isEqualToString:self.deviceId];
}

- (NSUInteger)hash
{
    return self.deviceId.hash;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"joinTime":@"time"};
}

@end

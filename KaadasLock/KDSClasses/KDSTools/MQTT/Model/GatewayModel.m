//
//  GatewayModel.m
//  lock
//
//  Created by zhaowz on 2018/5/2.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "GatewayModel.h"
//#import <objc/runtime.h>
#import <MJExtension/MJExtension.h>
#import "KDSGW.h"

@implementation GatewayModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"devices" : @"deviceList"};
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"devices" : GatewayDeviceModel.class};
}

- (instancetype)init{
    if (self = [super init]) {
//        _nickname = Localized(@"我的网关");
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) return YES;
    if ([object isKindOfClass:KDSGW.class])
    {
        KDSGW *gw = object;
        return gw.model && [self isEqual:gw.model];
    }
    else if ([object isKindOfClass:GatewayModel.class])
    {
        GatewayModel *m = object;
        return self.deviceSN && [m.deviceSN isEqualToString:self.deviceSN];
    }
    return NO;
}

- (NSUInteger)hash
{
    return self.deviceSN.hash;
}

@end

//
//  KDSLock.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLock.h"
#import "KDSBleAssistant.h"

@implementation KDSLock

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = KDSLockStateInitial;
        self.power = -1;
        self.connected = NO;
        self.powerUpdated = NO;
    }
    return self;
}

- (NSString *)name
{
    if (self.gwDevice) return self.gwDevice.nickName;
    if (self.wifiDevice) return self.wifiDevice.lockNickname;
    if (self.hangerModel){
        return self.hangerModel.hangerNickName;
    }
    return self.device.lockNickName ?: self.device.lockName;
}

- (NSString *)lockFunctionSet
{
    NSString * funSetStr;
    if (!self.device.functionSet) {
        if (self.device.bleVersion.intValue != 3) {
            funSetStr = @"0x00";
        }if (!self.device.model) {
            funSetStr = @"0x31";
        }else{
            if ([self.device.model hasPrefix:@"V6"] || [self.device.model hasPrefix:@"S100"]) {
                funSetStr = @"0x20";
            }else if ([self.device.model hasPrefix:@"S8"]){
                funSetStr = @"0x32";
            }else if ([self.device.model hasPrefix:@"V7"]){
                funSetStr = @"0x20";
            }else if ([self.device.model hasPrefix:@"K9"]){
                funSetStr = @"0x01";
            }else if ([self.device.model hasPrefix:@"S6"]){
                funSetStr = @"0x20";
            }else{
                funSetStr = @"0x31";
            }
        }
    }else{
        int a = self.device.functionSet.intValue;
        u_int8_t ttt;
        NSData *data = [NSData dataWithBytes:&a length:sizeof(ttt)];
        funSetStr = [NSString stringWithFormat:@"0x%@",[KDSBleAssistant convertDataToHexStr:data]];
    }
    return funSetStr;
}
- (NSString *)wifiLockFunctionSet
{
    int a = self.wifiDevice.functionSet.intValue;
    u_int8_t ttt;
    return [NSString stringWithFormat:@"0x%@",[KDSBleAssistant convertDataToHexStr:[NSData dataWithBytes:&a length:sizeof(ttt)]]];
}
- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSLock *lock = object;
    if (lock.device && self.device) return [lock.device isEqual:self.device];
    if (lock.gwDevice && self.gwDevice) return [lock.gwDevice isEqual:self.gwDevice];
    if (lock.wifiDevice && self.wifiDevice) return [lock.wifiDevice isEqual:self.wifiDevice];
    if (lock.gw && self.gw) return [lock.gw isEqual:self.gw];
    if(lock.hangerModel && self.hangerModel) {
        return [lock.hangerModel isEqual:self.hangerModel];
    }
    return NO;
}

- (BOOL)connected
{
    if (self.device)
    {
        return _connected;
    }
    else if (self.gwDevice && self.gw)
    {
        return self.gw.online && [self.gwDevice.event_str isEqualToString:@"online"];
    }else if (self.hangerModel) {
        return self.hangerModel.onlineState;
    }
    return self.gw.online;
}

@end

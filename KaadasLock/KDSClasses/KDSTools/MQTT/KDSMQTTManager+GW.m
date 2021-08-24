//
//  KDSMQTTManager+GW.m
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+GW.h"
#import <MJExtension/MJExtension.h>

@implementation KDSMQTTManager (GW)

- (KDSMQTTTaskReceipt *)gwGetDeviceListBindToGateway:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, NSArray<KDSGWBindedDevice *> * _Nullable))completion
{
    return [self gw:gateway performFunc:@"getDeviceList" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (!success)
        {
            completion(error, nil);
        }
        else if (![response[@"devList"] isKindOfClass:NSArray.class])
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil);
        }
        else
        {
            completion(nil, [KDSGWBindedDevice mj_objectArrayWithKeyValuesArray:response[@"devList"]].copy);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw deleteDevice:(GatewayDeviceModel *)device completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    if (!device.deviceId) device.deviceId = @"";
    return [self gw:gw performFunc:MQTTFuncDeleteDevice withParams:@{@"bustype":@"zigbee", @"deviceId":device.deviceId} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetNetSetting:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, KDSGWNetSetting * _Nullable))completion
{
    return [self gw:gateway performFunc:@"getNetBasic" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        !completion ?: completion(error, success ? [KDSGWNetSetting mj_objectWithKeyValues:response] : nil);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetWifiSetting:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))completion
{
    return [self gw:gateway performFunc:@"getWiFiBasic" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            NSString *ssid = response[@"ssid"];
            NSString *pwd = response[@"pwd"];
            NSString *encryption = response[@"encryption"];
            if (![ssid isKindOfClass:NSString.class] || (pwd && ![pwd isKindOfClass:NSString.class]) || (encryption && ![encryption isKindOfClass:NSString.class]))
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil, nil, nil);
            }
            else
            {
                completion(nil, ssid, pwd, encryption);
            }
        }
        else
        {
            completion(error, nil, nil, nil);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetChannel:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self gw:gateway performFunc:@"getZbChannel" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            NSString *channel = response[@"channel"];
            NSError *e = [channel isKindOfClass:NSString.class] ? nil : [NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil];
            completion(e, !e, e ? -9999 : channel.intValue);
        }
        else
        {
            completion(error, NO, -9999);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetDevicePower:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self gw:gateway performFunc:MQTTFuncGetPower withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            NSNumber *power = response[@"power"];
            NSError *e = [power isKindOfClass:NSNumber.class] ? nil : [NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil];
            completion(e, !e, e ? -9999 : power.intValue);
        }
        else
        {
            completion(error, NO, -9999);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetTime:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL, NSString * _Nullable, NSInteger))completion
{
    return [self gw:gateway performFunc:MQTTFuncGetTime withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            NSString *zone = response[@"timezone"];
            NSString *timestamp = response[@"timevalue"];
            NSError *e = ([zone isKindOfClass:NSString.class] && [timestamp isKindOfClass:NSString.class]) ? nil : [NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil];
            completion(e, !e, e ? nil : zone, e ? 0 : timestamp.integerValue);
        }
        else
        {
            completion(error, success, nil, 0);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetMemeState:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self gw:gateway performFunc:@"getMemevpnStatus" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            NSString *status = response[@"memeStatus"];
            NSError *e = [status isKindOfClass:NSString.class] ? nil : [NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil];
            completion(e, !e, e ? -9999 : status.intValue);
        }
        else
        {
            completion(error, NO, -9999);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetStat:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, KDSGWStat * _Nullable))completion
{
    return [self gw:gateway performFunc:@"getRa0Stat" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success ? [KDSGWStat mj_objectWithKeyValues:response] : nil);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gwGetPir:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL, int, int, int, int, int, BOOL))completion
{
    return [self gw:gateway performFunc:@"getPirSilent" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        if (success)
        {
            NSNumber *periodtime = response[@"periodtime"];
            NSNumber *threshold = response[@"threshold"];
            NSNumber *protecttime = response[@"protecttime"];
            NSNumber *ust = response[@"ust"];
            NSNumber *maxprohibition = response[@"maxprohibition"];
            NSNumber *enable = response[@"enable"];
            Class cls = NSNumber.class;
            if (![periodtime isKindOfClass:cls] || ![threshold isKindOfClass:cls] || ![protecttime isKindOfClass:cls] || ![ust isKindOfClass:cls] || ![maxprohibition isKindOfClass:cls] || ![enable isKindOfClass:cls])
            {
                !completion ?: completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999, -9999, -9999, -9999, -999, NO);
            }
            else
            {
                !completion ?: completion(nil, YES, periodtime.intValue, threshold.intValue, protecttime.intValue, ust.intValue, maxprohibition.intValue, enable.intValue==1 ? YES : NO);
            }
        }
        else
        {
            !completion ?: completion(error, NO, -9999, -9999, -9999, -9999, -9999, NO);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setNetLan:(NSString *)lan mask:(NSString *)mask completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    lan = lan ?: @"192.168.1.15"; mask = mask ?: @"255.255.255.0";
    return [self gw:gw performFunc:@"setNetBasic" withParams:@{@"lanIp":lan, @"lanNetmask":mask} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setWiFiSSID:(NSString *)ssid pwd:(NSString *)pwd encryption:(NSString *)encryption completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    ssid = ssid ?: @"kdsgateway"; pwd = pwd ?: @(arc4random() % 123456 + 338750).stringValue;
    encryption = encryption ?: @"wpa2";
    return [self gw:gw performFunc:@"setWiFiBasic" withParams:@{@"ssid":ssid, @"pwd":pwd, @"encryption":encryption} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setDeviceAccess:(NSString *)mode enable:(BOOL)enable completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    mode = mode ?: @"zigbee";
    return [self gw:gw performFunc:@"setJoinAllow" withParams:@{@"mode" : mode} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setChannel:(int)channel completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFunc:@"setZbChannel" withParams:@{@"channel" : @(channel).stringValue} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
    
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setTime:(NSInteger)time completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFunc:MQTTFuncSetTime withParams:@{@"timezone":@"0", @"timevalue":@(time).stringValue} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setPirEnable:(BOOL)enable withPeriod:(int)period threshold:(int)threshold protectTime:(int)ptime ust:(int)ust maxProhibit:(int)mprohibit completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFunc:@"setPirSilent" withParams:@{@"periodtime":@(period), @"threshold":@(threshold), @"protecttime":@(ptime), @"ust":@(ust), @"maxprohibition":@(mprohibit), @"enable":@(enable)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

@end

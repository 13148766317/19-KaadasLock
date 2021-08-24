//
//  KDSMQTTManager+CY.m
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+CY.h"
#import <MJExtension/MJExtension.h>

@implementation KDSMQTTManager (CY)

- (KDSMQTTTaskReceipt *)cyGetDeviceParams:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, KDSGWCateyeParam * _Nullable))completion
{
    return [self cy:cy performFunc:@"basicInfo" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        KDSGWCateyeParam *param = success ? [KDSGWCateyeParam mj_objectWithKeyValues:response] : nil;
        param.deviceId = cy.deviceId;
        !completion ?: completion(error, param);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cyGetDevicePower:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self cy:cy performFunc:MQTTFuncGetPower withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSNumber *power = response[@"power"];
        if (![power isKindOfClass:NSNumber.class] && success)
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            return;
        }
        completion(error, success, success ? power.intValue : -9999);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cyGetTime:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, BOOL, NSString * _Nullable, NSInteger))completion
{
    return [self cy:cy performFunc:MQTTFuncGetTime withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
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

- (KDSMQTTTaskReceipt *)cyGetSDCardStatus:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self cy:cy performFunc:@"sdStatus" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSNumber *status = response[@"sdStatus"];
        if (![status isKindOfClass:NSNumber.class] && success)
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            return;
        }
        completion(error, success, success ? status.intValue : -9999);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setTime:(NSInteger)time completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:MQTTFuncSetTime withParams:@{@"timezone":@"0", @"timevalue":@(time).stringValue} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setBell:(int)bell completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setBellNum" withParams:@{@"bellNum" : @(bell)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setVolume:(NSString*)volume completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setBellVolume" withParams:@{@"bellVolume" :volume } returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setPirEnable:(NSString *)enable completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setPirEnable" withParams:@{@"pirStatus" :enable} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setResolution:(NSString *)resolution completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setVedioRes" withParams:@{@"resolution" : resolution} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setMessageEnable:(BOOL)enable completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setMbEnable" withParams:@{@"mbStatus" : @(enable)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cyResetDevice:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"restartCamera" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cyWakeup:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"wakeupCamera" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy openFtpRelay:(BOOL)relay withAddress:(NSString *)ip completion:(void (^)(NSError * _Nullable, NSString * _Nullable, NSInteger))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"relay"] = @(relay).stringValue;
    param[@"ipaddr"] = ip;
    return [self cy:cy performFunc:@"setFtpEnable" withParams:param returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        if (!completion) return;
        if (!success)
        {
            completion(error, nil, -9999);
        }
        else
        {
            NSString *ip = response[@"ftpCmdIp"];
            NSNumber *port = response[@"ftpCmdPort"];
            if ([ip isKindOfClass:NSString.class] && [port isKindOfClass:NSNumber.class])
            {
                completion(nil, ip, port.integerValue);
            }
            else
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil, -9999);
            }
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setBellTimes:(int)times completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setBellCount" withParams:@{@"bellCount" : @(times)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setPirWanderTimes:(int)times inSeconds:(int)seconds completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setPirWander" withParams:@{@"wander" : [NSString stringWithFormat:@"%d,%d", times, seconds]} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cy:(GatewayDeviceModel *)cy setCamInfrared:(int)AutomaticModel photoresistorHAcquisition:(int)photoresistorHacquisition photoresistorLacquisition:(int)photoresistorLacquisition completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self cy:cy performFunc:@"setPropertys" withParams:@{@"propertys" :@[@"CamInfrared"],@"values":@[[NSString stringWithFormat:@"%d,%d,%d",AutomaticModel,photoresistorHacquisition,photoresistorLacquisition]]} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)cyGetCamInfrared:(GatewayDeviceModel *)cy completion:(void (^)(NSError * _Nullable, BOOL, NSString * _Nonnull))completion
{
    return [self cy:cy performFunc:@"getPropertys" withParams:@{@"propertys":@[@"CamInfrared"]} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        if (!completion) return;
        if (success) {
            NSArray * automaticModelArr = response[@"values"];
            NSString * automaticModel = automaticModelArr.firstObject;
            [automaticModel isKindOfClass:NSString.class] ? nil : [NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil];
            !completion ?: completion(error,success,success ? automaticModel :nil);
        }else{
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil],nil,@"");
        }
        
    }].receipt;
}


@end

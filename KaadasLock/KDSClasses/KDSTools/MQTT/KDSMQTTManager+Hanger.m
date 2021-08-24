//
//  KDSMQTTManager+Hanger.m
//  KaadasLock
//
//  Created by Apple on 2021/4/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+Hanger.h"

@implementation KDSMQTTManager (Hanger)

- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger light:(HangerSwitch ) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    
    return [self hanger:hanger performFunc:@"setLight" withParams:@{@"switch":@(hangerSwitch)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置晾衣机电机上升/暂停/下降接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger motorAction:(HangerMotorAction) motorAction  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    return [self hanger:hanger performFunc:@"setMotor" withParams:@{@"action":@(motorAction)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置晾衣机风干接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger airDry:(HangerAirDry) airDry  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    return [self hanger:hanger performFunc:@"setAirDry" withParams:@{@"switch":@(airDry)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置晾衣机烘干接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger baking:(HangerBaking) baking  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    return [self hanger:hanger performFunc:@"setBaking" withParams:@{@"switch":@(baking)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置晾衣机消毒接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger uv:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    return [self hanger:hanger performFunc:@"setUV" withParams:@{@"switch":@(hangerSwitch)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置晾衣机童锁接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger childLock:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    return [self hanger:hanger performFunc:@"setChildLock" withParams:@{@"switch":@(hangerSwitch)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置晾衣机语音控制开关接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger loudspeaker:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion {
    return [self hanger:hanger performFunc:@"setLoudspeaker" withParams:@{@"switch":@(hangerSwitch)} enableTimeout:NO  completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 * 获取晾衣机状态
 */
- (KDSMQTTTaskReceipt *)getHangerStatus:(KDSDeviceHangerModel *)hanger   completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion{
    return [self hanger:hanger performFunc:@"getAllStatus" withParams:nil enableTimeout:YES completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}


@end

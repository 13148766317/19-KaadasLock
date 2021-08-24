//
//  KDSMQTTManager+SmartHome.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+SmartHome.h"


@implementation KDSMQTTManager (SmartHome)

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setTriggerActions:(NSDictionary *)actions time:(NSDictionary *)time trigger:(NSDictionary *)trigger contion:(NSDictionary *)contion completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFunc:@"triggerAdd" withScene_rule:@{@"triggerId":@"001",@"triggerName":@"周日场景",@"pushNotification":@0,@"enable":@1,@"time":@{@"startdate":@"2020/2/28",@"starttime":@"14:35",@"enddate":@"2020/2/28",@"endtime":@"15:00",@"timezone":@"+0800"},@"trigger":@{@"deviceId":@"ZG01185110817",@"deviceType":@"timer",@"event":@"14:55"},@"contion":@[]/*@{@"deviceId":gw.deviceSN,@"attributeId":@"Attriid",@"operator":@">",@"value":@"111"}*/,@"actions":@[@{@"deviceId":@"00:12:4b:00:1d:40:10:e2",@"func":@"setControlLight",@"params":@{@"optype":@"openLight",@"ch":@1,@"type":@"pin",@"pin":@"147147",@"userid":[KDSUserManager sharedManager].user.uid}}]}  returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw delTriggerId:(NSString *)triggerId completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFuncAndNoScene_rule:@"triggerDel" triggerId:triggerId returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw getTriggerId:(NSString *)triggerId completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFuncAndNoScene_rule:@"triggerSyn" triggerId:triggerId returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw upDataTriggerId:(NSString *)triggerId completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFuncAndNoScene_rule:@"triggerActivation" triggerId:triggerId returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)addSwitchWithWf:(KDSWifiLockModel *)wf completion:(void (^)(NSError * _Nullable, BOOL, NSInteger, NSString * _Nonnull, NSTimeInterval))completion
{
    return [self wf:wf performFunc:@"addSwitch" withParams:@{} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (!success)
        {
            completion(error, nil, -9999,@"",-9999);
        }
        else
        {
            NSString * type = response[@"type"];
            NSString * macaddr = response[@"mac"];
            NSString * tt = response[@"timestamp"];
            NSTimeInterval time = tt.intValue;
            !completion ?: completion(error, success ,type.integerValue,macaddr,time);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setSwitchWithWf:(KDSWifiLockModel *)wf stParams:(NSArray *)stParams switchEn:(int)switchEn completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setSwitch" withParams:@{@"switchEn":@(switchEn),@"switchArray":stParams} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getSwitchWithWf:(KDSWifiLockModel *)wf completion:(void (^)(NSError * _Nullable, NSArray<KDSDevSwithModel *> * _Nonnull))completion
{
    return [self wf:wf performFunc:@"getSwitch" withParams:@{} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
         NSArray * devSts = [KDSDevSwithModel mj_objectWithKeyValues:response].copy;
         !completion ?: completion(error, success ? devSts : nil);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setLockWithWf:(KDSWifiLockModel *)wf completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLock" withParams:@{@"safeMode":wf.safeMode,@"language":wf.language,@"volume":@(wf.volume.intValue),@"amMode":@(wf.amMode.intValue)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}
- (KDSMQTTTaskReceipt *)setLockLanguageWithWf:(KDSWifiLockModel *)wf language:(NSString *)language completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLock" withParams:@{@"language":language} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setLockSafaModeWithWf:(KDSWifiLockModel *)wf safeMode:(int)safeMode completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLock" withParams:@{@"safeMode":@(safeMode)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
    
}

- (KDSMQTTTaskReceipt *)setLockVolumeWithWf:(KDSWifiLockModel *)wf volume:(int)volume completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLock" withParams:@{@"volume":@(volume)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setLockAmModeWithWf:(KDSWifiLockModel *)wf amMode:(int)amMode completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLock" withParams:@{@"amMode":@(amMode)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setCameraVideoConnectionSettingsWithWf:(KDSWifiLockModel *)wf alive_time:(NSDictionary *)alive_time keep_alive_status:(int)keep_alive_status completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString * snooze_start_time = alive_time[@"snooze_start_time"];
    NSString * snooze_end_time = alive_time[@"snooze_end_time"];
    NSArray * keep_alive_snooze = alive_time[@"keep_alive_snooze"];
    param[@"keep_alive_status"] = @(keep_alive_status);
    param[@"alive_time"] = @{@"keep_alive_snooze":keep_alive_snooze,@"snooze_end_time":@(snooze_end_time.intValue),@"snooze_start_time":@(snooze_start_time.intValue)};
    
    return [self wf:wf performFunc:@"setCamera" withParams:param returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setCameraPIRSensitivitySettingsWithWf:(KDSWifiLockModel *)wf setPir:(NSDictionary *)setPir stay_status:(int)stay_status completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString * stay_time = setPir[@"stay_time"];
    NSString * pir_sen = setPir[@"pir_sen"];
    param[@"stay_status"] = @(stay_status);
    param[@"setPir"] = @{@"stay_time":@(stay_time.intValue),@"pir_sen":@(pir_sen.intValue)};
    
    return [self wf:wf performFunc:@"setCamera" withParams:param returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

///  设置开门方向
- (KDSMQTTTaskReceipt *)setOpenDirectionWithWf:(KDSWifiLockModel *)wf value:(int)value completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setOpenDirection" withParams:@{@"openDirection":@(value)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        !completion ?: completion(error, success);
    }].receipt;
}

///  设置开门力量

- (KDSMQTTTaskReceipt *)setOpenForceWithWf:(KDSWifiLockModel *)wf value:(int)value completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setOpenForce" withParams:@{@"openForce":@(value)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

///  设置上锁方式
- (KDSMQTTTaskReceipt *)setLockingMethodWithWf:(KDSWifiLockModel *)wf value:(int)value completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLockingMethod" withParams:@{@"lockingMethod":@(value)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

/**
 设置人脸徘徊开关
 */
- (KDSMQTTTaskReceipt *)setLockWithWf:(KDSWifiLockModel *)wf hoverAlarm:(NSUInteger) hoverAlarm hoverAlarmLevel:(NSUInteger) hoverAlarmLevel completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setLock" withParams:@{@"hoverAlarm":@(hoverAlarm),@"hoverAlarmLevel":@(hoverAlarmLevel)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setScreenBrightnessWithWf:(KDSWifiLockModel *)wf brightness:(int)brightness completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion{
   
    return [self wf:wf performFunc:@"setCamera" withParams:@{@"screenLightLevel":@(brightness)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
    
}
///设置门铃呼叫时屏亮
- (KDSMQTTTaskReceipt *)setScreenLightWithWf:(KDSWifiLockModel *)wf lightUpSwitch:(int)lightUpSwitch lightTime:(int)lightTime completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion{

    return [self wf:wf performFunc:@"setCamera" withParams:@{@"screenLightSwitch":@(lightUpSwitch),@"screenLightTime":@(lightTime)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
    
}
///设置音量水平
- (KDSMQTTTaskReceipt *)setVoiceLevelWithWf:(KDSWifiLockModel *)wf voiceLevel:(int)voiceLevel completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion{
    
    return [self wf:wf performFunc:@"setLock" withParams:@{@"volLevel":@(voiceLevel)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
    
}

@end

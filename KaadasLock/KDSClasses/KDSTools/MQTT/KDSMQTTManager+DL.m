//
//  KDSMQTTManager+DL.m
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+DL.h"
#import <MJExtension/MJExtension.h>

@implementation KDSMQTTManager (DL)

- (KDSMQTTTaskReceipt *)dlGetState:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self dl:dl performFunc:@"lockStatus" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * __nullable response) {
        
        if (!completion) return;
        NSString *state = response[@"lockstatus"];
        NSDictionary<NSString *, NSNumber *> *map = @{@"notFullyLocked":@0, @"lock":@1, @"unlock":@2};
        if (success && (![state isKindOfClass:NSString.class] || !map[state]))
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            return;
        }
        completion(error, success, success ? map[state].intValue : -9999);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetKeyInfo:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, KDSGWLockKeyInfo * _Nullable))completion
{
    return [self dl:dl performFunc:@"lockPwdInfo" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        !completion ?: completion(error, success ? [KDSGWLockKeyInfo mj_objectWithKeyValues:response] : nil);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetLanguage:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, NSString * _Nullable))completion
{
    return [self dl:dl performFunc:@"getLang" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSString *language = response[@"lang"];
        if (success && ![language isKindOfClass:NSString.class])
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil);
            return;
        }
        completion(error, success ? language : nil);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetVolume:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self dl:dl performFunc:@"soundVolume" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSNumber *volume = response[@"volume"];
        if (success && ![volume isKindOfClass:NSNumber.class])
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            return;
        }
        completion(error, success, success ? volume.intValue : -9999);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetDevicePower:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self dl:dl performFunc:MQTTFuncGetPower withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            NSNumber *power = response[@"power"];
            NSError *e = [power isKindOfClass:NSNumber.class] ? nil : [NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil];
            completion(e, !e, e ? -9999 : power.intValue / 2);
        }
        else
        {
            completion(error, NO, -9999);
        }
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetTime:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, NSString * _Nullable, NSInteger))completion
{
    return [self dl:dl performFunc:MQTTFuncGetTime withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (success)
        {
            //NSNumber *time = response[@"time"];
            //NSDate *date = [NSDate dateWithTimeIntervalSince1970:time.doubleValue + MQTTFixedTime];
            NSString *zone = response[@"timezone"];//timezone
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

- (KDSMQTTTaskReceipt *)dlGetMaxLogNumber:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self dl:dl performFunc:@"getLogNum" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSNumber *number = response[@"maxlognum"];
        if (success && ![number isKindOfClass:NSNumber.class])
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            return;
        }
        completion(error, success, success ? number.intValue : -9999);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl getLogsBetweenIndex:(int)idx1 andIndex:(int)idx2 completion:(void (^)(NSError * _Nullable, NSArray<NSString *> * _Nullable))completion
{
    return [self dl:dl performFunc:@"getLog" withParams:nil returnData:@{@"logstart":@(idx1), @"logend":@(idx2)} completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSArray *logs = response[@"log"];
        BOOL c = [logs isKindOfClass:NSArray.class];
        if (c)
        {
            for (NSObject *obj in logs)
            {
                if (![obj isKindOfClass:NSString.class])
                {
                    c = NO;
                    break;
                }
            }
        }
        if (success && !c)
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], nil);
            return;
        }
        completion(error, success ? logs : nil);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetDeviceParams:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, KDSGWLockParam * _Nullable))completion
{
    return [self dl:dl performFunc:@"BasicInfo" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success ? [KDSGWLockParam mj_objectWithKeyValues:response] : nil);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetMode:(GatewayDeviceModel *)dl completion:(nullable void(^)(NSError * __nullable error, BOOL success, int mode))completion
{
    return [self dl:dl performFunc:@"getArmLocked" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        if (!completion) return;
        if (success)
        {
            NSNumber *mode = response[@"operatingMode"];
            if (!mode || ![mode isKindOfClass:NSNumber.class])
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            }
            else
            {
                completion(nil, YES, mode.intValue);
            }
        }
        else
        {
            completion(error, NO, -9999);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl getPwdType:(int)pwdNum completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self dl:dl performFunc:@"getUserType" withParams:@{@"userID" : @(pwdNum)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        if (!completion) return;
        if (success)
        {
            NSNumber *uid = response[@"userID"], *type = response[@"userType"];
            if (![uid isKindOfClass:NSNumber.class] || uid.intValue!=pwdNum || ![type isKindOfClass:NSNumber.class])
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            }
            else
            {
                completion(nil, YES, type.intValue);
            }
        }
        else
        {
            completion(error, NO, -9999);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetAMStatus:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, BOOL))completion
{
    return [self dl:dl performFunc:@"getAM" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        if (!completion) return;
        if (success)
        {
            NSNumber *automatic = response[@"autoRelockTime"];
            if (!automatic || ![automatic isKindOfClass:NSNumber.class] || !(automatic.intValue==0 || automatic.intValue==10))
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, -9999);
            }
            else
            {
                completion(nil, YES, automatic.intValue == 10);
            }
        }
        else
        {
            completion(error, NO, -9999);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl operateLock:(BOOL)open withPwd:(NSString *)pwd completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self dl:dl performFunc:@"openLock" withParams:@{@"optype":open ? @"unlock" : @"lock", @"userid"/*v2.2文档从i改为I*/:[KDSUserManager sharedManager].user.uid, @"type":@"pin", @"pin":pwd} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl manageKey:(int)action withPwd:(NSString *)pwd number:(int)number type:(int)type completion:(void (^)(NSError * _Nullable, BOOL, NSString * _Nullable, NSString * _Nullable))completion
{
    pwd = pwd ?: @"";
    NSDictionary *actionMap = @{@0:@"set", @1:@"get", @2:@"clear"};
    NSDictionary *keyMap = @{@1:@"pin", @2:@"fingerprint", @3:@"rfid"};
    NSDictionary *params =  @{@"action":actionMap[@(action)] ?: @"get", @"type":@"pin", @"type":keyMap[@(type)] ?: @"pin", @"pwdid":@(number).stringValue, @"pwdvalue":pwd};
    return [self dl:dl performFunc:@"setPwd" withParams:params returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (!success || !response)
        {
            completion(error, NO, nil, nil);
            return;
        }
        NSNumber *status = response[@"status"];
        if (![status isKindOfClass:NSNumber.class])
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, nil,nil);
            return;
        }
        int code = status.intValue;
        if (action == 1)
        {
            //userType: 0 永久性密钥 userType: 1 策略密钥 userType: 3 管理员密钥 userType: 4 无权限密钥 status：0 表示此pwdid编号没有设置密码
            //status：1 表示此pwdid编号已设置密码
            completion(code==1 ? nil : [NSError errorWithDomain:@"该编号没有设置密码" code:code userInfo:nil], code == 1, code ==1 ? response[@"status"] : nil, code==1 ? response[@"userType"] : nil );
        }
        else
        {
            completion(code==0 ? nil : [NSError errorWithDomain:@"设置/清除密码失败" code:code userInfo:nil], code == 0, nil,nil);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setLanguage:(NSString *)language completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    language = language ?: @"zh";
    return [self dl:dl performFunc:@"setLang" withParams:@{@"language" : language} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setVolume:(int)volume completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self dl:dl performFunc:@"setSoundVolume" withParams:@{@"volume" : @(volume)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setTime:(NSInteger)time completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    //时区好像是按照±86400标准算的，不太确定。
    return [self dl:dl performFunc:MQTTFuncSetTime withParams:@{@"timezone":@"0", @"timevalue":@(time).stringValue} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl scheduleAction:(int)action withSchedule:(KDSGWLockSchedule *)schedule completion:(void (^)(NSError * _Nullable, BOOL, KDSGWLockSchedule * _Nullable))completion
{
    NSDictionary *map = @{@0:@"set", @1:@"get", @2:@"clear"};
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(schedule.scheduleId), @"scheduleId", @(schedule.userId), @"userId", map[@(action)] ?: @"get", @"action", nil];
    if ([schedule.yearAndWeek isEqualToString:@"year"])
    {
        params[@"type"] = @"year";
        params[@"zLocalStartT"] = @(schedule.beginTime.integerValue);
        params[@"zLocalEndT"] = @(schedule.endTime.integerValue);
    }
    else
    {
        params[@"type"] = @"week";
        params[@"dayMaskBits"] = @(schedule.mask);
        params[@"startHour"] = @(schedule.beginH);
        params[@"startMinute"] = @(schedule.beginMin);
        params[@"endHour"] = @(schedule.endH);
        params[@"endMinute"] = @(schedule.endMin);
    }
    
    return [self dl:dl performFunc:@"schedule" withParams:params returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        NSLog(@"设置密码策略成功失败结束：%@--%d",response,success);
        
        if (!completion) return;
        if (success)
        {
            NSNumber *status = response[@"status"] ?: response[@"scheduleStatus"];
            if (![status isKindOfClass:NSNumber.class])
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, nil);
                return;
            }
            if (status.intValue == 1)
            {
                completion([NSError errorWithDomain:@"设置/获取/清除失败" code:1 userInfo:nil], NO, nil);
                return;
            }
            KDSGWLockSchedule *schedule = nil;
            if (action == 1)
            {
                schedule = [KDSGWLockSchedule mj_objectWithKeyValues:response];
                NSLog(@"查询密码策略的结束：%@",response);
                if (status.intValue != 0)//失败
                {
                    completion([NSError errorWithDomain:@"查询失败" code:0 userInfo:nil], NO, nil);
                    return;

                }
            }
            completion(error, success, schedule);
        }
        else
        {
            completion(error, NO, nil);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setDefence:(BOOL)open completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion
{
    return [self dl:dl performFunc:@"setArm" withParams:@{@"operatingMode" : open ? @1 : @0} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setAutoMode:(BOOL)automatic completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self dl:dl performFunc:@"setAM" withParams:@{@"autoRelockTime" : automatic ? @10 : @0} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dl:(GatewayDeviceModel *)dl setPwdType:(int)type withPwdNum:(int)pwdNum completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self dl:dl performFunc:@"setUserType" withParams:@{@"userID":@(pwdNum), @"userType":@(type)} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
         NSLog(@"设置锁密码类型0成功1失败：%d-%@",success,response);
        if (!completion) return;
        if (success)
        {
            NSNumber *status = response[@"status"];
            if (![status isKindOfClass:NSNumber.class])
            {
                completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO);
            }
            else
            {
                completion(nil, status.intValue == 0);//0成功，1失败
            }
        }
        else
        {
            completion(error, NO);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)dlGetSignalStrength:(GatewayDeviceModel *)dl completion:(void (^)(NSError * _Nullable, BOOL, int))completion
{
    return [self dl:dl performFunc:@"getzblocksignal" withParams:nil returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        NSNumber *signal = response[@"signal"];
        if (response && ![signal isKindOfClass:NSNumber.class])
        {
            completion([NSError errorWithDomain:@"网关返回值错误" code:KDSGatewayErrorInvalid userInfo:nil], NO, 9999);
            return;
        }
        completion(error, success, success ? signal.intValue : 9999);
    }].receipt;
}

@end

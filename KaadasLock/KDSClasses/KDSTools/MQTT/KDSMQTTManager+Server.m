//
//  KDSMQTTManager+Server.m
//  KaadasLock
//
//  Created by orange on 2019/7/8.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+Server.h"
#import <MJExtension/MJExtension.h>

#import "KDSUserManager.h"
@implementation KDSMQTTManager (Server)

- (KDSMQTTTaskReceipt *)bindGateway:(NSString *)sn completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    sn = sn ?: @"";
    return [self performServerFunc:MQTTFuncBindGW withParams:@{@"devuuid":sn} completion:^(NSError * __nullable error, BOOL success, id __nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)unbindGateway:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self performServerFunc:MQTTFuncUnbindGW withParams:@{@"devuuid":gateway.deviceSN ?: @""} completion:^(NSError * __nullable error, BOOL success, id __nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

-(KDSMQTTTaskReceipt *)testunbindGateway:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSString *sn = gateway.deviceSN ?: @"";
    return [self performServerFunc:@"testUnBindGateway" withParams:@{@"devuuid":sn, @"gwId":sn} completion:^(NSError * __nullable error, BOOL success, id __nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getGatewayList:(void (^)(NSError * _Nullable, NSArray<GatewayModel *> * _Nullable))completion
{
    return [self performServerFunc:MQTTFuncGWList withParams:@{} completion:^(NSError * _Nullable error, BOOL success, id _Nullable result) {
        if (!completion) return;
        if (error || !result)
        {
            completion(error, nil);
        }
        else if (![result isKindOfClass:NSArray.class])
        {
            completion([NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], nil);
        }
        else
        {
            completion(nil, [GatewayModel mj_objectArrayWithKeyValuesArray:result].copy);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getGatewayAndDeviceList:(void (^)(NSError * _Nullable, NSArray<GatewayModel *> * _Nullable, NSArray<MyDevice *> * _Nullable, NSArray<KDSWifiLockModel *> * _Nullable, NSArray<KDSProductInfoList *> * _Nullable,NSArray<KDSDeviceHangerModel *> *hangerList))completion
{
    return [self performServerFunc:@"getAllBindDevice" withParams:@{@"msgtype":@"request",@"modelSearchType":@2} completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        if (!completion) return;
        
        //dict to json string
        if (result) {
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];
            if(error) {
                KDSLog(@"dict to json error %@",error);
            }else {
                KDSLog(@"json %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
        NSArray *gws = [result valueForKey:@"gwList"], *bles = [result valueForKey:@"devList"] , *wifiList = [result valueForKey:@"wifiList"], *productInfoList = [result valueForKey:@"productInfoList"];
        NSArray *hangerList = [KDSDeviceHangerModel hangersFromDictArray:[result objectForKey:@"hangerList"]];
        
        [[KDSUserManager sharedManager].hangers removeAllObjects];
        if (hangerList && hangerList.count) {
            [[KDSUserManager sharedManager].hangers addObjectsFromArray:hangerList];
        }
        
        
        if ([gws isKindOfClass:NSNull.class]) gws = @[];
        if ([bles isKindOfClass:NSNull.class]) bles = @[];
        if ([wifiList isKindOfClass:NSNull.class]) wifiList = @[];
        if ([productInfoList isKindOfClass:NSNull.class]) productInfoList = @[];
        if (error || !result)
        {
            completion(error, nil, nil,nil,nil,nil);
        }
        else if (![result isKindOfClass:NSDictionary.class] || ![gws isKindOfClass:NSArray.class] || ![bles isKindOfClass:NSArray.class] || ![wifiList isKindOfClass:NSArray.class])
        {
            completion([NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], nil, nil,nil,nil,nil);
        }
        else
        {
            NSArray *gwArr = [GatewayModel mj_objectArrayWithKeyValuesArray:gws].copy;
            for (GatewayModel *gm in gwArr)
            {
                for (GatewayDeviceModel *device in gm.devices) {
                    device.gwId = device.gatewayId = gm.deviceSN;
                    device.currentTime = self.serverTime;
                    device.isAdmin = gm.isAdmin.intValue==1 && device.shareFlag==0;
                }
            }
            NSArray *bleArr = [MyDevice mj_objectArrayWithKeyValuesArray:bles].copy;
            for (MyDevice *dev in bleArr) dev.currentTime = self.serverTime;
            NSArray * wifiArr = [KDSWifiLockModel mj_objectArrayWithKeyValuesArray:wifiList].copy;
            NSArray * productInfoListArr = [KDSProductInfoList mj_objectArrayWithKeyValuesArray:productInfoList].copy;

            
            completion(nil, gwArr, bleArr, wifiArr,productInfoListArr,hangerList);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gatewayRegisterAndBindMeme:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSString *func = MQTTFuncRBMeme;
    NSString *sn = gateway.deviceSN ?: @"";
    return [self performServerFunc:func withParams:@{@"devuuid":sn, @"gwId":sn} completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getDeviceListBindToGateway:(GatewayModel *)gateway completion:(void (^)(NSError * _Nullable, NSArray<GatewayDeviceModel *> * _Nullable))completion
{
    NSString *func = MQTTFuncDeviceList;
    NSString *sn = gateway.deviceSN ?: @"";
    NSDictionary *params = @{@"devuuid":sn};
    return [self performServerFunc:func withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        
        if (!completion) return;
        if (!result)
        {
            completion(error, nil);
            return;
        }
        NSDictionary *response = result;
        NSArray *list = [response valueForKey:@"deviceList"];
        NSString *devuuid = [response valueForKey:@"devuuid"];
        if (![response isKindOfClass:NSDictionary.class] || ![list isKindOfClass:NSArray.class] || ![devuuid isKindOfClass:NSString.class])
        {
            completion([NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], nil);
            return;
        }
        NSArray<GatewayDeviceModel *> *models = [GatewayDeviceModel mj_objectArrayWithKeyValuesArray:list].copy;
        for (GatewayDeviceModel *m in models)
        {
            m.gatewayId = m.gwId = devuuid;
            m.currentTime = self.serverTime;
        }
        completion(nil, models);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getUnlockTimesInLock:(GatewayDeviceModel *)lock completion:(void (^)(NSError * _Nullable, BOOL, NSInteger))completion
{
    return [self performServerFunc:@"countOpenLockRecord" withParams:@{@"devuuid":lock.gwId ?: @"", @"deviceId":lock.deviceId ?: @""} completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        if (!completion) return;
        if (error)
        {
            completion(error, NO, -9999);
            return;
        }
        NSNumber *times = [result valueForKey:@"count"];
        if (![result isKindOfClass:NSDictionary.class] || ![times isKindOfClass:NSNumber.class])
        {
            completion([NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], NO, -9999);
            return;
        }
        completion(nil, YES, times.integerValue);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)updateDeviceNickname:(GatewayDeviceModel *)device completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSString *devId = device.deviceId ?: @"";
    NSString *func = MQTTFuncUpdateNickname;
    NSDictionary *params = @{@"devuuid":device.gatewayId ?: @"", @"deviceId":devId, @"nickName":device.nickName ?: @"",@"gwId":device.gwId?:device.gatewayId};
    return [self performServerFunc:func withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getGatewayApproveList:(void (^)(NSError * _Nullable, NSArray<ApproveModel *> * _Nullable))completion
{
    return [self performServerFunc:MQTTFuncApproveList withParams:@{} completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        if (!completion) return;
        if (error || !result)
        {
            completion(error, nil);
        }
        else if (![result isKindOfClass:NSArray.class])
        {
            completion([NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], nil);
        }
        else
        {
            completion(nil, [ApproveModel mj_objectArrayWithKeyValuesArray:result].copy);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)approveGateway:(ApproveModel *)model status:(int)status completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSString *sn = model.deviceSN ?: @"";
    NSDictionary *params = @{@"devuuid":sn, @"requestuid":model.uid ?: @"", @"_id":model._id ?: @"", @"type":@(status)};
    return [self performServerFunc:MQTTFuncApproveGW withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getDeviceUnlockRecords:(GatewayDeviceModel *)device atPage:(int)page completion:(void (^)(NSError * _Nullable, NSArray<KDSGWUnlockRecord *> * _Nullable))completion
{
    NSString *devId = device.deviceId ?: @"";
    NSString *func = MQTTFuncUnlockRecord;
    NSDictionary *params = @{@"devuuid":device.gatewayId ?: @"", @"deviceId":devId, @"page":@(page), @"pageNum":@20};
    return [self performServerFunc:func withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        
        if (!completion) return;
        if (![result isKindOfClass:NSArray.class])
        {
            completion(error ?: [NSError errorWithDomain:@"MQTT服务器返回值错误" code:9999 userInfo:nil], nil);
            return;
        }
        NSArray<KDSGWUnlockRecord *> *records = [KDSGWUnlockRecord mj_objectArrayWithKeyValuesArray:result].copy;
        completion(nil, records);
    }].receipt;
}
- (KDSMQTTTaskReceipt *)getDeviceAlarmList:(GatewayDeviceModel *)device atPage:(int)page completion:(void (^)(NSError * _Nullable, NSArray<KDSAlarmModel *> * _Nullable))completion
{
    NSString *devId = device.deviceId ?: @"";
    NSString *func = MQTTFuncAlarmList;
    NSDictionary *params = @{@"gwId":device.gatewayId ?: @"", @"deviceId":devId, @"pageNum":@(page),@"userId":[KDSUserManager sharedManager].user.uid,@"msgtype":@"request"};
    return [self performServerFunc:func withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        
        if (!completion) return;
        if (![result isKindOfClass:NSArray.class])
        {
            completion(error ?: [NSError errorWithDomain:@"MQTT服务器返回值错误" code:9999 userInfo:nil], nil);
            return;
        }
        NSArray<KDSAlarmModel *> *records = [KDSAlarmModel mj_objectArrayWithKeyValuesArray:result].copy;
        completion(nil, records);
    }].receipt;
    
}

- (KDSMQTTTaskReceipt *)otaWithParams:(NSDictionary *)params completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:params];
    p[@"uid"] = p[@"userId"];
    NSMutableDictionary * param = [NSMutableDictionary dictionaryWithDictionary:p[@"params"]];
    param[@"type"] = @1;
    p[@"params"] = param;
    return [self performServerFunc:MQTTFuncApproveGWOTA withParams:p completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getGatewayUsers:(GatewayModel *)gw completion:(void (^)(NSError * _Nullable, NSArray<KDSGWUser *> * _Nullable))completion
{
    return [self performServerFunc:@"getGatewayUserList" withParams:@{@"devuuid" : gw.deviceSN ?: @""} completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        if (!completion) return;
        if (![result isKindOfClass:NSArray.class])
        {
            completion(error ?: [NSError errorWithDomain:@"服务器返回值错误" code:9999 userInfo:nil], nil);
            return;
        }
        NSArray *users = [KDSGWUser mj_objectArrayWithKeyValuesArray:result].copy;
        for (KDSGWUser *user in users)
        {
            user.gwSn = gw.deviceSN;
        }
        completion(nil, users);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)deleteGatewayUser:(KDSGWUser *)user completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSDictionary *params = @{@"devuuid":user.gwSn, @"_id":user._id};
    return [self performServerFunc:@"delGatewayUser" withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)shareGatewayBindingWithGW:(GatewayModel *)gw device:(GatewayDeviceModel *)device userAccount:(NSString *)userAccount userNickName:(NSString *)userNickname shareFlag:(int)shareflag type:(int)type completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSDictionary *params = @{@"gwId":gw.deviceSN ?: @"",@"deviceId":device.deviceId ?:@"",@"userAccount":userAccount,@"shareFlag":@(shareflag), @"adminUid":gw.adminuid,@"userNickname":userNickname ?: @"",@"type":@(type)};
    return [self performServerFunc:@"shareDevice" withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}
- (KDSMQTTTaskReceipt *)getShareUserListWithGW:(GatewayModel *)gw device:(GatewayDeviceModel *)device completion:(void (^)(NSError * _Nullable, NSArray<KDSAuthCatEyeMember *> * _Nullable))completion
{
    KDSUserManager * userManager = [KDSUserManager sharedManager];
    NSDictionary *params = @{@"gwId":gw.deviceSN ?: @"",@"deviceId":device.deviceId ?:@"", @"adminUid":userManager.user.uid,@"msgtype":@"request"};
    return [self performServerFunc:@"shareUserList" withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        if (!completion) return;
        if (![result isKindOfClass:NSArray.class])
        {
            completion(error ?: [NSError errorWithDomain:@"MQTT服务器返回值错误" code:9999 userInfo:nil], nil);
            return;
        }
        NSArray<KDSAuthCatEyeMember *> *records = [KDSAuthCatEyeMember mj_objectArrayWithKeyValuesArray:result].copy;
        completion(nil, records);
    }].receipt;
}

-(KDSMQTTTaskReceipt *)updateGwNickNameWithGw:(GatewayModel *)gw nickName:(NSString *)nickname completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSDictionary *params = @{@"nickName":nickname ,@"gwId":gw.deviceSN ?: @""};
    return [self performServerFunc:@"updateGwNickName" withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)updateDevPushSwitchWithGw:(GatewayModel *)gw device:(GatewayDeviceModel *)device pushSwitch:(int)pushSwitch completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    NSDictionary *params = @{@"deviceId":device.deviceId ?: @"" ,@"gwId":gw.deviceSN ?: @"", @"pushSwitch":@(pushSwitch)};
    return [self performServerFunc:@"updateDevPushSwitch" withParams:params completion:^(NSError * _Nullable error, BOOL success, id  _Nullable result) {
        !completion ?: completion(error, success);
    }].receipt;
}
@end

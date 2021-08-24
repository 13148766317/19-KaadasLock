//
//  KDSHttpManager+Ble.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//
#import "KDSHttpManager+Ble.h"
//#import "MJExtension.h"
#import "KDSHttpManager+User.h"
#import "NSData+JKEncrypt.h"
@implementation KDSHttpManager (Ble)

- (NSURLSessionDataTask *)checkBleDeviceBindingStatusWithBleName:(NSString *)name uid:(NSString *)uid success:(void (^)(int, NSString *_Nullable))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    name = name ? : @""; uid = uid ? : @"";
    //这个请求由于返回201表示未绑定，202表示已绑定，因此不会执行success块，只能从error块中判断。
    return [self POST:@"adminlock/edit/checkadmindev" parameters:@{ @"user_id": uid, @"devname": name } success:nil error:^(NSError *_Nonnull error) {
        if (error.code == 201 || error.code == 202) {
            NSString *account = [[error.userInfo valueForKey:@"data"] valueForKey:@"adminname"];
            account = [account isKindOfClass:NSString.class] ? account : nil;
            !success ? : success((int)error.code, account);
        } else {
            !errorBlock ? : errorBlock(error);
        }
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getPwd1WithSN:(NSString *)sn success:(void (^)(NSString *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    sn = sn ? : @"";
    return [self POST:@"model/getpwdBySN" parameters:@{ @"SN": sn } success:^(id _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        if (![dict isKindOfClass:NSDictionary.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(NSInteger)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
        } else {
            !success ? : success([dict[@"password1"] isKindOfClass:NSString.class] ? dict[@"password1"] : @"");
        }
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)bindBleDevice:(MyDevice *)device uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    params[@"devmac"] = device.devmac;
    params[@"devname"] = device.lockName;
    params[@"user_id"] = uid ? : @"";
    params[@"password1"] = device.password1;
    params[@"password2"] = device.password2;
    params[@"model"] = device.model;
    params[@"bleVersion"] = device.bleVersion;
    if (device.softwareVersion.length >= 8) {
        params[@"softwareVersion"] = [device.softwareVersion substringWithRange:NSMakeRange(1, 8)];//截取固定长度
    } else {
        params[@"softwareVersion"] = device.softwareVersion; //兼容很老的K9S版本：V1.01.008之前
    }
    params[@"deviceSN"] = device.deviceSN;
    params[@"peripheralId"] = device.peripheralId;
    params[@"functionSet"] = device.functionSet;

    return [self POST:@"adminlock/reg/createadmindev" parameters:params success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)unbindBleDeviceWithBleName:(NSString *)name uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    name = name ? : @""; uid = uid ? : @"";
    return [self POST:@"adminlock/reg/deletevendordev" parameters:@{ @"devname": name, @"adminid": uid } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)checkUnlockAuthWithUid:(NSString *)uid token:(NSString *)token bleName:(NSString *)name isAdmin:(BOOL)admin isNewDevice:(BOOL)newDevice success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; token = token ? : @""; name = name ? : @"";
    //新的模块optn_type设置为100 服务器不插入开锁列表库中 旧的模块和非管理员为7 会插入开锁列表库中
    return [self POST:@"adminlock/open/openLockAuth" parameters:@{ @"user_id": uid, @"devname": name, @"is_admin": (admin ? @"1" : @"0"), @"open_type": ((newDevice && admin) ? @"100" : @"7") } success:^(id _Nullable responseObject) {
        NSLog(@"开锁权限%@", success);
        !success ? : success();
    } error:nil failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
        NSLog(@"开锁权限:%ld", error.code);
    }];
}

- (NSURLSessionDataTask *)reportUnlockWithUid:(NSString *)uid bleName:(NSString *)name isAdmin:(BOOL)admin success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"adminlock/open/adminOpenLock" parameters:@{ @"user_id": uid, @"devname": name, @"is_admin": (admin ? @"1" : @"0"), @"open_type": @"7" } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getBindedDeviceListWithUid:(NSString *)uid success:(void (^)(NSArray<MyDevice *> *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @"";
    return [self POST:@"adminlock/edit/getAdminDevlist" parameters:@{ @"user_id": uid } success:^(id _Nullable responseObject) {
        if (![responseObject isKindOfClass:NSArray.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }

        NSArray<MyDevice *> *devices = [MyDevice mj_objectArrayWithKeyValuesArray:responseObject];
        //int numX = 1, numT = 1;
        //MyDevice *deviceX = nil, *deviceT = nil;
        for (MyDevice *dev in devices) {
            /*if (!dev.device_nickname.length || [dev.device_nickname isEqualToString:dev.device_name])
            {
                if ([dev.model containsString:@"X5"])
                {
                    dev.device_nickname = [NSString stringWithFormat:@"X5-%02d", numX++];
                    deviceX = dev;
                }
                else
                {
                    dev.device_nickname = [NSString stringWithFormat:@"T5-%02d", numT++];
                    deviceT = dev;
                }
            }*/
            NSLog(@"--{Kaadas}--self.serverTime=%f", self.serverTime);
            dev.currentTime = self.serverTime;
        }
        //deviceX.device_nickname = numX==2 ? @"X5" : deviceX.device_nickname;
        //deviceT.device_nickname = numT==2 ? @"T5" : deviceT.device_nickname;
        !success ? : success(devices.copy);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getLockPwdInfoWithUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(NSArray<KDSLockPwdInfo *> *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"/adminlock/info/number/get" parameters:@{ @"uid": uid, @"devname": name } success:^(id _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || ![obj.firstObject isKindOfClass:NSArray.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        NSArray *infos = [KDSLockPwdInfo mj_objectArrayWithKeyValuesArray:obj.firstObject];
        !success ? : success(infos.copy);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)addLockPwdInfo:(KDSLockPwdInfo *)info withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    info.number = info.number ? : @"";
    return [self POST:@"/adminlock/info/number/update" parameters:@{ @"uid": uid, @"devname": name, @"num": info.number, @"numNickname": info.nickname ? : info.number } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)deleteBindedDeviceWithUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"adminlock/reg/deleteadmindev" parameters:@{ @"devname": name, @"adminid": uid } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
    //401参数错误，444没有登录，501业务处理失败，509服务器请求超时。
}

- (NSURLSessionDataTask *)alterBindedDeviceNickname:(NSString *)nickname withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    nickname = nickname ? : @""; uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"adminlock/edit/updateAdminlockNickName" parameters:@{ @"lockNickName": nickname, @"user_id": uid, @"devname": name } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getBindedDeviceUnlockRecordWithUid:(NSString *)uid bleName:(NSString *)name index:(int)index success:(void (^)(NSArray<News *> *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"openlock/downloadopenlocklist" parameters:@{ @"user_id": uid, @"pagenum": @(index).stringValue, @"device_name": name } success:^(id _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class])) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ? : success([News mj_objectArrayWithKeyValuesArray:responseObject].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)uploadBindedDeviceUnlockRecord:(NSArray<News *> *)records withUid:(NSString *)uid device:(MyDevice *)device success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    if (records.count == 0) {
        !success ? : success();
        return nil;
    }
    uid = uid ? : @"";
    NSMutableArray *array = [NSMutableArray array];
    for (News *record in records) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"user_num"] = record.user_num;
        info[@"open_type"] = record.open_type;
        info[@"open_time"] = record.open_time;
        if (record.nickName) {
            info[@"nickName"] = record.nickName;
        } else {
            info[@"nickName"] = record.user_num;
        }

        [array addObject:info];
    }
    NSDictionary *params = @{ @"device_name": device.lockName ? : @"", @"device_nickname": device.lockNickName ? : @"", @"openLockList": array, @"user_id": uid };
    return [self POST:@"openlock/uploadopenlocklist" parameters:params success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getBindedDeviceAlarmRecordWithDevName:(NSString *)name index:(int)index success:(void (^)(NSArray<KDSAlarmModel *> *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    name = name ? : @"";
    return [self POST:@"warning/list" parameters:@{ @"devName": name, @"pageNum": @(index) } success:^(id _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class])) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ? : success([KDSAlarmModel mj_objectArrayWithKeyValuesArray:obj].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)uploadBindedDeviceAlarmRecord:(NSArray<KDSAlarmModel *> *)records success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    if (!records.count) {
        !success ? : success();
    }
    NSMutableArray *models = [NSMutableArray array];
    for (KDSAlarmModel *model in records) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(model.warningType), @"warningType", @(model.warningTime), @"warningTime", nil];
        dict[@"content"] = model.content;
        [models addObject:dict];
    }
    return [self POST:@"warning/upload" parameters:@{ @"devName": records.firstObject.devName ? : @"", @"warningList": models } success:^(id _Nullable responseObject) {
        !success ? : success();//这个响应值是NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getBlePwdListWithUid:(NSString *)uid bleName:(NSString *)name pwdType:(KDSServerKeyTpye)type success:(void (^)(NSArray<KDSPwdListModel *> *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uid"] = uid;
    param[@"devName"] = name;
    param[@"pwdType"] = @(type);
    return [self POST:@"adminlock/pwd/list" parameters:param success:^(id _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        NSString *_id = obj[@"_id"];
        NSArray *arr = nil;
        switch (type) {
            case KDSServerKeyTpyePIN:
                arr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"pwdList"]];
                for (KDSPwdListModel *m in arr) { m.pwdType = KDSServerKeyTpyePIN; }
                break;

            case KDSServerKeyTpyeTempPIN:
                arr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"tempPwdList"]];
                for (KDSPwdListModel *m in arr) { m.pwdType = KDSServerKeyTpyeTempPIN; }
                break;

            case KDSServerKeyTpyeFingerprint:
                arr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"fingerprintList"]];
                for (KDSPwdListModel *m in arr) { m.pwdType = KDSServerKeyTpyeFingerprint; }
                break;

            case KDSServerKeyTpyeCard:
                arr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"cardList"]];
                for (KDSPwdListModel *m in arr) { m.pwdType = KDSServerKeyTpyeCard; }
                break;

            default: {
                NSArray *pin = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"pwdList"]] ? : @[];
                for (KDSPwdListModel *m in pin) { m.pwdType = KDSServerKeyTpyePIN; }
                NSArray *tpin = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"tempPwdList"]] ? : @[];
                for (KDSPwdListModel *m in tpin) { m.pwdType = KDSServerKeyTpyeTempPIN; }
                NSArray *fp = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"fingerprintList"]] ? : @[];
                for (KDSPwdListModel *m in fp) { m.pwdType = KDSServerKeyTpyeFingerprint; }
                NSArray *card = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"cardList"]] ? : @[];
                for (KDSPwdListModel *m in card) { m.pwdType = KDSServerKeyTpyeCard; }
                arr = [[[pin arrayByAddingObjectsFromArray:tpin] arrayByAddingObjectsFromArray:fp] arrayByAddingObjectsFromArray:card];
            }
            break;
        }
        for (KDSPwdListModel *m in arr) {
            m._id = _id;
        }
        !success ? : success(arr ? : @[]);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)addBlePwds:(NSArray<KDSPwdListModel *> *)models withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uid"] = uid;
    param[@"devName"] = name;
    NSMutableArray *array = [NSMutableArray array];
    for (KDSPwdListModel *m in models) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"pwdType"] = @(m.pwdType);
        dict[@"num"] = m.num;
        dict[@"nickName"] = m.nickName ? : [NSString stringWithFormat:@"%02d", m.num.intValue];
        dict[@"type"] = @(m.type);
        if (m.type == KDSServerCycleTpyeTwentyfourHours || m.type == KDSServerCycleTpyePeriod) {
            dict[@"startTime"] = @([m.startTime integerValue]);
            dict[@"endTime"] = @([m.endTime integerValue]);
        } else if (m.type == KDSServerCycleTpyeCycle) {
            dict[@"type"] = @((NSInteger)m.type);
            dict[@"startTime"] = @([m.startTime integerValue]);
            dict[@"endTime"] = @([m.endTime integerValue]);
            dict[@"items"] = m.items;
        }
        [array addObject:dict];
    }
    param[@"pwdList"] = array;
    return [self POST:@"adminlock/pwd/add" parameters:param success:^(id _Nullable responseObject) {
        !success ? : success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)setBlePwd:(KDSPwdListModel *)model withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uid"] = uid;
    param[@"devName"] = name;
    param[@"pwdType"] = @((NSInteger)model.pwdType);
    param[@"num"] = model.num;
    param[@"nickName"] = model.nickName;
    return [self POST:@"adminlock/pwd/edit/nickname" parameters:param success:^(id _Nullable responseObject) {
        !success ? : success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)deleteBlePwd:(NSArray <KDSPwdListModel *> *)array withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uid"] = uid;
    param[@"devName"] = name;
    NSMutableArray *pwdlistarray = [[NSMutableArray alloc] init];
    for (KDSPwdListModel *pwdmodel in array) {
        NSMutableDictionary *pwDic = [NSMutableDictionary dictionary];
        pwDic[@"pwdType"] = @((NSInteger)pwdmodel.pwdType);
        pwDic[@"num"] = pwdmodel.num;
        [pwdlistarray addObject:pwDic];
    }
    param[@"pwdList"] = pwdlistarray;
    return [self POST:@"adminlock/pwd/delete" parameters:param success:^(id _Nullable responseObject) {
        !success ? : success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)addNewUserToSeversWithGuest:(NSString *)uid bleName:(NSString *)name pwdarray:(NSArray <KDSPwdListModel *> *)array success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = uid;
    params[@"devName"] = name;
    NSMutableArray *pwdlistarray = [[NSMutableArray alloc] init];
    for (KDSPwdListModel *pwdmodel in array) {
        NSMutableDictionary *pwDic = [NSMutableDictionary dictionary];
        pwDic[@"nickName"] = pwdmodel.nickName;
        pwDic[@"num"] = pwdmodel.num;
        pwDic[@"pwdType"] = @((NSInteger)pwdmodel.pwdType);
        pwDic[@"type"] = @((NSInteger)pwdmodel.type);
        if (pwdmodel.type == KDSServerCycleTpyeTwentyfourHours || pwdmodel.type == KDSServerCycleTpyePeriod) {
            pwDic[@"startTime"] = @([pwdmodel.startTime integerValue]);
            pwDic[@"endTime"] = @([pwdmodel.endTime integerValue]);
        } else if (pwdmodel.type == KDSServerCycleTpyeCycle) {
            pwDic[@"type"] = @((NSInteger)pwdmodel.type);
            pwDic[@"startTime"] = @([pwdmodel.startTime integerValue]);
            pwDic[@"endTime"] = @([pwdmodel.endTime integerValue]);
            pwDic[@"items"] = pwdmodel.items;
        }
        [pwdlistarray addObject:pwDic];
    }
    params[@"pwdList"] = pwdlistarray;
    return [self POST:@"adminlock/pwd/add" parameters:params success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)checkBleOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersion:(NSString *)version withDevNum:(int)devNum success:(void (^)(NSString *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer"] = @(customer);
    params[@"deviceName"] = serialNumber;
    params[@"version"] = version;
    params[@"devNum"] = @(devNum);

    return [self POST:[[KDSAppSettings sharedInstance] serverObjectForKey:@"otaHost"] parameters:params success:^(id _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        //固件下载地址
        NSString *updateURL = obj[@"fileUrl"];
        if (![updateURL containsString:@"http://"]) {
            updateURL = [NSString stringWithFormat:@"http://%@", updateURL];
        }
        KDSLog(@"--{Kaadas}--updateURL==%@", updateURL);
        !success ? : success(updateURL);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (nullable NSURLSessionDataTask *)UpdateResultsBleOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersion:(NSString *)version withResultCode:(NSString *)resultCode withDevNum:(int)devNum success:(void (^)(void))success error:(nullable void (^)(NSError *error))errorBlock failure:(nullable void (^)(NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"customer"] = @(customer);
    params[@"sn"] = serialNumber;
    params[@"version"] = version;
    params[@"resultCode"] = resultCode;
    params[@"devNum"] = @(devNum);

    return [self POST:[[KDSAppSettings sharedInstance] serverObjectForKey:@"otaResults"] parameters:params success:^(id _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
//        NSLog(@"--{Kaadas}--obj=obj=%@",obj);
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)updateBleVersion:(int)version withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"adminlock/reg/updateBleVersion" parameters:@{ @"devname": name, @"user_id": uid, @"bleVersion": @(version).stringValue } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)updateFunctionSet:(NSString *)functionSet withUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    uid = uid ? : @""; name = name ? : @"";
    return [self POST:@"adminlock/reg/updateFunctionSet" parameters:@{ @"devname": name, @"user_id": uid, @"functionSet": functionSet } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)updateSoftwareVersion:(NSString *)softwareVersion withDevname:(NSString *)devname withUser_id:(NSString *)user_id withDeviceSN:(NSString *)deviceSN withPeripheralId:(NSString *)peripheralId success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    return [self POST:@"adminlock/reg/updateSoftwareVersion" parameters:@{ @"devname": devname, @"user_id": user_id, @"softwareVersion": softwareVersion, @"deviceSN": deviceSN, @"peripheralId": peripheralId } success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)uploadBindedDeviceOperationalRecords:(NSArray<KDSOperationalRecord *> *)records withUid:(NSString *)uid device:(MyDevice *)device success:(void (^)(void))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    if (records.count == 0) {
        !success ? : success();
        return nil;
    }
    uid = uid ? : @"";
    NSMutableArray *array = [NSMutableArray array];
    for (KDSOperationalRecord *record in records) {
        NSDictionary *timeParam = @{ @"eventType": @(record.eventType) ? : @"", @"eventSource": @(record.eventSource) ? : @"", @"eventCode": @(record.open_type.intValue) ? : @"", @"userNum": @(record.user_num.intValue), @"eventTime": record.open_time };
        [array addObject:timeParam];
    }
    NSDictionary *params = @{ @"devName": device.lockName ? : @"", @"operationList": array };
    return [self POST:@"operation/add" parameters:params success:^(id _Nullable responseObject) {
        !success ? : success();
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getBindedDeviceOperationalRecordsWithBleName:(NSString *)name index:(int)index success:(void (^)(NSArray<KDSOperationalRecord *> *_Nonnull))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSError *_Nonnull))failure
{
    name = name ? : @"";
    return [self POST:@"operation/list" parameters:@{ @"page": @(index), @"devName": name } success:^(id _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class])) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ? : success([KDSOperationalRecord mj_objectArrayWithKeyValuesArray:responseObject].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

- (NSURLSessionDataTask *)getDeviceModelMappingWithDevelopmentModel:(NSString *)developmentModel success:(void (^)(KDSDeviceModelMapping *_Nonnull))success error:(nullable void (^)(NSError *error))errorBlock failure:(nullable void (^)(NSError *error))failure
{
    NSDictionary *params = @{ @"developmentModel": developmentModel };

    return [self POST:KDS_deviceMapping parameters:params success:^(id _Nullable responseObject) {
        NSDictionary *dict = responseObject;

        KDSDeviceModelMapping *model =  [KDSDeviceModelMapping mj_objectWithKeyValues:dict];

        if (![dict isKindOfClass:NSDictionary.class]) {
            !errorBlock ? : errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(NSInteger)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
        } else {
            !success ? : success(model);
        }
    } error:errorBlock failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        !failure ? : failure(error);
    }];
}

@end

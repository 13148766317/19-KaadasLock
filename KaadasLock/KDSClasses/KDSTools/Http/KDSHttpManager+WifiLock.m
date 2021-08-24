//
//  KDSHttpManager+WifiLock.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager+WifiLock.h"


@implementation KDSHttpManager (WifiLock)

- (NSURLSessionDataTask *)checkWifiDeviceBindingStatusWithDevName:(NSString *)name uid:(NSString *)uid success:(void (^)(int, NSString * _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure{
    
    name = name ?: @""; uid = uid ?: @"";
    //这个请求由于返回201表示未绑定，202表示已绑定，因此不会执行success块，只能从error块中判断。
    return [self POST:@"wifi/device/checkadmind" parameters:@{@"uid":uid, @"devname":name} success:nil error:^(NSError * _Nonnull error) {
        if (error.code == 201 || error.code == 202)
        {
            NSString *account = [[error.userInfo valueForKey:@"data"] valueForKey:@"adminname"];
            account = [account isKindOfClass:NSString.class] ? account : nil;
            !success ?: success((int)error.code, account);
        }
        else
        {
            !errorBlock ?: errorBlock(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}

- (NSURLSessionDataTask *)bindWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    params[@"wifiSN"] = device.wifiSN;
    params[@"lockNickName"] = device.lockNickname ?: device.wifiSN;
    params[@"uid"] = uid ?: @"";
    params[@"randomCode"] = device.randomCode ?: @"";
    params[@"wifiName"] = device.wifiName;
    params[@"functionSet"] = @(device.functionSet.intValue);
    params[@"distributionNetwork"] = @(device.distributionNetwork);

    return [self POST:@"wifi/device/bind" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}
- (NSURLSessionDataTask *)updateBindWifiDevice:(KDSWifiLockModel *)device uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    params[@"wifiSN"] = device.wifiSN;
//    params[@"lockNickName"] = device.lockNickname ?: device.wifiSN;
    params[@"uid"] = uid ?: @"";
    params[@"randomCode"] = device.randomCode ?: @"";
    params[@"wifiName"] = device.wifiName;
    params[@"functionSet"] = @(device.functionSet.intValue);

    return [self POST:@"wifi/device/infoUpdate" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)unbindWifiDeviceWithWifiSN:(NSString *)wifiSN uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    wifiSN = wifiSN ?: @""; uid = uid ?: @"";
    return [self POST:@"wifi/device/unbind" parameters:@{@"wifiSN":wifiSN, @"uid":uid} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}
- (NSURLSessionDataTask *)alterWifiBindedDeviceNickname:(NSString *)nickname withUid:(NSString *)uid wifiModel:(KDSWifiLockModel *)wifiModel success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    nickname = nickname ?: @""; uid = uid ?: @"";
    NSString * wifisn = wifiModel.wifiSN ?: @"";
    return [self POST:@"wifi/device/updatenickname" parameters:@{@"lockNickname":nickname, @"uid":uid, @"wifiSN":wifisn} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)updateSwitchNickname:(NSArray *)switchNickname withUid:(NSString *)uid wifiModel:(KDSWifiLockModel *)wifiModel success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @"";
    NSString * wifisn = wifiModel.wifiSN ?: @"";
    return [self POST:@"wifi/device/updateSwitchNickname" parameters:@{@"switchNickname":switchNickname, @"uid":uid, @"wifiSN":wifisn} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}

- (NSURLSessionDataTask *)setUserWifiLockUnlockNotification:(int)open withUid:(NSString *)uid wifiSN:(NSString *)wifiSN completion:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    wifiSN = wifiSN ?: @""; uid = uid ?: @"";
    return [self POST:@"wifi/device/updatepushswitch" parameters:@{@"wifiSN":wifiSN ,@"uid":uid, @"switch":@(open)} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getWifiLockPwdListWithUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(void (^)(NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull, NSArray<KDSPwdListModel *> * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @""; wifiSN = wifiSN ?: @"";
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uid"] = uid;
    param[@"wifiSN"] = wifiSN;
    return [self POST:@"wifi/pwd/list" parameters:param success:^(id  _Nullable responseObject) {
        
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        NSArray *pwdList = nil;NSArray *fingerprintList = nil;NSArray *cardList = nil;NSArray *faceList = nil;
        NSArray *pwdNicknameArr = nil;NSArray *fingerprintNicknameArr = nil;NSArray *cardNicknameArr = nil;NSArray * faceNicknameArr = nil;NSArray *pwdDuressArr = nil;NSArray *fingerprintDuressArr;

        
        pwdList = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"pwdList"]] ?: @[];
        for (KDSPwdListModel *m in pwdList) {
            switch (m.type) {
                case 0:
                    m.pwdType = KDSServerKeyTpyePIN;
                    break;
                case 1:
                    m.pwdType = KDSServerKeyTpyeStrategyPIN;
                    break;
                 case 2:
                    m.pwdType = KDSServerKeyTpyeCoercePIN;
                    break;
                case 3:
                    m.pwdType = KDSServerKeyTpyeAdminPIN;
                    break;
                case 4:
                    m.pwdType = KDSServerKeyTpyeNoPermissionPIN;
                    break;
                case 254:
                    m.pwdType = KDSServerKeyTpyeTempPIN;
                    break;
                case 255:
                    m.pwdType = KDSServerKeyTpyeInvalidValue;
                    break;
                    
                default:
                    m.pwdType = KDSServerKeyTpyePIN;
                    break;
            }
            
        }
        
        fingerprintList = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"fingerprintList"]] ?: @[];
        for (KDSPwdListModel *m in fingerprintList) { m.pwdType = KDSServerKeyTpyeFingerprint; }
        
        cardList = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"cardList"]] ?: @[];
        for (KDSPwdListModel *m in cardList) { m.pwdType = KDSServerKeyTpyeCard; }
        
        faceList = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"faceList"]] ?: @[];
        for (KDSPwdListModel *m in faceList) { m.pwdType = KDSServerKeyTpyeFace; }
        
        pwdNicknameArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"pwdNickname"] ?: @[]];
        fingerprintNicknameArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"fingerprintNickname"] ?: @[]];
        cardNicknameArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"cardNickname"] ?: @[]];
        faceNicknameArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"faceNickname"] ?: @[]];
        pwdDuressArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"pwdDuress"] ?: @[]];
        fingerprintDuressArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:obj[@"fingerprintDuress"] ?: @[]];

        
        !success ?: success(pwdList, fingerprintList, cardList, faceList,
                            pwdNicknameArr, fingerprintNicknameArr, cardNicknameArr, faceNicknameArr,pwdDuressArr,fingerprintDuressArr);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}
- (nullable NSURLSessionDataTask *)setDuressAlarmSinglePwdSwitchWithUid:(NSString *)uid WifiSN:(NSString *)wifiSN PwdType:(KDSServerKeyTpye)pwdType Num:(int)num PwdDuressSwitch:(int)pwdDuressSwitch success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    //密钥类型：1密码 2指纹密码 3卡片密码
    if (pwdType == KDSServerKeyTpyeFace){
        param[@"pwdType"] = @(4);
    }else if (pwdType == KDSServerKeyTpyeCard) {
        param[@"pwdType"] = @(3);
    }else if (pwdType == KDSServerKeyTpyeFingerprint) {
        param[@"pwdType"] = @(2);
    }else{
        param[@"pwdType"] = @(1);
    }
    param[@"uid"] = uid;
    param[@"wifiSN"] = wifiSN;
    param[@"num"] = @(num);
    param[@"pwdDuressSwitch"] = @(pwdDuressSwitch);
    
    return [self POST:@"user/edit/pwdDuressAlarm" parameters:param success:^(id  _Nullable responseObject) {
        !success ?: success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (nullable NSURLSessionDataTask *)setDuressAlarmSinglePwdAccountWithUid:(NSString *)uid WifiSN:(NSString *)wifiSN PwdType:(KDSServerKeyTpye)pwdType Num:(int)num AccountType:(int)accountType DuressAlarmAccount:(NSString *)duressAlarmAccount success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    //密钥类型：1密码 2指纹密码 3卡片密码
    if (pwdType == KDSServerKeyTpyeFace){
        param[@"pwdType"] = @(4);
    }else if (pwdType == KDSServerKeyTpyeCard) {
        param[@"pwdType"] = @(3);
    }else if (pwdType == KDSServerKeyTpyeFingerprint) {
        param[@"pwdType"] = @(2);
    }else{
        param[@"pwdType"] = @(1);
    }
    param[@"uid"] = uid;
    param[@"wifiSN"] = wifiSN;
    param[@"num"] = @(num);
    param[@"accountType"] = @(accountType);
    param[@"duressAlarmAccount"] = duressAlarmAccount;
    
    return [self POST:@"user/edit/pwdDuressAccount" parameters:param success:^(id  _Nullable responseObject) {
        !success ?: success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (nullable NSURLSessionDataTask *)setDuressAlarmSwitchWithUid:(NSString *)uid WifiSN:(NSString *)wifiSN  DuressAlarmSwitch:(int)duressAlarmSwitch  success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];

    param[@"uid"] = uid;
    param[@"wifiSN"] = wifiSN;
    param[@"duressAlarmSwitch"] = @(duressAlarmSwitch);
   
    return [self POST:@"user/edit/duressAlarmSwitch" parameters:param success:^(id  _Nullable responseObject) {
        !success ?: success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)setWifiLockPwd:(KDSPwdListModel *)model withUid:(NSString *)uid wifiSN:(NSString *)wifiSN userNickname:(NSString *)userNickname success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
       //密钥类型：1密码 2指纹密码 3卡片密码
       if (model.pwdType == KDSServerKeyTpyeFace){
           param[@"pwdType"] = @(4);
       }else if (model.pwdType == KDSServerKeyTpyeCard) {
           param[@"pwdType"] = @(3);
       }else if (model.pwdType == KDSServerKeyTpyeFingerprint) {
           param[@"pwdType"] = @(2);
       }else{
           param[@"pwdType"] = @(1);
       }
       param[@"uid"] = uid;
       param[@"userNickname"] = userNickname;
       param[@"wifiSN"] = wifiSN;
       param[@"num"] = @(model.num.intValue);
       param[@"nickName"] = model.nickName;
       return [self POST:@"wifi/pwd/updatenickname" parameters:param success:^(id  _Nullable responseObject) {
           !success ?: success();//NSNull
       } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           !failure ?: failure(error);
       }];
}

- (NSURLSessionDataTask *)addWifiLockAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = uid;
    params[@"wifiSN"] = wifiSN;
    params[@"username"] = member.uname;
    params[@"userNickname"] = member.unickname;
    params[@"adminNickname"] = member.adminname;
    return [self POST:@"wifi/share/add" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}

- (NSURLSessionDataTask *)deleteWifiLockAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"wifi/share/del" parameters:@{@"uid":uid ?: @"", @"shareId":member._id ?: @"", @"adminNickname":member.adminname} success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)updateWifiLockAuthorizedUserNickname:(KDSAuthMember *)member wifiSN:(NSString *)wifiSN success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"wifi/share/updatenickname" parameters:@{@"shareId":member._id ?: @"", @"nickname":member.unickname ?: @"", @"uid":[KDSUserManager sharedManager].user.uid} success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getWifiLockAuthorizedUsersWithUid:(NSString *)uid wifiSN:(NSString *)wifiSN success:(void (^)(NSArray<KDSAuthMember *> * _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    
    uid = uid ?: @""; wifiSN = wifiSN ?: @"";
    return [self POST:@"wifi/share/list" parameters:@{@"wifiSN":wifiSN, @"uid":uid} success:^(id  _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class]))
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success([KDSAuthMember mj_objectArrayWithKeyValuesArray:obj].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getWifiLockBindedDeviceOperationWithWifiSN:(NSString *)wifiSN index:(int)index success:(void (^)(NSArray<KDSWifiLockOperation *> * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    wifiSN = wifiSN ?: @"";
    return [self POST:@"wifi/operation/list" parameters:@{@"wifiSN":wifiSN,@"page":@(index)} success:^(id  _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class]))
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success([KDSWifiLockOperation mj_objectArrayWithKeyValuesArray:responseObject].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getWifiLockBindedDeviceAlarmRecordWithWifiSN:(NSString *)wifiSN index:(int)index success:(void (^)(NSArray<KDSWifiLockAlarmModel *> * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    wifiSN = wifiSN ?: @"";
    return [self POST:@"wifi/alarm/list" parameters:@{@"wifiSN":wifiSN, @"page":@(index)} success:^(id  _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class]))
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success([KDSWifiLockAlarmModel mj_objectArrayWithKeyValuesArray:obj].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getWifiLockBindedDeviceOperationCountWithUid:(NSString *)uid wifiSN:(NSString *)wifiSN index:(int)index success:(void (^)(int))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
       uid = uid ?: @""; wifiSN = wifiSN ?: @"";
       return [self POST:@"wifi/operation/opencount" parameters:@{@"uid":uid, @"wifiSN":wifiSN,@"page":@(index).stringValue} success:^(id  _Nullable responseObject) {
           NSString * count = responseObject[@"count"];
           if (![count isKindOfClass:NSNumber.class])
           {
               !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
               return;
           }
           !success ?: success(count.intValue);
       } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           !failure ?: failure(error);
       }];
}

-(NSURLSessionDataTask *)checkWiFiOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersion:(NSString *)version withDevNum:(int)devNum success:(void (^)(id _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
       params[@"customer"] = @(customer);
       params[@"deviceName"] = serialNumber;
       params[@"version"] = version;
       params[@"devNum"] = @(devNum);
       // 打印请求ota地址
    KDSLog(@" zhu--- 请求OTA的地址 ===%@",[[KDSAppSettings sharedInstance] serverObjectForKey:@"otaHost"]);
       return [self POST:[[KDSAppSettings sharedInstance] serverObjectForKey:@"otaHost"]  parameters:params success:^(id  _Nullable responseObject) {
           NSDictionary *obj = responseObject;
           if (![obj isKindOfClass:NSDictionary.class])
           {
               !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
               return;
           }

           !success ?: success(obj);
       } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           !failure ?: failure(error);
       }];
}
// 多固件升级确认接口
-(NSURLSessionDataTask *)checkWiFiMUOTAWithSerialNumber:(NSString *)serialNumber withCustomer:(int)customer withVersions:(NSArray *)versions  success:(void (^)(id _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:versions options:NSJSONWritingPrettyPrinted  error:&parseError];
    NSString *jsonstr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *objectData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:objectData
                                
                                                               options:NSJSONReadingMutableContainers
                                
                                                                 error:&parseError];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
       params[@"customer"] = @(customer);
       params[@"deviceName"] = serialNumber;
       params[@"versions"] = jsonDic;  // 变成数组
    KDSLog(@" zhu--- 请求多个OTA的地址 ===%@",[[KDSAppSettings sharedInstance] serverObjectForKey:@"otaHostmu"]);
       return [self POST:[[KDSAppSettings sharedInstance] serverObjectForKey:@"otaHostmu"] parameters:params success:^(id  _Nullable responseObject) {
           NSDictionary *obj = responseObject;
           KDSLog(@"zhu--- 请求多个OTA的地址的参数 ===%@",responseObject);
           if (![obj isKindOfClass:NSDictionary.class])
           {
               !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
               return;
           }
           !success ?: success(obj);
       } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           !failure ?: failure(error);
       }];
}

-(NSURLSessionDataTask *)wifiDeviceOTAWithSerialNumber:(NSString *)serialNumber withOTAData:(NSDictionary *)data success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
          params[@"wifiSN"] = serialNumber;
          params[@"fileLen"] = data[@"fileLen"];
          params[@"fileUrl"] = data[@"fileUrl"];
          params[@"fileMd5"] = data[@"fileMd5"];
    ///升级编号。1为WIFI模块，2为WIFI锁，3为人脸模组
          params[@"devNum"] = data[@"devNum"];
          params[@"fileVersion"] = data[@"fileVersion"];
          
          return [self POST:KDS_WiFiLockOTA parameters:params success:^(id  _Nullable responseObject) {
              NSDictionary *obj = responseObject;
              if (![obj isKindOfClass:NSDictionary.class])
              {
                  !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
                  return;
              }
              !success ?: success();
          } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              !failure ?: failure(error);
          }];
}

// 多个固件升级确认
-(NSURLSessionDataTask *)wifiDeviceOTAWithSerialNumbermutip:(NSString *)serialNumber withOTAData:(NSDictionary *)data success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//  有个参数需要一个字典数组  字典数组 需要处理一下才能 存进去
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted  error:&parseError];
    NSString *jsonstr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *objectData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:objectData
                                
                                                               options:NSJSONReadingMutableContainers
                                
                                                                 error:&parseError];
          params[@"wifiSN"] = serialNumber;
          params[@"upgradeTask"] = jsonDic;
          return [self POST:KDS_WiFiLockOTAmu parameters:params success:^(id  _Nullable responseObject) {
              NSDictionary *obj = responseObject;
              if (![obj isKindOfClass:NSDictionary.class])
              {
                  !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
                  return;
              }

              !success ?: success();
          } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              !failure ?: failure(error);
          }];
}

- (NSURLSessionDataTask *)getSwitchInfoWithWifiSN:(NSString *)wifiSN userUid:(NSString *)uid success:(void (^)(NSDictionary * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @""; wifiSN = wifiSN ?: @"";
    return [self POST:@"wifi/device/getSwitchInfo" parameters:@{@"uid":uid, @"wifiSN":wifiSN} success:^(id  _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success(obj);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
}







@end

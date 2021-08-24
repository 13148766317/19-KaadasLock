//
//  KDSDBManager+CY.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/28.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDBManager+CY.h"

@implementation KDSDBManager (CY)


#pragma mark 添加/更新猫眼数据表
-(BOOL)updateCateye:(KDSGWCateyeParam *)cateyeModel{
    
    __block BOOL res = NO;
    KDSGWCateyeParam * oldCateyeModel = [self getCateyeSettingWithDeviceid:cateyeModel.deviceId];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
        if (oldCateyeModel)
        {
            res = [db executeUpdateWithFormat:@"update KDSCatEyeSQL set userId= %@,deviceId = %@,SWVsion = %@,HWVsion= %@,macaddr=%@,MCU = %@,T200 = %@,ipaddr = %@,wifiStrength = %@,curBellNum = %@,bellVolume = %@ ,maxBellNum = %@,resolution = %@,pirEnable = %d,bellCount = %@,sdStatus = %@,pirSensitivity = %@ where deviceId = %@",[KDSUserManager sharedManager].user.uid,cateyeModel.deviceId,cateyeModel.swVer,cateyeModel.hwVer,cateyeModel.macaddr,cateyeModel.mcuVer,cateyeModel.t200Ver,cateyeModel.ipaddr,@(cateyeModel.wifiStrength).stringValue,@(cateyeModel.curBellNum).stringValue,@(cateyeModel.bellVolume).stringValue,@(cateyeModel.maxBellNum).stringValue,cateyeModel.resolution,cateyeModel.pirEnable,@(cateyeModel.bellCount).stringValue,cateyeModel.sdStatus,cateyeModel.pirSensitivity,cateyeModel.deviceId];
        }else{
            res = [db executeUpdateWithFormat:@"insert into KDSCatEyeSQL (userId,deviceId,SWVsion,HWVsion,macaddr,MCU,T200,ipaddr,wifiStrength,curBellNum,bellVolume,maxBellNum,resolution,pirEnable,bellCount,sdStatus,pirSensitivity) values (%@, %@, %@, %@, %@,%@,%@,%@,%@,%@,%@,%@,%@,%d,%@,%@,%@)",[KDSUserManager sharedManager].user.uid,cateyeModel.deviceId,cateyeModel.swVer,cateyeModel.hwVer,cateyeModel.macaddr,cateyeModel.mcuVer,cateyeModel.t200Ver,cateyeModel.ipaddr,@(cateyeModel.wifiStrength).stringValue,@(cateyeModel.curBellNum).stringValue,@(cateyeModel.bellVolume).stringValue,@(cateyeModel.maxBellNum).stringValue,cateyeModel.resolution,cateyeModel.pirEnable,@(cateyeModel.bellCount).stringValue,cateyeModel.sdStatus,cateyeModel.pirSensitivity];
        }
        
        
    }];
    return res;
}
#pragma mark 获取缓存猫眼数据
-(KDSGWCateyeParam *)getCateyeSettingWithDeviceid:(NSString *)deviceid
{
    __block KDSGWCateyeParam *gwCateyeParam = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select * from KDSCatEyeSQL where deviceId = ?",deviceid];
        while ([set next])
        {
            gwCateyeParam = [[KDSGWCateyeParam alloc] init];
            gwCateyeParam.deviceId = [set stringForColumn:@"deviceId"];
            gwCateyeParam.swVer = [set stringForColumn:@"SWVsion"];
            gwCateyeParam.hwVer = [set stringForColumn:@"HWVsion"];
            gwCateyeParam.macaddr = [set stringForColumn:@"macaddr"];
            gwCateyeParam.mcuVer = [set stringForColumn:@"MCU"];
            gwCateyeParam.t200Ver = [set stringForColumn:@"T200"];
            gwCateyeParam.ipaddr = [set stringForColumn:@"ipaddr"];
            gwCateyeParam.wifiStrength = [set intForColumn:@"wifiStrength"];
            gwCateyeParam.curBellNum = [set intForColumn:@"curBellNum"];
            gwCateyeParam.bellVolume = [set intForColumn:@"bellVolume"];
            gwCateyeParam.maxBellNum = [set intForColumn:@"maxBellNum"];
            gwCateyeParam.resolution = [set stringForColumn:@"resolution"];
            gwCateyeParam.pirEnable = [set boolForColumn:@"pirEnable"];
            gwCateyeParam.deviceId = [set stringForColumn:@"deviceId"];
            gwCateyeParam.bellCount = [set intForColumn:@"bellCount"];
            gwCateyeParam.sdStatus = [set stringForColumn:@"sdStatus"];
            gwCateyeParam.pirSensitivity = [set stringForColumn:@"pirSensitivity"];
            
            [set close];
            break;
        }
    }];
    return gwCateyeParam;
}

-(NSString *)getBellSelectWithDeviceID:(NSString *)deviceid
{
    __block NSString * bell = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select curBellNum from KDSCatEyeSQL where deviceId = ?", deviceid];
        while ([set next])
        {
            bell = [set stringForColumn:@"curBellNum"];
        }
    }];
    return bell;
}
/*获取音量*/
-(NSString *)getBellVolumeWithDeviceID:(NSString*)deviceid
{
    __block NSString * bell = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select bellVolume from KDSCatEyeSQL where deviceId = ?", deviceid];
        while ([set next])
        {
            bell = [set stringForColumn:@"bellVolume"];
        }
    }];
    return bell;
}
-(NSString *)getBellAcount:(NSString *)deviceid
{
    __block NSString * bellCount = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select bellCount from KDSCatEyeSQL where deviceId = ?", deviceid];
        while ([set next])
        {
            bellCount = [set stringForColumn:@"bellCount"];
        }
    }];
    return bellCount;
}
-(NSString *)getResolution:(NSString *)deviceid
{
    __block NSString * resolution = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select resolution from KDSCatEyeSQL where deviceId = ?", deviceid];
        while ([set next])
        {
            resolution = [set stringForColumn:@"resolution"];
        }
    }];
    return resolution;
    
}

-(NSString *)getPirEnable:(NSString*)deviceid
{
    __block NSString * pirEnable = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select pirEnable from KDSCatEyeSQL where deviceId = ?", deviceid];
        while ([set next])
        {
            pirEnable = [set stringForColumn:@"pirEnable"];
        }
    }];
    return pirEnable;
    
}

/*sdCard状态*/
-(NSString *)getSdCardStatus:(NSString *)deviceid
{
    __block NSString * sdCardStatus = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select sdStatus from KDSCatEyeSQL where deviceId = ?", deviceid];
        while ([set next])
        {
            sdCardStatus = [set stringForColumn:@"sdStatus"];
        }
    }];
    return sdCardStatus;
    
}

-(BOOL)updateBellVolum:(NSString *)volum deviceID:(NSString*)deviceid
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET bellVolume = ?  WHERE deviceId = ?", volum,deviceid];
    }];
    return res;
}

/*更新门铃选择*/
-(BOOL)updatBellSelect:(NSString *)bellSelect deviceID:(NSString*)deviceid;
{
    __block BOOL res = NO;
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET curBellNum = ?  WHERE deviceId = ? ", bellSelect,deviceid];
        }];
    return res;
}
/*更新响铃次数*/
-(BOOL)updatbellNum:(NSString *)bellNum deviceID:(NSString*)deviceid
{
    __block BOOL res = NO;
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET bellCount = ?  WHERE deviceId = ? ", bellNum,deviceid];
        }];
    return res;
}

/*更新分辨率*/
-(BOOL)updatResolution:(NSString *)resolution deviceID:(NSString*)deviceid
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET resolution = ?  WHERE deviceId = ?", resolution,deviceid];
    }];
    return res;
}
/*更新pir开关*/
-(BOOL)updatPirSwitch:(NSString *)pirSwitch deviceID:(NSString*)deviceid
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET pirEnable = ?  WHERE deviceId = ? ", pirSwitch,deviceid];
    }];
    return res;
}
/*更新pir徘徊监测*/
-(BOOL)updatPirWander:(NSString *)pirWander deviceID:(NSString *)deviceid
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET pirSensitivity = ?  WHERE deviceId = ? ", pirWander,deviceid];
    }];
    return res;
}
/*更新sd卡状态*/
-(BOOL)updatSdCard:(NSString *)sdCard deviceID:(NSString*)deviceid
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"UPDATE KDSCatEyeSQL SET sdStatus = ?  WHERE deviceId = ? ", sdCard,deviceid];
    }];
    return res;
    
}
/*猫眼电量*/
- (BOOL)updateCateyePower:(int)power withDeviceId:(NSString *)deviceId
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select power from KDSCatEyeSQL where deviceId = ?", deviceId];
        res = [set next];
        if(!res){
            BOOL success = [db executeUpdateWithFormat:@"insert into KDSCatEyeSQL (power,deviceId) values (%@, %@)",@(power).stringValue,deviceId];
            if (success) {
                KDSLog(@"插入猫眼电量成功======power");
            }
        }else{
            res = [db executeUpdateWithFormat:@"update KDSCatEyeSQL set power = %@ where deviceId = '%@'",@(power).stringValue,deviceId];
        }
    }];
    return res;
}
     
- (NSString*)queryCateyePowerWithDeviceId:(NSString *)deviceId
{
    __block NSString* power = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select power from KDSCatEyeSQL where deviceId = ?", deviceId];
        while ([set next])
        {
            power = [set stringForColumn:@"power"];
        }
    }];
    return power;
}

#pragma mark 更新或添加m猫眼pir数组
-(void)addPirArray:(NSMutableArray<AlarmMessageModel *> *)pirArray cateyeID:(NSString *)cateyeID picDate:(NSString*)picDate{

    //处理数据
    NSMutableArray *ms = [NSMutableArray arrayWithCapacity:pirArray.count];
    for (AlarmMessageModel *am in pirArray) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:am];
        NSString *s = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        [ms addObject:s];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:ms options:NSJSONWritingPrettyPrinted error:nil];
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlSearch = @"SELECT pirPicArrayData FROM pirPicSQL where deviceId = ? and userId = ? and picDate = ?";
        FMResultSet *set = [db executeQuery:sqlSearch,cateyeID,[KDSUserManager sharedManager].user.uid,picDate];
        res = [set next];
    }];
    if (res) {
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlUpdate =  [NSString stringWithFormat:@"UPDATE pirPicSQL SET pirPicArrayData = ?  WHERE userId = '%@' and deviceId = '%@' and picDate = '%@'",[KDSUserManager sharedManager].user.uid,cateyeID,picDate];
            BOOL insertSuccess = [ db executeUpdate:sqlUpdate, data];
            if (insertSuccess) {
                KDSLog(@"更新pir数据成功======pir111");
            }
        }];
    }else{
        [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            NSString *sqlUpdate = @"insert into pirPicSQL (pirPicArrayData,userId,deviceId,picDate) values (?,?,?,?)";
            BOOL insertSuccess = [db executeUpdate:sqlUpdate,data,[KDSUserManager sharedManager].user.uid,cateyeID,picDate];
            if (insertSuccess) {
                KDSLog(@"插入猫眼pir数据成功=====pir2222");
            }
        }];
    }
}
-(NSArray<AlarmMessageModel *> *)getPirArrayWithCateID:(NSString*)cateyeID picDate:(NSString*)picDate{
    __block NSMutableArray *members = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlUpdate = [NSString stringWithFormat:@"select pirPicArrayData from pirPicSQL where deviceId = \'%@\' and userId = \'%@\' and picDate = \'%@\'",cateyeID,[KDSUserManager sharedManager].user.uid,picDate];
        FMResultSet *res = [db executeQuery:sqlUpdate];
        while ([res next]) {
            NSData *data = [res dataForColumn:@"pirPicArrayData"];
            if (!data) continue;
            NSArray<NSString *> *strings = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
            //        pirArrayData = [[NSData alloc] initWithData:[res dataForColumn:@"pirPicArrayData"]];
            for (NSString *string in strings)
            {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
                AlarmMessageModel *am = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
                !am ?: [members addObject:am];
            }
        }
    }];
    return members.count ? members.copy : nil;
}
#pragma mark 更新或添加猫眼通话录屏数组
-(void)addRecordVideoArray:(NSMutableArray<AlarmMessageModel *> *)recordArray cateyeID:(NSString *)cateyeID recordDate:(NSString*)recordDate{
    //处理数据
    NSMutableArray *ms = [NSMutableArray arrayWithCapacity:recordArray.count];
    for (AlarmMessageModel *am in recordArray) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:am];
        NSString *s = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        [ms addObject:s];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:ms options:NSJSONWritingPrettyPrinted error:nil];
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlSearch = @"SELECT recordViArrayData FROM recordVideoSQL where deviceId = ? and userId = ? and recordDate = ?";
        FMResultSet *set = [db executeQuery:sqlSearch,cateyeID,[KDSUserManager sharedManager].user.uid,recordDate];
        res = [set next];
    }];
    
    if (res) {
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlUpdate =  [NSString stringWithFormat:@"UPDATE recordVideoSQL SET recordViArrayData = ?  WHERE userId = '%@' and deviceId = '%@' and recordDate = '%@'",[KDSUserManager sharedManager].user.uid,cateyeID,recordDate];
            BOOL insertSuccess = [ db executeUpdate:sqlUpdate, data];
            if (insertSuccess) {
                KDSLog(@"更新recordVideo数据成功");
            }
        }];
    }else{
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlUpdate = @"insert into recordVideoSQL (recordViArrayData,userId,deviceId,recordDate) values (?,?,?,?)";
            BOOL insertSuccess = [db executeUpdate:sqlUpdate,data,[KDSUserManager sharedManager].user.uid,cateyeID,recordDate];
            if (insertSuccess) {
                KDSLog(@"插入猫眼recordVideo数据成功");
            }
        }];
    }
    
}
-(NSArray<AlarmMessageModel *> *)getRecordArrayWithCateID:(NSString*)cateyeID recordDate:(NSString*)recordDate{
    __block NSMutableArray *members = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlUpdate = [NSString stringWithFormat:@"select recordViArrayData from recordVideoSQL where deviceId = \'%@\' and userId = \'%@\' and recordDate = \'%@\'",cateyeID,[KDSUserManager sharedManager].user.uid,recordDate];
        FMResultSet *res = [db executeQuery:sqlUpdate];
        while ([res next]) {
            NSData *data = [res dataForColumn:@"recordViArrayData"];
            if (!data) continue;
            NSArray<NSString *> *strings = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
            //        pirArrayData = [[NSData alloc] initWithData:[res dataForColumn:@"pirPicArrayData"]];
            for (NSString *string in strings)
            {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
                AlarmMessageModel *am = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
                !am ?: [members addObject:am];
            }
        }
    }];
    return members.count ? members.copy : nil;
}

@end

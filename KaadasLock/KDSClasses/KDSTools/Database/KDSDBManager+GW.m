//
//  KDSDBManager+GW.m
//  KaadasLock
//
//  Created by orange on 2019/4/30.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSDBManager+GW.h"

@implementation KDSDBManager (GW)

- (void)createGWTableInDB:(FMDatabase *)db
{
    //创建网关表。包含网关sn号、网关模型等列。
    [db executeUpdate:@"create table if not exists KDSGatewayAttr (sn text primary key not null default '', gw blob default null)"];
    //创建网关锁表。包含锁id、锁所属网关的sn、锁模(GatewayDeviceModel)、开锁密码、开锁次数、密码错误次数、密码首次错误时间、锁电量、获取锁电量时的时间、同步锁时间时的时间等列。
    [db executeUpdate:@"create table if not exists KDSGWLockAttr (id text primary key not null default '', gwSn text not null default '', device blob, unlockPassword text default null, unlockTimes integer default null, pwdIncorrectTimes integer default null, pwdIncorrectFirstTime real default null, power integer default -1, powerDate real default null, syncDate real default null)"];
    //开锁、报警记录表。hash:记录唯一性(具体查看insert方法)，deviceId:设备id，gwSn:设备对应的网关sn，record:开锁或报警模型二进制数据，type:记录类型(1网关开锁，2网关报警，3猫眼开锁(有的话)，4猫眼报警)
    [db executeUpdate:@"create table if not exists KDSGWRecord (hash text primary key not null default '', deviceId text not null default '', gwSn text not null default '', record blob, type integer)"];
    //创建密密匙表。包含设备id+密码类型+密码编号组成的字符串、锁id、锁所属网关sn、密码模型。
    [db executeUpdate:@"create table if not exists KDSGWLockPwd (id text primary key not null default '', deviceId text not null default '', gwSn text not null default '', password blob)"];
}

- (void)clearGWTableCacheInDB:(FMDatabase *)db
{
    //KDSGWRecord需要删的
    [db executeUpdate:@"delete from KDSGWRecord"];
}

#pragma mark - 网关相关。
- (BOOL)updateBindedGateways:(NSArray<GatewayModel *> *)gateways
{
    __block BOOL result = YES;
    NSArray *old = [self queryBindedGateways];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (GatewayModel *m in old)
        {
            if (![gateways containsObject:m])
            {
                BOOL b1 = [db executeUpdate:@"delete from KDSGatewayAttr where sn = ?", m.deviceSN];
                BOOL b2 = [db executeUpdate:@"delete from KDSGWLockAttr where gwSn = ?", m.deviceSN];
                BOOL b3 = [db executeUpdate:@"delete from KDSGWRecord where gwSn = ?", m.deviceSN];
                BOOL b4 = [db executeUpdate:@"delete from KDSGWLockPwd where gwSn = ?", m.deviceSN];
                if (!(b1 && b2 && b3 && b4))
                {
                    result = NO;
                    break;
                }
            }
        }
        if (!result)
        {
            *rollback = YES;
            return;
        }
        for (GatewayModel *m in gateways)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:m];
            if ([old containsObject:m])
            {
                result = [db executeUpdate:@"update KDSGatewayAttr set gw = ? where sn = ?", data, m.deviceSN];
            }
            else
            {
                result = [db executeUpdate:@"insert into KDSGatewayAttr(sn, gw) values(?, ?)", m.deviceSN, data];
            }
            if (!result)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    if (result)//...
    {
        NSMutableArray *locks = [NSMutableArray array];
        for (GatewayModel *gw in gateways)
        {
            for (GatewayDeviceModel *device in gw.devices)
            {
                if ([device.device_type isEqualToString:@"kdszblock"])
                {
                    [locks addObject:device];
                }
            }
        }
        NSArray *oldLocks = [self queryGWLocksWithSN:nil];
        NSMutableArray *deletes = [NSMutableArray array];
        for (GatewayDeviceModel *old in oldLocks)
        {
            if (![locks containsObject:old]) [deletes addObject:old];
        }
        [self deleteGWLocks:deletes sn:nil];
        [self updateGWLocks:locks];
    }
    
    return result;
}

- (NSArray<GatewayModel *> *)queryBindedGateways
{
    __block NSMutableArray *array = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select * from KDSGatewayAttr"];
        while ([set next])
        {
            if (!array) array = [NSMutableArray array];
            NSData *data = [set dataForColumn:@"gw"] ?: NSData.data;
            GatewayModel *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (m) [array addObject:m];
        }
    }];
    return array;
}

#pragma mark - 网关锁相关
- (BOOL)updateGWLocks:(NSArray<GatewayDeviceModel *> *)locks
{
    __block BOOL result = YES;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (GatewayDeviceModel *lock in locks)
        {
            FMResultSet *set = [db executeQuery:@"select device from KDSGWLockAttr where id = ?", lock.deviceId];
            BOOL existed = NO;
            while ([set next])
            {
                existed = YES;
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:lock];
            if (existed)
{                       
                result = [db executeUpdate:@"update KDSGWLockAttr set device = ?, gwSn = ? where id = ?", data, lock.gwId, lock.deviceId];
            }
            else
            {
                result = [db executeUpdate:@"insert into KDSGWLockAttr(id, gwSn, device) values(?, ?, ?)", lock.deviceId, lock.gatewayId, data];
            }
            if (!result)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return result;
}

- (NSArray<GatewayDeviceModel *> *)queryGWLocksWithSN:(NSString *)gwSn
{
    __block NSMutableArray *array = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set;
        if (gwSn)
        {
            set = [db executeQuery:@"select device from KDSGWLockAttr where gwSn = ?", gwSn];
        }
        else
        {
            set = [db executeQuery:@"select device from KDSGWLockAttr"];
        }
        while ([set next])
        {
            if (!array) array = [NSMutableArray array];
            NSData *data = [set dataForColumn:@"device"] ?: NSData.data;
            GatewayDeviceModel *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (m) [array addObject:m];
        }
    }];
    return array.count ? array : nil;
}

- (BOOL)deleteGWLocks:(NSArray<GatewayDeviceModel *> *)locks sn:(NSString *)gwSn
{
    if (!locks && !gwSn) return NO;
    __block BOOL result = YES;
    
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (locks)
        {
            for (GatewayDeviceModel *lock in locks)
            {
                BOOL b1 = [db executeUpdate:@"delete from KDSGWRecord where deviceId = ?", lock.deviceId];
                BOOL b2 = [db executeUpdate:@"delete from KDSGWLockPwd where deviceId = ?", lock.deviceId];
                result = [db executeUpdate:@"delete from KDSGWLockAttr where id = ?", lock.deviceId];
                if (!result || !b1 || !b2)
                {
                    *rollback = YES;
                    break;
                }
            }
        }
        else
        {
            BOOL b1 = [db executeUpdate:@"delete from KDSGWRecord where gwSn = ?", gwSn];
            BOOL b2 = [db executeUpdate:@"delete from KDSGWLockPwd where gwSn = ?", gwSn];
            result = [db executeUpdate:@"delete from KDSGWLockAttr where gwSn = ?", gwSn];
            if (!result || !b1 || !b2)
            {
                *rollback = YES;
            }
        }
    }];
    
    return result;
}

- (BOOL)updateUnlockPwd:(nullable NSString *)pwd withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (!pwd)
        {
            FMResultSet *set = [db executeQuery:@"select pwdIncorrectTimes from KDSGWLockAttr where id = ?", lock.deviceId];
            int times = 0;
            while ([set next])
            {
                times = [set intForColumn:@"pwdIncorrectTimes"];
            }
            times ++;
            result = [db executeUpdate:@"update KDSGWLockAttr set unlockPassword = null, pwdIncorrectTimes = ? where id = ?", @(times), lock.deviceId];
        }
        else
        {
            result = [db executeUpdate:@"update KDSGWLockAttr set unlockPassword = ?, pwdIncorrectTimes = 0 where id = ?", pwd, lock.deviceId];
        }
    }];
    return result;
}

- (nullable NSString *)queryUnlockPwdWithLock:(GatewayDeviceModel *)lock
{
    __block NSString *pwd = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select unlockPassword from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            pwd = [set stringForColumn:@"unlockPassword"];
        }
    }];
    return pwd;
}

- (BOOL)updateUnlockTimes:(int)times withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"update KDSGWLockAttr set unlockTimes = ? where id = ?", @(times), lock.deviceId];
    }];
    return result;
}

- (int)queryUnlockTimesWithLock:(GatewayDeviceModel *)lock
{
    __block int times = -1;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select unlockTimes from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            times = [set intForColumn:@"unlockTimes"];
        }
    }];
    return times;
}

- (BOOL)updatePwdIncorrectTimes:(int)times withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"update KDSGWLockAttr set pwdIncorrectTimes = ? where id = ?", @(times), lock.deviceId];
    }];
    return result;
}

- (int)queryPwdIncorrectTimesWithLock:(GatewayDeviceModel *)lock
{
    __block int times = 0;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select pwdIncorrectTimes from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            times = [set intForColumn:@"pwdIncorrectTimes"];
        }
    }];
    return times;
}

- (BOOL)updatePwdIncorrectFirstTime:(double)seconds withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"update KDSGWLockAttr set pwdIncorrectFirstTime = ? where id = ?", @(seconds), lock.deviceId];
    }];
    return result;
}

- (double)queryPwdIncorrectFirstTimeWithLock:(GatewayDeviceModel *)lock
{
    __block double seconds = 0;//NAN
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select pwdIncorrectFirstTime from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            seconds = [set intForColumn:@"pwdIncorrectFirstTime"];
        }
    }];
    return seconds;
}

- (BOOL)updatePower:(double)power withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"update KDSGWLockAttr set power = ? where id = ?", @(power), lock.deviceId];
    }];
    return result;
}

- (int)queryPowerWithLock:(GatewayDeviceModel *)lock
{
    __block int power = -1;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select power from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            power = [set intForColumn:@"power"];
        }
    }];
    return power;
}

- (BOOL)updatePowerTime:(NSDate *)date withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"update KDSGWLockAttr set powerDate = ? where id = ?", date, lock.deviceId];
    }];
    return result;
}

- (NSDate *)queryPowerTimeWithLock:(GatewayDeviceModel *)lock
{
    __block NSDate *date = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select powerDate from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            date = [set dateForColumn:@"powerDate"];
        }
    }];
    return date;
}

- (BOOL)updateSyncTime:(NSDate *)date withLock:(GatewayDeviceModel *)lock
{
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"update KDSGWLockAttr set syncDate = ? where id = ?", date, lock.deviceId];
    }];
    return result;
}

- (NSDate *)querySyncTimeWithLock:(GatewayDeviceModel *)lock
{
    __block NSDate *date = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select syncDate from KDSGWLockAttr where id = ?", lock.deviceId];
        while ([set next])
        {
            date = [set dateForColumn:@"syncDate"];
        }
    }];
    return date;
}

#pragma mark - 开锁、报警记录表接口。KDSGWRecord
- (BOOL)insertRecords:(NSArray *)records inDevice:(GatewayDeviceModel *)device
{
    if (!device) return NO;
    __block BOOL result = YES;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (id record in records)
        {
            if ([record isKindOfClass:KDSAlarmModel.class])
            {
                KDSAlarmModel *m = record;
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:record];
                int type = [device.device_type isEqualToString:@"kdszblock"] ? 2 : 4;
                NSString *hash = [NSString stringWithFormat:@"%d%.6lf%@%d", m.warningType, m.warningTime, m.devName, type];//模型的hash每次启动都会变
                result = [db executeUpdate:@"insert or replace into KDSGWRecord values(?, ?, ?, ?, ?)", hash, device.deviceId, device.gwId, data, @(type)];
            }
            else if ([record isKindOfClass:KDSGWUnlockRecord.class])
            {
                KDSGWUnlockRecord *rec = record;
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:record];
                int type = [device.device_type isEqualToString:@"kdszblock"] ? 1 : 3;
                NSString *hash = [NSString stringWithFormat:@"%@%d%d%.6lf%d", rec.lockName, rec.user_num.intValue, rec.open_type.intValue, rec.open_time, type];
                result = [db executeUpdate:@"insert or replace into KDSGWRecord values(?, ?, ?, ?, ?)", hash, device.deviceId, device.gwId, data, @(type)];
            }
            else
            {
                continue;
            }
            if (!result)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return result;
}

- (nullable NSArray *)queryRecordsInDevice:(nullable GatewayDeviceModel *)device type:(int)type
{
    if ([device.device_type isEqualToString:@"kdszblock"] && !(type==1 || type==2))
    {
        return nil;
    }
    else if ([device.device_type isEqualToString:@"kdscateye"] && !(type==3 || type==4))
    {
        return nil;
    }
    else if (!device && !(type==1 || type==2 || type==3 || type==4 || type==5 || type==6 || type==99))
    {
        return nil;
    }
    __block NSMutableArray *array = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql;
        if (device)
        {
            sql = [NSString stringWithFormat:@"select record from KDSGWRecord where deviceId = '%@' and type = %d", device.deviceId, type];
        }
        else if (type == 5)
        {
            sql = @"select record from KDSGWRecord where type = 1 or type = 3";
        }
        else if (type == 6)
        {
            sql = @"select record from KDSGWRecord where type = 2 or type = 4";
        }
        else if (type == 99)
        {
            sql = @"select * from KDSGWRecord";
        }
        else
        {
            sql = [NSString stringWithFormat:@"select record from KDSGWRecord where type = %d", type];
        }
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"record"] ?: NSData.data;
            id record = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            !record ?: [array addObject:record];
        }
    }];
    return array.count ? array : nil;
}

- (BOOL)deleteRecordsInDevice:(nullable GatewayDeviceModel *)device type:(int)type
{
    if ([device.device_type isEqualToString:@"kdszblock"] && !(type==1 || type==2))
    {
        return NO;
    }
    else if ([device.device_type isEqualToString:@"kdscateye"] && !(type==3 || type==4))
    {
        return NO;
    }
    else if (!device && !(type==1 || type==2 || type==3 || type==4 || type==5 || type==6 || type==99))
    {
        return NO;
    }
    __block BOOL result = YES;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql;
        if (device)
        {
            sql = [NSString stringWithFormat:@"delete from KDSGWRecord where deviceId = '%@' and type = %d", device.deviceId, type];
        }
        else if (type == 5)
        {
            sql = @"delete from KDSGWRecord where type = 1 or type = 3";
        }
        else if (type == 6)
        {
            sql = @"delete from KDSGWRecord where type = 2 or type = 4";
        }
        else if (type == 99)
        {
            sql = @"delete from KDSGWRecord";
        }
        else
        {
            sql = [NSString stringWithFormat:@"delete from KDSGWRecord where type = %d", type];
        }
        result = [db executeUpdate:sql];
    }];
    return result;
}

#pragma mark - 密码表接口。KDSGWLockPwd
- (BOOL)insertPasswords:(NSArray<KDSPwdListModel *> *)models withLock:(GatewayDeviceModel *)lock
{
    if (models.count==0 || lock.deviceId.length==0) return YES;
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (KDSPwdListModel *m in models)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:m];
            NSLog(@"写入数据库的密码的策略：%@-%@以及密码个数：%@",m.startTime,m.endTime,m.num);
            int type = 0;
            switch (m.pwdType)
            {
                case KDSServerKeyTpyePIN:
                    type = 1;
                    break;
                    
                case KDSServerKeyTpyeTempPIN:
                    type = 2;
                    break;
                    
                case KDSServerKeyTpyeFingerprint:
                    type = 3;
                    break;
                    
                case KDSServerKeyTpyeCard:
                    type = 4;
                    break;
                    
                default:
                    break;
            }
            NSString *_id = [NSString stringWithFormat:@"%@%02d%03d", lock.deviceId, type, m.num.intValue];
            res = [db executeUpdate:@"insert or replace into KDSGWLockPwd values(?, ?, ?, ?)", _id, lock.deviceId, lock.gwId, data];
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}
//func = openLock;
- (NSArray<KDSPwdListModel *> *)queryPasswordsWithLock:(GatewayDeviceModel *)lock type:(int)type
{
    NSMutableArray *models = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select password from KDSGWLockPwd where id like '%@%@%%'", lock.deviceId, type==99 ? @"" : [NSString stringWithFormat:@"%02d", type]];
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"password"];
            KDSUnlockAttr *attr = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
            !attr ?: [models addObject:attr];
        }
    }];
    return models.count ? models.copy : nil;
}

- (BOOL)deletePasswords:(NSArray<KDSPwdListModel *> *)models withLock:(GatewayDeviceModel *)lock
{
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
        NSString *sql = nil;
        if (!models)
        {
            sql = [NSString stringWithFormat:@"delete from KDSGWLockPwd where id like '%@%%'", lock.deviceId];
            res = [db executeUpdate:sql];
            if (!res)
            {
                *rollback = YES;
            }
        }
        else
        {
            for (KDSPwdListModel *model in models)
            {
                int type = 0;
                switch (model.pwdType)
                {
                    case KDSServerKeyTpyePIN:
                        type = 1;
                        break;
                        
                    case KDSServerKeyTpyeTempPIN:
                        type = 2;
                        break;
                        
                    case KDSServerKeyTpyeFingerprint:
                        type = 3;
                        break;
                        
                    case KDSServerKeyTpyeCard:
                        type = 4;
                        break;
                        
                    default:
                        break;
                }
                sql = [NSString stringWithFormat:@"delete from KDSGWLockPwd where id like '%@%02d%03d'", lock.deviceId, type, model.num.intValue];
                
                res = [db executeUpdate:sql];
                if (!res)
                {
                    *rollback = YES;
                    break;
                }
            }
        }
    }];
    return res;
}

@end

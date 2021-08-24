//
//  KDSDBManager.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/24.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSDBManager.h"
#import "NSString+extension.h"
#import <SAMKeychain/SAMKeychain.h>
#import "KDSDBManager+GW.h"
#import "KDSDBManager+XMMediaLock.h"

static const NSInteger DB_USER_VERSION = 1;//!<当前APP版本的数据库用户版本，此变量用于数据库版本迁移升级。

@interface KDSDBManager ()
{
    FMDatabaseQueue * _dbQueue;
    ///当前的数据库用户名，使用保存的登录名。如果登录名已改变，则关闭原数据库，打开新数据库。
    NSString *_username;
}

@end

@implementation KDSDBManager

+ (instancetype)sharedManager
{
    static KDSDBManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSDBManager alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self dbQueue];
    }
    return self;
}

- (FMDatabaseQueue *)dbQueue
{
    NSString *account = [KDSTool getDefaultLoginAccount];
    if (!account.length) return nil;
    if (![_username isEqualToString:account])
    {
        [_dbQueue close];
        _dbQueue = nil;
    }
    if (!_dbQueue)
    {
        _username = account;
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dbDir = [document stringByAppendingPathComponent:@"KDSDB"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:dbDir])
        {
            [fm createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *dbPath = [dbDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.db", (unsigned long)account.hash]];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
//        NSString *key = [SAMKeychain passwordForService:@"KDSDBService" account:account];
        NSError *error = nil;
         NSString *key =  [SAMKeychain passwordForService:@"KDSDBService" account:account error:&error];
        if(key){
            //设这个是在设备第一次解锁后，可以使用。这个最常见的就是后台唤醒功能里面。
            [SAMKeychain setAccessibilityType:kSecAttrAccessibleAfterFirstUnlock];
            
            [SAMKeychain setPassword:key forService:@"KDSDBService" account:account];
        }
        //苹果bug，手机没解锁keyChain出现偶然存取失败-25308
        if([error code] == -25308){
            NSLog(@"--{kaadas}--SAMKeychain error=%@",error.localizedDescription);
        }
        if (!key)
        {
            key = [NSString uuid];
            [SAMKeychain setPassword:key forService:@"KDSDBService" account:account];
        }
        key = [key stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db setKey:key];
            [self createTableInDB:db];
            [self createGWTableInDB:db];
            [self createXMMediaLockTableInDB:db];
            [self migrateDatabase:db];
        }];
    }
    return _dbQueue;
}

///建表
- (void)createTableInDB:(FMDatabase *)db
{
    //用户表，包含用户名(账号)、昵称、登录token、uid、用户名、用户密码、头像数据、手势密码状态、手势密码、touch id状态、最后验证时间(手势密码和touchID)、(手势密码和touchID)剩余验证次数、协议内容、授权开锁成员(KDSAuthMember)等。
    [db executeUpdate:@"create table if not exists KDSUser (name text primary key not null default '', nickname text, token text, uid text, username text, password text, avatarData blob, gesturePwdState integer default 0, gesturePwd text default null, touchIDState integer default 0, lastAuthDate date default null, remainAuthTimes integer default 5, userAgreement blob default null, members blob default null)"];
    //[db executeUpdate:@"alter table KDSUser add column members blob default null"];
    //蓝牙属性表，主键是蓝牙名称，包含优先级、是否最后一次连接、开锁密码(6~12位数字)、设备模型、最后一次上传开锁记录数据(20字节转成的40字节字符串)、最后一次上传报警记录数据(20字节转成的40字节字符串)、开锁次数、密码开锁失败次数、首次失败时间(距70年秒数，方便和服务器返回的时间对比)、锁电量、获取锁电量时的时间。
    [db executeUpdate:@"create table if not exists KDSBleAttr (bleName text primary key not null default '', priorityLevel integer default 0, isLastConnectBle integer default 0, unlockPassword text default null, device blob, lastUploadUnlockData text default null, lastUploadAlarmData text default null, unlockTimes integer default null, pwdIncorrectTimes integer default 0, pwdIncorrectFirstTime real default 0, power integer default -1, powerDate real default null)"];
    
    ///开锁类型表，缓存开锁记录的开锁属性。id由蓝牙名称+3位编号组成的字符串+开锁类型组成。
    [db executeUpdate:@"create table if not exists KDSUnlockAttr (id text primary key not null default '', unlockAttribute blob default null)"];
    //缓存APP设置的密码属性。id由蓝牙名称+2位密码类型(01密码，02临时密码，03指纹，04卡片)+3位编号组成的字符串，pwdAttribute(KDSPwdListModel归档数据)
    [db executeUpdate:@"create table if not exists KDSPasswordAttr (id text primary key not null default '', pwdAttribute blob default null)"];
    ///开锁、操作和报警记录表。为减少蓝牙的读取，如果记录读取完毕但是由于网络原因未上传成功，那么将记录保存于此，以后上传时先检查有没有未上传的记录，如果有，一并上传。recordKey唯一性，由命令2字节16进制字符串+28(操作24)字节16进制记录字符串+(1~2)字节10进制字符串记录类型组成；bleName蓝牙名称；recordType:记录类型，0未上传的开锁记录，1未上传的报警记录，2开锁记录，3报警记录，4未上传的操作记录，5操作记录；recordData记录模型二进制数据。
    [db executeUpdate:@"create table if not exists KDSRecord (recordKey text primary key not null default '', bleName text not null default '', recordType integer, recordData blob)"];
    ///鉴权异常记录表，蓝牙名称+异常记录。
    [db executeUpdate:@"create table if not exists KDSAuthException (bleName text not null default '', authException blob)"];
    ///FAQ和系统消息表，hash模型_id值，FAQOrMessage FAQ或者系统消息模型NSData数据，type类型(1FAQ，2系统消息，3本地被标记为删除的FAQ，4本地被标记为删除的系统消息)
    [db executeUpdate:@"create table if not exists KDSFAQAndMessage (hash text primary key not null default '', FAQOrMessage blob, type integer)"];
    ///猫眼的基本信息（设备ID、userID、硬件版本号、软件版本号、mac地址、铃响次数、铃声、分辨率,电量）
    
    [db executeUpdate:@"create table if not exists KDSCatEyeSQL (userId text,deviceId text,SWVsion text, HWVsion text, macaddr text, MCU text,T200 text,ipaddr text,wifiStrength text,curBellNum text,bellVolume text,maxBellNum text,resolution text,pirEnable text,bellCount text,sdStatus text,pirSensitivity text)"];
    
    //用户猫眼pir信息
    [db executeUpdate:@"create table if not exists pirPicSQL (pirPicArrayData blob,userId text,deviceId text,picDate text)"];
    //用户猫眼录屏信息
    [db executeUpdate:@"create table if not exists recordVideoSQL (recordViArrayData blob,userId text,deviceId text,recordDate text)"];
    
}

///数据库版本的迁移升级。
- (void)migrateDatabase:(FMDatabase *)db
{
    NSInteger userVersion = db.userVersion;
    if (userVersion >= DB_USER_VERSION) return;
    BOOL success = YES;
    [db beginTransaction];
    while (userVersion < DB_USER_VERSION)
    {
        switch (userVersion)
        {
            case 0://2019.6.12添加，下一个版本前的迁移请在这里处理。
                //在KDSUser表新增一个手势密码、指纹验证开启字段，解决使用日期验证时可以一直修改系统日期跳过验证的问题。
                success = [db executeUpdate:@"alter table KDSUser add column needAuthentication boolean default 0"];
                if (!success) break;
                //在蓝牙属性表KDSBleAttr添加一个最后更新的操作记录数据。
                success = [db executeUpdate:@"alter table KDSBleAttr add column lastUpdateOpData text default null"];
                if (!success) break;
                //在猫眼属性表添加一个电量数据
                success = [db executeUpdate:@"alter table KDSCatEyeSQL add column power text default null"];
                if (!success) break;
                break;
                
            default:
                break;
        }
        if (!success) break;
        userVersion++;
    }
    if (success)
    {
        db.userVersion = DB_USER_VERSION;
        [db commit];
    }
    else
    {
        [db rollback];
    }
}

#pragma mark - 用户表接口KDSUser
- (BOOL)updateUser:(KDSUser *)user
{
    __block BOOL res = NO;
    KDSUser *oldUser = [self queryUser];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (oldUser)
        {
            res = [db executeUpdateWithFormat:@"update KDSUser set token = %@, uid = %@, username = %@, password = %@", user.token, user.uid, user.username, user.password];
        }
        else
        {
            res = [db executeUpdateWithFormat:@"insert into KDSUser (name, token, uid, username, password) values (%@, %@, %@, %@, %@)", user.name, user.token, user.uid, user.username, user.password];
        }
        if (user.token.length)//登录成功后更新验证时间。
        {
            [db executeUpdate:@"update KDSUser set lastAuthDate = ?", @(NSDate.date.timeIntervalSince1970)];
            [db executeUpdate:@"update KDSUser set remainAuthTimes = 5"];
        }
    }];
    return res;
}

- (KDSUser *)queryUser
{
    __block KDSUser *user = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select * from KDSUser"];
        while ([set next])
        {
            user = [[KDSUser alloc] init];
            user.name = [set stringForColumn:@"name"];
            user.token = [set stringForColumn:@"token"];
            user.uid = [set stringForColumn:@"uid"];
            user.username = [set stringForColumn:@"username"];
            user.password = [set stringForColumn:@"password"];
            [set close];
            break;
        }
    }];
    return user;
}

- (BOOL)updateUserNickname:(nullable NSString *)nickname
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set nickname = ?", nickname];
    }];
    return res;
}

- (nullable NSString *)queryUserNickname
{
    __block NSString *nickname = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select nickname from KDSUser"];
        while ([set next])
        {
            nickname = [set stringForColumn:@"nickname"];
        }
    }];
    return nickname;
}

- (BOOL)updateUserAvatarData:(NSData *)data
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set avatarData = ?", data];
    }];
    return res;
}

- (NSData *)queryUserAvatarData
{
    __block NSData *data = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select avatarData from KDSUser"];
        while ([set next])
        {
            data = [set dataForColumn:@"avatarData"];
        }
    }];
    return data;
}

- (BOOL)updateUserGesturePwdState:(BOOL)state
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set gesturePwdState = ?", @(state)];
    }];
    return res;
}

- (BOOL)queryUserGesturePwdState
{
    __block BOOL state = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select gesturePwdState from KDSUser"];
        while ([set next])
        {
            state = [set boolForColumn:@"gesturePwdState"];
        }
    }];
    return state;
}

- (BOOL)updateUserGesturePwd:(NSString *)pwd
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set gesturePwd = ?", pwd];
    }];
    return res;
}

- (NSString *)queryUserGesturePwd
{
    __block NSString *pwd = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select gesturePwd from KDSUser"];
        while ([set next])
        {
            pwd = [set stringForColumn:@"gesturePwd"];
        }
    }];
    return pwd;
}

- (BOOL)updateUserTouchIDState:(BOOL)state
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set touchIDState = ?", @(state)];
    }];
    return res;
}

- (BOOL)queryUserTouchIDState
{
    __block BOOL state = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select touchIDState from KDSUser"];
        while ([set next])
        {
            state = [set boolForColumn:@"touchIDState"];
        }
    }];
    return state;
}

- (BOOL)updateUserAuthDate:(NSDate *)date
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set lastAuthDate = ?", @(date.timeIntervalSince1970)];
    }];
    return res;
}

- (NSDate *)queryUserAuthDate
{
    __block NSDate *date = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select lastAuthDate from KDSUser"];
        while ([set next])
        {
            date = [NSDate dateWithTimeIntervalSince1970:[set doubleForColumn:@"lastAuthDate"]];
        }
    }];
    return date;
}

- (BOOL)updateAuthenticationState:(BOOL)needAuthentication
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set needAuthentication = ?", @(needAuthentication)];
    }];
    return res;
}

- (BOOL)queryAuthenticationState
{
    __block BOOL state = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select needAuthentication from KDSUser"];
        while ([set next])
        {
            state = [set boolForColumn:@"needAuthentication"];
        }
    }];
    return state;
}

- (BOOL)updateUserAuthTimes:(int)times
{
    times = times>5 ? 5 : times;
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSUser set remainAuthTimes = ?", @(times)];
    }];
    return res;
}

- (int)queryUserAuthTimes
{
    __block int times = 0;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select remainAuthTimes from KDSUser"];
        while ([set next])
        {
            times = [set intForColumn:@"remainAuthTimes"];
        }
    }];
    return times;
}

- (BOOL)updateUserAuthMembers:(NSArray<KDSAuthMember *> *)members
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (!members.count)
        {
            res = [db executeUpdate:@"update KDSUser set members = null"];
        }
        else
        {
            NSMutableArray *ms = [NSMutableArray arrayWithCapacity:members.count];
            for (KDSAuthMember *m in members)
            {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:m];
                NSString *s = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                [ms addObject:s];
            }
            NSData *data = [NSJSONSerialization dataWithJSONObject:ms options:0 error:0];
            res = [db executeUpdate:@"update KDSUser set members = ?", data];
        }
    }];
    return res;
}

- (NSArray<KDSAuthMember *> *)queryUserAuthMembers
{
    __block NSMutableArray *members = [NSMutableArray array];;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select members from KDSUser"];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"members"];
            if (!data) continue;
            NSArray<NSString *> *strings = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
            for (NSString *string in strings)
            {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
                KDSAuthMember *m = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
                !m ?: [members addObject:m];
            }
        }
    }];
    return members.count ? members.copy : nil;
}

#pragma mark - 蓝牙属性表接口KDSBleAttr
- (BOOL)updateBindedDevices:(NSArray<MyDevice *> *)devices
{
    __block BOOL res = NO;
    NSArray<MyDevice *> *oldDevices = [self queryBindedDevices];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (MyDevice *device in oldDevices)
        {
            if (![devices containsObject:device])
            {
                [db executeUpdate:@"delete from KDSBleAttr where bleName = ?", device.lockName];
                NSString *sql = [NSString stringWithFormat:@"delete from KDSUnlockAttr where id like '%@%%'", device.lockName];
                [db executeUpdate:sql];
                sql = [NSString stringWithFormat:@"delete from KDSPasswordAttr where id like '%@%%'", device.lockName];
                [db executeUpdate:sql];
                [db executeUpdate:@"delete from KDSRecord where bleName = ?", device.lockName];
                [db executeUpdate:@"delete from KDSAuthException where bleName = ?", device.lockName];
            }
        }
        for (MyDevice *device in devices)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:device];
            if ([oldDevices containsObject:device])
            {
                res = [db executeUpdateWithFormat:@"update KDSBleAttr set device = %@ where bleName = %@", data, device.lockName];
            }
            else
            {
                res = [db executeUpdateWithFormat:@"insert into KDSBleAttr (bleName, device) values(%@, %@)", device.lockName, data];
            }
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (BOOL)updateBindedWifiModels:(NSArray<KDSWifiLockModel *> *)wifiModels
{
    __block BOOL res = NO;
    NSArray<KDSWifiLockModel *> *oldDevices = [self queryBindedWifiModels];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (KDSWifiLockModel *device in oldDevices)
        {
            if (![wifiModels containsObject:device])
            {
                [db executeUpdate:@"delete from KDSBleAttr where bleName = ?", device.wifiSN];
            }
        }
        for (KDSWifiLockModel *device in wifiModels)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:device];
            if ([oldDevices containsObject:device])
            {
                res = [db executeUpdateWithFormat:@"update KDSBleAttr set device = %@ where bleName = %@", data, device.wifiSN];
            }
            else
            {
                res = [db executeUpdateWithFormat:@"insert into KDSBleAttr (bleName, device) values(%@, %@)", device.wifiSN, data];
            }
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (NSArray<MyDevice *> *)queryBindedDevices
{
    __block NSMutableArray<MyDevice *> *devices = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select * from KDSBleAttr"];
        while ([set next])
        {
            NSData *rootData = [set dataForColumn:@"device"];
            if (rootData)
            {
                MyDevice *device = [NSKeyedUnarchiver unarchiveObjectWithData:rootData];
                if (device && [device isKindOfClass:[MyDevice class]]) [devices addObject:device];
            }
        }
    }];
    return devices.count ? devices.copy : nil;
}

- (NSArray<KDSWifiLockModel *> *)queryBindedWifiModels
{
    __block NSMutableArray<KDSWifiLockModel *> *devices = [NSMutableArray array];
       [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
           FMResultSet *set = [db executeQuery:@"select * from KDSBleAttr"];
           while ([set next])
           {
               NSData *rootData = [set dataForColumn:@"device"];
               if (rootData)
               {
                   KDSWifiLockModel *device = [NSKeyedUnarchiver unarchiveObjectWithData:rootData];
                   if (device && [device isKindOfClass:[KDSWifiLockModel class]]) [devices addObject:device];
               }
           }
       }];
       return devices.count ? devices.copy : nil;
}

- (BOOL)updateUploadRecordData:(NSString *)data withBleName:(NSString *)name type:(int)type
{
    if (!data) return NO;
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSDictionary *map = @{@0:@"lastUploadUnlockData", @1:@"lastUploadAlarmData", @2:@"lastUpdateOpData"};
        NSString *column = map[@(type)] ?: @"unknowColumn";
        NSString *sql = [NSString stringWithFormat:@"update KDSBleAttr set %@ = '%@' where bleName = '%@'", column, data, name];
        res = [db executeUpdate:sql];
    }];
    return res;
}

- (NSString *)queryUploadRecordDataWithBleName:(NSString *)name type:(int)type
{
    __block NSString *date = nil;
    NSDictionary *map = @{@0:@"lastUploadUnlockData", @1:@"lastUploadAlarmData", @2:@"lastUpdateOpData"};
    NSString *column = map[@(type)] ?: @"unknowColumn";
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from KDSBleAttr where bleName = '%@'", column, name];
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            date = [set stringForColumn:column];
        }
    }];
    if (date.length != 40)
    {
        char c[41] = {0};
        for (int i = 0; i < 40; ++i)
        {
            c[i] = '0';
        }
        c[40] = 0;
        date = @(c);
    }
    return date;
}

- (BOOL)updateUnlockPwd:(NSString *)pwd withBleName:(NSString *)name
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (!pwd.length)
        {
            FMResultSet *set = [db executeQuery:@"select pwdIncorrectTimes from KDSBleAttr where bleName = ?", name];
            int times = 0;
            while ([set next])
            {
                times = [set intForColumn:@"pwdIncorrectTimes"];
            }
            times ++;
            res = [db executeUpdate:@"update KDSBleAttr set unlockPassword = null, pwdIncorrectTimes = ? where bleName = ?", @(times), name];
        }
        else
        {
            res = [db executeUpdate:@"update KDSBleAttr set unlockPassword = ?, pwdIncorrectTimes = 0 where bleName = ?", pwd, name];
        }
    }];
    return res;
}

- (NSString *)queryUnlockPwdWithBleName:(NSString *)name
{
    __block NSString * pwd = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select unlockPassword from KDSBleAttr where bleName = ?", name];
        while ([set next])
        {
            pwd = [set stringForColumn:@"unlockPassword"];
        }
    }];
    return pwd;
}

- (BOOL)updateUnlockTimes:(int)times withBleName:(NSString *)name
{
    if (times < 0) return NO;
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSBleAttr set unlockTimes = ? where bleName = ?", @(times), name];
    }];
    return res;
}

- (int)queryUnlockTimesWithBleName:(NSString *)name
{
    __block int times = -1;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select unlockTimes from KDSBleAttr where bleName = ?", name];
        while ([set next])
        {
            times = [set intForColumn:@"unlockTimes"];
        }
    }];
    return times;
}

- (BOOL)updatePwdIncorrectTimes:(int)times withBleName:(NSString *)name
{
    if (times < 0) return NO;
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSBleAttr set pwdIncorrectTimes = ? where bleName = ?", @(times), name];
    }];
    return res;
}

/**
 *@abstract 查询已绑定设备的密码开锁失败次数。
 *@param name 蓝牙名称。
 *@return 已绑定设备的密码开锁失败次数。
 */
- (int)queryPwdIncorrectTimesWithBleName:(NSString *)name
{
    __block int times = 0;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select pwdIncorrectTimes from KDSBleAttr where bleName = ?", name];
        while ([set next])
        {
            times = [set intForColumn:@"pwdIncorrectTimes"];
        }
    }];
    return times;
}

- (BOOL)updatePwdIncorrectFirstTime:(double)seconds withBleName:(NSString *)name
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSBleAttr set pwdIncorrectFirstTime = ? where bleName = ?", @(seconds), name];
    }];
    return res;
}

- (double)queryPwdIncorrectFirstTimeWithBleName:(NSString *)name
{
    __block double time = 0;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select pwdIncorrectFirstTime from KDSBleAttr where bleName = ?", name];
        while ([set next])
        {
            time = [set doubleForColumn:@"pwdIncorrectFirstTime"];
        }
    }];
    return time;
}

- (BOOL)updatePower:(double)power withBleName:(NSString *)name
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSBleAttr set power = ? where bleName = ?", @(power), name];
    }];
    return res;
}

- (int)queryPowerWithBleName:(NSString *)name
{
    __block int power = -1;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select power from KDSBleAttr where bleName = ?", name];
        while ([set next])
        {
            power = [set intForColumn:@"power"];
        }
    }];
    return power;
}

- (BOOL)updatePowerTime:(NSDate *)date withBleName:(NSString *)name
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db executeUpdate:@"update KDSBleAttr set powerDate = ? where bleName = ?", date, name];
    }];
    return res;
}

- (NSDate *)queryPowerTimeWithBleName:(NSString *)name
{
    __block NSDate *date = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select powerDate from KDSBleAttr where bleName = ?", name];
        while ([set next])
        {
            date = [set dateForColumn:@"powerDate"];
        }
    }];
    return date;
}

#pragma mark - 开锁类型属性表接口KDSUnlockAttr
- (BOOL)insertUnlockAttr:(NSArray<KDSUnlockAttr *> *)attrs
{
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (KDSUnlockAttr *attr in attrs)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attr];
            NSString *_id = [NSString stringWithFormat:@"%@%03d%@", attr.bleName, attr.number, attr.unlockType];
            res = [db executeUpdate:@"insert or replace into KDSUnlockAttr values(?, ?)", _id, data];
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (NSArray<KDSUnlockAttr *> *)queryUnlockAttrWithBleName:(NSString *)name
{
    NSMutableArray *attrs = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select unlockAttribute from KDSUnlockAttr where id like '%@%%'", name];
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"unlockAttribute"];
            KDSUnlockAttr *attr = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
            !attr ?: [attrs addObject:attr];
        }
    }];
    return attrs.count ? attrs.copy : nil;
}

#pragma mark - 密码属性表接口KDSPasswordAttr
- (BOOL)insertPwdAttrs:(NSArray<KDSPwdListModel *> *)models bleName:(nonnull NSString *)name
{
    __block BOOL res = YES;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (KDSPwdListModel *m in models)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:m];
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
            NSString *_id = [NSString stringWithFormat:@"%@%02d%03d", name, type, m.num.intValue];
            res = [db executeUpdate:@"insert or replace into KDSPasswordAttr values(?, ?)", _id, data];
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (NSArray<KDSPwdListModel *> *)queryPwdAttrWithBleName:(NSString *)name type:(int)type
{
    NSMutableArray *models = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select pwdAttribute from KDSPasswordAttr where id like '%@%@%%'", name, type==99 ? @"" : [NSString stringWithFormat:@"%02d", type]];
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"pwdAttribute"];
            KDSPwdListModel *model = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
            !model ?: [models addObject:model];
        }
    }];
    return models.count ? models.copy : nil;
}

- (BOOL)deletePwdAttrs:(NSArray<KDSPwdListModel *> *)models bleName:(NSString *)name
{
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = nil;
        if (!models)
        {
            sql = [NSString stringWithFormat:@"delete from KDSPasswordAttr where id like '%@%%'", name];
            res = [db executeUpdate:sql];
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
                sql = [NSString stringWithFormat:@"delete from KDSPasswordAttr where id like '%@%02d%03d'", name, type, model.num.intValue];
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

#pragma mark - 开锁、报警、操作记录表接口KDSRecord
- (BOOL)insertRecord:(NSArray *)records type:(int)type bleName:(NSString *)name
{
    if (records.count == 0) return YES;
    if (!([records.firstObject isKindOfClass:KDSBleUnlockRecord.class] || [records.firstObject isKindOfClass:KDSBleAlarmRecord.class] || [records.firstObject isKindOfClass:KDSBleOpRec.class])) return NO;
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *key = @"";
        for (id obj in records)
        {
            if ([obj isKindOfClass:KDSBleUnlockRecord.class])
            {
                KDSBleUnlockRecord *rec = obj;
                key = [NSString stringWithFormat:@"%@%@%d", [rec.hexString substringWithRange:NSMakeRange(6, 2)], [rec.hexString substringWithRange:NSMakeRange(12, 28)], type];
            }
            else if ([obj isKindOfClass:KDSBleAlarmRecord.class])
            {
                KDSBleAlarmRecord *rec = obj;
                key = [NSString stringWithFormat:@"%@%@%d", [rec.hexString substringWithRange:NSMakeRange(6, 2)], [rec.hexString substringWithRange:NSMakeRange(12, 28)], type];
            }
            else if ([obj isKindOfClass:KDSBleOpRec.class])
            {
                KDSBleOpRec *rec = obj;
                key = [NSString stringWithFormat:@"%@%@%d", [rec.hexString substringWithRange:NSMakeRange(6, 2)], [rec.hexString substringWithRange:NSMakeRange(16, 24)], type];
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
            res = [db executeUpdateWithFormat:@"insert or replace into KDSRecord values(%@, %@, %d, %@)", key, name, type, data];
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (nullable NSArray *)queryRecord:(int)type bleName:(NSString *)name
{
    NSMutableArray *mArr = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQueryWithFormat:@"select * from KDSRecord where bleName = %@ and recordType = %d", name, type];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"recordData"];
            if (data)
            {
                id record = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                !record ?: [mArr addObject:record];
            }
        }
    }];
    return mArr.count ? mArr.copy : nil;
}

- (BOOL)deleteRecord:(int)type bleName:(NSString *)name
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (type == 99)
        {
            res = [db executeUpdateWithFormat:@"delete from KDSRecord where bleName = %@", name];
        }
        else
        {
            res = [db executeUpdateWithFormat:@"delete from KDSRecord where bleName = %@ and recordType = %d", name, type];
        }
    }];
    return res;
}

#pragma mark - 鉴权异常记录表KDSAuthException接口
- (BOOL)insertAuthExceptions:(NSArray<KDSAuthException *> *)exceptions
{
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (KDSAuthException *exception in exceptions)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:exception];
            res = [db executeUpdateWithFormat:@"insert into KDSAuthException values(%@, %@)", exception.bleName, data];
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (NSArray<KDSAuthException *> *)queryAuthExceptions:(NSString *)bleName
{
    NSMutableArray *arr = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = bleName ? [NSString stringWithFormat:@"select authException from KDSAuthException where bleName = '%@'", bleName] : @"select authException from KDSAuthException";
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"authException"];
            if (data)
            {
                KDSAuthException *exception = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                !exception ?: [arr addObject:exception];
            }
        }
    }];
    return arr.count ? arr.copy : nil;
}

#pragma mark - 常见问题和系统消息表接口KDSFAQAndMessage
- (BOOL)insertFAQOrMessage:(NSArray *)faqmsgs
{
    if (faqmsgs.count == 0) return YES;
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (NSObject *obj in faqmsgs)
        {
            if (!([obj isKindOfClass:KDSFAQ.class] || [obj isKindOfClass:KDSSysMessage.class])) continue;
            
            BOOL isFaq = [obj isKindOfClass:KDSFAQ.class];
            NSString *hash = isFaq ? ((KDSFAQ *)obj)._id : ((KDSSysMessage *)obj)._id;
            BOOL deleted = isFaq ? NO : ((KDSSysMessage *)obj).deleted;
            //1FAQ，2系统消息，3本地被标记为删除的FAQ，4本地被标记为删除的系统消息
            int type = isFaq ? (!deleted ? 1 : 3) : (!deleted ? 2 : 4);
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
            res = [db executeUpdateWithFormat:@"insert or replace into KDSFAQAndMessage values(%@, %@, %d)", hash, data, type];
            if (!res)
            {
                *rollback = YES;
                break;
            }
        }
    }];
    return res;
}

- (NSArray *)queryFAQOrMessage:(int)type
{
    NSMutableArray *arr = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = type!=99 ? [NSString stringWithFormat:@"select * from KDSFAQAndMessage where type = %d", type] : @"select * from KDSFAQAndMessage";
        FMResultSet *set = [db executeQuery:sql];
        while ([set next])
        {
            NSData *data = [set dataForColumn:@"FAQOrMessage"];
            if (data)
            {
                NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                !obj ?: [arr addObject:obj];
            }
        }
    }];
    return arr.count ? arr.copy : nil;
}

- (BOOL)deleteFAQOrMessage:(NSObject *)fom type:(int)type
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (fom)
        {
            NSString *hash = [fom isKindOfClass:KDSFAQ.class] ? ((KDSFAQ *)fom)._id : ((KDSSysMessage *)fom)._id;
            res = [db executeUpdateWithFormat:@"delete from KDSFAQAndMessage where hash = %@", hash];
        }
        else if (type == 99)
        {
            res = [db executeUpdate:@"delete from KDSFAQAndMessage"];
        }
        else
        {
            res = [db executeUpdate:@"delete from KDSFAQAndMessage where type = ? or type = ?", @(type), @(type + 2)];
        }
    }];
    return res;
}


#pragma mark - 其它方法。
- (void)resetDatabase
{
    if (_dbQueue)
    {
        [_dbQueue close];
    }
    _dbQueue = nil;
}

- (void)clearDiskCache
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        //用户表需要删的
        [db executeUpdate:@"update KDSUser set avatarData = null, userAgreement = null, members = null"];
        //蓝牙属性表需要删的
        [db executeUpdate:@"delete from KDSBleAttr"];
        //开锁类型属性表KDSUnlockAttr需要删的
        [db executeUpdate:@"delete from KDSUnlockAttr"];
        //密码属性表KDSPasswordAttr需要删的
        [db executeUpdate:@"delete from KDSPasswordAttr"];
        //记录表KDSRecord需要删的
        [db executeUpdate:@"delete from KDSRecord"];
        //鉴权异常记录表KDSAuthException需要删的。
        [db executeUpdate:@"delete from KDSAuthException"];
        //常见问题和系统消息表接口KDSFAQAndMessage需要删除的。
        [db executeUpdate:@"delete from KDSFAQAndMessage"];
        //网关分表需要删的。
        [self clearGWTableCacheInDB:db];
    }];
}

@end

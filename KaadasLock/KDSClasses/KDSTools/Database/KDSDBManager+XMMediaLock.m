//
//  KDSDBManager+XMMediaLock.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDBManager+XMMediaLock.h"

@implementation KDSDBManager (XMMediaLock)

- (void)createXMMediaLockTableInDB:(FMDatabase *)db
{
    //创建网关锁表。包含锁sn、锁相关的截图、录屏。
    [db executeUpdate:@"create table if not exists KDSXMMediaLockAttr (_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,mediaWifiLockSn text, lockCutData blob,imageName text,mp4Address text)"];
}

- (BOOL)insertXMMediaCutScreenData:(NSData *)data withImageName:(NSString *)imageName mp4Address:(NSString *)mp4Address deviceSn:(NSString *)deviceSn
{
    __block BOOL result = YES;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (mp4Address.length >0) {
            
            result = [db executeUpdateWithFormat:@"insert into KDSXMMediaLockAttr (mediaWifiLockSn, mp4Address, imageName) values (%@, %@, %@)", deviceSn, mp4Address, imageName];
        }else{
            result = [db executeUpdateWithFormat:@"insert into KDSXMMediaLockAttr (mediaWifiLockSn, lockCutData, imageName) values (%@, %@, %@)", deviceSn, data, imageName];
        }
        if (!result)
        {
            *rollback = YES;
        }
        
    }];
    return result;
}

- (NSArray<KDSXMMediaLockModel *> *)queryBindedRecordAndCutFileWithDeviceSn:(NSString *)deviceSn 
{
    __block NSMutableArray *array = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"select * from KDSXMMediaLockAttr where mediaWifiLockSn = ?",deviceSn];
        while ([set next])
        {
            if (!array) array = [NSMutableArray array];
            KDSXMMediaLockModel * mode = [KDSXMMediaLockModel new];
            mode.lockCutData = [set dataForColumn:@"lockCutData"] ?: NSData.data;
            mode.imageName = [set stringForColumn:@"imageName"] ?: @"";
            mode.lockRecordScreenData = [set dataForColumn:@"lockRecordScreenData"] ?: NSData.data;
            mode.recordScreenMP4Name = [set stringForColumn:@"recordScreenMP4Name"] ?: @"";
            mode.mp4Address = [set stringForColumn:@"mp4Address"];
            if (mode.lockCutData || mode.lockRecordScreenData) [array addObject: mode];
        }
    }];
    return array;
}

@end

//
//  KDSDBManager+CY.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/28.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDBManager.h"
#import "AlarmMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDBManager (CY)


#pragma mark - Cateye相关数据操作


/**
 *@abstract 更新猫眼基本信息列表，内部实现使用事务(transaction)。
 *@param cateyeModel 需要更新的猫眼基本信息。
 *@note 如果本地没有记录，会插入新数据；如果有记录，会将新数据整个替换有有数据。因此希望保存原来数据就必须先将原来的数据赋给相应的属性。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updateCateye:(KDSGWCateyeParam *)cateyeModel;
/**
 *@abstract 查询本地cateyeSQL表保存的CateyeModel。
 *@return CateyeModel，can be nil.
 */
-(KDSGWCateyeParam *)getCateyeSettingWithDeviceid:(NSString *)deviceid;
/**
 *@abstract 查询已绑定猫眼的铃声。
 *@param deviceid 猫眼的设备ID。
 *@return 如果没有记录则返回空。
 */
-(NSString *)getBellSelectWithDeviceID:(NSString*)deviceid;
/**
 *@abstract 查询已绑定猫眼的音量。
 *@param deviceid 猫眼的设备ID。
 *@return 如果没有记录则返回空。
 */
-(NSString *)getBellVolumeWithDeviceID:(NSString*)deviceid;
/**
 *@abstract 查询已绑定猫眼的响铃次数。
 *@param deviceid 猫眼的设备ID。
 *@return 如果没有记录则返回空。
 */
-(NSString *)getBellAcount:(NSString*)deviceid;
/**
 *@abstract 查询已绑定猫眼的分辨率。
 *@param deviceid 猫眼的设备ID。
 *@return 如果没有记录则返回空。
 */
-(NSString *)getResolution:(NSString*)deviceid;
/**
 *@abstract 查询已绑定猫眼的pir开关状态0：关、1:开。
 *@param deviceid 猫眼的设备ID。
 *@return 如果没有记录则返回空。
 */
-(NSString *)getPirEnable:(NSString*)deviceid;
/**
 *@abstract 查询已绑定猫眼的sdCard状态0:无sd卡、1:有sd卡。
 *@param deviceid 猫眼的设备ID。
 *@return 如果没有记录则返回空。
 */
-(NSString *)getSdCardStatus:(NSString *)deviceid;
/**
 *@abstract 更新猫眼门铃音量：高、中、低。
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updateBellVolum:(NSString *)volum deviceID:(NSString*)deviceid;
/**
 *@abstract 更新猫眼门铃选择。
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updatBellSelect:(NSString *)bellSelect deviceID:(NSString*)deviceid;
/**
 *@abstract 更新猫眼响铃次数1～5次。
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updatbellNum:(NSString *)bellNum deviceID:(NSString*)deviceid;
/**
 *@abstract 更新猫眼分辨率：960x540、1280x720。
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updatResolution:(NSString *)resolution deviceID:(NSString*)deviceid;
/**
 *@abstract 更新猫眼pir开关状态0:关闭pir、1:开启pir。
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updatPirSwitch:(NSString *)pirSwitch deviceID:(NSString*)deviceid;
/**
 *@abstract 更新猫眼pir徘徊监测：触发次数(N)/秒数(M)，此处6秒内触发3次才拍照上报pir触发事件,M范围3~15秒，M秒触发N次作为灵敏度，N 小于等于 M/2
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updatPirWander:(NSString *)pirWander deviceID:(NSString *)deviceid;
/**
 *@abstract 更新猫眼sd卡状态0:无sd卡、1:有sd卡。
 *@param deviceid 猫眼的设备ID。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
-(BOOL)updatSdCard:(NSString *)sdCard deviceID:(NSString*)deviceid;

- (BOOL)updateCateyePower:(int)power withDeviceId:(NSString *)deviceId;
- (NSString *)queryCateyePowerWithDeviceId:(NSString *)deviceId;

-(void)addPirArray:(NSMutableArray<AlarmMessageModel *> *)pirArray cateyeID:(NSString *)cateyeID picDate:(NSString*)picDate;
-(NSArray<AlarmMessageModel *> *)getPirArrayWithCateID:(NSString*)cateyeID picDate:(NSString*)picDate;
-(void)addRecordVideoArray:(NSMutableArray<AlarmMessageModel *> *)recordArray cateyeID:(NSString *)cateyeID recordDate:(NSString*)recordDate;
-(NSArray<AlarmMessageModel *> *)getRecordArrayWithCateID:(NSString*)cateyeID recordDate:(NSString*)recordDate;
@end

NS_ASSUME_NONNULL_END

//
//  KDSDBManager+GW.h
//  KaadasLock
//
//  Created by orange on 2019/4/30.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSDBManager.h"
#import "KDSAlarmModel.h"
#import "GatewayModel.h"
#import "GatewayDeviceModel.h"
#import "KDSPwdListModel.h"

NS_ASSUME_NONNULL_BEGIN

///网关分类，包含网关+网关锁+猫眼。
@interface KDSDBManager (GW)

///在数据库中创建网关分表，在KDSDBManager实现文件中打开数据库时调用。@warning 其它地方不要调用这个方法。
- (void)createGWTableInDB:(FMDatabase *)db;
///清除网关分表的缓存，在KDSDBManager实现文件中clearDiskCache实现调用。@warning 其它地方不要调用这个方法。
- (void)clearGWTableCacheInDB:(FMDatabase *)db;


#pragma mark - 网关相关。
///FIXME:如果新的网关列表不包含数据库中已有的设备列表的其中的设备，则会删除同一网关名称的其它表的内容，因此请新增表时更新该方法实现。
/**
 *@abstract 更新已绑定的网关列表，内部实现使用事务(transaction)。一般从服务器请求回来或者删除设备时需要调用此方法。
 *如果网关模型下的设备数组不为空，会自动更新锁设备。相当于调用updateGWLocks:和deleteGWLocks:。
 *@param gateways 最新的已绑定的网关列表。如果新设备列表不包含已保存列表其中的设备，会将已保存的设备删除。
 *@note 如果新的设备列表不包含数据库中已有的设备列表的其中的设备，则会删除同一网关的其它表的内容，因此请新增表时更新该方法实现。由于网关模型很多属性都是本地定义的，更新时会替换本地保存的数据，因此希望保存原来数据就必须先将原来的数据赋给相应的属性。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateBindedGateways:(NSArray<GatewayModel *> *)gateways;

/**
 *@abstract 查询本地保存的已绑定网关列表。
 *@return 已绑定网关列表，can be nil.
 */
- (nullable NSArray<GatewayModel *> *)queryBindedGateways;

#pragma mark - 网关锁相关
/**
 *@abstract 更新网关锁列表，内部实现使用事务(transaction)。使用锁相关的接口时，必须先保存锁。
 *@param locks 需要更新的网关锁。此方法只负责更新锁，并不会删除锁。
 *@note 如果本地没有记录，会插入新数据；如果有记录，会将新数据整个替换原有数据。希望保存原来数据就必须先将原来的数据赋给相应的属性。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateGWLocks:(NSArray<GatewayDeviceModel *> *)locks;

/**
 *@abstract 查询本地保存的网关锁。
 *@param gwSn 网关sn，如果此参数不为空，则只返回指定网关下的锁，否则返回全部锁。
 *@return 本地保存的网关锁，can be nil.
 */
- (nullable NSArray<GatewayDeviceModel *> *)queryGWLocksWithSN:(nullable NSString *)gwSn;

/**
 *@abstract 删除数据库中保存的网关锁。
 *@param locks 如果不为空，删除指定的锁且忽略gwSn参数。
 *@param gwSn 网关sn，删除指定网关下绑定的锁。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)deleteGWLocks:(nullable NSArray<GatewayDeviceModel *> *)locks sn:(nullable NSString *)gwSn;

/**
 *@abstract 更新已绑定的网关锁开锁密码。
 *@param pwd 开锁密码。如果此值为nil，则会删除数据库中保存的数据，且开锁错误次数会加1；如果不为nil，开锁错误次数会设置为0.
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUnlockPwd:(nullable NSString *)pwd withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 查询最近一次保存的网关锁开锁密码。
 *@param lock 网关锁模型。
 *@return 最近一次保存的对应网关锁的开锁密码，如果没有则返回空。
 */
- (nullable NSString *)queryUnlockPwdWithLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 更新已绑定的设备的开锁次数。
 *@param times 开锁次数。如果此参数为负数，则直接返回失败。
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUnlockTimes:(int)times withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 查询已绑定设备的开锁次数。
 *@param lock 网关锁模型。
 *@return 最近一次保存的对应网关锁的开锁次数，如果没有记录则返回负数。
 */
- (int)queryUnlockTimesWithLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 更新已绑定的设备的密码开锁失败次数。开锁成功后会自动设置为0.
 *@param times 开锁次数。如果此参数为负数，则直接返回失败。
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePwdIncorrectTimes:(int)times withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 查询已绑定设备的密码开锁失败次数。如果失败10次，锁定app，提示失败次数过多，五分钟后再试
 *@param lock 网关锁模型。
 *@return 已绑定设备的密码开锁失败次数。
 */
- (int)queryPwdIncorrectTimesWithLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 更新已绑定的设备的密码开锁首次失败时间，使用服务器返回的时间，距70年的秒数。
 *@param seconds 失败的时间，距70年秒数。
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePwdIncorrectFirstTime:(double)seconds withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 查询已绑定设备的密码开锁首次失败时间。
 *@param lock 网关锁模型。
 *@return 最近一次保存的对应网关锁的密码开锁首次失败时间，距70年的秒数。
 */
- (double)queryPwdIncorrectFirstTimeWithLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 更新已绑定的设备的电量。这个方法一般和updatePowerTime:withLock:一起使用。
 *@param power 已绑定的设备的电量。
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePower:(double)power withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 查询已绑定设备的电量。
 *@param lock 网关锁模型。
 *@return 设备电量，如果没有记录，返回负数。
 */
- (int)queryPowerWithLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 更新已绑定的设备获取电量的时间。这个方法一般和updatePower:withLock:一起使用。
 *@param date 设备获取电量的时间。一般使用NSDate.date.
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePowerTime:(NSDate *)date withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 查询已绑定设备的电量更新时间。
 *@param lock 网关锁模型。
 *@return 设备电量，如果没有记录，返回负数。
 */
- (nullable NSDate *)queryPowerTimeWithLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 更新已绑定的网关锁同步锁时间成功时的时间。使用服务器时间。
 *@param date 同步网关锁时间成功时的时间。一般使用[NSDate dateWithTimeIntervalSince1970:<服务器时间>].
 *@param lock 网关锁模型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateSyncTime:(NSDate *)date withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 获取已绑定的网关锁同步锁时间成功时的时间。
 *@param lock 网关锁模型。
 *@return 网关锁同步锁时间成功时的时间，如果没有记录，返回nil。
 */
- (nullable NSDate *)querySyncTimeWithLock:(GatewayDeviceModel *)lock;

#pragma mark - 开锁、报警记录表接口。KDSGWRecord
/**
 *@abstract 将记录数据保存到数据库。测试时插入1000个左右开锁记录耗时不足0.2秒。
 *@param records 要插入的记录。请确保此数组内容为KDSAlarmModel或KDSGWUnlockRecord类型。
 *@param device 记录产生的网关锁或猫眼。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertRecords:(NSArray *)records inDevice:(GatewayDeviceModel *)device;

/**
 *@abstract 查询数据库中保存的记录数据。测试时查询1000个左右开锁记录耗时不足50毫秒。
 *@param device 记录产生的网关锁或猫眼，如果此参数不为空，type只能取1、2或3、4，否则一定返回空。
 *@param type 记录类型，1网关开锁记录，2网关报警记录，3猫眼开锁记录(有的话)，4猫眼报警记录，5全部开锁记录，6全部报警记录，99所有。
 *@return 开锁(KDSAlarmModel类型数组)或报警(KDSGWUnlockRecord类型数组)记录。
 */
- (nullable NSArray *)queryRecordsInDevice:(nullable GatewayDeviceModel *)device type:(int)type;

/**
 *@abstract 删除数据库中保存的记录数据。
 *@param device 记录产生的网关锁或猫眼，如果此参数不为空，type只能取1、2或3、4，否则一定返回NO。
 *@param type 记录类型，1网关开锁记录，2网关报警记录，3猫眼开锁记录(有的话)，4猫眼报警记录，5全部开锁记录，6全部报警记录，99所有。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)deleteRecordsInDevice:(nullable GatewayDeviceModel *)device type:(int)type;

#pragma mark - 密码表接口。KDSGWLockPwd
/**
 *@abstract 插入(去重)密码模型，如果密码类型+密码编号和已有的数据相同，那么会覆盖已有数据。
 *@param models 密码模型列表。
 *@param lock 密码所属的网关锁。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertPasswords:(NSArray<KDSPwdListModel *> *)models withLock:(GatewayDeviceModel *)lock;

/**
 *@abstract 获取密码模型。
 *@param lock 要获取密码的网关锁。
 *@param type 要查询的记录类型，1密码，2临时密码，3指纹，4卡片，99所有。
 *@return 密码属性数组，nil没有记录。
 */
- (nullable NSArray<KDSPwdListModel *> *)queryPasswordsWithLock:(GatewayDeviceModel *)lock type:(int)type;

/**
 *@abstract 删除数据库中的对应锁的密码模型。
 *@param models 要删除的密码数组模型，如果此参数为空，那么会删除对应锁下的所有数据。
 *@param lock 密码所属的网关锁。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)deletePasswords:(nullable NSArray<KDSPwdListModel *> *)models withLock:(GatewayDeviceModel *)lock;

@end

NS_ASSUME_NONNULL_END

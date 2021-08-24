//
//  KDSDBManager.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/24.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "KDSUser.h"
#import "KDSAuthException.h"
#import "KDSFAQ.h"
#import "KDSSysMessage.h"
#import "KDSAuthMember.h"
#import "KDSUnlockAttr.h"
#import "KDSPwdListModel.h"
#import "CateyeModel.h"
#import "KDSGWCateyeParam.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 数据库类，请先设置setDefaultLoginAccount。
 */
@interface KDSDBManager : NSObject

///首次使用时请确保[KDSTool getDefaultLoginAccount]返回不为空。
+ (instancetype)sharedManager;

///fmdb queue，如果[KDSTool getDefaultLoginAccount]返回空，此值也会返回空。
@property (nonatomic, strong, readonly, nullable) FMDatabaseQueue *dbQueue;

///登录不同的账号成功后调用此方法重置数据库，否则使用的是上一个账号的数据库。
- (void)resetDatabase;

#pragma mark - 用户表接口KDSUser
/**
 *@abstract 更新用户表的KDSUser类包含的5个属性。
 *@param user 新的用户属性。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUser:(KDSUser *)user;

/**
 *@abstract 查询本地用户表保存的KDSUser。
 *@return user，can be nil.
 */
- (nullable KDSUser *)queryUser;

/**
 *@abstract 更新用户表的用户昵称。
 *@param nickname 新的用户昵称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserNickname:(nullable NSString *)nickname;

/**
 *@abstract 查询本地用户表保存的用户昵称。
 *@return user nickname，can be nil.
 */
- (nullable NSString *)queryUserNickname;

/**
 *@abstract 更新用户表的用户头像数据。
 *@param data 新的用户头像数据。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserAvatarData:(nullable NSData *)data;

/**
 *@abstract 查询本地用户表保存的用户头像数据。
 *@return user avatar data，can be nil.
 */
- (nullable NSData *)queryUserAvatarData;

/**
 *@abstract 更新用户表的手势密码状态。
 *@param state 手势密码状态，YES开启，NO关闭。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserGesturePwdState:(BOOL)state;

/**
 *@abstract 查询用户表的手势密码状态。
 *@return 手势密码状态，YES开启，NO关闭。
 */
- (BOOL)queryUserGesturePwdState;

/**
 *@abstract 更新用户表的手势密码。
 *@param pwd 手势密码。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserGesturePwd:(nullable NSString *)pwd;

/**
 *@abstract 查询用户表的手势密码。
 *@return 手势密码，如果没有则返回nil。
 */
- (nullable NSString *)queryUserGesturePwd;

/**
 *@abstract 更新用户表的touch id状态。
 *@param state touch id状态，YES开启，NO关闭。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserTouchIDState:(BOOL)state;

/**
 *@abstract 查询用户表的手势密码状态。
 *@return touch id状态，YES开启，NO关闭。
 */
- (BOOL)queryUserTouchIDState;

/**
 *@abstract 更新用户表的touch id、手势密码最新的验证时间。
 *@param date 最新验证时间。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserAuthDate:(NSDate *)date;

/**
 *@abstract 查询用户表的touch id、手势密码最新的验证时间。
 *@return 如果有记录，返回记录的日期，否则返回nil。
 */
- (nullable NSDate *)queryUserAuthDate;

/**
 *@abstract 更新用户表的touch id、手势密码的验证状态(即是否需要进入验证页面)。为防止一直修改手机时间跳过验证的问题，当首次查询
 *验证日期距当前日期超过一定时间时，调用此方法设置验证状态为真，下一次跳过日期比较。
 *@param needAuthentication 验证状态。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateAuthenticationState:(BOOL)needAuthentication;

/**
 *@abstract 查询用户表的touch id、手势密码的验证状态(即是否需要进入验证页面)。
 *@return 返回记录的验证状态。如果返回YES，则跳过日期比较。
 */
- (BOOL)queryAuthenticationState;

/**
 *@abstract 更新用户表的touch id、手势密码验证剩余次数，密码登录成功后会重置次数。
 *@param times 剩余次数。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserAuthTimes:(int)times;

/**
 *@abstract 查询用户表的touch id、手势密码剩余验证次数。
 *@return 手势密码剩余验证次数
 */
- (int)queryUserAuthTimes;

/**
 *@abstract 更新用户表的授权开锁成员。此更新操作为直接替换数据，请注意使用。
 *@param members 新的成员，如果为空，则会删除数据库中的数据。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUserAuthMembers:(nullable NSArray<KDSAuthMember *> *)members;

/**
 *@abstract 查询用户表的授权开锁成员。
 *@return 如果有记录，返回记录成员，否则返回nil。
 */
- (nullable NSArray<KDSAuthMember *> *)queryUserAuthMembers;

#pragma mark - 蓝牙属性表接口KDSBleAttr
///FIXME:如果新的设备列表不包含数据库中已有的设备列表的其中的设备，则会删除同一蓝牙名称的其它表的内容，因此请新增表时更新该方法实现。
/**
 *@abstract 更新已绑定的设备列表，内部实现使用事务(transaction)。一般从服务器请求回来或者删除设备时需要调用此方法。
 *@param devices 最新的已绑定的设备列表。如果新设备列表不包含已保存列表其中的设备，会将已保存的设备删除。
 *@note 如果新的设备列表不包含数据库中已有的设备列表的其中的设备，则会删除同一蓝牙名称的其它表的内容，因此请新增表时更新该方法实现。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateBindedDevices:(NSArray<MyDevice *> *)devices;
/**
 *@abstract 更新已绑定的设备列表，内部实现使用事务(transaction)。一般从服务器请求回来或者删除设备时需要调用此方法。
 *@param wifiModels 最新的已绑定的wifi设备列表。如果新设备列表不包含已保存列表其中的设备，会将已保存的设备删除。
 *@return 参考FMDatabase类的executeUpdate方法。
*/
- (BOOL)updateBindedWifiModels:(NSArray<KDSWifiLockModel *> *)wifiModels;

/**
 *@abstract 查询本地已绑定设备列表。
 *@return 已绑定设备列表，can be nil.
 */
- (nullable NSArray<MyDevice *> *)queryBindedDevices;
/**
 *@abstract 查询本地已绑定设备列表。
 *@return 已绑定设备列表，can be nil.
*/
- (nullable NSArray<KDSWifiLockModel *> *)queryBindedWifiModels;

/**
 *@abstract 更新已绑定的设备蓝牙上传开锁、报警记录的数据(请传递协议返回的20字节数据转换成的长度40的16进制字符串)。
 *@param data 最新的上传记录数据，请传递协议返回的20字节数据转换成的长度40的16进制字符串。
 *@param name 蓝牙名称。
 *@param type 记录类型，0开锁记录，1报警记录，2操作记录。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUploadRecordData:(NSString *)data withBleName:(NSString *)name type:(int)type;

/**
 *@abstract 查询最近一次上传的已绑定的设备蓝牙开锁、报警记录的数据。
 *@param name 蓝牙名称。
 *@param type 记录类型，0开锁记录，1报警记录，2操作记录。
 *@return 最近一次上传记录的数据(按标准长度是40字节)，如果没有记录或记录不是40个字节返回40个'0'组成的字符串。
 */
- (NSString *)queryUploadRecordDataWithBleName:(NSString *)name type:(int)type;

/**
 *@abstract 更新已绑定的设备蓝牙开锁密码。
 *@param pwd 开锁密码。如果此值为nil，则会删除数据库中保存的数据，且开锁错误次数会加1；如果不为nil，开锁错误次数会设置为0.
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUnlockPwd:(nullable NSString *)pwd withBleName:(NSString *)name;

/**
 *@abstract 查询最近一次保存的蓝牙开锁密码。
 *@param name 蓝牙名称。
 *@return 最近一次保存的对应蓝牙的开锁密码，如果没有则返回空。
 */
- (nullable NSString *)queryUnlockPwdWithBleName:(NSString *)name;

/**
 *@abstract 更新已绑定的设备的开锁次数。
 *@param times 开锁次数。如果此参数为负数，则直接返回失败。
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updateUnlockTimes:(int)times withBleName:(NSString *)name;

/**
 *@abstract 查询已绑定设备的开锁次数。
 *@param name 蓝牙名称。
 *@return 最近一次保存的对应蓝牙的开锁次数，如果没有记录则返回负数。
 */
- (int)queryUnlockTimesWithBleName:(NSString *)name;

/**
 *@abstract 更新已绑定的设备的密码开锁失败次数。开锁成功后会自动设置为0.
 *@param times 开锁次数。如果此参数为负数，则直接返回失败。
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePwdIncorrectTimes:(int)times withBleName:(NSString *)name;

/**
 *@abstract 查询已绑定设备的密码开锁失败次数。
 *@param name 蓝牙名称。
 *@return 已绑定设备的密码开锁失败次数。
 */
- (int)queryPwdIncorrectTimesWithBleName:(NSString *)name;

/**
 *@abstract 更新已绑定的设备的密码开锁首次失败时间，使用服务器返回的时间，距70年的秒数。
 *@param seconds 失败的时间，距70年秒数。
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePwdIncorrectFirstTime:(double)seconds withBleName:(NSString *)name;

/**
 *@abstract 查询已绑定设备的密码开锁首次失败时间。
 *@param name 蓝牙名称。
 *@return 最近一次保存的对应蓝牙的密码开锁首次失败时间，距70年的秒数。
 */
- (double)queryPwdIncorrectFirstTimeWithBleName:(NSString *)name;

/**
 *@abstract 更新已绑定的设备的电量。这个方法一般和updatePowerTime:withBleName:一起使用。
 *@param power 已绑定的设备的电量。
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePower:(double)power withBleName:(NSString *)name;

/**
 *@abstract 查询已绑定设备的电量。
 *@param name 蓝牙名称。
 *@return 设备电量，如果没有记录，返回负数。
 */
- (int)queryPowerWithBleName:(NSString *)name;

/**
 *@abstract 更新已绑定的设备获取电量的时间。这个方法一般和updatePower:withBleName:一起使用。
 *@param date 设备获取电量的时间。一般使用NSDate.date.
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)updatePowerTime:(NSDate *)date withBleName:(NSString *)name;

/**
 *@abstract 查询已绑定设备的电量更新时间。
 *@param name 蓝牙名称。
 *@return 设备电量更新时间，如果没有记录，返回空。
 */
- (nullable NSDate *)queryPowerTimeWithBleName:(NSString *)name;


#pragma mark - 开锁类型属性表接口KDSUnlockAttr
/**
 *@abstract 插入(去重)蓝牙开锁类型的属性，这个属性一般是用于同步开锁记录显示的，同步完成上传服务器后必须已服务器返回的昵称为准。
 *@param attrs 密码属性列表，属性除昵称外其它字段是必填字段，否则插入记录会不正确。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertUnlockAttr:(NSArray<KDSUnlockAttr *> *)attrs;

/**
 *@abstract 获取蓝牙开锁类型的属性，这个昵称一般是用于同步开锁记录过程中显示的，同步完成上传服务器后必须已服务器返回的昵称为准。
 *@param name 蓝牙名称。
 *@return 密码属性数组，nil没有记录。
 */
- (nullable NSArray<KDSUnlockAttr *> *)queryUnlockAttrWithBleName:(NSString *)name;

#pragma mark - 密码属性表接口KDSPasswordAttr
/**
 *@abstract 插入(去重)密码模型，如果密码类型+密码编号和已有的数据相同，那么会覆盖已有数据。
 *@param models 密码模型列表。
 *@param name 密码所属的锁的蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertPwdAttrs:(NSArray<KDSPwdListModel *> *)models bleName:(NSString *)name;

/**
 *@abstract 获取密码模型。
 *@param name 蓝牙名称。
 *@param type 要查询的记录类型，1密码，2临时密码，3指纹，4卡片，99所有。
 *@return 密码属性数组，nil没有记录。
 */
- (nullable NSArray<KDSPwdListModel *> *)queryPwdAttrWithBleName:(NSString *)name type:(int)type;

/**
 *@abstract 删除数据库中的对应蓝牙名称的密码模型。
 *@param models 要删除的密码模型数组，如果此参数为空，那么会删除对应蓝牙下的所有数据。删除多个时如果失败，会回滚。
 *@param name 密码所属的锁的蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)deletePwdAttrs:(nullable NSArray<KDSPwdListModel *> *)models bleName:(NSString *)name;

#pragma mark - 开锁、报警、操作记录表接口KDSRecord
/**
 *@abstract 将记录数据保存到数据库。测试时插入1000个左右开锁记录耗时不足0.2秒。
 *@param records 要插入的记录。请确保此数组内容为KDSBleAlarmRecord、KDSBleOpRec或KDSBleUnlockRecord类型。
 *@param type 记录类型，0未上传的开锁记录，1未上传的报警记录，4未上传的操作记录，上传失败时保存使用；2开锁记录，3报警记录，5操作记录，展示离线记录用。
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertRecord:(NSArray *)records type:(int)type bleName:(NSString *)name;

/**
 *@abstract 查询数据库中保存的记录数据。测试时查询1000个左右开锁记录耗时不足50毫秒。
 *@param type 0查询未上传的开锁记录数据，1查询未上传的报警记录数据，2查询开锁记录，3查询报警记录，4查询未上传的操作记录(扩展用)，5查询保存的操作记录。
 *@param name 蓝牙名称。
 *@return 开锁(KDSBleUnlockRecord类型数组)或报警(KDSBleAlarmRecord类型数组)或操作(KDSBleOpRec类型数组)记录。
 */
- (nullable NSArray *)queryRecord:(int)type bleName:(NSString *)name;

/**
 *@abstract 删除数据库中保存的和蓝牙名对应的记录数据。测试时删除1000个左右开锁记录耗时不足50毫秒。
 *@param type 99删除蓝牙名=name的所有记录，其它请参考insertRecord:type:bleName:方法。
 *@param name 蓝牙名称。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)deleteRecord:(int)type bleName:(NSString *)name;

#pragma mark - 鉴权异常记录表KDSAuthException接口
/**
 *@abstract 插入异常的鉴权记录。
 *@param exceptions 要插入的异常鉴权记录数组。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertAuthExceptions:(NSArray<KDSAuthException *> *)exceptions;

/**
 *@abstract 查询异常的鉴权记录。
 *@param bleName 发生异常鉴权记录的锁的蓝牙名称。如果该参数为空，则返回全部的异常记录。
 *@return 鉴权异常记录，可能为空。
 */
- (nullable NSArray<KDSAuthException *> *)queryAuthExceptions:(nullable NSString *)bleName;

#pragma mark - 常见问题和系统消息表接口KDSFAQAndMessage
/**
 *@abstract 将FAQ和系统消息保存到数据库。
 *@note 这个操作会替换判断(_id)为相等的数据，而不会管有没有被标记为删除，请注意使用。
 *@param faqmsgs 要插入的记录。请确保此数组内容为KDSFAQ或KDSSysMessage类型。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertFAQOrMessage:(NSArray *)faqmsgs;

/**
 *@abstract 查询数据库中保存的记录数据。
 *@param type 1查询FAQ，2查询系统消息，3查询本地标记为已删除的FAQ(保留使用)，4查询本地标记为已删除的系统消息，99查询所有记录。
 *@return FAQ(KDSFAQ类型数组)或系统消息(KDSSysMessage类型数组)记录。
 */
- (nullable NSArray *)queryFAQOrMessage:(int)type;

/**
 *@abstract 删除数据库中保存的FAQ或者系统消息记录数据。
 *@param fom 如果不为空，必须为KDSFAQ或KDSSysMessage类型，如果不为空删除单条记录，忽略type参数，如果为空参考type说明。
 *@param type 1删除FAQ记录数据，2删除系统消息记录数据，99删除全部记录。忽略被删除标记。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)deleteFAQOrMessage:(nullable NSObject*)fom type:(int)type;



#pragma mark - 其它方法。
///清理缓存，同步阻塞操作。如果有需要清理的缓存，请在此方法内新增数据库删除操作。
- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END

//
//  KDSTool.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSTool : NSObject

///在NSUserDefaults中设置/获取电话国际区号，不包含最前面的+号。
@property (nonatomic, strong, class, nullable) NSString *crc;
///app版本。
@property (nonatomic, strong, readonly, class) NSString *appVersion;

/**
 *@abstract 设置界面语言。新增语言时，需要更新内部实现。如果设置的语言和上一次的不一样且不为空，会发送一个本地语言改变的通知。
 *@param language 语言代码，如果空，已有设置使用已有设置，未有设置使用系统的设置。否则请确保参数为正确的语言代码。
 */
+ (void)setLanguage:(nullable NSString *)language;

/**
 *@abstract 获取当前界面的本地化设置语言。
 *@return 如果没有设置过，返回nil，其它返回已设置的语言。
 */
+ (nullable NSString *)getLanguage;
/**
 *@abstract 保存代理返回的通知token到NSUserDefaults中。
 *@param deviceToken 通知token的16进制字符串。
 */
+ (void)saveDeviceToken:(NSString *)deviceToken;

/**
 *@abstract 获取保存在NSUserDefaults中的通知token的16进制字符串。
 *@return 通知token的16进制字符串，可能为空。
 */
+ (nullable NSString *)getDeviceToken;

/**
 *@abstract 获取保存在NSUserDefaults中的PKPushCredentials token的16进制字符串。
 *@return PKPushCredentials token的16进制字符串，可能为空。
 */
+ (nullable NSString *)getVoIPDeviceToken;
/**
 *@abstract 保存代理返回的PKPushCredentials token到NSUserDefaults中。
 *@param deviceToken PKPushCredentials token的16进制字符串。
 */
+ (void)saveVoIPDeviceToken:(nonnull NSString *)deviceToken;

/**获取设备类型*/
+ (NSString*)getIphoneType;

/**判断是否是邮箱*/
+ (BOOL)isValidateEmail:(NSString *)email;

/**判断是否是手机号(以1开头的11位数字)*/
+ (BOOL)isValidatePhoneNumber:(NSString *)phone;

/**
 *@abstract 判断字符串是否是有效的密码。有效的密码必须包含数字+字母，且长度在6-16位之间。
 *@param text 要判断的字符串。
 *@return 判断结果。
 */
+ (BOOL)isValidPassword:(NSString *)text;

/**
 *@abstract 当登录/退出成功后，调用此方法设置当前登录的用户账号。免登录以及获取数据库数据时使用。
 *@param account 用户账号，如果为nil，会清除当前记录的信息。
 */
+ (void)setDefaultLoginAccount:(nullable NSString *)account;
/**
 *@abstract 当登录/退出成功后，调用此方法设置当前登录的用户账号。免登录以及获取数据库数据时使用。
 *@param passWord 用户密码。
 */
+ (void)setDefaultLoginPassWord:(nullable NSString *)passWord;
/**
 *@abstract 调用此方法获取当前登录的用户账号。免登录以及获取数据库数据时使用。
 *@return 用户账号，如果为nil，则当前没有记录的信息。
 */
+ (nullable NSString *)getDefaultLoginAccount;
/**
 *@abstract 调用此方法获取当前登录的用户账号密码。免登录以及获取数据库数据时使用。
 *@return 用户账号密码，如果为nil，则当前没有记录的信息。
 */
+ (nullable NSString *)getDefaultLoginPassWord;

/**
 *@abstract 设置是否开启锁报警通知。在允许通知消息的情况下，默认开启。该属性只关联APP内页面展示的报警UI，不关联系统本地通知。
 *@param on YES开启，NO关闭。
 *@param deviceId 对于蓝牙锁来说是蓝牙名称，对于网关锁来说是锁的deviceId。
 */
+ (void)setNotificationOn:(BOOL)on forDevice:(NSString *)deviceId;

/**
 *@abstract 获取是否开启锁报警通知。在允许通知消息的情况下，默认开启。该属性只关联APP内页面展示的报警UI，不关联系统本地通知。
 *@param deviceId 对于蓝牙锁来说是蓝牙名称，对于网关锁来说是锁的deviceId。
 *@return YES开启，NO关闭。默认是开启的。
 */
+ (BOOL)getNotificationOnForDevice:(NSString *)deviceId;


/**
 获取通过UTF8转码后的Data

 @param string 需要转码的字符串
 @return 转码的Data
 */
+(NSData *)getTranscodingStringDataWithString:(NSString *)string;

/**
 *@brief 从原字符串截取至限制长度(16字节)后的字符串。utf8编码。
 *@param string 原字符串。
 *@return 截取至限制长度后的字符串。
 */
+ (NSString *)limitedLengthStringWithString:(NSString *)string;

/**
 去掉字符串中特殊字符
 */
+ (NSString *)deleteSpecialCharacters:(NSString *)currentStr;

/**
 *@brief 判断锁中设置的数字密码是否是简单密码，纯数字、长度6~12。不能顺序、倒叙、相同。
 *@param password 用户输入的密码。
 *@return 判断结果。
 */
+ (BOOL)isSimplePasswordInLock:(NSString *)password;

/**
 *@brief 获取当前时间的时间戳，距70年间隔的浮点型值字符串。
 *@return 得到时间戳字符串。
 */
+(NSString *)getNowTimeTimestamp;

/**
 *@brief 时间戳—>字符串时间:yyyy-MM-dd HH:mm:ss。
 *@param timestamp 输入原始字符串。
 *@return 得到转换后的字符串：yyyy-MM-dd HH:mm:ss。
 */
+ (NSString *)timeStringFromTimestamp:(NSString *)timestamp;

/**
 *@brief 时间戳—>字符串时间:yyyy-MM-dd。
 *@param timestamp 输入原始字符串。
 *@return 得到转换后的字符串：yyyy-MM-dd。
 */
+ (NSString *)timeStringYYMMDDFromTimestamp:(NSString *)timestamp;

/**
 *@brief 时间戳—>字符串时间。
 *@param format 输入原始字符串。
 *@return 得到转换后的字符串：utc。
 */
+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format;

/**
 *@brief 判断wifi/密码输入字符是否符合规则。
 *@param value 输入原始字符串。
 *@return 判断结果。
 */
+(BOOL)isValidateWiFi:(NSString *)value;
/**
 *@brief 判断IP是否合法有效。
 *@param value 输入原始字符串。
 *@return 判断结果。
 */
+(BOOL)isValidateIP:(NSString *)value;
/**
 *@brief 判断是否是数字    。
 *@param strValue 输入原始字符串。
 *@return 判断结果。
 */
+(BOOL)isNumber:(NSString *)strValue;
///世界标准时间UTC /GMT 转为当前系统时区对应的时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;
////时间戳转date
+ (NSDate *)getDateTimeFromMilliSeconds:(long long) miliSeconds;
///时间戳转化为时间 顺带解决NSDate的8小时问题
+ (NSString *)getTimeToShowWithTimestamp:(NSString *)timestamp;
/// ---- 将时间戳转换成时间
+ (NSString *)getTimeFromTimestamp:(long long)time;
/*
 * 判断是否打开定位
 */
+ (BOOL)determineWhetherTheAPPOpensTheLocation;
/*
 *跳转到系统设置页面
 */
+(void)openSettingsURLString;
+(UIViewController*)currentViewController;
///语言设置改变的通知名字。当更改字符串常量时，请同步修改MJRefreshComponent.m中的通知名字。
FOUNDATION_EXTERN NSString * const KDSLocaleLanguageDidChangeNotification;
///判断是否为全面屏
+(BOOL)isNotchScreen;

+(NSString *)timestampSwitchUTCTime:(NSInteger)timestamp andFormatter:(NSString *)format;

+(NSDate *)getTimeAfterNowWithDay:(NSInteger)day isAfter:(BOOL)isAfter;

+(int)mixmkvWithfileName:(const char *)in_filename in_filename2:(const char *)in_filename2 out_filename:(const char *)out_filename framerate:(int)framerate samplerate:(int)samplerate;

/**
 * 获取ssid保存过的密码
 */
+(NSString *) getPwdWithSSID:(NSString *) ssid;
/**
 * 保存ssid与密码
 */
+(void) saveSSID:(NSString *) ssid pwd:(NSString *) pwd;
@end

NS_ASSUME_NONNULL_END

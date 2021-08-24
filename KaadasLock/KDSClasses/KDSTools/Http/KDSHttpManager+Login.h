//
//  KDSHttpManager+Login.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/22.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All  rights reserved.
//
#import "KDSHttpManager.h"
#import "KDSUser.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *@abstract 登录http请求的错误类型。
 */

typedef NS_ENUM(NSUInteger, KDSHttpLoginError) {
    ///参数错误。
    KDSHttpLoginErrorParamError = 401,
    ///服务器请求处理超时。
    KDSHttpLoginErrorServerTimeout = 509,
    ///发送次数过多(验证码)。
    KDSHttpLoginErrorFrequently = 704,
    ///用户已注册。
    KDSHttpLoginErrorHaveBeenSignup = 405,
    ///验证码错误。
    KDSHttpLoginErrorCaptchaError = 445,
    ///用户名不存在。
    KDSHttpLoginErrorNotExist = 408,
    ///旧密码不正确。
    KDSHttpLoginErrorPwdIncorrect = 208,
    ///用户名或密码错误。
    KDSHttpLoginErrorNameOrPwdIncorrect = 101,
};

@interface KDSHttpManager (Login)

/**
 *@abstract 通过邮箱获取验证码。
 *@param email 邮箱。
 *@param success 服务器返回成功的回调，服务器返回成功时data字段为空，因此此回调不带参数，
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。704获取太频繁。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getCaptchaWithEmail:(NSString *)email success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 通过手机号获取验证码。
 *@param tel 手机号。
 *@param crc country or region code，国家或地区码，不带+前缀。
 *@param success 服务器返回成功的回调，服务器返回成功时data字段为空，因此此回调不带参数，
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。704获取太频繁。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getCaptchaWithTel:(NSString *)tel crc:(NSString *)crc success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 注册。
 *@param source 注册源，手机(1)，邮箱(2)。
 *@param name 注册的账号。如果是手机号注册，手机号前必须加上国家/地区码，如8613500010086.
 *@param captcha 验证码。
 *@param pwd 密码，长度6-16，必须包含数字+字母。
 *@param success 服务器返回成功的回调。
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)signup:(int)source username:(NSString *)name captcha:(NSString *)captcha password:(NSString *)pwd success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 忘记密码后重新设置密码。
 *@param source 注册源，手机(1)，邮箱(2)。
 *@param name 注册的账号。如果是手机号注册，手机号前必须加上国家/地区码，如8613500010086.
 *@param captcha 验证码。
 *@param pwd 新设的密码，长度6-16，必须包含数字+字母。
 *@param success 服务器返回成功的回调。
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)forgotPwd:(int)source name:(NSString *)name captcha:(NSString *)captcha newPwd:(NSString *)pwd success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改密码。
 *@param name 注册的账号。如果是手机号注册，手机号前必须加上国家/地区码，如8613500010086.
 *@param oldPwd 旧的密码。
 *@param newPwd 新设的密码，长度6-16，必须包含数字+字母，不能和旧密码一样。
 *@param success 服务器返回成功的回调。
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updatePwd:(NSString *)name oldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 登录接口。
 *@param source 登录源，手机(1)，邮箱(2)。
 *@param name 登录用户名。如果是手机号注册，手机号前必须加上国家/地区码，如8613500010086.
 *@param pwd 登录密码。
 *@param success 成功回调。
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)login:(int)source username:(NSString *)name password:(NSString *)pwd success:(nullable void(^)(KDSUser *user))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 退出登录接口。当前服务器的接口并不要求传递参数，接口这些参数先留着。
 *@param source 登录源，手机(1)，邮箱(2)。
 *@param name 登录用户名。如果是手机号注册，手机号前必须加上国家/地区码，如8613500010086.
 *@param uid 登录时服务器返回的uid。
 *@param success 成功回调。
 *@param errorBlock 服务器返回错误时的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)logout:(int)source username:(NSString *)name uid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

@end
NS_ASSUME_NONNULL_END

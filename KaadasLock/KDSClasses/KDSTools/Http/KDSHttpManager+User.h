//
//  KDSHttpManager+User.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/22.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSHttpManager.h"
#import "KDSUserAgreement.h"
#import "KDSAuthMember.h"
#import "KDSFAQ.h"
#import "KDSSysMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSHttpManager (User)

/**
 *@abstract 获取用户昵称。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调，nickname：服务器返回的用户昵称，可能为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getUserNicknameWithUid:(NSString *)uid success:(nullable void(^)(NSString * __nullable nickname))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改用户昵称。
 *@param nickname 新的昵称。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setUserNickname:(NSString *)nickname withUid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取用户头像照片。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调，image：服务器返回的用户头像，可能为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getUserAvatarImageWithUid:(NSString *)uid success:(nullable void(^)(UIImage * __nullable image))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 上传用户头像照片。
 *@param image 要上传的照片。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setUserAvatarImage:(UIImage *)image withUid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取系统消息。
 *@param uid 服务器返回的uid。
 *@param page 页数，从1开始。
 *@param success 请求成功执行的回调，messages：服务器返回的消息数组，可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getSystemMessageWithUid:(NSString *)uid page:(int)page success:(nullable void(^)(NSArray<KDSSysMessage *> * messages))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取系统消息。
 *@param msg 消息模型，_id属性值不能为空。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调，messages：服务器返回的消息数组，可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)deleteSystemMessage:(KDSSysMessage *)msg withUid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 上传用户反馈。
 *@param content 用户反馈的内容，长度8~300。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)feedback:(NSString *)content withUid:(NSString *)uid success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取用户协议版本。
 *@param success 请求成功执行的回调，agreement包含协议id、名称、版本号和标签。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getUserAgreementVersion:(nullable void(^)(KDSUserAgreement *agreement))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 根据协议版本id获取用户协议内容。
 *@param agreement 包含协议id和名称的协议模型。@see getUserAgreementVersion:error:failure:
 *@param success 请求成功执行的回调，agreement包含协议id、名称、版本号和标签。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getUserAgreementContentWithAgreement:(KDSUserAgreement *)agreement success:(nullable void(^)(KDSUserAgreement *agreement))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取被授权开锁的用户列表。
 *@param uid 服务器返回的uid。
 *@param name 蓝牙名称。
 *@param success 请求成功执行的回调，members：服务器返回的被授权用户，可能为空。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getAuthorizedUsersWithUid:(NSString *)uid bleName:(NSString *)name success:(nullable void(^)(NSArray<KDSAuthMember *> * __nullable members))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 添加开锁的被授权用户。
 *@param member 授权成员模型，必须设置被授权账号、权限和起始时间。
 *@param uid 服务器返回的uid。
 *@param device 蓝牙对应的设备模型。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。401被授权账号不存在，409该账号已添加，433锁被重置且当前账号不是管理员。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)addAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid device:(MyDevice *)device success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 修改锁的被授权用户的昵称。
 *@param member 被授权账号，unickname必须包含新的昵称。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)updateAuthorizedUserNickname:(KDSAuthMember *)member success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 设置(修改)开锁的被授权用户的信息和权限。
 *@param member 授权成员模型，必须设置被授权账号、权限和起始时间。
 *@param uid 服务器返回的uid。
 *@param device 蓝牙对应的设备模型。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid device:(MyDevice *)device success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 删除已被授权的用户。
 *@param member 授权成员模型，必须设置被授权账号。
 *@param uid 服务器返回的uid。
 *@param device 蓝牙对应的设备模型。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)deleteAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid device:(MyDevice *)device success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取FAQ。
 *@param language 语言类型。1简体中文， 2繁体中文， 3英文， 4泰语。
 *@param success 请求成功执行的回调，faqs：服务器返回的faq，可能为空数组。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getFAQ:(int)language success:(nullable void(^)(NSArray<KDSFAQ *> * faqs))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 上传pushToken和notiToken。
 *@param pushToken PushKit返回的token十六进制字符串。
 *@param notiToken 推送通知返回的token十六进制字符串。
 *@param uid 服务器返回的uid。
 *@param mobileInfo 手机信息（型号，系统版本号）
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)uploadPushToken:(NSString *)pushToken remoteNotificationToken:(NSString *)notiToken withUid:(NSString *)uid mobileInfo:(NSDictionary *)mobileInfo success:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 获取网关锁开锁推送功能开关。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调，open返回开关是否开启。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)getUserGWLockUnlockNotificationWithUid:(NSString *)uid completion:(nullable void(^)(BOOL open))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

/**
 *@abstract 设置网关锁开锁推送功能开关。
 *@param open 开启或关闭。
 *@param uid 服务器返回的uid。
 *@param success 请求成功执行的回调，open返回开关是否开启。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (nullable NSURLSessionDataTask *)setUserGWLockUnlockNotification:(BOOL)open withUid:(NSString *)uid completion:(nullable void(^)(void))success error:(nullable void(^)(NSError *error))errorBlock failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

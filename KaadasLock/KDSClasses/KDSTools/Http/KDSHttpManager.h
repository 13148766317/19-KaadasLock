//
//  KDSHttpManager.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/21.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFNetworking.h"
#import "AFNetworking-umbrella.h"
#import "KDSHttpResOption.h"


///这里只定义一些未知错误。
typedef NS_ENUM(NSInteger, KDSHttpError) {
    ///服务器返回的值不正确，例如本应该返回字典却返回字符串等。
    KDSHttpErrorReturnValueIncorrect = 9999,
    ///调用方法时传入的参数错误，例如传入参数要求非空却传入一个空的值。
    KDSHttpErrorParamIncorrect = 9998,
};

NS_ASSUME_NONNULL_BEGIN

@interface KDSHttpManager : NSObject

+ (instancetype)sharedManager;

///请求和响应序列化都设置为JSON的AF请求类。
@property (nonatomic, strong, readonly) AFHTTPSessionManager *afManager;
///登录的token，由使用者赋值。
@property (nonatomic, strong, nullable) NSString *token;
///安全政策。
@property (nonatomic, strong, readonly) AFSecurityPolicy *customSecurityPolicy;
///服务器当前时间，距70年的本地时间秒数。
@property (nonatomic, assign, readonly) NSTimeInterval serverTime;
//自定义NSError
@property(nonatomic,strong)NSError *resError;
/**
 *@abstract 过滤掉原字典中的NSNull值。
 *@param dictionary 原字典。
 *@return 过滤掉原字典中的NSNull(删掉值为NSNull的key)值后返回的新的可变字典，如果传入的参数不是字典，会返回空字典。
 */
- (NSMutableDictionary *)filteredDictionaryWithDictionary:(NSDictionary *)dictionary;

/**
 Creates and runs an `NSURLSessionDataTask` with a `GET` request.
 
 @param URLString The URL string used to create the request URL.如果是全路径则不会改变，否则加上统一的前缀。
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully, 即服务器返回200. This block has no return value and one argument: responseObject是返回字典中的data字段的值。
 @param errorBlock 当服务器返回数据被正确解析后，返回字典的code字段不是200，则会执行这个回调，error的code是字典的code的值，domain直接放字典的msg信息。
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                               success:(nullable void (^)(id _Nullable responseObject))success
                                 error:(nullable void (^)(NSError *error))errorBlock
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 Creates and runs an `NSURLSessionDataTask` with a `POST` request.
 
 @param URLString The URL string used to create the request URL.如果是全路径则不会改变，否则加上统一的前缀。
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully, 即服务器返回200. This block has no return value and takes one argument: responseObject是返回字典中的data字段的值。
 @param errorBlock When received response from server, if code wasn't 200, there might be an error occurred. So, the userInfo of the block's error param may contain response data optionally. 
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:
 */
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                success:(nullable void (^)(id _Nullable responseObject))success
                                error:(nullable void (^)(NSError *error))errorBlock
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

#pragma mark - 通知相关
/** 登录后保存的token过期了，需要退出登录后重新登录。 */
FOUNDATION_EXTERN NSString * const KDSHttpTokenExpiredNotification;

@end

NS_ASSUME_NONNULL_END

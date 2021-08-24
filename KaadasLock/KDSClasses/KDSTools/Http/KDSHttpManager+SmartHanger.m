//
//  KDSHttpManager+SmartHanger.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager+SmartHanger.h"

@implementation KDSHttpManager (SmartHanger)

- (NSURLSessionDataTask *)bindSmartHangerDevice:(KDSSmartHangerModel *)device uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    params[@"wifiSN"] = device.wifiSN;
    params[@"uid"] = uid;

    return [self POST:@"wifi/hanger/bind" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)bindSmartHangerDeviceSN:(NSString  *)deviceSN uid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    params[@"wifiSN"] = deviceSN ? deviceSN : @"";
    params[@"uid"] = uid ? uid: @"";

    return [self POST:@"wifi/hanger/bind" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

/**
 *@abstract 解绑晾衣机设备。
 *@param hanger 晾衣机模型
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)unbindSmartHanger:(KDSDeviceHangerModel *)hanger success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"wifiSN"] = hanger.wifiSN ? : @"";
    params[@"uid"] = hanger.uid ? : @"";

    return [self POST:@"wifi/hanger/unbind" parameters:params success:^(id  _Nullable responseObject) {
        //更新
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

/**
 *@abstract 用户检查升级。
 *@param hanger 晾衣机模型
 *@param customer 客户。1为凯迪仕，15为小凯智能生活
 *@param success 请求成功执行的回调upgradeTask，需要保存给升级用。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)checkUpdateSmartHanger:(KDSDeviceHangerModel *)hanger customer:(NSUInteger) customer success:(void (^)(NSArray *upgradeTask))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"deviceName"] = hanger.wifiSN  ?  : @"";
    params[@"devtype"] = @"KdsMxchipHanger";
    params[@"customer"] = @(customer);
    params[@"versions"] = @[@{@"devNum":@(7),@"version":hanger.hangerVersion},@{@"devNum":@(6),@"version":hanger.moduleVersion}];

    return [self POST:@"ota/multiCheckUpgrade" parameters:params success:^(id  _Nullable responseObject) {
        
        
        !success ?: success((responseObject && responseObject
                            [@"upgradeTask"] ?  responseObject
                             [@"upgradeTask"] : nil));
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}
/**
 *@abstract 升级晾衣机。
 *@param hanger 晾衣机模型
 *@param upgradeTask 升级任务。
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)upgradeSmartHanger:(KDSDeviceHangerModel *)hanger upgradeTask:(NSArray *) upgradeTask success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"wifiSN"] = hanger.wifiSN  ?  : @"";
    params[@"devtype"] = @"KdsMxchipHanger";
    params[@"upgradeTask"] = upgradeTask;

    return [self POST:@"wifi/device/multiOta" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}
/**
 *@abstract 修改晾衣机昵称
 *@param hanger 晾衣机模型
 *@param nickName 新昵称
 *@param success 请求成功执行的回调。
 *@param errorBlock 出错执行的回调，参数error的code是服务器返回的code，domain是服务器返回的msg。
 *@param failure 由于数据解析及网络等原因失败的回调，error是系统传递过来的。
 *@return 当前的请求任务。
 */
- (NSURLSessionDataTask *)updateSmartHanger:(KDSDeviceHangerModel *)hanger nickName:(NSString *) nickName success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"wifiSN"] = hanger.wifiSN  ?  : @"";
    params[@"uid"] = hanger.uid ? : @"";
    params[@"hangerNickname"] = nickName ? : @"";

    return [self POST:@"wifi/hanger/updateNickName" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}
@end

//
//  KDSHttpManager+ZigBeeLock.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/15.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSHttpManager+ZigBeeLock.h"

@implementation KDSHttpManager (ZigBeeLock)

- (NSURLSessionDataTask *)getZigBeeInfoWithGwSN:(NSString *)gwSN uid:(NSString *)uid zigbeeSN:(NSString *)zigbeeSN success:(void (^)(id _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    gwSN = gwSN ?: @""; uid = uid ?: @""; zigbeeSN = zigbeeSN ?: @"";
    return [self POST:@"v1/user/getZigBeeInfo" parameters:@{@"gwSN":gwSN, @"uid":uid, @"zigbeeSN":zigbeeSN} success:^(id  _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success(obj);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
    
    
}


@end

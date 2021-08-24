//
//  KDSUser.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/24.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSUser : NSObject

///账号名称，如果是手机必须添加前缀国家代码，例如8613500010086.
@property (nonatomic, strong, nullable) NSString *name;
///服务器返回的uid字段值，是一个哈希化的字符串。
@property (nonatomic, strong, nullable) NSString *uid;
///服务器返回的meUsername字段值，是一个哈希化的字符串。
@property (nonatomic, strong, nullable) NSString *username;
///服务器返回的mePwd字段值，是一个哈希化的字符串。
@property (nonatomic, strong, nullable) NSString *password;
///服务器返回的token字段值，是一个哈希化的字符串。
@property (nonatomic, strong, nullable) NSString *token;

@end

NS_ASSUME_NONNULL_END

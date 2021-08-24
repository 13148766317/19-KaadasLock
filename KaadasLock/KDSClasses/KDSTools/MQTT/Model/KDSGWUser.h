//
//  KDSGWUser.h
//  KaadasLock
//
//  Created by orange on 2019/5/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"

NS_ASSUME_NONNULL_BEGIN

///网关授权用户模型。
@interface KDSGWUser : KDSCodingObject

@property (nonatomic, strong) NSString *_id;
///授权用户uid
@property (nonatomic, strong) NSString *uid;
///授权用户账号
@property (nonatomic, strong) NSString *username;
///授权用户昵称
@property (nonatomic, strong) NSString *userNickname;
///关联的网关SN，本地添加的属性。
@property (nonatomic, strong) NSString *gwSn;

@end

NS_ASSUME_NONNULL_END

//
//  KDSAuthCatEyeMember.h
//  KaadasLock
//
//  Created by zhaona on 2019/7/1.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///授权猫眼的成员模型。
@interface KDSAuthCatEyeMember : NSObject<NSCoding>
///_id
@property (nonatomic, strong) NSString *_id;
///绑定设备的账号。
@property (nonatomic, strong) NSString *adminuid;
///被授权账号。
@property (nonatomic, strong) NSString *username;
///授权账号昵称。
@property (nonatomic, strong, nullable) NSString *userNickname;
///授权时间yyyy-MM-dd HH:mm
@property (nonatomic, strong) NSString * time;

@end

NS_ASSUME_NONNULL_END

//
//  KDSGWLockKeyInfo.h
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///网关接口返回的锁密钥基本信息模型。
@interface KDSGWLockKeyInfo : NSObject

///支持的最大密码数量。
@property (nonatomic, assign) NSInteger maxpwdusernum;
///支持的最大RFID数量。
@property (nonatomic, assign) NSInteger maxrfidusernum;
///支持的所有类型密匙最大数量。测试没发现有这个字段返回。
@property (nonatomic, assign) NSInteger maxusernum;
///支持的密码最大长度。
@property (nonatomic, assign) NSInteger maxpwdsize;
///支持的密码最小长度。
@property (nonatomic, assign) NSInteger minpwdsize;
///RFID的最大长度，这是什么鬼？
@property (nonatomic, assign) NSInteger maxrfidsize;
///RFID的最小长度，这是什么鬼？
@property (nonatomic, assign) NSInteger minrfidsize;

@end

NS_ASSUME_NONNULL_END

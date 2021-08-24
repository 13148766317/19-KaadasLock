//
//  KDSGWNetSetting.h
//  KaadasLock
//
//  Created by orange on 2019/4/15.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWNetSetting : KDSCodingObject

///固件版本号。
@property (nonatomic, strong) NSString *SW;
///znp软件版本号。2019/5/9的文档新增。
@property (nonatomic, strong) NSString *znpVersion;
///局域网IP。
@property (nonatomic, strong) NSString *lanIp;
///局域网子网掩码。
@property (nonatomic, strong) NSString *lanNetmask;
///广域网IP。
@property (nonatomic, strong) NSString *wanIp;
///广域网子网掩码。
@property (nonatomic, strong) NSString *wanNetmask;
///广域网接入方式。
@property (nonatomic, strong) NSString *wanType;

@end

NS_ASSUME_NONNULL_END

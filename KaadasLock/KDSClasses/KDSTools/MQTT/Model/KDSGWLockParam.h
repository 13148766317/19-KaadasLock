//
//  KDSGWLockParam.h
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///网关->锁->设备参数。
@interface KDSGWLockParam : NSObject

///锁的IEEE Mac地址？格式xx:xx:xx:xx:xx:xx?
@property (nonatomic, strong) NSString *macaddr;
///获取模块标志，什么鬼？
@property (nonatomic, strong) NSString *model;
///固件版本。
@property (nonatomic, strong) NSString *firmware;
///硬件版本。
@property (nonatomic, strong) NSString *hwversion;
///软件版本。
@property (nonatomic, strong) NSString *swversion;
///厂商名。
@property (nonatomic, strong) NSString *manufact;
///链路信号值。
@property (nonatomic, strong) NSString *linkquality;
///锁型号，锁功能集，锁软件版本，锁硬件版本之间是用分号隔开的<8100Z,8100A>
@property (nonatomic, strong) NSString *lockversion;

@end

NS_ASSUME_NONNULL_END

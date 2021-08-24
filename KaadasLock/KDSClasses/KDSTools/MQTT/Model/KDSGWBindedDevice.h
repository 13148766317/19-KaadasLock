//
//  KDSGWBindedDevice.h
//  KaadasLock
//
//  Created by orange on 2019/4/15.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///通过网关接口获取的接入设备模型。
@interface KDSGWBindedDevice : NSObject

///设备类型？kdszblock=锁？kdscateye=猫眼？。
@property (nonatomic, strong) NSString *deviceType;
///
@property (nonatomic, strong) NSString *deviceId;
///接入类型？net_bus又表示什么？
@property (nonatomic, strong) NSString *joinType;
///接入时间？格式距70年秒数？
@property (nonatomic, strong) NSString *joinTime;
///设备状态，0离线，2在线。
@property (nonatomic, assign) NSInteger devSta;

@end

NS_ASSUME_NONNULL_END

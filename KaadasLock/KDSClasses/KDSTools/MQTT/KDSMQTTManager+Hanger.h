//
//  KDSMQTTManager+Hanger.h
//  KaadasLock
//
//  Created by Apple on 2021/4/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"

NS_ASSUME_NONNULL_BEGIN



//开关
typedef enum : NSUInteger {
    HangerSwitchOFF = 0,
    HangerSwitchON,
} HangerSwitch;

//马达动作
typedef enum : NSUInteger {
    HangerMotorPause = 0,
    HangerMotorDown,
    HangerMotorUp,
} HangerMotorAction;

//马达状态
typedef enum : NSUInteger {
    //正常
    HangerMotorStatusNormal = 0,
    //上限
    HangerMotorStatusUpperLimit,
    //下限
    HangerMotorStatusLowerLimit,
    //遇阻
    HangerMotorStatusBlocked,
    //过载
    HangerMotorStatusOverload,
    //离线
    HangerMotorStatusOffline = 101,
    //上升
    HangerMotorStatusUpper = 102,
    //下降
    HangerMotorStatusLower = 103,
    
} HangerMotorStatus;

//风干
typedef enum : NSUInteger {
    HangerAirDryOFF,
    HangerAirDry120,
    HangerAirDry240,
} HangerAirDry;
//烘干
typedef enum : NSUInteger {
    HangerBakingOFF,
    HangerBaking120,
    HangerBaking240,
} HangerBaking;

@interface KDSMQTTManager (Hanger)

/**
 设置照明开关
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger light:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;
/**
 设置晾衣机电机上升/暂停/下降接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger motorAction:(HangerMotorAction) motorAction  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 设置晾衣机风干接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger airDry:(HangerAirDry) airDry  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 设置晾衣机烘干接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger baking:(HangerBaking) baking  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 设置晾衣机消毒接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger uv:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 设置晾衣机童锁接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger childLock:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 设置晾衣机语音控制开关接口
 */
- (KDSMQTTTaskReceipt *)hanger:(KDSDeviceHangerModel *)hanger loudspeaker:(HangerSwitch) hangerSwitch  completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 * 获取晾衣机状态
 */
- (KDSMQTTTaskReceipt *)getHangerStatus:(KDSDeviceHangerModel *)hanger   completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;





@end

NS_ASSUME_NONNULL_END

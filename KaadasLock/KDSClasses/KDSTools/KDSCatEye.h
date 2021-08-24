//
//  KDSCatEye.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/24.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSGWCateyeParam.h"
#import "GatewayDeviceModel.h"
#import "KDSGW.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 猫眼状态枚举，用于设置页面状态标签和状态图片等。
 */
typedef NS_ENUM(NSUInteger, KDSCatEyeState) {
    ///猫眼在线
    KDSCatEyeStateOnLine = 0,
    ///猫眼离线
    KDSCatEyeStateOffLine =1,
};

@interface KDSCatEye : NSObject
///从服务器获取到的猫眼设备模型。
//@property (nonatomic, strong) CateyeModel *cateyeModel;
@property (nonatomic,readwrite,strong) GatewayDeviceModel * gatewayDeviceModel;
@property (nonatomic,readwrite,strong)KDSGWCateyeParam * cateyeModel;
///猫眼所在的网关
@property (nonatomic,readwrite,strong)KDSGW * gw;
///猫眼设备的显示名称，昵称。
@property (nonatomic, strong, readonly) NSString *name;
///猫眼设备当前是否为主动呼叫状态。
@property (nonatomic, assign) BOOL isCalling;
///猫眼电量。
@property (nonatomic, assign) int powerStr;
///获取电量的时间戳，距70年间隔的浮点型值字符串。
@property (nonatomic, copy) NSString *getPowerTime;
///由于网关设备查询电量比较麻烦，这里设置一个布尔属性，如果启动后已成功查询到一次电量，则将此值设置为YES，避免频繁查询。默认为NO。
@property (atomic, assign) BOOL powerDidrequest;
///cat eye local state, decide by property "gw" and "gatewayDeviceModel".
@property (nonatomic, assign, readonly) BOOL online;
@end

NS_ASSUME_NONNULL_END

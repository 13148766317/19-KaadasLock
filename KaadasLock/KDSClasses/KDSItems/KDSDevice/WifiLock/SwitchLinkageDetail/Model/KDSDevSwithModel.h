//
//  KDSDevSwithModel.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSDevSwithModel : KDSCodingObject
///开关的设备ID
@property (nonatomic,strong)NSString * devId;
///通道号(可填单个如:1-1)
@property (nonatomic,strong)NSString * channelnum;
///时间策略使能（enable:0/unable:1）
@property (nonatomic,assign)int timeEn;
///开始执行时间距离1970年的秒数
@property (nonatomic,strong)NSString * startTime;
///结束执行时间距离1970年的秒数
@property (nonatomic,strong)NSString * stopTime;
///生效设置(策略总开关，on:1/off:0)
@property (nonatomic,assign)int switchEn;
///开关设备的mac地址"XX:XX:XX:XX:XX:XX",
@property (nonatomic,strong)NSString * macaddr;
///表示开关设备上的某一个子开关，从0开始
@property (nonatomic,assign)int type;
///开关状态改变上报 "on/off"
@property (nonatomic,strong)NSString * status;
///开关的网络地址
@property (nonatomic,strong)NSString * nwaddr;
///设置开关状态"on/off",
@property (nonatomic,strong)NSString * optype;
///周的位掩码，低位起分别表示星期日、一、二、三、四、五、六，最高位保留0，1选中。周计划使用。
@property (nonatomic, assign) char mask;

@end

NS_ASSUME_NONNULL_END

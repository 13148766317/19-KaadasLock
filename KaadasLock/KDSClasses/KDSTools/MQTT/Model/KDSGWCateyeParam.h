//
//  KDSGWCateyeParam.h
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///网关->猫眼->设备参数。
@interface KDSGWCateyeParam : NSObject
///设备序列号（sn号）。
//@property (nonatomic, copy) NSString *snNumber;
///软件版本号。
@property (nonatomic, copy) NSString *swVer;
///硬件版本号。
@property (nonatomic, copy) NSString *hwVer;
///MCU版本号。
@property (nonatomic, copy) NSString *mcuVer;
///T200版本号。
@property (nonatomic, copy) NSString *t200Ver;
///mac地址。格式xx:xx:xx:xx:xx:xx
@property (nonatomic, copy) NSString *macaddr;
///ip地址。
@property (nonatomic, copy) NSString *ipaddr;
///pir开启状态。
@property (nonatomic, assign) BOOL pirEnable;
///message box(留言)开启状态。
@property (nonatomic, assign) BOOL mbStatus;
///当前门铃音乐编号。从1开始。
@property (nonatomic, assign) int curBellNum;
///门铃音量。0高音？1低音？2正常音？3静音？
@property (nonatomic, assign) int bellVolume;
///响铃次数。
@property (nonatomic, assign) int bellCount;
///猫眼WiFi信号强度。
@property (nonatomic, assign) int wifiStrength;
///视频分辨率。格式如1920x1080.
@property (nonatomic, copy) NSString *resolution;
///门铃音乐最大个数。
@property (nonatomic, assign) int maxBellNum;
///猫眼电池电量，0-100.
@property (nonatomic, assign) int power;
///猫眼的设备ID
@property (nonatomic, copy)NSString * deviceId;
///sd卡状态
@property (nonatomic, copy)NSString * sdStatus;
///pir徘徊
@property (nonatomic, copy)NSString * pirSensitivity;
/**
 *猫眼的夜视功能：0,120,70
 *参数1：自动手动切换模式，0为自动模式，1为手动切换白天模式，2为手动切换黑夜模式
 *参数2：光敏电阻采集ADC值高于这个值时，且在自动模式下，切换为白天模式
 *参数3：光敏电阻采集ADC值低于这个值时，且在自动模式下，切换为黑夜模式
 *
 */
@property (nonatomic, copy)NSString * CamInfrared;

@end

NS_ASSUME_NONNULL_END

//
//  KDSBleLockInfoModel.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///KDSBleTunnelOrderGetLockInfo命令获取到的参数。
@interface KDSBleLockInfoModel : NSObject

/**
 *@abstract 便利初始化方法。time属性需要用到NSDateFormatter比较消耗性能，因此该属性在此方法中不提取，由外部赋值。
 *@param data 蓝牙模块返回的操作记录数据(20字节，请确保参数格式正确)。
 *@return instance。
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *@abstract 锁功能，具体位和功能说明如下：
 *
 *0:密码开锁功能，0不支持，1支持。
 *
 *1:RFID开锁功能，0不支持，1支持。
 *
 *2:指纹开锁功能，0不支持，1支持。
 *
 *3:远程开锁功能，0不支持，1支持。
 *
 *4:一键布防功能，0不支持，1支持。
 *
 *5:RTC时钟功能，0不支持，1支持。
 *
 *6:虹膜识别开锁功能，0不支持，1支持。
 *
 *7:声音识别开锁功能，0不支持，1支持。
 *
 *8:一键开锁开锁功能，0不支持，1支持。
 *
 *9:自动上锁功能，0不支持，1支持。
 *
 *10:门磁功能，0不支持，1支持。
 *
 *11:指静脉功能，0不支持，1支持。
 *
 *12:人脸识别功能，0不支持，1支持。
 *
 *13:安全模式功能，0不支持，1支持。
 *
 *14:反锁功能，0不支持，1支持。
 *
 *15:蓝牙功能，0不支持，1支持。
 *
 *16:红外，0不支持，1支持。
 *
 *17~31:保留。
 */
@property (nonatomic, assign) uint32_t lockFunc;

/**
 *@abstract 门锁状态，具体位和功能说明如下：
 *
 *0:锁斜舌状态，0已锁，1未锁阻塞。
 *
 *1:主锁舌(联动锁舌)状态，0已锁，1未锁。
 *
 *2:反锁(独立锁舌)状态，0反锁，1未反锁。
 *
 *3:门状态，0已锁，1未锁。
 *
 *4:门磁状态，0关，1开。
 *
 *5:安全模式状态，0不启用或不支持，1已启用。
 *
 *6:管理密码状态，0出厂(默认管理密码)状态，1已修改。
 *
 *7:手动/自动模式状态，0手动，1自动。
 *
 *8:布防状态，0未布防，1已布防。
 *
 *9:蓝牙开关状态，0关，1开。
 *
 *10:管理模式，0非管理模式，1管理模式。
 *
 *11:红外，0开，1关。
 *
 *12~31:保留。
 */
@property (nonatomic, assign) uint32_t lockState;
///音量，0静音，1低音，2高音，3-255保留。
@property (nonatomic, assign) uint8_t volume;
///锁语言，ISO639-1标准的2字节英文字符。
@property (nonatomic, strong, nullable) NSString *language;
///锁电量，0-100，默认是-1.
@property (nonatomic, assign) int power;
///锁时间，格式yyyy-MM-dd HH:mm:ss。
@property (nonatomic, strong, nullable) NSString *time;

@end

NS_ASSUME_NONNULL_END

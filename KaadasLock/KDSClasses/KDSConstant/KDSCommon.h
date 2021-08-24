//
//  KDSCommon.h
//  KaadasLock
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//
#ifndef KDSCommon_h
#define KDSCommon_h
/*常用的宏定义*/
// 获取Documents目录路径
#define PATHDOCUMNT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]

#define KDSRGBColorZA(r, g, b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// 过期提醒
#define KDSDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)
#define KDSRGBColor(r, g, b)        [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define NaviBackGroundColour            KDSRGBColor(42, 47, 63)
#define KDSPublicBackgroundColor        KDSRGBColor(248, 248, 248)
#define KDSPublicCellBackgroundColor    KDSRGBColor(46, 47, 65)

#define KDSClearBackgroundColor     [UIColor clearColor]
#define KDSGrayBackgroundColor      [UIColor grayColor]
#define KDSWhiteBackgroundColor     [UIColor whiteColor]

#define KDSNotificationCenter       [NSNotificationCenter defaultCenter]
#define KDSUserDefaults             [NSUserDefaults standardUserDefaults]
#define KDSWeakSelf(type)           __weak typeof(type) weak##type = type;

/*国际化语言相关*/
#define AppLanguageIsChanged          @"appLanguageIsChange"
#define AppLanguage                   @"appLanguage"
#define JianTiZhongWen                @"zh-Hans"
#define FanTiZhongWen                 @"zh-Hant"
#define English                       @"en"
#define Thailand                      @"th-TH"

/*屏幕相关设置*/
// 屏幕宽度
#define KDSScreenWidth ((CGRectGetWidth([UIScreen mainScreen].bounds) > CGRectGetHeight([UIScreen mainScreen].bounds))?(CGRectGetHeight([UIScreen mainScreen].bounds)):(CGRectGetWidth([UIScreen mainScreen].bounds)))
// 屏幕高度
#define KDSScreenHeight ((CGRectGetWidth([UIScreen mainScreen].bounds) > CGRectGetHeight([UIScreen mainScreen].bounds))?(CGRectGetWidth([UIScreen mainScreen].bounds)):(CGRectGetHeight([UIScreen mainScreen].bounds)))
#define KDSSSALE_WIDTH(width)      (width * (KDSScreenWidth / 375.0))

#define KDSSSALE_HEIGHT(height)      (height * (KDSScreenHeight / 667.0))

#define KDSUserDefaults             [NSUserDefaults standardUserDefaults]
//猫眼设置菜单
#define DoorBellSelect                     @"DoorBellSelect"                    //铃声选择
#define DoorBellVolumSetting               @"DoorBellVolumSetting"              //铃声音量
#define DoorBellRingNum                    @"DoorBellRingNum"                   //响铃次数
#define VideoResolutionSeting              @"VideoResolutionSeting"             //视频分辨率
#define IsAllowLeaveMessage                @"isAllowLeaveMessage"               //门铃留言功能开启
#define IsAllowPIR                         @"IsAllowPIR"                        //门铃pir开关
#define IsAllowRemoteRestart               @"IsAllowRemoteRestart"              //远程重启猫眼
#define BluetoothBin                   @"BluetoothBin"                          //蓝牙固件文件名
#define BluetoothProtocolStack         @"BluetoothProtocolStack"                //协议栈文件名
#define BluetoothBinP6                 @"BluetoothBinP6"                        //蓝牙固件文件名P6
#define WRITE_WITH_RESP_MAX_DATA_SIZE   133
#define WRITE_NO_RESP_MAX_DATA_SIZE   300
#endif /* KDSCommon_h */
/**
 *kEnvAddress
 * 切换正式与测试环境
 *注释掉为测试环境，打开为正式环境
 */
#define kEnvAddress     @"定义环境"
#ifdef kEnvAddress
//正式环境
//#define kBaseURL             @"https://app-kaadas.juziwulian.com:34000/"
#define kBaseURL             @"https://app.kaadas.com:34000/"
#define kMQTTHost            @"mqtt-kaadas.juziwulian.com"
#define kSIPHost             @"sip-kaadas.juziwulian.com"

#define kOTAHost             @"https://app.kaadas.com:34000/ota/checkUpgrade"
#define kOTAResults          @"https://app.kaadas.com:34000/ota/btResultAdd"
#define kOTAHostmu           @"https://app.kaadas.com:34000/ota/multiCheckUpgrade"
#define kFTPRelayHost        @"ftpserver.juziwulian.com"
#define kMQTTPort 1883
/*--商城模块--*/
#define KDSNetWorkEnvironment 1
/*--商城模块--*/
#else
//测试环境
#define kBaseURL             @"https://test.juziwulian.com:8090/"
#define kMQTTHost            @"test.juziwulian.com"
#define kSIPHost             @"test.juziwulian.com"
// 单固件地址的检查
#define kOTAHost             @"https://test.juziwulian.com:8090/ota/checkUpgrade"
// 多固件地址的检查
#define kOTAHostmu             @"https://test.juziwulian.com:8090/ota/multiCheckUpgrade"

#define kOTAResults            @"https://test.juziwulian.com:8090/ota/btResultAdd"

#define kFTPRelayHost          @"ftpserver.juziwulian.com"
#define kMQTTPort 1883
/*--商城模块--*/
#define KDSNetWorkEnvironment 0
/*--商城模块--*/
#endif

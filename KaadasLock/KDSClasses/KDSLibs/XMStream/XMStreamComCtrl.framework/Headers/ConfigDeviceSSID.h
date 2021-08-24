//
//  ConfigDeviceSSID.h
//  XMStreamComCtrl
//
//  Created by ryanlzj on 2017/5/19.
//  Copyright © 2017年 ryan. All rights reserved.
//

#warning 注意需要开启工程 Capabilities->Access WiFi Information

#import <Foundation/Foundation.h>

/**
 配网结果枚举
 */
typedef NS_ENUM(NSInteger, WIFI_CNF_STATUS_TYPE) {
    ///配网成功
    WIFI_CNF_STATUS_SUCCESSFUL = 0,
    ///配网超时
    WIFI_CNF_STATUS_TIMEOUT = -1, 
    ///配网传入的SSID参数为空
    WIFI_CNF_STATUS_SSID_IS_NULL = -2,
    ///选择的网关的SSID不正确
    WIFI_CNF_STATUS_INVALID_SSID = -3,
    ///与网关通讯出错
    WIFI_CNF_STATUS_COMMUNICATE_FAILED = -4,    
};

/**
 加密类型
 */
typedef NS_ENUM(NSInteger,ConfigEncryptionType) {
    /// 1:OPEN(开放的)
    ConfigEncryptionTypeOpen = 1,
    /// 2:WEP 
    ConfigEncryptionTypeWEP = 2,
    /// 3:WPA
    ConfigEncryptionTypeWPA = 3,
};

typedef NS_ENUM(NSInteger,ConfigModelType) {
    ConfigModelTypeRouterSet = 0, // 默认
    ConfigModelTypeRouterSetGW,
    ConfigModelTypeRouterSet64,
    ConfigModelTypeHDIP,
    ConfigModelTypeBatCam,
    ConfigModelTypeCatEye
};

@interface ConfigModel : NSObject
/// 设备配网类型
@property (nonatomic,assign) ConfigModelType modelType;
/// WiFi名称
@property (nonatomic,copy,nonnull) NSString *ssid;
/// WiFi密码
@property (nonatomic,copy,nullable) NSString *password;
/// WiFi加密类型
@property (nonatomic,assign) ConfigEncryptionType encyType;

@property (nonatomic,copy,nullable) NSString *token;

@end

@protocol ConfigWIFIDelegate<NSObject>
/**
 配网状态的返回的回调

 @param DID 设备配网成功后返回设备的DID值(nullable)
 @param status 配网状态值
 */
-(void)ConfigWIFIStatus:(nullable NSString *)DID Status:(WIFI_CNF_STATUS_TYPE)status;
@end

@interface ConfigDeviceSSID : NSObject
@property(nonatomic, weak) id<ConfigWIFIDelegate> _Nullable delegate;

/**
 对手机已经选中的设备WIFI(设备在AP模式下)进行配网，超时时间默认1分钟，调用前请把delegate(代理)设置好

 @param model 设备配置到相关配置
 */
-(void)StartConfigWithConfigModel:(nonnull ConfigModel *)model; 

/**
 对手机已经选中的设备WIFI(设备在AP模式下)进行配网（提供给猫眼的使用的AP配网函数）

 @param SSID 设备配置到的路由器名称
 @param pwd 设备配置到的路由器密码（没有可以传空字符串）
 @param type 设备配置到的路由器的加密类型
 @param registerID 设备的注册ID
 */
-(void)StartConfigUsingAP_ForCatEye:(nonnull NSString*)SSID Password:(nullable NSString*)pwd EncryptionType:(ConfigEncryptionType)type RegisterID:(nonnull NSString *)registerID;

/**
 停止AP配网
 */
-(void)StopConfigUsingAP;

@end

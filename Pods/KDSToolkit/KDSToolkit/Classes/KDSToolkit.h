//
//  KDSToolkit.h
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import <Foundation/Foundation.h>


//设置类
#import "KDSAppSettings.h"
//修改设置视图
#import "KDSAppSettingsVC.h"
//日志
#import "KDSAppLog.h"


NS_ASSUME_NONNULL_BEGIN

//以下值使用objectForKey或setObject方法获取与设置
//配置类型：Debug/Release
extern NSString *const KDSToolKitSettingServer;
//是否开启
extern NSString *const KDSToolKitSettingEnableDebug;


//以下键值使用 configObjectForKey方法获取
//HTTP接口URL
extern NSString *const KDSToolKitConfigHttpServer;
//MQTT服务器地址
extern NSString *const KDSToolKitConfigMqttServer;
//SIP服务器地址
extern NSString *const KDSToolKitConfigSipServer;


@interface KDSToolkit : NSObject

@end

NS_ASSUME_NONNULL_END

//
//  KDSToolkit.m
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import "KDSToolkit.h"

//以下值使用objectForKey或setObject方法获取与设置

//服务器配置
NSString *const KDSToolKitSettingServer = @"server";
//是否开启调试模式
NSString *const KDSToolKitSettingEnableDebug = @"enableDebug";

//以下键值使用(服务器配置) serverConfigObjectForKey方法获取

//HTTP接口URL
NSString *const KDSToolKitConfigHttpServer = @"httpServer";
//MQTT服务器地址
NSString *const KDSToolKitConfigMqttServer = @"mqttServer";
//SIP服务器地址
NSString *const KDSToolKitConfigSipServer = @"sipServer";


@implementation KDSToolkit

@end

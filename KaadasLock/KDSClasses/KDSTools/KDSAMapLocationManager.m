//
//  KDSAMapLocationManager.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAMapLocationManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface KDSAMapLocationManager ()<AMapLocationManagerDelegate,CLLocationManagerDelegate>
///定位管理者
@property (nonatomic, strong) CLLocationManager * kdsLocationManager;

@end

@implementation KDSAMapLocationManager

+ (instancetype)sharedManager
{
    static KDSAMapLocationManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSAMapLocationManager alloc] init];
    });
    return _manager;
}

- (void)initWithLocationManager
{
    CGFloat version = [[UIDevice currentDevice].systemVersion doubleValue];//float
    if(!_kdsLocationManager){
        
        // 初始化定位管理器
        _kdsLocationManager = [[CLLocationManager alloc] init];
        // 设置代理
        _kdsLocationManager.delegate = self;
        // 设置定位精确度到米
        _kdsLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置过滤器为无
        _kdsLocationManager.distanceFilter = kCLDistanceFilterNone;
        
        if(version > 8.0f){
            [_kdsLocationManager requestWhenInUseAuthorization]; //这句话ios8以上版本使用。
        }
        [_kdsLocationManager startUpdatingLocation];
        NSDictionary *netInfo = [self fetchNetInfo];
//        NSLog(@"提示提示提示提示提示睡一会：%@",netInfo);
        if (![[netInfo objectForKey:@"SSID"] hasPrefix:@"kaadas_"]) {
//            NSLog(@"中国中国中国中国%@",netInfo);
            self.originalSsid = [netInfo objectForKey:@"SSIDDATA"];
            self.ssid = [netInfo objectForKey:@"SSID"];
            self.bssid = [netInfo objectForKey:@"BSSID"];
        }
        
    }else{
        [self checkPermissions];
    }
   
}


-(void)checkPermissions{
    
    if (![KDSTool determineWhetherTheAPPOpensTheLocation]){
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请到设置->隐私->定位服务中开启【凯迪仕智能】定位服务，否则无法添加设备" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [KDSNotificationCenter postNotificationName:@"didOpenAutoLock" object:nil userInfo:nil];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];

        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alerVC addAction:cancleAction];
        [alerVC addAction:sureAction];
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alerVC animated:YES completion:nil];
        self.originalSsid = @"";
        self.ssid = @"";
        self.bssid = @"";
//        NSLog(@"提示提示提示提示提示睡一会");
    }else{
        NSDictionary *netInfo = [self fetchNetInfo];
//        NSLog(@"提示提示提示提示提示睡一会：%@",netInfo);
        if (![[netInfo objectForKey:@"SSID"] hasPrefix:@"kaadas_"]) {
//            NSLog(@"中国中国中国中国%@",netInfo);
            self.originalSsid = [netInfo objectForKey:@"SSIDDATA"];
            self.ssid = [netInfo objectForKey:@"SSID"];
            self.bssid = [netInfo objectForKey:@"BSSID"];
        }
        
    }
}
- (NSString *)fetchSsid
{
    NSDictionary *ssidInfo = [self fetchNetInfo];
    
    return [ssidInfo objectForKey:@"SSID"];
}

- (NSString *)fetchBssid
{
    NSDictionary *bssidInfo = [self fetchNetInfo];
    return [bssidInfo objectForKey:@"BSSID"];
}

- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

@end

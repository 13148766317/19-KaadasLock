//
//  KDSAMapLocationManager.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAMapLocationManager : NSObject

+(instancetype)sharedManager;
///检查定位是否打开，没有打开提醒用户打开权限
-(void)initWithLocationManager;
///wifi的ssid
@property (nonatomic, strong) NSString * ssid;
///wifi的bssid
@property (nonatomic, strong) NSString * bssid;
///wifi的原始ssid数据
@property (nonatomic, strong) NSData * originalSsid;

@end

NS_ASSUME_NONNULL_END

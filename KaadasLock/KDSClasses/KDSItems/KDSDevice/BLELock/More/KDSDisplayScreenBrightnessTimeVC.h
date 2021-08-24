//
//  KDSDisplayScreenBrightnessTimeVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/6/8.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDisplayScreenBrightnessTimeVC : KDSAutoConnectViewController

///显示屏亮度时间的回调
@property (nonatomic, copy) void (^screenBrightnessTimeChangeBlock)(int newScreenBrightnessSwitch,int newScreenBrightnessTime);

@end

NS_ASSUME_NONNULL_END

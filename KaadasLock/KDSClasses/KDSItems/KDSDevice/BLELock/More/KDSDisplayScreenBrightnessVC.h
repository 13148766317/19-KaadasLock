//
//  KDSDisplayScreenBrightnessVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/6/8.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDisplayScreenBrightnessVC : KDSAutoConnectViewController

///显示屏亮度的回调
@property (nonatomic, copy) void (^screenBrightnessChangeBlock)(int newScreenBrightness);

@end

NS_ASSUME_NONNULL_END

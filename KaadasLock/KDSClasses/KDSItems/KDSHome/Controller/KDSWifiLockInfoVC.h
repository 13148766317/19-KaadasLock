//
//  KDSWifiLockInfoVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///wifi锁。
@interface KDSWifiLockInfoVC : UIViewController

///绑定的设备对应的门锁模型，设置此属性前，请确保gwDevice已设置。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

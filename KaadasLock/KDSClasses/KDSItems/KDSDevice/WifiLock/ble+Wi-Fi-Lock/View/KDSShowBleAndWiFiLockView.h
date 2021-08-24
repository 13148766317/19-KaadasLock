//
//  KDSShowBleAndWiFiLockView.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/22.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSShowBleAndWiFiLockView : UIView

// 点击取消事件回调
@property (nonatomic,copy)dispatch_block_t cancelBtnClickBlock;
// 点击添加蓝牙锁事件回调
@property (nonatomic,copy)dispatch_block_t settingBtnClickBlock;

@end

NS_ASSUME_NONNULL_END

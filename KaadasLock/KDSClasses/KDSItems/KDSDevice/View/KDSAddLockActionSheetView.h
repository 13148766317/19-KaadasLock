//
//  KDSAddLockActionSheetView.h
//  KaadasLock
//
//  Created by zhaona on 2019/6/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface KDSAddLockActionSheetView : UIView

// 点击取消事件回调
@property (nonatomic,copy)dispatch_block_t cancleBtnClickBlock;
// 点击添加蓝牙锁事件回调
@property (nonatomic,copy)dispatch_block_t addBleLockBtnClickBlock;
// 点击添加网关锁事件回调
@property (nonatomic,copy)dispatch_block_t addGWLockBtnClickBlock;
// 点击添加门锁套装事件回调
@property (nonatomic,copy)dispatch_block_t addWifiLockClickBlock;

@end

NS_ASSUME_NONNULL_END

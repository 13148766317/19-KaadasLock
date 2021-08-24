//
//  KDSDeviceTimingCell.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/14.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSDeviceTimingCell : UITableViewCell

///开关状态改变执行的回调。
@property (nonatomic, copy, nullable) void(^powerStateBtnDidChangeBlock) (UIButton *sender);

@end

NS_ASSUME_NONNULL_END

//
//  KDSDeviceCell.h
//  KaadasLock
//
//  Created by orange on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSDeviceCell : UITableViewCell

///associated device model.蓝牙、网关锁传KDSLock对象，猫眼传KDSCatEye对象，网关传KDSGW对象。
@property (nonatomic, strong) id model;
///是否隐藏箭头，默认否。
@property (nonatomic, assign) BOOL hideArrow;

@end

NS_ASSUME_NONNULL_END

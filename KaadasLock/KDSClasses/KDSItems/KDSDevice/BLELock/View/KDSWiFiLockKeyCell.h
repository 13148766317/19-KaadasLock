//
//  KDSWiFiLockKeyCell.h
//  KaadasLock
//
//  Created by zhaona on 2020/5/29.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSWiFiLockKeyCell : UITableViewCell

///序号+名称。
@property (nonatomic, strong) NSString *name;
///权限描述。
@property (nonatomic, strong) NSString *jurisdiction;
///是否隐藏分隔线。
@property (nonatomic, assign) BOOL hideSeparator;
///是否隐藏右箭头，默认否。
@property (nonatomic, assign) BOOL hideArrow;

@end

NS_ASSUME_NONNULL_END

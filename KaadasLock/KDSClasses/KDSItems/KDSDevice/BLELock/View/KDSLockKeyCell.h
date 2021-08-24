//
//  KDSLockKeyCell.h
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSLockKeyCell : UITableViewCell

///名称。
@property (nonatomic, strong) NSString *name;
///权限描述。
@property (nonatomic, strong) NSString *jurisdiction;
///是否隐藏分隔线。
@property (nonatomic, assign) BOOL hideSeparator;
///是否隐藏右箭头，默认否。
@property (nonatomic, assign) BOOL hideArrow;

@end

NS_ASSUME_NONNULL_END

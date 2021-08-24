//
//  KDSDeviceModelCell.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 添加设备时选择的设备模型cell。
 */
@interface KDSDeviceModelCell : UITableViewCell

///设备型号。
@property (nonatomic, assign) KDSDeviceModel model;

@end

NS_ASSUME_NONNULL_END

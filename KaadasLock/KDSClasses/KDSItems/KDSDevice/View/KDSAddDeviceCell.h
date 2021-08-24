//
//  KDSAddDeviceCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/24.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddDeviceCell : UITableViewCell

@property (nonatomic,class,readonly,copy)NSString *ID;
///设备类型：zigbee、蓝牙
@property (nonatomic,readwrite,strong)UIImageView * deviceTypeIconImg;
///设备类型标题
@property (nonatomic,readwrite,strong)UILabel * deviceTypeNameLabel;
///设备类型内容:添加zigbee设备、添加蓝牙设备
@property (nonatomic,readwrite,strong)UILabel * detailLabel;
@end

NS_ASSUME_NONNULL_END

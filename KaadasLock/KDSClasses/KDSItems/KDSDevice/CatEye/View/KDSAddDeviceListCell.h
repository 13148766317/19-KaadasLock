//
//  KDSAddDeviceListCell.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddDeviceListCell : UICollectionViewCell
///根据设备名称展示相应的图片
@property (weak, nonatomic) IBOutlet UIImageView *deviceNameImg;
///设备的名称
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLb;
///cell中间的间隔线
@property (weak, nonatomic) IBOutlet UIView *line;

@end

NS_ASSUME_NONNULL_END

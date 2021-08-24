//
//  KDSAddZigBeeCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/4.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddZigBeeCell : UITableViewCell

///设备图标
@property (nonatomic,readwrite,strong)UIImageView * deviceIconImg;
///设备名称
@property (nonatomic,readwrite,strong)UILabel * deviceNameLabel;

@end

NS_ASSUME_NONNULL_END

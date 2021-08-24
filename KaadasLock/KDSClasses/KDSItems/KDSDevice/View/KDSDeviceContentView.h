//
//  KDSDeviceContentView.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/4.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSDeviceContentView : UIView

@property (nonatomic,readwrite,strong)UIButton *addDeviceBtn;
///你还没有设备哦
@property (nonatomic,readwrite,strong)UILabel * promptingLabel;

@end

NS_ASSUME_NONNULL_END

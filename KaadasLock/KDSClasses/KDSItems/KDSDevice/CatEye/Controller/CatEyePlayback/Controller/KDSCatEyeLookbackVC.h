//
//  KDSCatEyeLookbackVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/5/7.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSCatEyeLookbackVC : UIViewController
@property (nonatomic,readwrite,strong) GatewayDeviceModel * gatewayDeviceModel;
@property(nonatomic,copy)NSString *currentRecordDate;    //当前正在操作的日期 :2019-05-09

@end

NS_ASSUME_NONNULL_END

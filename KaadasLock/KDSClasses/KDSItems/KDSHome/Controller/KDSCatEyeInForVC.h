//
//  KDSCatEyeInForVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/22.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "GatewayDeviceModel.h"
#import "KDSCatEye.h"

NS_ASSUME_NONNULL_BEGIN

///猫眼。
@interface KDSCatEyeInForVC : KDSBaseViewController

///下拉刷新执行的操作。由于首页控制器添加下拉刷新会造成滚动视图上下弹跳，不美观，因此将下拉刷新放到此控制器做。
@property (nonatomic, copy, nullable) void(^pulldownRefreshBlock) (void);
///绑定的设备对应的猫眼模型
@property (nonatomic,readwrite,strong)KDSCatEye * cateye;

@end

NS_ASSUME_NONNULL_END

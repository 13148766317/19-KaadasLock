//
//  KDSDFUVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/5/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSAutoConnectViewController.h"

//--p6平台的ota升级
NS_ASSUME_NONNULL_BEGIN

///密码管理->更多设置->检查Psoc6固件升级。
@interface KDSDFUVC : KDSAutoConnectViewController 
///固件下载地址
@property (strong, nonatomic)  NSString *url;
///当前是bootload模式
@property (assign, nonatomic)  BOOL isBootLoadModel;
///倒计时秒数。初始化时为5
@property (nonatomic, assign) NSInteger countdown;


@end

NS_ASSUME_NONNULL_END

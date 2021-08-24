//
//  KDSOADVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/5/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSAutoConnectViewController.h"

//TI平台的oat升级
NS_ASSUME_NONNULL_BEGIN

///密码管理->更多设置->检查TI固件升级。
@interface KDSOADVC : KDSAutoConnectViewController
///固件下载地址
@property (nonatomic, strong)NSString * url;
///协议栈下载地址
@property (nonatomic, strong)NSString * protocolStackUrl;
///倒计时秒数。初始化时为5
@property (nonatomic, assign) NSInteger countdown;
///当前是bootload模式
@property (assign, nonatomic)  BOOL isBootLoadModel;

@end

NS_ASSUME_NONNULL_END

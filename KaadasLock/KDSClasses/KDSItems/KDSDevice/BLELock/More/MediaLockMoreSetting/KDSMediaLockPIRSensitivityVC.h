//
//  KDSMediaLockPIRSensitivityVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSMediaLockPIRSensitivityVC : KDSAutoConnectViewController
///选择完毕执行的回调。
@property (nonatomic, copy) void(^didSelectPIRSensitivityBlock) (int PIRSensitivityNum);

@end

NS_ASSUME_NONNULL_END

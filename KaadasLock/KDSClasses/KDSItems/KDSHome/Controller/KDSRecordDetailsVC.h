//
//  KDSRecordDetailsVC.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/18.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSRecordDetailsVC : KDSAutoConnectViewController

///已查看设备动态页，更新首页设备动态时使用到。
@property (nonatomic, copy, nullable) void(^didViewDynamic) (void);

@end

NS_ASSUME_NONNULL_END

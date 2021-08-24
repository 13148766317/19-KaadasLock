//
//  KDSLongConnectionPeriodVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSLongConnectionPeriodVC : KDSAutoConnectViewController

///选择完毕执行的回调，参数keep_alive_snooze、snooze_start_time、snooze_end_time。
@property (nonatomic, copy) void(^didSelectWeekAndTimeBlock) (NSArray * keep_alive_snooze,int snooze_start_time ,int snooze_end_time);

@end

NS_ASSUME_NONNULL_END

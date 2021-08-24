//
//  KDSDatePickerVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSDatePickerVC : UIViewController

///时效密码设置为0，周期密码设置为1.
@property (nonatomic) int mode;
///起始日期，参考UIDatePicker的date属性说明。
@property (nonatomic, strong) NSDate *beginDate;
///结束日期，周期密码时使用。
@property (nonatomic, strong) NSDate *endDate;
///控制器销毁时执行的回调。回调参数：时效密码时只返回beginDate，周期密码时返回2个。
@property (nonatomic, copy) void(^didPickupDateBlock) (NSDate *beginDate, NSDate * __nullable endDate);

@end

NS_ASSUME_NONNULL_END

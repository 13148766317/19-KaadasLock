//
//  KDSDanPDatePickerVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSDanPDatePickerVC : UIViewController


///起始日期，参考UIDatePicker的date属性说明。
@property (nonatomic, strong) NSString *beginStr;
///结束日期，周期密码时使用。
@property (nonatomic, strong) NSString *endStr;
@property (nonatomic, strong) NSString * titleStr;
///控制器销毁时执行的回调。回调参数：时效密码时只返回beginDate，周期密码时返回2个。
@property (nonatomic, copy) void(^didPickupDateBlock) (NSString * beginDate);


@end

NS_ASSUME_NONNULL_END

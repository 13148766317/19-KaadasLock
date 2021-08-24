//
//  KDSBleWeeklyModel.h
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSBleScheduleModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 获取周计划接口返回数据组装的模型。
 */
@interface KDSBleWeeklyModel : KDSBleScheduleModel

///周掩码，从高位到低位(保留，星期6，5，4，3，2，1，日)，对应位为1表示选中 。
@property (nonatomic, assign, readonly) UInt8 mask;
///开始小时，0-23.
@property (nonatomic, assign, readonly) NSUInteger beginHour;
///开始分钟，0-59.
@property (nonatomic, assign, readonly) NSUInteger beginMin;
///结束小时，0-23.
@property (nonatomic, assign, readonly) NSUInteger endHour;
///结束分钟，0-59.
@property (nonatomic, assign, readonly) NSUInteger endMin;

@end

NS_ASSUME_NONNULL_END

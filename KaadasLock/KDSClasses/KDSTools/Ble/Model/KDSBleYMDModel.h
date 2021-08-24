//
//  KDSBleYMDModel.h
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSBleScheduleModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 获取年月日计划接口返回数据组装的模型。
 */
@interface KDSBleYMDModel : KDSBleScheduleModel

///开始时间，距系统设置的时区2000年1月1日0点0分0秒的秒数。
@property (nonatomic, assign, readonly) NSInteger beginTime;
///结束时间，距系统设置的时区2000年1月1日0点0分0秒的秒数。
@property (nonatomic, assign, readonly) NSInteger endTime;

@end

NS_ASSUME_NONNULL_END

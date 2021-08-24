//
//  KDSGWLockSchedule.h
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///网关->门锁->策略或年月日、周计划。根据beginTime的长度是否为0来区分是年月日还是周计划。
@interface KDSGWLockSchedule : NSObject

///计划编号。最好和密码编号对应并限定在0~4。
@property (nonatomic, assign) int scheduleId;
///密码编号。
@property (nonatomic, assign) int userId;
///周的位掩码，低位起分别表示星期日、一、二、三、四、五、六，最高位保留0，1选中。周计划使用。
@property (nonatomic, assign) uint8_t mask;
///起始小时，0~23.周计划使用。
@property (nonatomic, assign) int beginH;
///起始分钟，0~59。周计划使用。
@property (nonatomic, assign) int beginMin;
///结束小时，0~23.周计划使用。
@property (nonatomic, assign) int endH;
///结束分钟，0~59。周计划使用。
@property (nonatomic, assign) int endMin;
///年月日计划的开始时间，距离2000年的秒数，需要加上本地时区和0时区的秒差，字符串值。
@property (nonatomic, strong, nullable) NSString *beginTime;
///年月日计划结束时间，距离2000年的秒数，需要加上本地时区和0时区的秒差，字符串值。
@property (nonatomic, strong, nullable) NSString *endTime;
///查询的时候用到：查询的计划是周、年 "type":"week/year",
@property (nonatomic, strong, nullable) NSString * yearAndWeek;
///日掩码
@property (nonatomic, assign) int daysMask;
///开始小时
@property (nonatomic, assign) int startHour;
///开始分钟
@property (nonatomic, assign) int startMinutes;
///结束小时
@property (nonatomic, assign) int endHour;
///结束分钟
@property (nonatomic, assign) int endMinutes;
///计划状态。1为生效。
@property (nonatomic, strong) NSString * scheduleStatus;
///开始时间
@property (nonatomic, strong) NSString * startTime;

@end

NS_ASSUME_NONNULL_END

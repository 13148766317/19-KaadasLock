//
//  KDSZigBeeLockInfoModel.h
//  KaadasLock
//
//  Created by zhaona on 2020/5/20.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSZigBeeLockInfoModel : NSObject

///支持的记录个数
@property (nonatomic,assign)int numberOfLogRecordsSupported;
///支持的总用户数
@property (nonatomic,assign)int numberOfTotalUsersSupported;
///支持的密码个数
@property (nonatomic,assign)int numberOfPINUsersSupported;
///支持卡片个数
@property (nonatomic,assign)int numberOfRFIDUsersSupported;
///每个用户支持的周计划个数
@property (nonatomic,assign)int numberOfWeekDaySchedulesSupportedPerUser;
///每个用户支持的年日计划个数
@property (nonatomic,assign)int numberOfYearDaySchedulesSupportedPerUser;
///支持的假期计划个数
@property (nonatomic,assign)int numberOfHolidaySchedulesSupported;
///最大密码长度
@property (nonatomic,assign)int maxPINCodeLength;
////最小密码长度
@property (nonatomic,assign)int minPINCodeLength;
///最大卡片长度
@property (nonatomic,assign)int maxRFIDCodeLength;
///最小卡片长度
@property (nonatomic,assign)int minRFIDCodeLength;
///支持指纹个数
@property (nonatomic,assign)int numberOfFingerUsersSupported;

@end

NS_ASSUME_NONNULL_END

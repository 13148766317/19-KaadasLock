//
//  KDSLockPwdInfo.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/29.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///锁中密码信息(和授权共用模型)。
@interface KDSLockPwdInfo : NSObject

///密码编号，[00, 最大密码数)。
@property (nonatomic, strong) NSString *number;
///昵称，锁不存在此属性，提升用户体验用。
@property (nonatomic, strong) NSString *nickname;
///策略、权限ID。
@property (nonatomic, strong) NSString *scheduleID;
///密码。
//@property (nonatomic, strong) NSString *pwd;
///权限，此属性只是对应授权权限，对应锁密码策略时需要进行转换。"1"1次(年月日)或一段时间，"2"多次(周)，"3"永久，"4"1次且已经使用过。
@property (nonatomic, strong) NSString *jurisdiction;
///权限为"2"时使用，设置和获取时都应该包含7个"0"(未选中)或"1"(选中)字符串，按顺序代表星期日、一、二、三、四、五、六。
@property (nonatomic, strong) NSArray<NSString *> *items;
///起始时间。年月日权限时格式为yyyy-MM-dd HH:mm，周权限时格式为HH:mm，永久时忽略。
@property (nonatomic, strong) NSString *beginDate;
///结束时间。年月日权限时格式为yyyy-MM-dd HH:mm，周权限时格式为HH:mm，永久时忽略。
@property (nonatomic, strong) NSString *endDate;

@end

NS_ASSUME_NONNULL_END

//
//  KDSAuthMember.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/28.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///授权开锁的成员模型。
@interface KDSAuthMember : NSObject <NSCoding>

///_id
@property (nonatomic, strong) NSString *_id;
///绑定设备的账号。
@property (nonatomic, strong) NSString *adminname;
///被授权账号。
@property (nonatomic, strong) NSString *uname;
///被授权账号昵称。
@property (nonatomic, strong, nullable) NSString *unickname;
///wifi锁分享用户的昵称
@property (nonatomic, strong, nullable) NSString *userNickname;
///被授权限。"1"1次(年月日)，"2"多次(多次)，"3"永久，"4"1次且已经使用过。
@property (nonatomic, strong) NSString *jurisdiction;
///权限为"2"时使用，设置和获取时都应该包含7个"0"(未选中)或"1"(选中)字符串，按顺序代表星期日、一、二、三、四、五、六。
@property (nonatomic, strong) NSArray<NSString *> *items;
///起始时间。年月日权限时格式为yyyy-MM-dd HH:mm，周权限时格式为HH:mm，永久时忽略。
@property (nonatomic, strong) NSString *beginDate;
///结束时间。年月日权限时格式为yyyy-MM-dd HH:mm，周权限时格式为HH:mm，永久时忽略。
@property (nonatomic, strong) NSString *endDate;
///绑定时间，距70年的本地时间秒数。
@property (nonatomic, assign) NSTimeInterval createTime;

@end

NS_ASSUME_NONNULL_END

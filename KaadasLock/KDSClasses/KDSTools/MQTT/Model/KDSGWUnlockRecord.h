//
//  KDSGWUnlockRecord.h
//  KaadasLock
//
//  Created by orange on 2019/4/15.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///MQTT请求网关开锁记录返回数据对应的模型。
@interface KDSGWUnlockRecord : KDSCodingObject

///对应锁的deviceId属性。
@property (nonatomic, copy) NSString *lockName;
@property (nonatomic, copy) NSString *user_num;

@property (nonatomic, copy) NSString *open_type;
@property (nonatomic, copy) NSString *nickName;
///距70年的毫秒数。
@property (nonatomic, assign) NSTimeInterval open_time;
///这个属性是本地设置的，用于从open_time计算日期，格式yyyy-MM-dd HH:mm:ss。
@property (nonatomic, strong, nullable) NSString *date;

@end

NS_ASSUME_NONNULL_END

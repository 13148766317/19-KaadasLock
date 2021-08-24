//
//  KDSBleAlarmRecord.h
//  lock
//
//  Created by orange on 2019/1/18.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import "KDSBleRecord.h"
#import "KDSBleOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 锁报警记录。新蓝牙。
 */
@interface KDSBleAlarmRecord : KDSBleRecord

///报警类型。
@property (nonatomic, readonly) KDSBleAlarmType type;

@end

NS_ASSUME_NONNULL_END

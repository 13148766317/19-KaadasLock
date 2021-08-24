//
//  KDSBleUnlockRecord.h
//  lock
//
//  Created by orange on 2018/12/19.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "KDSBleRecord.h"

NS_ASSUME_NONNULL_BEGIN
/** 开锁记录模型 */
@interface KDSBleUnlockRecord : KDSBleRecord

///旧蓝牙协议不使用记录总数和当前记录编号2个属性。透传蓝牙记录会在initWithData方法内部提取。
///用户编号%02d格式
@property (nonatomic, strong, readonly) NSString *userNum;
///开锁类型，如果是@"手机"表示APP开锁。
@property (nonatomic, strong, readonly) NSString *unlockType;

@end

NS_ASSUME_NONNULL_END

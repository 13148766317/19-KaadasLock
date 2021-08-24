//
//  KDSSetSwithEntryTimeVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/21.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSetSwithEntryTimeVC : KDSBaseViewController

@property (nonatomic,strong) KDSLock * lock;
///单火开关的设备模型
@property (nonatomic, strong) KDSDevSwithModel * stModel;
///开关按键属性
@property (nonatomic, assign) NSString * swithType;

@property (nonatomic, copy) void(^didSelectTimeBlock) (NSString * startTime,NSString * stopTime);

@end

NS_ASSUME_NONNULL_END

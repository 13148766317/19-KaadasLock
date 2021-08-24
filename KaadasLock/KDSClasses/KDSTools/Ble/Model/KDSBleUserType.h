//
//  KDSBleUserType.h
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSBleOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 获取锁用户类型接口返回数据组装的模型。
 */
@interface KDSBleUserType : NSObject

///密钥类型，默认无效值。
@property (nonatomic, assign) KDSBleKeyType keyType;
///用户编号。
@property (nonatomic, assign) NSUInteger userId;
///用户类型，默认无效值。
@property (nonatomic, assign) KDSBleSetUserType userType;

@end

NS_ASSUME_NONNULL_END

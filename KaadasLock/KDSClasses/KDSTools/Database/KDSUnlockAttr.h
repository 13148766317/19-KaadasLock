//
//  KDSUnlockAttr.h
//  xiaokaizhineng
//
//  Created by orange on 2019/3/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///本地缓存的开锁类型属性。网络连接不正常时从锁获取开锁记录后显示昵称使用。
@interface KDSUnlockAttr : NSObject <NSCoding>

///锁蓝牙名称。
@property (nonatomic, strong) NSString *bleName;
///不知道为什么解档时unlockType属性有时一直会出现问题，明明initWithCoder时得出的是字符串，但是到了数据库中的变量后就会变为其它类型了。在此添加多一个属性，和unlockType一样表示开锁类型，赋值赋给unlockType就行。
@property (nonatomic, strong) NSString *type;
///开锁类型，参考KDSBleUnlockRecord。
@property (nonatomic, assign) NSString *unlockType;
///开锁对应类型的密码编号。
@property (nonatomic, assign) int number;
///密码昵称，getter获取时，如果为空，会返回编号对应的2位数字。
@property (nonatomic, strong) NSString *nickname;

@end

NS_ASSUME_NONNULL_END

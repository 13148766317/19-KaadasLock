//
//  KDSAddSwitchSuccessVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddSwitchSuccessVC : KDSBaseViewController

///用来表示当前开关是几键：目前是：一、二、三、四
@property (nonatomic,strong)KDSLock * lock;
///单火开关的macaddr
@property (nonatomic,strong)NSString * macaddr;
///单火开关的类型：（表明是几键开关的字段）
@property (nonatomic,assign)NSInteger switchType;
///单火开关的绑定时间
@property (nonatomic,assign)NSTimeInterval switchBindTime;

@end

NS_ASSUME_NONNULL_END

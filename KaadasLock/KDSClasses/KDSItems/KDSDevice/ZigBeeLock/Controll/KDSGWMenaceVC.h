//
//  KDSGWMenaceVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

///---胁迫密码---
@interface KDSGWMenaceVC : KDSTableViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

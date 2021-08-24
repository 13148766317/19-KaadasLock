//
//  KDSOldBLEMoreSettingVC.h
//  KaadasLock
//
//  Created by orange on 2019/5/6.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSOldBLEMoreSettingVC : KDSTableViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

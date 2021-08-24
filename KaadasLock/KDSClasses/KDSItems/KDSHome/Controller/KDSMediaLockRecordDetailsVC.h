//
//  KDSMediaLockRecordDetailsVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSMediaLockRecordDetailsVC : KDSBaseViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

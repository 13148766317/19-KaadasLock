//
//  KDSGWRecordDetailsVC.h
//  KaadasLock
//
//  Created by orange on 2019/5/10.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWRecordDetailsVC : KDSBaseViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

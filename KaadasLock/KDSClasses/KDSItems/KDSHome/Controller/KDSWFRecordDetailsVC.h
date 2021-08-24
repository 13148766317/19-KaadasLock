//
//  KDSWFRecordDetailsVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSWFRecordDetailsVC : KDSBaseViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;

@end

NS_ASSUME_NONNULL_END

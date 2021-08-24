//
//  KDSBLEBindHelpVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/10.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBLEBindHelpVC : KDSTableViewController
///标示是蓝牙锁、网关锁（文案会不一样）
@property (nonatomic, strong) NSString * helpFromStr;

@end

NS_ASSUME_NONNULL_END

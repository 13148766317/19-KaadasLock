//
//  KDSBindingGatewayVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//


#import "KDSTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

///网关列表
@interface KDSBindingGatewayVC : KDSTableViewController

///标记从那个设备跳转过来的:1->网关、2->猫眼、3->智能锁
@property (nonatomic,readwrite,assign)NSUInteger  fromStrValue;
///网关数组
@property (nonatomic,strong)NSArray<KDSGW *> *gateways;

@end

NS_ASSUME_NONNULL_END

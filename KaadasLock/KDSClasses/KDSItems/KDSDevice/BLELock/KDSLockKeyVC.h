//
//  KDSLockKeyVC.h
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSCatEye.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSLockKeyVC : KDSAutoConnectViewController

///密匙类型。授权成员传KDSBleKeyTypeReserved。
@property (nonatomic,assign)KDSBleKeyType keyType;
///授权的猫眼。       
@property (nonatomic,strong)KDSCatEye * catEye;


@end

NS_ASSUME_NONNULL_END

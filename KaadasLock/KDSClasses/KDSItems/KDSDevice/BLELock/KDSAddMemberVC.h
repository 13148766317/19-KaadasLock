//
//  KDSAddMemberVC.h
//  xiaokaizhineng
//
//  Created by wzr on 2019/2/18.
//  Copyright © 2019 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSLock.h"

@class KDSAuthMember;

NS_ASSUME_NONNULL_BEGIN

@interface KDSAddMemberVC : KDSBaseViewController

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///添加被授权用户成功执行的回调，参数member只包含adminname、uname、jurisdiction(3)、items(默认全0)、beginDate和endDate。
@property (nonatomic, copy) void(^memberDidAddBlock) (KDSAuthMember *member);
@property (nonatomic, strong) KDSCatEye * catEye;

@end

NS_ASSUME_NONNULL_END

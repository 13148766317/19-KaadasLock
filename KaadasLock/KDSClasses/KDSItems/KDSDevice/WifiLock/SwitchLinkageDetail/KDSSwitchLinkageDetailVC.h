//
//  KDSSwitchLinkageDetailVC.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSwitchLinkageDetailVC :KDSBaseViewController

@property (nonatomic,strong) KDSLock * lock;
///根据请求结果决定是否刷新数据源,默认是否
@property (nonatomic,assign)BOOL isRefreshPage;

@end

NS_ASSUME_NONNULL_END

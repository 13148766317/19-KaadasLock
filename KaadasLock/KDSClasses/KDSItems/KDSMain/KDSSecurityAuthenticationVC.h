//
//  KDSSecurityAuthenticationVC.h
//  xiaokaizhineng
//
//  Created by orange on 2019/3/7.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSViewController.h"

NS_ASSUME_NONNULL_BEGIN

///用于启动/活跃时开启touch ID或手势密码验证。
@interface KDSSecurityAuthenticationVC : KDSViewController

///验证完成后执行的回调，参数表示验证是否成功，一般总是成功。
@property (nonatomic, copy) void(^finishBlock) (BOOL success);

@end

NS_ASSUME_NONNULL_END

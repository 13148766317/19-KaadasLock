//
//  KDSAddKeyVC.h
//  xiaokaizhineng
//
//  Created by orange on 2019/3/4.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

///添加卡片或者指纹。
@interface KDSAddKeyVC : KDSAutoConnectViewController

///功能类型，0添加卡片，1添加指纹，默认0。
@property (nonatomic, assign) int type;
///卡片或指纹添加成功执行的回调。添加成功后，会向服务器发送添加请求，但没有将结果保存到本地数据库中。
@property (nonatomic, copy) void(^keyAddSuccessBlock) (KDSPwdListModel *model);

@end

NS_ASSUME_NONNULL_END

//
//  KDSAutoConnectViewController.h
//  xiaokaizhineng
//
//  Created by orange on 2019/3/1.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSLock.h"

NS_ASSUME_NONNULL_BEGIN

///当首页蓝牙没有连接成功时，此类用于进入后需要自动连接蓝牙的页面(在viewDidAppear中连接)，代理已设置好，除发现外设、已连接、获取系统ID鉴权、获取电量、断开重连代理外请自行在子类实现需要的代理方法。本类的对象在销毁前会自动恢复蓝牙工具的上一个代理。
@interface KDSAutoConnectViewController : KDSBaseViewController <KDSBluetoothToolDelegate>

///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///如果不需要自动连接，请将此属性设置为NO，默认为YES。
@property (nonatomic, assign) BOOL autoConnect;
///鉴权成功0.2秒后执行的回调。如果进入本页面时才连接，或者重新连接，此后鉴权成功时会执行此回调。
@property (nonatomic, copy) void(^authenticateSuccess) (void);

@end

NS_ASSUME_NONNULL_END

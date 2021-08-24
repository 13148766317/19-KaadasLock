//
//  XMP2PManager.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSWifiLockModel.h"
#import <XMStreamComCtrl/XMStreamComCtrl.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMP2PManager : NSObject

@property (nonatomic,strong)KDSWifiLockModel * model;
/// 音视频流的管理
@property (nonatomic, strong) XMStreamComCtrl *streamManager;
///讯美p2p服务器连接的状态>0成功，其他都是失败，具体查看resultCode
@property (nonatomic, copy) void(^XMP2PConnectDevStateBlock) (NSInteger resultCode);
///讯美MQTT服务器连接的状态
@property (nonatomic, copy) void(^XMMQTTConnectDevStateBlock) (BOOL isCanBeDistributed);
///讯美MQTT服务器连接超时
@property (nonatomic,copy)dispatch_block_t XMMQTTConnectDevOutTimeBlock;
///收到讯美通知模块升级的响应
@property (nonatomic,copy)dispatch_block_t XMModuleUpgradeResponseBlock;

/**
 *@abstract 单例。
 *@return instance。
 */
+ (instancetype)sharedXMP2PManager;

///连接讯美P2P服务器。要用到KDSWifiLockModel里面的:device_did、device_sn、p2p_password
- (void)connectDevice;
/// 释放p2p连接和解码器
- (void)releaseLive;


@end

NS_ASSUME_NONNULL_END

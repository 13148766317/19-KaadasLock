//
//  KDSJoinGWEvent.h
//  KaadasLock
//
//  Created by orange on 2019/4/18.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///MQTT服务器上报事件->用户请求加入管理员名下的网关->MQTT服务器随事件返回的参数，所有参数。基本无文档参数注释。
@interface KDSJoinGWEvent : NSObject

@property (nonatomic, strong) NSString *_id;
///猜测应该是管理员账号登录返回的uid。
@property (nonatomic, strong) NSString *adminuid;
///猜测应该是网关的昵称。
@property (nonatomic, strong) NSString *deviceNickName;
///猜测应该是网关的sn。
@property (nonatomic, strong) NSString *deviceSN;
///猜测应该是事件方法名。
@property (nonatomic, strong) NSString *func;
///根据返回结果猜测应该是申请用户的账号或者昵称。
@property (nonatomic, strong) NSString *requestNickName;
///申请用户的账号登录时返回的uid。
@property (nonatomic, strong) NSString *requestuid;

@end

NS_ASSUME_NONNULL_END

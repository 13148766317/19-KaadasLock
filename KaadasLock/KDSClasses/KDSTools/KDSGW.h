//
//  KDSGW.h
//  KaadasLock
//
//  Created by orange on 2019/7/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"
#import "GatewayModel.h"
#import "KDSGWNetSetting.h"


///网关本地模型
@interface KDSGW : KDSCodingObject

///服务器请求模型。
@property (nonatomic, strong, nonnull) GatewayModel *model;
///the state over server notification。online or offline
@property (nonatomic, strong, nullable) NSString *state;
///network availability
@property (nonatomic, assign) BOOL networkAvailable;
///gateway local state, decide by property "state" and "networkAvailable".
@property (nonatomic, assign, readonly) BOOL online;

///gateway net settings.
@property (nonatomic, strong, nullable) KDSGWNetSetting *netSetting;
///gateway wifi name.
@property (nonatomic, strong, nullable) NSString *wifiName;
///gateway wifi password.
@property (nonatomic, strong, nullable) NSString *wifiPWD;
///gateway wifi encrytion type.
@property (nonatomic, strong, nullable) NSString *encryption;
///gateway wifi signal channel.
@property (nonatomic, strong, nullable) NSString *channel;

@end

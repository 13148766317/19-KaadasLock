//
//  GatewayModel.h
//  lock
//
//  Created by zhaowz on 2018/5/2.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "KDSCodingObject.h"

@class GatewayDeviceModel;

/*
 */
@interface GatewayModel : KDSCodingObject
/**************************************************************
 *          新增变量时不要添加结构体和C指针，没有做编码兼容            *
 **************************************************************/
/*获取网关列表返回如下信息**/
@property (nonatomic, copy) NSString *deviceSN;
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *deviceNickName;
///网关下绑定锁或者猫眼。getGatewayAndDeviceList接口才会从服务器返回，getGatewayList接口不会返回。
@property (nonatomic, strong) NSArray<GatewayDeviceModel *> *devices;
///1管理员角色，2授权角色。
@property (nonatomic, copy) NSString *isAdmin;
@property (nonatomic, copy) NSString *adminNickname;
@property (nonatomic, copy) NSString *adminuid;

@property (nonatomic, copy) NSString *meUsername;
@property (nonatomic, copy) NSString *mePwd;
@property (nonatomic, copy) NSString *meBindState;
///网关的模型：6010、6030、6032
@property (nonatomic, copy) NSString * model;

@end

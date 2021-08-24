//
//  KDSSmartHangerModel.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSmartHangerModel : KDSCodingObject
///SN
@property (nonatomic,strong)NSString * wifiSN;
/////产品型号
//@property (nonatomic,strong)NSString * productModel;
/////晾衣机昵称
//@property (nonatomic,strong)NSString * lockNickname;
///用户ID
@property (nonatomic,strong)NSString * uid;
/////设备软件版本
//@property (nonatomic,strong)NSString * softwareVersion;
/////wifi锁的功能集
//@property (nonatomic,strong)NSString * functionSet;
/////1:管理员 0：普通用户
//@property (nonatomic, copy)NSString *isAdmin;
/////wifi名称（设备绑定的wifi名称)
//@property (nonatomic,strong)NSString * wifiName;
/////设备的唯一ID
@property (nonatomic,strong)NSString * _id;
/////设备管理员账号
//@property (nonatomic,strong)NSString * adminName;
/////主用户的Uid
//@property (nonatomic,strong)NSString * adminUid;
/////分享用户ID
//@property (nonatomic,strong)NSString * appId;
/////用户账号
//@property (nonatomic,strong)NSString * uname;
/////wifi版本号
//@property (nonatomic,strong)NSString * wifiVersion;
/////更新数据的时间距离1970年的秒数
//@property (nonatomic,assign)NSTimeInterval updateTime;
/////绑定设备的时间距离1970年的秒数
//@property (nonatomic,assign)NSTimeInterval createTime;
/////服务器当前时间距离1970年的秒数
//@property (nonatomic, assign)NSTimeInterval currentTime;
//
//
//
/////重复日期:[1,2,3,4,5,6,7]
//@property (nonatomic,strong)NSArray * keep_alive_snooze;


@end

NS_ASSUME_NONNULL_END

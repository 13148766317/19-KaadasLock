//
//  KDSWifiLockOperation.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//
/*************************************************************************
* 公       司： 深圳市凯迪仕科技有限公司
* 文件名称：KDSWifiLockOperation
* 内容摘要：wifif门锁操作记录消息模型
* 日        期： 2016/11/30
************************************************************************/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockOperation : KDSCodingObject

///操作记录ID
@property (nonatomic,strong)NSString * _id;
///操作时间,当前时区当前时间至70年的秒数。
@property (nonatomic,assign)NSTimeInterval time;
///本地添加的，从warningTime转换的时间字符串，格式yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong, nullable) NSString *date;
///记录类型：1开锁 2关锁 3添加密钥 4删除密钥 5修改管理员密码 6自动模式 7手动模式 8安全模式切换 9常用模式切换 10反锁模式 11布防模式
@property (nonatomic,assign)int type;
///设备SN
@property (nonatomic,strong)NSString * wifiSN;
///密码类型：1密码 2指纹 3卡片 4APP用户
@property (nonatomic,assign)int  pwdType;
///密码编号
@property (nonatomic,assign)int pwdNum;
///记录创建时间,当前时区当前时间至70年的秒数。
@property (nonatomic,assign)NSTimeInterval createTime;
///分享用户编号
@property (nonatomic,assign)int appId;
///用户id
@property (nonatomic,strong)NSString * uid;
///用户账号
@property (nonatomic,strong)NSString * uname;
///用户昵称/密钥昵称
@property (nonatomic,strong)NSString * userNickname;
///分享用户账号
@property (nonatomic,strong)NSString * shareAccount;
///分享用户uid
@property (nonatomic,strong)NSString * shareUid;
///分享用户昵称
@property (nonatomic,strong)NSString * shareUserNickname;
///密钥昵称
@property (nonatomic,strong)NSString * pwdNickname;


@end

NS_ASSUME_NONNULL_END

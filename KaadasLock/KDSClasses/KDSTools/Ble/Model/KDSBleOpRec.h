//
//  KDSBleOpRec.h
//  KaadasLock
//
//  Created by orange on 2019/6/21.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBleRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleOpRec : KDSBleRecord

///操作总记录条数，如果没有报警记录，此值为0.
@property (nonatomic, readonly) int niketotal;
///当前记录的编号，从0开始，编号越小，操作越晚。
@property (nonatomic, readonly) int nikecurrent;
///1：Operation操作(动作类)\2：Program程序(用户管理类)\3：Alarm\4：混合记录
@property (nonatomic,assign,readonly) int cmdType;
///1：Operation操作(动作类)\2：Program程序(用户管理类)\3：Alarm
@property (nonatomic,assign,readonly) int eventType;
///操作媒介。0:键盘，1:RF遥控，2:手工，3:卡片，4:指纹，5:语音，6:指静脉，7:人脸识别，255:未知。Event Source
@property (nonatomic, assign, readonly) int eventSource;
///操作类型。0:保留，1:管理员密码修改，2:密码添加，3:密码删除，4:密码修改，5:卡片添加，6:卡片删除，7:指纹添加，8:指纹删除，9:APP添加(wtf)，10:APP删除，11:人脸添加，12:人脸删除，13:指静脉添加，14:指静脉删除。Event Code
@property (nonatomic, readonly) int eventCode;
///编号，和操作类型相关的编号，有范围或指定值。密码范围0~9，指纹、卡片、静脉、APP范围0~99，人脸范围0~25，机械方式100，遥控开锁101，一键开锁102，APP指令(指开锁指令？)103，BLE自动编号104，一次性密码252，访客密码253，管理密码254，未知255。UserID
@property (nonatomic, assign, readonly) int userID;
////记录操作的锁的蓝牙名称
@property (nonatomic, strong)NSString * bleName;

///蓝牙返回的操作记录二进制数据的16进制字符串。
@property (nonatomic, readonly) NSString *hexString;

@end

NS_ASSUME_NONNULL_END

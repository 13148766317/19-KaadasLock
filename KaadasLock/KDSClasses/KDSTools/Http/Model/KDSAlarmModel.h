//
//  KDSAlarmModel.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/27.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///报警记录接口模型。网关锁、猫眼的报警记录模型也使用这个，网关的报警记录暂时存放本地，不上传服务器。
@interface KDSAlarmModel : KDSCodingObject

///记录id，这个值是服务器返回的唯一性字段。
@property (nonatomic, strong) NSString *_id;
///网关SN。
@property (nonatomic, strong) NSString *gwSn;
///设备名称(一般是蓝牙广播名)。网关锁、猫眼填写锁的deviceId。
@property (nonatomic, strong) NSString *devName;
///报警类型(和蓝牙协议的报警类型一样)。猫眼的类型以KDSCYAlarmType为准。@see See KDSBleAlarmRecord.
@property (nonatomic, assign) int warningType;
///报警时间，当前时区当前时间至70年的毫秒数。
@property (nonatomic, assign) NSTimeInterval warningTime;
///本地添加的，从warningTime转换的时间字符串，格式yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong, nullable) NSString *date;
///报警内容。
@property (nonatomic, strong, nullable) NSString *content;

@end

NS_ASSUME_NONNULL_END

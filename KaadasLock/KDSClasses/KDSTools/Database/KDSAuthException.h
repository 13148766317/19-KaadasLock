//
//  KDSAuthException.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///记录鉴权异常的类。当收到鉴权异常通知时，将该异常添加到数据库中，用于帮助日志查看。
@interface KDSAuthException : NSObject <NSCoding>

///蓝牙外设名称。
@property (nonatomic, strong) NSString *bleName;
///设备昵称。
@property (nonatomic, strong) NSString *nickname;
///发生异常的日期。
@property (nonatomic, strong) NSDate *date;
///异常代码。按蓝牙协议，0x7e未绑定(pwd2为空)，0x91鉴权内容不正确，0x9A重复，0xC0硬件错误，0xC2校验错误(一般是pwd2被修改)
@property (nonatomic, assign) int code;
///异常日期字符串，格式yyyy/MM/dd HH:mm:ss
@property (nonatomic, strong) NSString *dateString;

@end

NS_ASSUME_NONNULL_END

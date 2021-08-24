//
//  MyDevice.m
//  kaadas
//
//  Created by ise on 16/9/12.
//  Copyright © 2016年 ise. All rights reserved.
//
/*************************************************************************
 * 公       司： 深圳市高金科技有限公司
 * 作       者： 深圳市高金科技有限公司	king
 * 文件名称：MyDevice.h
 * 内容摘要：蓝牙设备模型
 * 日        期： 2016/11/30
 ************************************************************************/
#import "MyDevice.h"
//#import "MJExtension.h"

@implementation MyDevice

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    //key为模型属性值
    return @{
             @"devmac":@"macLock",
             @"isAutoLock":@"auto_lock",
             };
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    if (self == object) return YES;
    MyDevice *other = object;
    return [self.lockName isEqualToString:other.lockName] && self.is_admin.boolValue == other.is_admin.boolValue;
}

- (NSUInteger)hash
{
    return self.lockName.hash  + self.is_admin.boolValue;
}

@end

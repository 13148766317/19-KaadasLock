//
//  KDSBleScheduleModel.h
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSBleOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 计划查询接口返回的公共数据模型。这是一个抽象基类，不直接使用。
 */
@interface KDSBleScheduleModel : NSObject

/**
 *@abstract 便利初始化方法。新模块date属性需要用到NSDateFormatter比较消耗性能，因此该属性在此方法中不提取，由外部赋值。
 *@note 基类实现已提取scheduleId、userId、keyType这3个属性，子类重载实现各自的功能时必须调用父类实现。
 *@param data 蓝牙模块返回的操作记录数据(20字节，请确保参数格式正确)。
 *@return instance。
 */
- (instancetype)initWithData:(NSData *)data;

///计划编号。
@property (nonatomic, assign, readonly) NSUInteger scheduleId;
///用户编号。由于一个计划可以添加多个用户，不知道返回这个值有什么意义。
@property (nonatomic, assign, readonly) NSUInteger userId;
///密匙类型，协议标注2是保留值，默认无效值。
@property (nonatomic, assign, readonly) KDSBleKeyType keyType;

@end

NS_ASSUME_NONNULL_END

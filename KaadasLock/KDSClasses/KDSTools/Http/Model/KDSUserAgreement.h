//
//  KDSUserAgreement.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///用户协议接口(包括协议版本和协议内容)返回的模型。调用获取协议内容时一般需先调用协议版本方法获取返回的协议id作为参数。
@interface KDSUserAgreement : NSObject <NSCoding>

///协议名称(版本接口返回)。
@property (nonatomic, strong) NSString *name;
///协议id(版本和内容接口都返回)。
@property (nonatomic, strong) NSString *_id;
///协议内容(内容接口返回)。
@property (nonatomic, strong, nullable) NSString *content;
///协议版本(版本和内容接口都返回)。
@property (nonatomic, strong) NSString *version;
///协议标签(版本和内容接口都返回)。
@property (nonatomic, strong) NSString *tag;

@end

NS_ASSUME_NONNULL_END

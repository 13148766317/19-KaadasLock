//
//  KDSBleTunnelTask.h
//  lock
//
//  Created by orange on 2018/12/14.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSBleOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 该类封装app->ble命令任务。实现文件内开启默认定时事件，如果20秒内还没有收到蓝牙的回应，则自动执行bleReplyBlock。
 */
@interface KDSBleTunnelTask : NSObject

/**
 *@abstract 便利初始化方法，新模块使用，旧透传模块不能使用此方法初始化。
 *@param data 发送给蓝牙模块的未加密前的20字节数据。
 *@return instance。
 */
- (instancetype)initWithData:(NSData *)data;

///命令唯一凭证。新蓝牙协议使用tsn值10进制数字字符串。旧协议使用旧命令值对应的10进制数字字符串。
@property (nonatomic, strong, readonly) NSString *receipt;
///新蓝牙协议传输序列号，旧协议会忽略此属性，默认无效值0。
@property (nonatomic, assign, readonly) NSInteger tsn;
///新协议命令类型，旧协议会忽略此属性。
@property (nonatomic, assign, readonly) KDSBleTunnelOrder order;
///发送给新蓝牙模块的未加密前的20字节数据。
@property (nonatomic, strong, readonly) NSData *data;
///旧协议命令类型，新协议不要设置。默认KDSBleOldCommandInvalid。
@property (nonatomic, assign) KDSBleOldCommand command;
///自定义的一些属性，可以按需设置。
@property (nonatomic, strong, nullable) NSDictionary *attrs;
///新蓝牙用于重发时执行的block。当设置此属性时，会开启一个定时器，5秒后每隔0.5秒执行一次，如果不再需要重发，请将此属性设置为nil(仅用于停止重发，setter暂时不会将此属性置为nil。)。重发次数达到3次后会自动停止重发。
@property (nonatomic, copy) void (^ __nullable taskResendBlock)(void);
///当收到蓝牙返回数据时执行的回调。参数data如果为空则出错了，否则是蓝牙模块返回且解密后的数据。从对象创建起，默认20秒内此块还不执行，则会自动执行，且参数为nil。因此，当已经收到蓝牙回复执行后，应该将此属性置为空或者销毁本对象。设置timeout会改变默认行为。
@property (nonatomic, copy) void (^ __nullable bleReplyBlock) (NSData * __nullable data);
///是否是查询任务。如果是查询任务，有时新蓝牙模块会先返回一个确认帧(cmd是0且不加密)后再返回查询数据(cmd等于order属性且加密)，因此不能使用确认帧的数据。以后添加新功能时记得更新内部实现。
@property (nonatomic, assign, readonly) BOOL isQueryTask;
///超时时间，默认20秒。如果超过此时间后自动执行bleReplyBlock回调且参数为空。需要注意的是，每次设置后时间都会从当前重新计算。
@property (nonatomic, assign) int timeout;
///发送的命令会返回多条数据时，获取到一条数据后，开启一个定时器，将此值设置一个秒数，如果从设置时起超过该时间没收到数据，判断为数据接收结束。如果将此值设置为0或负数，则销毁定时器。
@property (nonatomic, assign) float dataInterval;

@end

NS_ASSUME_NONNULL_END

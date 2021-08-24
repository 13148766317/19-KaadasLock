//
//  AsyncSocketTool.h
//  SocketClient
//
//  Created by zhaowz on 2017/6/7.
//  Copyright © 2017年 Edward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol AsyncSocketToolDelegate <NSObject>

- (void)didReceiveMessageFromServer:(NSDictionary *)dictionary;
- (void)didConnectServerSuccess:(NSString *)serverIp;

@end

@interface AsyncSocketTool : NSObject<GCDAsyncSocketDelegate>
//客户端socket
@property (nonatomic) GCDAsyncSocket *clinetSocket;
@property (nonatomic, weak) id<AsyncSocketToolDelegate> delegate;
/**初始化*/
- (instancetype)initWithDelegate:(id<AsyncSocketToolDelegate>)deleagte;
/**连接服务器*/
- (void)begainConnectToHost:(NSString *)host port:(uint16_t)port timeout:(NSTimeInterval)timeout;
/**发送消息*/
- (void)sendMessage:(NSDictionary *)messageDic;
/**断开连接*/
- (void)disConnect;
// 字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict;
#pragma mark - 获取路由器地址
- (NSString *)getRouterIp;
#pragma mark - 获取wifi名称
- (NSString *)getCurrentWifiSSID;
#pragma mark - 获取wifi Mac地址
- (NSString *)getWifiMacIP;

@end

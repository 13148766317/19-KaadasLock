//
//  KDSGCDSocketManager.h
//  KaadasLock
//
//  Created by zhaona on 2020/1/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TcpRecvDelegate<NSObject>

///收到数据做相应的事件
-(void)recv:(NSData *)data withTag:(long)tag;
///主动发数据超时没有相应
-(void)recvDataTimeOut;

@end

@interface KDSGCDSocketManager : NSObject

/// socket的IP
@property (nonatomic,strong) NSString *socketHost;
/// socket的prot端口
@property (nonatomic,assign) int socketPort;
///连接上的socket放入此数据，然后会丢失
@property (nonatomic,strong) NSMutableArray *clientSocket;
///全局的serverSocket变量
@property (nonatomic,strong) GCDAsyncSocket * serverSocket;
@property (nonatomic,strong) dispatch_queue_t golbalQueue;
///开启服务是否成功
@property (nonatomic,assign) BOOL startChatServerIsSuccess;
@property (nonatomic,weak) id<TcpRecvDelegate> delegate;
@property (nonatomic,assign)BOOL wifiSuccess;
@property (nonatomic,strong)NSString * isApConfigStr;
///每输入一次账号密码记数一次，允许用户输错5次。
@property (nonatomic, assign) int currentNetworkNum;

/**
 *@abstract 单例。
 *@return instance。
 */
+ (instancetype)sharedManager;
-(void)startChatServer;

@end

NS_ASSUME_NONNULL_END

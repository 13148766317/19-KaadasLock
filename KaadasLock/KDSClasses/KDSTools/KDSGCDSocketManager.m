//
//  KDSGCDSocketManager.m
//  KaadasLock
//
//  Created by zhaona on 2020/1/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSGCDSocketManager.h"
#import "KDSBleAssistant.h"
#import "GCDAsyncSocket.h"
#import "NSData+JKEncrypt.h"
#import "NSString+extension.h"
#import "UIView+Extension.h"


@interface KDSGCDSocketManager ()<GCDAsyncSocketDelegate>

@end

@implementation KDSGCDSocketManager

+ (instancetype)sharedManager
{
    static KDSGCDSocketManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSGCDSocketManager alloc] init];
       
    });
    return _manager;
}
-(void)startChatServer{
    
    //创建全局queue
    self.golbalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //开启服务前先断开，不然会开启失败
    if (self.serverSocket && self.serverSocket.isConnected) {
        [self.serverSocket disconnect];
    }
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //打开监听端口
    NSError *err;
    [self.serverSocket acceptOnPort:self.socketPort error:&err];
    if (!err) {
        NSLog(@"服务开启成功：%ld",(long)err.code);
        self.startChatServerIsSuccess = YES;
        self.wifiSuccess = YES;
    }else{
        NSLog(@"服务开启失败： %ld",(long)err.code);
        ///主意，本来开启服务失败即是配网失败
        self.startChatServerIsSuccess = NO;
        self.wifiSuccess = NO;
        
    }
}

#pragma mark GCDAsyncSocketDelegate

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
  elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"wifi--elapsed==%f,length==%lu,tag==%ld",elapsed,(unsigned long)length,tag);

    if (elapsed >= 10)
    {
        //taf:10001读取数据失败
        [self.serverSocket writeData:[@"TimeOut" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:10001];
        return 0;
    }

    return 0;
}
#pragma mark  读流关闭
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"wifi--读流关闭，sock=%@,_serverSocket==%@,err=%@,errCode=%ld",sock,_serverSocket,err,(long)err.code);
    if (sock && err.code == 7) {//端口关闭
        NSLog(@"wifi--读流关闭，sock=%@",_serverSocket);
        if ([self.delegate respondsToSelector:@selector(recvDataTimeOut)]) {
            [self.delegate recvDataTimeOut];
        }
    }

}
#pragma mark 有客户端建立连接的时候调用
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"wifi--有客户端建立连接的时候调用");
    [self.clientSocket addObject:newSocket];
    self.serverSocket = newSocket;
    [self.serverSocket readDataWithTimeout:-1 tag:10000];
}

#pragma mark 服务器写数据给客户端
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"wifi--服务器写数据给客户端：%ld",tag);
    [sock readDataWithTimeout:-1 tag:100002];
}

#pragma mark 接收客户端传递过来的数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"wifi--客户端的socket发来的数据:%@",data);
    self.serverSocket = sock;
    if ([self.delegate respondsToSelector:@selector(recv:withTag:)]) {
        if (data.length >= 46 && self.wifiSuccess) {
             self.wifiSuccess = NO;
             [self.delegate recv:data withTag:tag];
        }
    }
    
}


@end

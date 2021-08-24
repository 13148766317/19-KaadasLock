//
//  CGlobal.m
//  myCar
//
//  Created by 白天鹏 on 14-6-3.
//  Copyright (c) 2014年 白天鹏. All rights reserved.
//

#import "CGlobal.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "getgateway.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>

#define TIMEOUT_TCP_WRITE      -1
#define TAG_TCP_WRITE_STREAM    201
#define TAG_TCP_WRITE_HEART  202

@interface CGlobal ()

@property (nonatomic, strong) NSMutableArray<AsyncSocket *> *clients;
@property (nonatomic, assign) NSInteger tcpConnectCount; //TCP断开重连尝试次数 10次之后不再连接

@end

@implementation CGlobal{
    
    AsyncSocket *_asyncSocket;
    BOOL _socketManualDisconnect;
    NSTimer* _socketHeartbeatTimer;
}

#pragma mark - 公开类方

+ (CGlobal *)sharedInstance
{
    static CGlobal *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CGlobal alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc
{
    
    [self closeTcpConnection];
    
}

#pragma mark - 公开方法：socket 相关
-(void)openTcpConnection:(NSString*)host port:(NSInteger)port
{

    if (_asyncSocket)
    {
        if (_asyncSocket.isConnected)
        {
            [_asyncSocket setDelegate:nil];
            [_asyncSocket disconnect];
        }
    }
    _asyncSocket = [[AsyncSocket alloc] init];
    _asyncSocket.delegate = self;
    NSError *err = nil;
    
    if(![_asyncSocket connectToHost:host onPort:port error:&err])
    {
        return;
    }
}
- (void)closeTcpConnection
{
    if (_asyncSocket.isConnected)
    {
        NSLog(@"手动断开tcp连接");
        [_asyncSocket setDelegate:nil];
        [_asyncSocket disconnect];
        [self stopTimer];
    }else{
        [_asyncSocket setDelegate:nil];
        [self stopTimer];
    }
}
-(void)setDelegate_ITcpClient:(id<ITcpClient>)_itcpClient
{
    itcpClient = _itcpClient;
}

- (void)sendMessage:(NSDictionary *)messageDic
{
    if (!_asyncSocket)
    {
        return;
    }
    NSString *jsonStr = [self convertToJsonData:messageDic];
    NSData * mesData = [self getCompleteData:jsonStr];
    [_asyncSocket writeData:mesData withTimeout:TIMEOUT_TCP_WRITE tag:TAG_TCP_WRITE_STREAM];
}

- (void)socketRelease
{
    _asyncSocket = nil;
}

#pragma mark - AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    self.tcpConnectCount = 0;
    [self startTimer];
    NSLog(@"TCPonSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    if (sock != _asyncSocket) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Socket连接成功后，主线程发送数据
        [itcpClient OnConnect:sock.connectedHost];
    });
    //等待读取数据
    [_asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [itcpClient OnSendDataSuccess:sock.connectedHost:[NSString stringWithFormat:@"tag:%li",tag]];
    });
}

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *contentData = [data subdataWithRange:NSMakeRange(8, data.length-8)];
    NSString * str = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
    NSDictionary * reciveDict = [self dictionaryWithJsonString:str];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [itcpClient OnReciveData:sock.connectedHost:reciveDict];
    });
    [_asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"TCP连接将要断开");
    _didDisConnectStr = [NSString stringWithFormat:@"%@",sock.connectedHost];
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
    _error = err;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    [self stopTimer];
    
    NSLog(@"TCP连接已断开%@",sock.connectedHost);
    NSLog(@"onSocket: DidDisconnect:%p", sock);

    if(_error.code == 61){
        //Connection refused
        NSLog(@"不是Kaadas网关");
        dispatch_async(dispatch_get_main_queue(), ^{
            [itcpClient notKaadasGateway:_error];
        });
        
    }else{
        self.tcpConnectCount ++;
        //重连
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里实现断开重连
            if (self.tcpConnectCount <= 10) {
                KDSLog(@"TCP尝试重连次数:%ld",self.tcpConnectCount);
                [itcpClient OnDisconnect:_didDisConnectStr:nil];
            }
        });
    }
}
//启动心跳包
-(void)startTimer
{
    _socketHeartbeatTimer =[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFunction:) userInfo:nil repeats:YES];
}
//发送心跳包
-(void)timerFunction:(id)sender
{
    KDSLog(@"发送心跳包");
    if (self.asyncSocket) {
        Byte headByte[8];
        headByte[0] = 0xAF;
        headByte[1] = 0x01;
        headByte[2] = 0x00;
        headByte[3] = 0x00;
        NSData *HeaderData  = [[NSData alloc] initWithBytes:headByte length:8];
        [self.asyncSocket writeData:HeaderData withTimeout:-1 tag:TAG_TCP_WRITE_HEART];
    }
}
//销毁心跳包
-(void)stopTimer
{
    if(_socketHeartbeatTimer!=nil){
        [_socketHeartbeatTimer invalidate];
        _socketHeartbeatTimer=nil;
    }
}
//获取默认网关IP地址
- (NSString *)getRouterIp {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *ip = @"Not Found";
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL)
        /*/
         int i=255;
         while((i--)>0)
         //*/
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                //检查界面是否为en0，即iPhone上的wifi连接
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {

                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    KDSLog(@"address--%@",address);

                    //routerIP----192.168.1.255 广播地址
                    KDSLog(@"broadcast address--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    //--192.168.1.106 本机地址
                    KDSLog(@"local device ip--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                    //--255.255.255.0 子网掩码地址
                    KDSLog(@"netmask--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    //--en0 端口地址
                    KDSLog(@"interface--%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                    
                    
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    const char * str =[address UTF8String];//NSString转char *
    in_addr_t* x =&i;
    //unsigned char *s=getdefaultgateway(x);//有bug--wifi信号不好时会获取到两个网关地址
    unsigned char *s= getdefaultgatewayWithIP(str);//修改为添加本地ip地址对比

    ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];

    free(s);
    
    return ip;
}

//获取wifi名称
- (NSString *)getCurrentWifiSSID
{
    NSString *ssid = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
        }
    }
    return ssid;
}
//获取wifi的Mac地址
- (NSString *)getWifiMacIP{
    NSString *bssid = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            bssid = [dict valueForKey:@"BSSID"];
        }
    }
    return bssid;
}
//获取到给tcp发送的数据
-(NSData*)getCompleteData:(NSString *)string{
    long length = string.length;
    Byte headByte[8];
    u_int8_t highByte;
    u_int8_t lowByte;
    headByte[0] = 0xAF;
    headByte[1] = 0x02;
    highByte = length>>8/*length/256&0xFF*/;  //获取十进制数高八位
    lowByte = (length<<8)>>8 /*length&0xFF*/;   //获取十进制数低八位
    headByte[2] = highByte;
    headByte[3] = lowByte;
    NSData *HeaderData  = [[NSData alloc] initWithBytes:headByte length:8]; //数据头
    NSData *contentData = [string dataUsingEncoding:NSUTF8StringEncoding];  //数据内容
    //发送的数据
    NSMutableData *sendConnectData = [NSMutableData data];
    [sendConnectData appendData:HeaderData];
    [sendConnectData appendData:contentData];
    return sendConnectData;
}
//json字符串转字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
// 字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        KDSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}


@end

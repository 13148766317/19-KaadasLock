//
//  AsyncSocketTool.m
//  SocketClient
//
//  Created by zhaowz on 2017/6/7.
//  Copyright © 2017年 Edward. All rights reserved.
//

#import "AsyncSocketTool.h"
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


@implementation AsyncSocketTool

- (instancetype)initWithDelegate:(id<AsyncSocketToolDelegate>)deleagte{
    if (self = [super init]) {
        self.delegate = deleagte;
        self.clinetSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    }
    return self;
}
- (void)begainConnectToHost:(NSString *)host port:(uint16_t)port timeout:(NSTimeInterval)timeout{
    
    if (self.clinetSocket.isConnected) {
        return;
    }
    [self.clinetSocket disconnect];
    NSError *error = nil;
    [self.clinetSocket connectToHost:host onPort:port withTimeout:timeout error:&error];
    KDSLog(@"error:%@",error);
}
- (void)disConnect{
    [self.clinetSocket disconnect];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    KDSLog(@"socket连接成功,ip:%@",host);
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectServerSuccess:)]) {
        [_delegate didConnectServerSuccess:host];
    }
    [self.clinetSocket readDataWithTimeout:-1 tag:0];
}

//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //    NSData *headData = [data subdataWithRange:NSMakeRange(0, 4)];
    NSData *contentData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
    NSString * str = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
    NSDictionary * reciveDict = [self dictionaryWithJsonString:str] ;
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveMessageFromServer:)]) {
        [_delegate didReceiveMessageFromServer:reciveDict];
    }
    [self.clinetSocket readDataWithTimeout:-1 tag:0];
}

//发送消息
- (void)sendMessage:(NSDictionary *)messageDic {
    NSString *jsonStr = [self convertToJsonData:messageDic];
    NSData * mesData = [self getCompleteData:jsonStr];
    [self.clinetSocket writeData:mesData withTimeout:-1 tag:0];
}

- (NSString *)getRouterIp {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
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
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
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
    in_addr_t* x =&i;
    unsigned char *s=getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
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
//获取到给tcp发送消息
-(NSData*)getCompleteData:(NSString *)string{
    long length = string.length;
    Byte headByte[4];
    u_int8_t highByte;
    u_int8_t lowByte;
    headByte[0] = 0xAF;
    headByte[1] = 0xBF;
    highByte = length>>8/*length/256&0xFF*/;  //获取十进制数高八位
    lowByte = (length<<8)>>8 /*length&0xFF*/;   //获取十进制数低八位
    headByte[2] = highByte;
    headByte[3] = lowByte;
    NSData *HeaderData  = [[NSData alloc] initWithBytes:headByte length:4];
    NSData *contentData = [string dataUsingEncoding:NSUTF8StringEncoding];
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

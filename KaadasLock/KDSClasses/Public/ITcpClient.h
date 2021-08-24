//
//  ITcpClient.h
//  smartqhome
//
//  Created by laihy on 15-3-7.
//  Copyright (c) 2014年 ky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITcpClient <NSObject>

#pragma mark ITcpClient
@optional
/**发送到服务器端的数据*/
-(void)OnSendDataSuccess:(NSString*)connectHost :(NSString*)sendedStr;

/**收到服务器端发送的数据*/
-(void)OnReciveData:(NSString*)connectHost :(NSDictionary*)dic;

/**socket连接出现错误*/
-(void)OnDisconnect:(NSString*)connectHost :(NSError *)err;

/**socket连接**/
-(void)OnConnect:(NSString*)connectHost;

/**读取流被断开**/
-(void)ReadStreamDidClose:(NSString*)connectHost;

/**不是凯迪仕网关**/
-(void)notKaadasGateway:(NSError*)error;

@end

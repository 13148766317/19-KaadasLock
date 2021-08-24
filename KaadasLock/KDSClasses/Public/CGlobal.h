//
//  CGlobal.h
//  myCar
//
//  Created by 白天鹏 on 14-6-3.
//  Copyright (c) 2014年 白天鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITcpClient.h"
#import "AsyncSocket.h"

@interface CGlobal : NSObject<AsyncSocketDelegate>
{
    id<ITcpClient> itcpClient;
}

@property (nonatomic,retain) AsyncSocket *asyncSocket;
@property (nonatomic,strong) NSString *didDisConnectStr;
@property (nonatomic,strong) NSError *error;

+ (CGlobal *)sharedInstance;
- (NSString *)getCurrentWifiSSID;
- (NSString *)getRouterIp;
-(void)openTcpConnection:(NSString*)host port:(NSInteger)port;

-(void)closeTcpConnection;

-(void)setDelegate_ITcpClient:(id<ITcpClient>)_itcpClient;

- (void)sendMessage:(NSDictionary *)messageDic;

@end

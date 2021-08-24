//
//  XMP2PManager.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "XMP2PManager.h"
#import "XMUtil.h"

@interface XMP2PManager ()<StreamDelegate>
/// 初始化音视频流的标记
@property (nonatomic, assign, getter=isInitStream) BOOL initStream;
/// 断开重连的标记
@property (nonatomic, assign, getter=isCanReconnect) BOOL canReconnect;
/// 当前页面显示的标记
@property (nonatomic, assign, getter=isViewActivated) BOOL viewActivated;
/// 重连的连接次数
@property (nonatomic, assign) NSInteger connectCount;
///讯美p2p连接时超时没有登录MQTT成功
@property (nonatomic,strong)NSTimer * outTimer;

@end


@implementation XMP2PManager

+ (instancetype)sharedXMP2PManager
{
    static XMP2PManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[XMP2PManager alloc] init];
    });
    return _manager;
}

- (void)connectDevice
{
    self.outTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(callOutTime:) userInfo:nil repeats:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initXMStreamComCtrl];
        /// 以下连接信息正式环境将由讯美提供，现在以下均是测试数据。
        XMConnectParameter parameter;
        // 设备的did
        parameter.did = self.model.device_did;//@"AYIOTCN-000337-FDFTF";
        // 摄像机的sn
        parameter.sn = self.model.device_sn;//@"010000000020500020";
        // 设备的通道号
        parameter.channel = 0;
        // 唯一的用户名
        parameter.usr_id = @"xmitceh_ios";
        // 登录的字符串
        parameter.serverString = AERVICE_STRING;
        // 登录的用户名，目前是设备的sn。
        // 注意：这里的SN与上面的parameter.sn如果是基站版会则会不一样，这里是设备SN：字段：device_sn，上面的是摄像机SN，字段：camera_sn。目前是单机版则SN是一样的，需要注意区别。
        parameter.userName = self.model.device_sn;//@"010000000020500020";
        // 登录的密码
        parameter.userPassword = self.model.p2p_password;//@"ut4D0mvz";
        WeakSelf
        [self.streamManager StartConnectWithMode:XMStreamConnectModeWAN connectParam:parameter completeBlock:^(XMStreamComCtrl *steamComCtrl, NSInteger resultCode) {
            
            !self.XMP2PConnectDevStateBlock ?: self.XMP2PConnectDevStateBlock(resultCode);
            
            if (resultCode > 0) {
                weakSelf.canReconnect = true;
                [weakSelf loginMqtt];
            }
        }];
    });
    
}

/// 通知设备MQTT登录
- (void)loginMqtt {
    [self.streamManager mqttCtrl:1 channel:0];
}

/// 通知设备MQTT退出登录
- (void)logoutMqtt {
    [self.streamManager mqttCtrl:0 channel:0];
}

///关闭设备的连接
- (void)StopConnectDevice
{
    [self.streamManager StopConnectDevice];
}
/// 释放p2p连接和解码器
- (void)releaseLive
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self logoutMqtt];
        [self.streamManager StopAudioStream];
        [self.streamManager StopVideoStream];
        [self.streamManager StopConnectDevice];
        [self.streamManager StopTalkback];
    });
    
}
/// 设备登录回调
/// @param RetDic 登录回调结果数据
/// @param DID 登录的设备did
- (void)LogInDeviceProcResult:(NSDictionary *)RetDic DID:(NSString *)DID {
    NSLog(@"LogInDeviceProcResult = %@", RetDic);
    if ([[RetDic objectForKey:@"result"] isEqualToString:@"ok"]) {
//        if (self.type == XMPlayTypeReplay) {
//            [self searchRecordFileListWithDateString:nil];
//        }
    } else {
        NSInteger errorCode = [[RetDic objectForKey:@"errno"] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (errorCode) {
                case 6: {
                    NSLog(@"Connection password error.");
                }
                    break;
                case 114: {// 目前只支持3个用户同时查看，这里会返回最后一个查看的用户
                    NSString *user_id = [RetDic objectForKey:@"user_id"];
                    NSLog(@"User %@ is viewing, please try again later.", user_id);
                }
                    break;
                    
                default: {
                    NSLog(@"Login failed.");
                }
                    break;
            }
        });
    }
}

- (void)onMqttCtrlProcResult:(NSDictionary *)RetDic {
    if(RetDic && [RetDic[@"result"] isEqualToString:@"ok"]) {
        NSLog(@"MQTT 命令发送成功");
    } else {
        // errno = 9999 是设备还不支持这个命令
        NSLog(@"MQTT 命令发送失败. RetDic == %@", RetDic);
    }
}

#pragma mark - 设备主动通知APP
/// 设备主动通知用户的相关消息
/// @param dic 消息内容
/// @param DID 设备did
- (void)OnPushCmdRet:(NSDictionary *)dic DevId:(NSString *)DID {
    if (dic) {
        NSLog(@"设备主动通知用户的相关消息:%@",dic);
        NSInteger cmdId = [[dic objectForKey:@"CmdId"] intValue];
        switch (cmdId) {
            case xMP2P_MSG_FILE_RECEIVE_END: {
               //////(102)SD卡发送文件结束
            }
                break;
            case 29: {//xMP2P_MSG_MQTT_CTRL_RESULT 暂时是写死的 cmdId:29
                NSDictionary *payload = [dic objectForKey:@"payload"];
                if (payload && payload.count > 0) {
                    if ([[payload objectForKey:@"result"] isEqualToString:@"ok"]) {
                        NSInteger ctrl = [[payload objectForKey:@"ctrl"] integerValue];
                        if (ctrl == 1) {
                            
                            !self.XMMQTTConnectDevStateBlock ?: self.XMMQTTConnectDevStateBlock(YES);
                            [self.outTimer invalidate];
                            self.outTimer = nil;
                        } else {
                            NSLog(@"MQTT 退出登录成功");
                        }
                    } else {
                        !self.XMMQTTConnectDevStateBlock ?: self.XMMQTTConnectDevStateBlock(NO);
                        NSInteger errorCode = [[payload objectForKey:@"errno"] integerValue];
                        switch (errorCode) {
                            case 1011: {
                                NSLog(@"MQTT登录失败");
                            }
                                break;
                            case 1012: {
                                NSLog(@"MQTT登出失败");
                            }
                                break;
                            case 1013: {
                                NSLog(@"MQTT登出失败，有任务正在执行。");
                            }
                                break;
                                
                            default: {
                                NSLog(@"MQTT登录或者退出登录失败，原因未知。dic = %@", dic);
                            }
                                break;
                        }
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)NotifyGateWayNewVersionProcResult:(NSDictionary *)RetDic
{
    NSLog(@"是否收到模块响应通知模块升级");
    !_XMModuleUpgradeResponseBlock ?: _XMModuleUpgradeResponseBlock();
}

/// 当前连接的异常断开回调
/// @param ErrorNo 错误码
- (void)OnConnectfailed:(NSInteger)ErrorNo {
    if (ErrorNo == ERROR_PPCS_USER_CONNECT_BREAK) {// 主动断开
        return;
    }
    if (self.isCanReconnect) {// 断开重连
        self.canReconnect = false;
        dispatch_queue_t reconnectQueue = dispatch_queue_create("net.xmitech.reconnectQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, reconnectQueue, ^{
            [self.streamManager StopConnectDevice];
        });
        dispatch_group_notify(group, reconnectQueue, ^{
            [self connectDevice];
        });
    }
}

#pragma mark - init XMStreamComCtrl
/// 初始化p2p连接库
- (void)initXMStreamComCtrl {
    if (self.isInitStream) {
        return;
    }
    [self deinitXMStreamComCtrl];
    const char *str = [AERVICE_STRING cStringUsingEncoding:NSASCIIStringEncoding];
    [XMStreamComCtrl initAPI:(char *)str];
    self.initStream = true;
}
/// 释放p2p连接库
- (void)deinitXMStreamComCtrl {
    if (self.isInitStream) {
        [XMStreamComCtrl deinitAPI];
        self.initStream = false;
    }
}

#pragma mark --定时器的回调
///超时没有登录服务器
- (void)callOutTime:(NSTimer *)overTimer
{
    !_XMMQTTConnectDevOutTimeBlock ?: _XMMQTTConnectDevOutTimeBlock();
    [self.outTimer invalidate];
    self.outTimer = nil;
}

#pragma mark - lazy
- (XMStreamComCtrl *)streamManager {
    if (_streamManager == nil) {
        _streamManager = [XMStreamComCtrl new];
        self.streamManager.delegate = self;
    }
    return _streamManager;
}

@end

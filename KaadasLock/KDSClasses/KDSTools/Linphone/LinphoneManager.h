/* LinphoneManager.h
 *
 * Copyright (C) 2011  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <CoreTelephony/CTCallCenter.h>
#import <XMStreamComCtrl/GCDAsyncUdpSocket.h>

#import <sqlite3.h>

//#import "ProviderDelegate.h"
//#import "IASKSettingsReader.h"
//#import "IASKSettingsStore.h"
//#import "IASKAppSettingsViewController.h"
//#import "FastAddressBook.h"
//#import "InAppProductsManager.h"

#include "linphone/linphonecore.h"
#include "bctoolbox/list.h"

#define LINPHONE_LOGS_MAX_ENTRY 5000
#define IPAD (LinphoneManager.runningOnIpad)
#define LC ([LinphoneManager getLc])



extern NSString *const LINPHONERC_APPLICATION_KEY;

//linphone初始化状态刷新
extern NSString *const kLinphoneCoreUpdate;
extern NSString *const kLinphoneDisplayStatusUpdate;
extern NSString *const kLinphoneMessageReceived;
extern NSString *const kLinphoneTextComposeEvent;
//通话更新
extern NSString *const kLinphoneCallUpdate;
//登录注册状态更新
extern NSString *const kLinphoneRegistrationUpdate;
extern NSString *const kLinphoneMainViewChange;
extern NSString *const kLinphoneAddressBookUpdate;
extern NSString *const kLinphoneLogsUpdate;
extern NSString *const kLinphoneSettingsUpdate;
extern NSString *const kLinphoneBluetoothAvailabilityUpdate;
extern NSString *const kLinphoneConfiguringStateUpdate;
extern NSString *const kLinphoneGlobalStateUpdate;
extern NSString *const kLinphoneNotifyReceived;
extern NSString *const kLinphoneNotifyPresenceReceivedForUriOrTel;
extern NSString *const kLinphoneCallEncryptionChanged;
extern NSString *const kLinphoneFileTransferSendUpdate;
extern NSString *const kLinphoneFileTransferRecvUpdate;

///网络的枚举：2G、3G、4G、WIFI
typedef enum _NetworkType {
    network_none = 0,
    network_2g,
    network_3g,
    network_4g,
    network_lte,
    network_wifi
} NetworkType;
//网络的连接方式：WIFI、蜂窝、无
typedef enum _Connectivity {
    wifi,
    wwan,
    none
} Connectivity;

extern const int kLinphoneAudioVbrCodecDefaultBitrate;

/* Application specific call context */
typedef struct _CallContext {
    LinphoneCall* call;
    bool_t cameraIsEnabled;
} CallContext;

struct NetworkReachabilityContext {
    bool_t testWifi, testWWan;
    void (*networkStateChanged) (Connectivity newConnectivity);
};

@interface LinphoneCallAppData :NSObject {
@public
    bool_t batteryWarningShown;
    UILocalNotification *notification;
    NSMutableDictionary *userInfos;
    bool_t videoRequested; /*set when user has requested for video*/
    NSTimer* timer;
};
@end

typedef struct _LinphoneManagerSounds {
    SystemSoundID vibrate;
} LinphoneManagerSounds;

@interface LinphoneManager : NSObject <GCDAsyncUdpSocketDelegate>{
@protected
    SCNetworkReachabilityRef proxyReachability;
    
@private
    NSTimer* mIterateTimer;
    NSMutableArray*  pushCallIDs;
    Connectivity connectivity;
    UIBackgroundTaskIdentifier pausedCallBgTask;
    UIBackgroundTaskIdentifier incallBgTask;
    UIBackgroundTaskIdentifier pushBgTask;
    //实例化一个拨打电话的类
    CTCallCenter* mCallCenter;
    NSDate *mLastKeepAliveDate;
@public
    CallContext currentCallContextBeforeGoingBackground;
}
+ (LinphoneManager*)instance;

+ (LinphoneCore*) getLc;
+ (BOOL)runningOnIpad;
+ (NSString *)getPreferenceForCodec: (const char*) name withRate: (int) rate;
+ (BOOL)isCodecSupported: (const char*)codecName;
+ (NSSet *)unsupportedCodecs;
+ (int)unreadMessageCount;

- (void)resetLinphoneCore;
- (void)startLinphoneCore;
- (void)destroyLinphoneCore;
- (BOOL)resignActive;
- (void)becomeActive;
- (BOOL)enterBackgroundMode;
- (void)addPushCallId:(NSString*) callid;
- (void)configurePushTokenForProxyConfig: (LinphoneProxyConfig*)cfg;
- (BOOL)popPushCallID:(NSString*) callId;
- (void)acceptCallForCallId:(NSString*)callid;
- (LinphoneCall *)callByCallId:(NSString *)call_id;
- (void)cancelLocalNotifTimerForCallId:(NSString*)callid;
- (void)startPushLongRunningTask:(BOOL)msg;
+ (void)kickOffNetworkConnection;
- (void)setupNetworkReachabilityCallback;
- (void)refreshRegisters;

- (bool)allowSpeaker;
- (void)setLogsEnabled:(BOOL)enabled;
- (void)configureVbrCodecs;
+ (BOOL)copyFile:(NSString*)src destination:(NSString*)dst override:(BOOL)override;
+ (NSString*)bundleFile:(NSString*)file;
+ (NSString*)documentFile:(NSString*)file;
+ (NSString*)cacheDirectory;

+(BOOL)clearCacheWithFilePath:(NSString *)path;
+(NSString*)createDirectoryWithFileName:(NSString*)filename;
-(NSInteger)getNowTimestamp;


//+++++++++++++++++++++++++++++++
//当前linphone引擎是否启动
+ (BOOL)isLcReady;
//配置登录信息
- (void)addProxyConfig:(NSString*)username password:(NSString*)password displayName:(NSString *)displayName domain:(NSString*)domain port:(NSString *)port withTransport:(NSString*)transport;
//注销登录信息
- (void)removeAccount;
//获取当前通话
- (LinphoneCall *)currentCall;
/**获取通话时长*/
- (int)getCallDuration;
//挂断电话
- (void)hangUpCall;
//通过一个字符串生成LinphoneAddress
- (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)value andNickName:(NSString *)NickName;
- (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)addr;

//接电话
- (void)acceptCall:(LinphoneCall *)call evenWithVideo:(BOOL)video;
//打电话(包含一些逻辑判断，最终还是调用的doCall：)
- (void)call:(const LinphoneAddress *)address showVideo:(BOOL)video;
//打电话
- (BOOL)doCall:(const LinphoneAddress *)iaddr;
//拨打电话（是否开启视频）
- (void)callPhoneWithPhoneNumber:(NSString *)phone wihtVideo:(BOOL)video;
/**关闭视频,保持通话*/
- (void)closeVideoOnly;
/**打开视频*/
- (void)openVideo;
/**关闭话筒 Yes：关闭，NO：打开*/
- (void)closeOrOnSpeak:(BOOL )close;
/**设置外音开启关闭，Yes：开启，No：关闭*/
- (void)setVoiceEnabled:(BOOL)enable;
//+++++++++++++++++++++++++++++++

//- (void)acceptCall:(LinphoneCall *)call evenWithVideo:(BOOL)video;
- (void)call:(const LinphoneAddress *)address;
//- (BOOL)doCall:(const LinphoneAddress *)iaddr;

+(id)getMessageAppDataForKey:(NSString*)key inMessage:(LinphoneChatMessage*)msg;
+(void)setValueInMessageAppData:(id)value forKey:(NSString*)key inMessage:(LinphoneChatMessage*)msg;

- (void)lpConfigSetString:(NSString*)value forKey:(NSString*)key;
- (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section;
- (NSString *)lpConfigStringForKey:(NSString *)key;
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section;
- (NSString *)lpConfigStringForKey:(NSString *)key withDefault:(NSString *)value;
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section withDefault:(NSString *)value;

- (void)lpConfigSetInt:(int)value forKey:(NSString *)key;
- (void)lpConfigSetInt:(int)value forKey:(NSString *)key inSection:(NSString *)section;
- (int)lpConfigIntForKey:(NSString *)key;
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section;
- (int)lpConfigIntForKey:(NSString *)key withDefault:(int)value;
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section withDefault:(int)value;

- (void)lpConfigSetBool:(BOOL)value forKey:(NSString*)key;
- (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key inSection:(NSString *)section;
- (BOOL)lpConfigBoolForKey:(NSString *)key;
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section;
- (BOOL)lpConfigBoolForKey:(NSString *)key withDefault:(BOOL)value;
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section withDefault:(BOOL)value;

- (void)silentPushFailed:(NSTimer*)timer;

- (void)removeAllAccounts;
- (void)clearProxyConfig;
-(void)setSipAcountStatus:(BOOL)isOnline;
+ (BOOL)isMyself:(const LinphoneAddress *)addr;
//- (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)addr;


//- (void)setProviderDelegate:(ProviderDelegate *)del;

@property (readonly) BOOL isTesting;
//@property(readonly, strong) FastAddressBook *fastAddressBook;
@property Connectivity connectivity;
@property (readonly) NetworkType network;
@property (readonly) const char*  frontCamId;
@property (readonly) const char*  backCamId;
@property(strong, nonatomic) NSString *SSID;
@property (readonly) sqlite3* database;
@property(nonatomic, strong) NSData *pushNotificationToken;
@property (readonly) LinphoneManagerSounds sounds;
@property (readonly) NSMutableArray *logs;
@property (nonatomic, assign) BOOL speakerEnabled;
@property (nonatomic, assign) BOOL bluetoothAvailable;
@property (nonatomic, assign) BOOL bluetoothEnabled;
@property (readonly) ALAssetsLibrary *photoLibrary;
@property (readonly) NSString* contactSipField;
@property (readonly,copy) NSString* contactFilter;
@property (copy) void (^silentPushCompletion)(UIBackgroundFetchResult);
@property (readonly) BOOL wasRemoteProvisioned;
@property (readonly) LpConfig *configDb;
@property(strong, nonatomic) NSTimer *reciveRingTime;
@property(strong, nonatomic) NSMutableArray *fileTransferDelegates;
@property BOOL nextCallIsTransfer;
@property BOOL conf;
//
@property (nonatomic, assign) BOOL SIPAcountLoginSuccess;
///从VoIP Push过来的标志位
@property BOOL hasPushkit;
@property NSDictionary *pushDict;
@property (strong,nonatomic)GCDAsyncUdpSocket *udpSocket;
- (void)sendMsg:(NSString *)msg;
-(void)sendInfoMessage;
@end

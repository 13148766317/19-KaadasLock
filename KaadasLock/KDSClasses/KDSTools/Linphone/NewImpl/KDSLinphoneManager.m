//
//  KDSLinphoneManager.m
//  KaadasLock
//
//  Created by orange on 2019/7/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSLinphoneManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "linphone/linphonecore_utils.h"
#import "SIPUACTU.h"
#import "KDSLpAssistant.h"
#import "AudioHelper.h"
#import "KDSLpUIHelper.h"


#define kLinphoneInternalChatDBFilename @"linphone_chats.db"

#define kLinphoneAudioVbrCodecDefaultBitrate 36 /*you can override this from linphonerc or linphonerc-factory*/
#define kMTU 1400 //!<The maximum transmission unit for RTP.

extern void libmsamr_init(MSFactory *factory);
extern void libmsx264_init(MSFactory *factory);
extern void libmsopenh264_init(MSFactory *factory);
extern void libmssilk_init(MSFactory *factory);
extern void libmswebrtc_init(MSFactory *factory);
extern void libmscodec2_init(MSFactory *factory);

#define FRONT_CAM_NAME                                                                                                 \
"AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:1" /*"AV Capture: Front Camera"*/
#define BACK_CAM_NAME                                                                                                  \
"AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:0" /*"AV Capture: Back Camera"*/

#define kNewVer 0 ///<基于版本字符串"3.12.0-3396-g12a3c99eb"(版本号4.2)的linphone官方版本。

@interface KDSLinphoneManager ()

///linphone core全局配置。
@property (readonly, assign) LinphoneConfig *configDb;
///linphone core
@property (nonatomic, assign) LinphoneCore* lpCore;
///迭代linphone事件等的定时器。
@property (nonatomic, strong) NSTimer *iterateTimer;
///记录注册的账户名，自动刷新注册时使用。
@property (nonatomic, strong) NSString *account;
///处理来电的事务用户，每收到一个来电或发出一个邀请就创建一个事务用户，每释放一个就删除一个事务用户。key: call id, value: tu.
@property (nonatomic, strong) NSMutableDictionary<NSString *, SIPUACTU *> *tus;
///call center. use for c function.
@property (nonatomic, strong) CTCallCenter *callCenter;
///ui helper, handle multiple calls.
@property (nonatomic, strong) KDSLpUIHelper *uiHelper;
///discriminate external or internal of cleaning registration. if external, this property is YES, default NO.
@property (nonatomic, assign) BOOL cleanRegActive;

@end

@implementation KDSLinphoneManager

+ (instancetype)sharedManager
{
    static KDSLinphoneManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        _manager.tus = [NSMutableDictionary dictionary];
        _manager.cleanRegActive = NO;
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    });
    return _manager;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
        
        
        [self copyDefaultSettings];
        [self overrideDefaultSettings];
        
        // set default values for first boot
        if ([KDSLpAssistant lpConfigStringForKey:@"debugenable_preference" inConfig:self.configDb] == nil) {
#ifdef DEBUG
            [KDSLpAssistant lpConfigSetInt:1 forKey:@"debugenable_preference" forConfig:self.configDb];
#else
            [KDSLpAssistant lpConfigSetInt:0 forKey:@"debugenable_preference" forConfig:self.configDb];
#endif
        }
        
        // by default if handle_content_encoding is not set, we use plain text for debug purposes only
        if ([KDSLpAssistant lpConfigStringForKey:@"handle_content_encoding" inSection:@"misc" inConfig:self.configDb] == nil) {
#ifdef DEBUG
            [KDSLpAssistant lpConfigSetString:@"none" forKey:@"handle_content_encoding" inSection:@"misc" forConfig:self.configDb];
#else
            [KDSLpAssistant lpConfigSetString:@"conflate" forKey:@"handle_content_encoding" inSection:@"misc" forConfig:self.configDb];
#endif
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.lpCore)
    {
        [self terminateAllCalls];
        linphone_core_unref(self.lpCore);
        self.lpCore = NULL;
    }
}

- (CTCallCenter *)callCenter
{
    if (!_callCenter)
    {
        _callCenter = [[CTCallCenter alloc] init];
    }
    return _callCenter;
}

- (KDSLpUIHelper *)uiHelper
{
    if (_uiHelper == nil)
    {
        _uiHelper = [[KDSLpUIHelper alloc] init];
    }
    return _uiHelper;
}

#pragma mark  通知相关方法。
///进入后台。
- (void)appDidEnterBackground:(NSNotification *)noti
{
    [self enterBackgroundMode];
}

///激活。
- (void)appDidBecomeActive:(NSNotification *)noti
{
    if (self.lpCore == NULL) return;
    linphone_core_start_dtmf_stream(self.lpCore);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){}];
    [self internalStartRegister];
}

///网络状态改变的通知。
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].isReachable;
    if (isReachable)
    {
        [self refreshRegisters];
    }
    if (self.lpCore)
    {
        linphone_core_set_network_reachable(self.lpCore, isReachable);
    }
}

///for some reasons(for example, a phone call is coming) an audio interruption occurs.
- (void)audioSessionInterrupted:(NSNotification *)notification {
    int interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self terminateAllCalls];
    }
}

///system's audio route changes.
- (void)audioRouteChangeListenerCallback:(NSNotification *)notif
{
    if (KDSLpAssistant.isPad)
        return;
    
    // there is at least one bug when you disconnect an audio bluetooth headset
    // since we only get notification of route having changed, we cannot tell if that is due to:
    // -bluetooth headset disconnected or
    // -user wanted to use earpiece
    // the only thing we can assume is that when we lost a device, it must be a bluetooth one (strong hypothesis though)
    AVAudioSessionRouteDescription *newRoute = [AVAudioSession sharedInstance].currentRoute;
    if (newRoute && newRoute.outputs.count > 0) {
        NSString *route = newRoute.outputs[0].portType;
        _speakerEnabled = [route isEqualToString:AVAudioSessionPortBuiltInSpeaker];
        if (([[AudioHelper bluetoothRoutes] containsObject:route]) && !_speakerEnabled) {
            
        }
    }
}

#pragma mark - 内部功能接口
///注册。
- (BOOL)internalStartRegister
{
    KDSUser *user = [KDSUserManager sharedManager].user;
    if (user.token.length == 0 || user.uid.length == 0 || self.cleanRegActive) return NO;
    if (self.lpCore == NULL)
    {
        [self startLinphoneCore];
    }
    if ([self.account isEqualToString:user.uid])
    {
        [self refreshRegisters];
        return YES;
    }
    const bctbx_list_t* list = linphone_core_get_proxy_config_list(self.lpCore);
    while (list && list->data) {
        LinphoneProxyConfig* cfg = list->data;
        const LinphoneAddress* address = linphone_proxy_config_get_identity_address(cfg);
        const char* username = linphone_address_get_username(address);
        if (username != NULL && strcmp(username, user.uid.UTF8String) == 0)
        {
            [self refreshRegisters];
            return YES;
        }
        list = list->next;
    }//切换环境时，先注释这里清空注册环境。
    [self internalClearRegister];
    LinphoneProxyConfig* cfg = linphone_core_create_proxy_config(self.lpCore);
    const char* domain = [[[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigSipServer] UTF8String];
    const char *identity = [[NSString stringWithFormat:@"sip:%@@%s", user.uid, domain] cStringUsingEncoding:NSUTF8StringEncoding];
    LinphoneAddress* address = linphone_address_new(identity);
    linphone_address_set_username(address, user.uid.UTF8String);
    NSString *server_address = [NSString stringWithFormat:@"%s:5061;transport=udp", domain];
    linphone_proxy_config_set_server_addr(cfg, [server_address UTF8String]);
    linphone_address_set_domain(address, domain);
    linphone_proxy_config_set_identity_address(cfg, address);
    LinphoneAuthInfo *info = linphone_auth_info_new(linphone_address_get_username(address), // username
                                                    NULL,                                // user id
                                                    "123456",                        // passwd
                                                    NULL,                                // ha1
                                                    domain,   // realm - assumed to be domain
                                                    domain    // domain
                                                    );
    linphone_core_add_auth_info(self.lpCore, info);
    linphone_auth_info_unref(info);
    linphone_address_unref(address);
    
    if (cfg) {
        if (linphone_core_add_proxy_config(self.lpCore, cfg) != -1) {
            linphone_core_set_default_proxy_config(self.lpCore, cfg);
            self.account = user.uid;
        }
    }
    
    return YES;
}

///清除注册信息。
- (void)internalClearRegister
{
    if (!self.lpCore) return;
    [self terminateAllCalls];
    self.account = nil;
    linphone_core_clear_proxy_config(self.lpCore);
    linphone_core_clear_all_auth_info(self.lpCore);
}

///创建linphone core实例，并初始化一些其它设置。
- (void)startLinphoneCore
{
    if (self.lpCore != NULL) return;
    
    signal(SIGPIPE, SIG_IGN);
    
    // create linphone core
    [self createLinphoneCore];
    // - Security fix - remove multi transport migration, because it enables tcp or udp, if by factoring settings only
    // tls is enabled.     This is a problem for new installations.
    // linphone_core_migrate_to_multi_transport(self.lpCore);
    
    // init audio session (just getting the instance will init)
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // go directly to bg mode
        [self enterBackgroundMode];
    }
}

///创建linphone core实例。包括创建实例、设置回调、启动ms库相关功能等。
- (void)createLinphoneCore
{
    //[self migrationAllPre];
    if (self.lpCore != NULL) return;
    
    LinphoneFactory *factory = linphone_factory_get();
    LinphoneCoreCbs *cbs = linphone_factory_create_core_cbs(factory);
#if defined(kNewVer) && kNewVer == 1
    self.lpCore = linphone_factory_create_core_with_config_3(factory, _configDb, NULL);
    linphone_core_add_callbacks(self.lpCore, cbs);
    linphone_core_start(self.lpCore);
#else
    self.lpCore = linphone_factory_create_core_with_config_2(factory, cbs, _configDb, NULL, NULL);
    linphone_core_iterate(self.lpCore);
#endif
    linphone_core_set_mtu(self.lpCore, kMTU);
    //linphone_core_set_max_calls(self.lpCore, 1);
    linphone_core_set_network_reachable(self.lpCore, [AFNetworkReachabilityManager sharedManager].isReachable);
    // Let the core handle cbs
    linphone_core_set_network_reachable(self.lpCore, [AFNetworkReachabilityManager sharedManager].isReachable);
    linphone_core_cbs_set_call_state_changed(cbs, linphone_call_state_changed);
    linphone_core_cbs_set_registration_state_changed(cbs,linphone_core_registration_state_changed);
    linphone_core_cbs_set_authentication_requested(cbs, linphone_core_need_auth_info);
    linphone_core_cbs_set_configuring_status(cbs, linphone_core_configuring_status_changed);
    linphone_core_cbs_set_global_state_changed(cbs, linphone_core_global_state_changed);
    linphone_core_cbs_set_call_encryption_changed(cbs, linphone_call_encryption_changed);
    linphone_core_cbs_set_user_data(cbs, (__bridge void *)(self));
    linphone_core_cbs_unref(cbs);
    // Load plugins if available in the linphone SDK - otherwise these calls will do nothing
    MSFactory *f = linphone_core_get_ms_factory(self.lpCore);
    libmssilk_init(f);
    libmsamr_init(f);
    libmsx264_init(f);
    libmsopenh264_init(f);
    libmswebrtc_init(f);
    libmscodec2_init(f);
    
    linphone_core_reload_ms_plugins(self.lpCore, NULL);
    //[self migrationAllPost];
    
    /* Use the rootca from framework, which is already set*/
    //linphone_core_set_root_ca(theLinphoneCore, [LinphoneManager bundleFile:@"rootca.pem"].UTF8String);
    
    /* The core will call the linphone_core_configuring_status_changed callback when the remote provisioning is loaded
     (or skipped).
     Wait for this to finish the code configuration */
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(audioSessionInterrupted:)
                                               name:AVAudioSessionInterruptionNotification
                                             object:nil];
    /*call iterate once immediately in order to initiate background connections with sip server or remote provisioning
     * grab, if any */
    [self iterate];
    // start scheduler
    self.iterateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(iterate) userInfo:nil repeats:YES];
    Class cls = SIPUACTU.class;
    if ([cls respondsToSelector:@selector(linphoneCoreDidCreate:)]) [cls linphoneCoreDidCreate:self.lpCore];
}

///销毁linphone核心。这个函数副作用多，慎用。
- (void)destroyLinphoneCore
{
    if (self.lpCore == NULL) return;
    [self.iterateTimer invalidate];
    self.iterateTimer = nil;
    [self terminateAllCalls];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    SEL sel = @selector(linphoneCoreDidDestory:);
    Class cls = SIPUACTU.class;
    if ([cls respondsToSelector:sel]) [cls linphoneCoreDidDestory:self.lpCore];
    const LinphoneCoreCbs* cbs = linphone_core_get_current_callbacks(self.lpCore);
    linphone_core_remove_callbacks(self.lpCore, cbs);
    linphone_core_unref(self.lpCore);
    self.lpCore = NULL;
}

///重设linphone核心，先销毁再重建。这个函数副作用多，慎用。
- (void)resetLinphoneCore
{
    [self destroyLinphoneCore];
    [self startLinphoneCore];
}

///进入后台模式，停止dtmf功能，将不活跃的呼叫杀掉。
- (BOOL)enterBackgroundMode
{
    if (self.lpCore == NULL) return NO;
#if defined(kNewVer) && kNewVer == 1
    linphone_core_enter_background(self.lpCore);
#endif
    const bctbx_list_t* calls = linphone_core_get_calls(self.lpCore);
    while (calls && calls->data)
    {
        LinphoneCall* call = calls->data;
        LinphoneCallState state = linphone_call_get_state(call);
        if(state == LinphoneCallPausing || state == LinphoneCallPaused) linphone_call_terminate(call);
        calls = calls->next;
    }
    linphone_core_enable_video_preview(self.lpCore, FALSE);
    linphone_core_stop_dtmf_stream(self.lpCore);
    [self iterate];
    return YES;
}

///刷新注册用户。
- (void)refreshRegisters
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable && self.account && self.lpCore != NULL)
    {
        linphone_core_refresh_registers(self.lpCore);
    }
}

///迭代linphone事件。。。
- (void)iterate
{
    NSLog(@"--{Kaadas}--iterate1");
    if (self.lpCore == NULL) return;
    UIBackgroundTaskIdentifier coreIterateTaskId = 0;
    coreIterateTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:coreIterateTaskId];
    }];
    NSLog(@"--{Kaadas}--iterate2");
    linphone_core_iterate(self.lpCore);
    if (coreIterateTaskId != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:coreIterateTaskId];
    NSLog(@"--{Kaadas}--iterate3");
}

///挂断所有的电话。这里只处理特殊情况，挂断所有的电话。
- (void)terminateAllCalls
{
    if (self.lpCore == NULL) return;
    linphone_core_terminate_all_calls(self.lpCore);
}

- (bool)allowSpeaker {
    if (KDSLpAssistant.isPad)
        return true;
    
    bool allow = true;
    AVAudioSessionRouteDescription *newRoute = [AVAudioSession sharedInstance].currentRoute;
    if (newRoute && newRoute.outputs.count > 0) {
        NSString *route = newRoute.outputs[0].portType;
        allow = !([route isEqualToString:AVAudioSessionPortLineOut] ||
                  [route isEqualToString:AVAudioSessionPortHeadphones] ||
                  [[AudioHelper bluetoothRoutes] containsObject:route]);
    }
    return allow;
}

#pragma mark linphone全局配置创建、查询、修改等。
///将linphone默认配置写到文件/Library/Preferences/linphone/linphonerc中。第一次安装后就不会再改变默认配置了。
- (void)copyDefaultSettings {
    NSString *src = [KDSLpAssistant bundleFile:@"linphonerc"];
    NSString *srcIpad = [KDSLpAssistant bundleFile:@"linphonerc~ipad"];
    if ([KDSLpAssistant isPad] && srcIpad) src = srcIpad;
    NSString *dst = [KDSLpAssistant preferenceFile:@"linphonerc"];
    [KDSLpAssistant copyFile:src destination:dst override:FALSE];
}

///将自定义的配置覆盖linphone默认配置，然后创建linphone全局配置。只有先创建linphone全局配置后，才能成功创建linphone核心对象。
- (void)overrideDefaultSettings {
    NSString *factory = [KDSLpAssistant bundleFile:@"linphonerc-factory"];
    NSString *factoryIpad = [KDSLpAssistant bundleFile:@"linphonerc-factory~ipad"];
    if ([KDSLpAssistant isPad] && [[NSFileManager defaultManager] fileExistsAtPath:factoryIpad]) {
        factory = factoryIpad;
    }
    NSString *confiFileName = [KDSLpAssistant preferenceFile:@"linphonerc"];
    _configDb = lp_config_new_with_factory([confiFileName UTF8String], [factory UTF8String]);
}

#pragma mark - linphone的各类C回调
///linphone core全局状态更新，这个回调应该是反映LinphoneCore单例对象创建过程的。
static void linphone_core_global_state_changed(LinphoneCore *lc, LinphoneGlobalState gstate, const char *message)
{
    if (gstate == LinphoneGlobalOn)
    {
        //Force keep alive to workaround push notif on chat message
        linphone_core_enable_keep_alive(lc, true);
        // get default config from bundle
        NSString *zrtpSecretsFileName = [KDSLpAssistant dataFile:@"zrtp_secrets"];
        NSString *chatDBFileName = [KDSLpAssistant dataFile:kLinphoneInternalChatDBFilename];
        NSString *device = [NSString stringWithFormat:@"%@iOS/%@ (%@) LinphoneSDK",
                                            [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                            [[UIDevice currentDevice] name]];
        linphone_core_set_user_agent(lc, device.UTF8String, linphone_core_get_version());
        linphone_core_set_zrtp_secrets_file(lc, [zrtpSecretsFileName UTF8String]);
        linphone_core_set_call_logs_database_path(lc, [chatDBFileName UTF8String]);
        char **camlist = (char **)linphone_core_get_video_devices(lc);
        if (camlist) {
            for (char *cam = *camlist; *camlist != NULL; cam = *++camlist) {
                if (strcmp(FRONT_CAM_NAME, cam) == 0) {
                    linphone_core_set_video_device(lc, cam);
                }
                else if (strcmp(BACK_CAM_NAME, cam) == 0) {
                    //linphone_core_set_video_device(lc, cam);
                }
            }
        }
    }
}

///注册状态更新。
static void linphone_core_registration_state_changed(LinphoneCore *lc, LinphoneProxyConfig *cfg, LinphoneRegistrationState state, const char *message)
{
    if (state == LinphoneRegistrationFailed)//可以加次数限制。
    {
        KDSLinphoneManager *mgr = [KDSLinphoneManager sharedManager];
        [mgr internalClearRegister];
        [mgr internalStartRegister];
    }
}

///linphone core配置状态更新，这个应该是将apns的token传给sip服务器的。
static void linphone_core_configuring_status_changed(LinphoneCore *lc, LinphoneConfiguringState status, const char *message) {}

///验证信息无效，需要更新。
static void linphone_core_need_auth_info(LinphoneCore *lc, LinphoneAuthInfo *auth_info, LinphoneAuthMethod method)
{
    const char * realm = linphone_auth_info_get_realm(auth_info);
    const char * username = linphone_auth_info_get_username(auth_info);
    const char * domain = linphone_auth_info_get_domain(auth_info);
    LinphoneAuthInfo *info = linphone_auth_info_new(username, NULL, "123456", NULL, realm, domain);
    linphone_core_add_auth_info([KDSLinphoneManager sharedManager].lpCore, info);
    [[KDSLinphoneManager sharedManager] refreshRegisters];
}

///通话状态更新。
static void linphone_call_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state, const char *message)
{
    KDSLinphoneManager *manager = [KDSLinphoneManager sharedManager];
    LinphoneCallLog* log = linphone_call_get_call_log(call);
    const char* callID = log==NULL ? NULL : linphone_call_log_get_call_id(log);
    if (linphone_call_get_dir(call) == LinphoneCallOutgoing && state == LinphoneCallOutgoingInit)
    {
        return;
    }
    assert(callID != NULL);//The call id can't be null, considered use username instead.
    if (state == LinphoneCallIncomingReceived || state == LinphoneCallOutgoingProgress)
    {
        /*first step is to re-enable ctcall center*/
        if (manager.callCenter.currentCalls.count && state == LinphoneCallIncomingReceived)
        {
            linphone_call_decline(call, LinphoneReasonBusy);
            return;
        }
        SIPUACTU *tu = [[SIPUACTU alloc] initWithCall:call];
        manager.tus[@(callID)] = tu;
        const bctbx_list_t* list = linphone_core_get_calls(lc);
        if (bctbx_list_size(list) > 1 && state == LinphoneCallIncomingReceived)
        {
            manager.uiHelper.tus = manager.tus.allValues;
            return;
        }
    }
    SIPUACTU *tu = manager.tus[@(callID)];
    if ([tu respondsToSelector:@selector(linphoneCall:didUpdateState:withMessage:)])
    {
        [tu linphoneCall:call didUpdateState:state withMessage:message==NULL ? @"no message" : @(message)];
    }
    if (state == LinphoneCallReleased)
    {
        manager.tus[@(callID)] = nil;
    }
    manager.uiHelper.tus = manager.tus.allValues;
}

///通话加密，待研究。
static void linphone_call_encryption_changed(LinphoneCore *lc, LinphoneCall *call, bool_t on, const char *authentication_token) {}

#pragma mark - 对外功能接口
- (BOOL)startRegister
{
    self.cleanRegActive = NO;
    return [self internalStartRegister];
}

- (void)cleanRegister
{
    if (!self.lpCore) return;
    self.cleanRegActive = YES;
    [self internalClearRegister];
}

- (BOOL)setMicEnable:(BOOL)enabled
{
    if (self.lpCore == NULL) return NO;
    linphone_core_enable_mic(self.lpCore, enabled);
    return linphone_core_mic_enabled(self.lpCore);
}

- (void)setSpeakerEnabled:(BOOL)speakerEnabled
{
    if (self.lpCore == NULL) return;
    _speakerEnabled = speakerEnabled;
    NSError *err = nil;
    
    if (speakerEnabled && [self allowSpeaker]) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:FALSE];
    } else {
        AVAudioSessionPortDescription *builtinPort = [AudioHelper builtinAudioDevice];
        [[AVAudioSession sharedInstance] setPreferredInput:builtinPort error:&err];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:(linphone_core_get_calls_nb(self.lpCore) > 0)];
    }
}

- (void)call:(const LinphoneAddress *)iaddr showVideo:(BOOL)video
{
    BOOL isSas = NO;
    LinphoneAddress *addr = linphone_address_clone(iaddr);
    NSString *displayName = @(linphone_address_get_display_name(iaddr));
    
    // Finally we can make the call
    LinphoneCallParams *lcallParams = linphone_core_create_call_params(self.lpCore, NULL);
    linphone_call_params_enable_video(lcallParams, true);
    if ([KDSLpAssistant lpConfigBoolForKey:@"edge_opt_preference" inConfig:self.configDb] /*&& (self.network == network_2g)*/) {
        KDSLog(@"Enabling low bandwidth mode");
        linphone_call_params_enable_low_bandwidth(lcallParams, YES);
    }
    
    if (displayName != nil) {
        linphone_address_set_display_name(addr, displayName.UTF8String);
    }
    if ([KDSLpAssistant lpConfigBoolForKey:@"override_domain_with_default_one" inConfig:self.configDb]) {
        linphone_address_set_domain(
                                    addr, [[KDSLpAssistant lpConfigStringForKey:@"domain" inSection:@"assistant" inConfig:self.configDb] UTF8String]);
    }
    
    LinphoneCall *call = NULL;
    if (call/*LinphoneManager.instance.nextCallIsTransfer*/) {
        char *caddr = linphone_address_as_string(addr);
        call = linphone_core_get_current_call(self.lpCore);
         linphone_call_transfer(call, caddr);
        //self.nextCallIsTransfer = NO;
        ms_free(caddr);
    } else {
        //We set the record file name here because we can't do it after the call is started.
        NSString *writablePath = @"writablePath";
        linphone_call_params_set_record_file(lcallParams, [writablePath cStringUsingEncoding:NSUTF8StringEncoding]);
        if (isSas)
            linphone_call_params_set_media_encryption(lcallParams, LinphoneMediaEncryptionZRTP);
        call = linphone_core_invite_address_with_params(self.lpCore, addr, lcallParams);
    }
    linphone_address_destroy(addr);
    linphone_call_params_destroy(lcallParams);
}

@end

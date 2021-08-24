//
//  SIPUACTU.m
//  KaadasLock
//
//  Created by orange on 2019/7/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "SIPUACTU.h"
#import "KDSIncomingView.h"
#import "KDSCateyeCallVC.h"
#import "AFNetworkReachabilityManager.h"

@interface TUDelegateProxy : NSObject

- (instancetype)initWithTUDelegate:(id<TUDelegate>)delegate;

///the tu delegate.
@property (nonatomic, weak, readonly) id<TUDelegate> proxy;

@end
@implementation TUDelegateProxy

- (instancetype)initWithTUDelegate:(id<TUDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _proxy = delegate;
    }
    return self;
}

@end

@interface SIPUACTU ()

///the call.
@property (nonatomic, assign) LinphoneCall* call;
///incoming view.
@property (nonatomic, weak) KDSIncomingView *incomingView;
///TUDelegateProxy objects, for handling multi-delegate simultaneously and avoiding circular reference.
@property (nonatomic, strong) NSMutableArray<TUDelegateProxy *> *proxys;
///indicate whether there is a video update requesting.
@property (nonatomic, assign) BOOL videoUpdateRequesting;

@end

@implementation SIPUACTU

@dynamic speakerEnabled;

#pragma mark - 生命周期
- (instancetype)initWithCall:(LinphoneCall *)call
{
    self = [super init];
    if (self)
    {
        if (call)
        {
            self.call = linphone_call_ref(call);
            _date = NSDate.date;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.call)
    {
        linphone_call_unref(self.call);
        self.call = NULL;
    }
}

#pragma mark - getter setter
- (NSMutableArray<TUDelegateProxy *> *)proxys
{
    if (_proxys == nil)
    {
        _proxys = [NSMutableArray array];
    }
    return _proxys;
}

- (void)setDelegate:(id<TUDelegate>)delegate
{
    if (delegate == nil) return;
    for (TUDelegateProxy *proxy in self.proxys)
    {
        if (proxy.proxy == delegate) return;
    }
    TUDelegateProxy *proxy = [[TUDelegateProxy alloc] initWithTUDelegate:delegate];
    [self.proxys addObject:proxy];
}

- (LinphoneCallState)callState
{
    if (self.call == NULL) return LinphoneCallIdle;
    return linphone_call_get_state(self.call);
}

- (NSString *)callID
{
    if (self.call == NULL) return nil;
    const char* cid = linphone_call_log_get_call_id(linphone_call_get_call_log(self.call));
    return cid==NULL ? nil : @(cid);
}

- (NSString *)remoteUsername
{
    if (self.call == NULL) return nil;
    LinphoneCallLog* log = linphone_call_get_call_log(self.call);
    const LinphoneAddress* address = log==NULL ? NULL : linphone_call_log_get_remote_address(log);//direction
    const char* name = address==NULL ? NULL : linphone_address_get_username(address);
    return name==NULL ? nil : @(name);
}

#pragma mark - 通知
///网络状态改变的通知。
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    if (self.call == NULL || linphone_call_get_state(self.call) != LinphoneCallConnected) return;
    BOOL isReachableWifi = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
    if (isReachableWifi)
    {
        
    }
    else
    {
        
    }
}

///进入后台。
- (void)appDidEnterBackground:(NSNotification *)noti
{
    if (self.call == NULL) return;
    [self updateVideoState:NO];
}

///激活。
- (void)appDidBecomeActive:(NSNotification *)noti
{
    if (self.call == NULL) return;
    [self updateVideoState:YES];
}

#pragma mark - UI相关。
///根据对应的call显示来电页面。
- (void)showCallIncomingView:(LinphoneCall*)call enableSound:(BOOL)enabled
{
    self.incomingView = [KDSIncomingView show:enabled];
    self.incomingView.nickname = self.remoteUsername;
    __weak typeof(self) weakSelf = self;
    self.incomingView.userInteractiveAction = ^(BOOL accepted) {
        accepted ? [weakSelf acceptCall] : [weakSelf declineCall];
    };
}

///显示猫眼呼叫界面。
- (void)showCateyeCallViewController
{
    KDSCateyeCallVC *CallVC = [[KDSCateyeCallVC alloc] init];
    //CallVC.gatewayDeviceModel = cateye.gatewayDeviceModel;
    CallVC.hidesBottomBarWhenPushed = YES;
    CallVC.tu = self;
    CallVC.tu.delegate = CallVC;
    UIViewController * VC = [KDSTool currentViewController];
    [VC.navigationController pushViewController:CallVC animated:YES];
}

#pragma mark - KDSLinphoneDelegate
- (void)linphoneCall:(LinphoneCall *)call didUpdateState:(LinphoneCallState)state withMessage:(NSString *)msg
{
    [self updateVideoStateInCall:call state:state];
    SEL sel = nil;
    switch (state)
    {
        case LinphoneCallIncomingReceived:
            //[self showCallIncomingView:call enableSound:YES];//Now be replaced with KDSLpUIHelper.
            break;
            
        case LinphoneCallConnected:
            [self showCateyeCallViewController];
            sel = @selector(tuCallConnected:);
            break;
            
        case LinphoneCallStreamsRunning:
            sel = @selector(tuCallStreamRunning:);
            break;
            
        case LinphoneCallUpdatedByRemote:
            [self handleCallRemoteUpdate:call];
            break;
            
        case LinphoneCallPausedByRemote:
            sel = @selector(tuCallPausedByRemote:);
            break;
            
        case LinphoneCallPaused:
            sel = @selector(tuCallPaused:);
            break;
            
        case LinphoneCallError:
            [self handleCallError:call withMessage:msg];
            break;
            
        case LinphoneCallEnd:
            [self.incomingView hide];
            sel = @selector(tuCallEnd:);
            break;
            
        case LinphoneCallReleased:
            for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:@selector(tuCallRelease:)])
            {
                [proxy.proxy tuCallRelease:self];
            }
            if (self.call != NULL)
            {
                linphone_call_unref(self.call);
                self.call = NULL;
            }
            break;
        
        default:
            break;
    }
    if (sel)
    {
        for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:sel])
        {
            NSObject *obj = proxy.proxy;
            void (*imp)(id, SEL, id) = (void*)[obj methodForSelector:sel];
            imp(obj, sel, self);
        }
    }
}

#pragma mark - linphone接口的C回调。
///call did take a snapshot.
static void linphone_call_did_take_a_snapshot(LinphoneCall *call, const char *filepath)
{
    SIPUACTU *tu = (__bridge SIPUACTU *)linphone_call_get_user_data(call);
    for (TUDelegateProxy *proxy in [tu proxysForTUDelegateImpProtocolSEL:@selector(tu:snapshotDidFinish:)])
    {
        [proxy.proxy tu:tu snapshotDidFinish:@(filepath)];
    }
}

#pragma mark - linphone接电话等相关功能相关方法。
#pragma mark 内部功能接口。
///查找实现协议方法的代理。
- (nullable NSArray<TUDelegateProxy *> *)proxysForTUDelegateImpProtocolSEL:(SEL)sel
{
    if (sel == nil) return nil;
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.proxys.count; ++i)
    {
        TUDelegateProxy *proxy = self.proxys[i];
        if (proxy.proxy == nil)
        {
            [self.proxys removeObjectAtIndex:i];
            i--;
            continue;
        }
        if ([proxy.proxy respondsToSelector:sel])
        {
            [arr addObject:proxy];
        }
    }
    return arr.count ? arr : nil;
}

///当主动请求更新通话视频状态有结果后，执行协议方法，重置更新请求状态。
- (void)updateVideoStateInCall:(LinphoneCall*)call state:(LinphoneCallState)state
{
    if (!self.videoUpdateRequesting) return;
    //!linphone_core_sound_resources_locked(linphone_call_get_core(call))
    if (state == LinphoneCallStreamsRunning)
    {
        const LinphoneCallParams *current = linphone_call_get_current_params(call);
        const LinphoneCallParams *remote = linphone_call_get_remote_params(call);
        BOOL b1 = current != NULL ? linphone_call_params_video_enabled(current) : NO;
        BOOL b2 = remote != NULL ? linphone_call_params_video_enabled(remote) : NO;
        for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:@selector(tu:videoStateDidUpdate:)])
        {
            [proxy.proxy tu:self videoStateDidUpdate:b1 && b2];//can be only b1?
        }
        self.videoUpdateRequesting = NO;
    }
}

///处理会话出错。
- (void)handleCallError:(LinphoneCall*)call withMessage:(NSString *)msg
{
    const LinphoneErrorInfo* info = linphone_call_get_error_info(call);
    //const LinphoneErrorInfo* info = linphone_call_log_get_error_info(linphone_call_get_call_log(call));
    LinphoneReason reason = linphone_error_info_get_reason(info);
    const char* warning = linphone_error_info_get_warnings(info);
    const char* phrase = linphone_error_info_get_phrase(info);
    int code = linphone_error_info_get_protocol_code(info);
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    userInfo[@"LinphoneReason"] = @(reason);
    userInfo[@"SIPCode"] = @(code);
    userInfo[@"warning"] = warning==NULL ? nil : @(warning);
    userInfo[@"phrase"] = phrase==NULL ? nil : @(phrase);
    userInfo[@"message"] = msg;
    NSError *error = [NSError errorWithDomain:@"com.kaidishi.lock" code:code userInfo:userInfo];
    for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:@selector(tu:callError:)])
    {
        [proxy.proxy tu:self callError:error];
    }
}

///处理对方请求开/关视频。
- (void)handleCallRemoteUpdate:(LinphoneCall*)call
{
    LinphoneCore* core = linphone_call_get_core(call);
    const LinphoneCallParams *current = linphone_call_get_current_params(call);
    const LinphoneCallParams *remote = linphone_call_get_remote_params(call);
    BOOL b1 = linphone_call_params_video_enabled(current);
    BOOL b2 = linphone_call_params_video_enabled(remote);
    if (!((!b1 && b2) || (b1 && !b2))) return;
    if (linphone_core_video_display_enabled(core) && !b1 && b2)
    {
        linphone_call_defer_update(call);
    }
    NSArray<TUDelegateProxy *> *proxys = [self proxysForTUDelegateImpProtocolSEL:@selector(tu:callUpdateByRemote:handler:)];
    __weak typeof(self) weakSelf = self;
    void (^handler)(BOOL) = ^(BOOL allowed) {
        if (b1 || !b2 || weakSelf.call == NULL) return;
        LinphoneCallParams *params = linphone_core_create_call_params(core, call);
        linphone_call_params_enable_video(params, allowed);
        linphone_call_accept_update(call, params);
        linphone_call_params_unref(params);
    };
    void (^noeffect)(BOOL) = ^(BOOL allowed) {};
    if (proxys.count == 0)
    {
        handler(YES);
        return;
    }
    for (TUDelegateProxy *proxy in proxys)
    {
        [proxy.proxy tu:self callUpdateByRemote:!b1 && b2 handler:proxy==proxys.lastObject ? handler : noeffect];
    }
}

#pragma mark 对外接口。
- (void)acceptCall
{
    if (self.call == NULL) return;
    LinphoneCore* core = linphone_call_get_core(self.call);
    LinphoneCallParams *lcallParams = linphone_core_create_call_params(core, self.call);
    BOOL network2g = NO;
    if (network2g)
    {
        linphone_call_params_enable_low_bandwidth(lcallParams, true);
    }
    BOOL enable = YES;//[AFNetworkReachabilityManager sharedManager].isReachableViaWiFi
    linphone_call_params_enable_video(lcallParams, enable);
    //设置视频录制的保存路径
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *currentCallCateyeId = self.remoteUsername;
    NSString * pathDir1 = [pathDocuments stringByAppendingPathComponent:currentCallCateyeId];//将需要创建的串拼接到后面
    NSString * pathDir2 = [NSString stringWithFormat:@"%@%@",pathDir1,@"RePlayerFilePath"];
    ///var/mobile/Containers/Data/Application/xxxx/Documents/CH01183910014RePlayerFilePath/20190523
    //当天文件夹名
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString * pathDir3 = [pathDir2 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",dateStr]];
    NSError *error;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:pathDir3 isDirectory:&isDir];
    if (!existed) {
        [fileManager createDirectoryAtPath:pathDir3 withIntermediateDirectories:YES attributes:nil error:&error];
    }
    [KDSUserManager sharedManager].currentCallTimeStamp = [KDSTool getNowTimeTimestamp];
    [KDSUserManager sharedManager].currentCallRecordPath = pathDir3;
    NSString *videoSaveName = [NSString stringWithFormat:@"/%@.mkv",[KDSUserManager sharedManager].currentCallTimeStamp];
    NSString *videoSaveStr = [pathDir3 stringByAppendingPathComponent:videoSaveName];
    linphone_call_params_set_record_file(lcallParams,videoSaveStr.UTF8String);
    linphone_call_accept_with_params(self.call, lcallParams);
    linphone_call_params_unref(lcallParams);
}

- (BOOL)pauseCall
{
    if (self.call == NULL) return NO;
    linphone_call_pause(self.call);
    return YES;
}

- (BOOL)resumeCall
{
    if (self.call == NULL) return NO;
    linphone_call_resume(self.call);
    return YES;
}

- (void)declineCall
{
    if (self.call == NULL) return;
    LinphoneCallState state = linphone_call_get_state(self.call);
    if (state == LinphoneCallIncomingReceived)
    {
        linphone_call_decline(self.call, LinphoneReasonDeclined);
    }
    else
    {
        linphone_call_terminate(self.call);
    }
}

- (void)setVideoDisplayView:(UIView *)view
{
    if (self.call == NULL) return;
    linphone_core_set_native_video_window_id(linphone_call_get_core(self.call), (__bridge void*)view);
}

- (BOOL)updateVideoState:(BOOL)enable
{
    if (self.videoUpdateRequesting || self.call == NULL) return NO;
    self.videoUpdateRequesting = YES;
    SEL sel = @selector(tu:videoStateDidUpdate:);
    if (self.call == NULL || !linphone_core_video_display_enabled(linphone_call_get_core(self.call)))
    {
        for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:sel])
        {
            [proxy.proxy tu:self videoStateDidUpdate:NO];
        }
        return YES;
    }
    const LinphoneCallParams *current = linphone_call_get_current_params(self.call);
    const LinphoneCallParams *remote = linphone_call_get_remote_params(self.call);
    BOOL b1 = current != NULL ? linphone_call_params_video_enabled(current) : NO;
    BOOL b2 = remote != NULL ? linphone_call_params_video_enabled(remote) : NO;
    if (enable && b1 && b2)
    {
        for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:sel])
        {
            [proxy.proxy tu:self videoStateDidUpdate:YES];
        }
        return YES;
    }
    else if (!enable && (!b1 || !b2))
    {
        for (TUDelegateProxy *proxy in [self proxysForTUDelegateImpProtocolSEL:sel])
        {
            [proxy.proxy tu:self videoStateDidUpdate:NO];
        }
        return YES;
    }
    LinphoneCore* core = linphone_call_get_core(self.call);
    LinphoneCallParams *call_params = linphone_core_create_call_params(core, self.call);
    linphone_call_params_enable_video(call_params, enable);
    linphone_call_update(self.call, call_params);
    linphone_call_params_unref(call_params);
    return YES;
}

- (BOOL)setMicEnable:(BOOL)enabled
{
    if (self.call == NULL) return NO;
    return [[KDSLinphoneManager sharedManager] setMicEnable:enabled];
}

- (BOOL)speakerEnabled
{
    return self.call==NULL ? NO : [KDSLinphoneManager sharedManager].speakerEnabled;
}

- (void)setSpeakerEnabled:(BOOL)speakerEnabled
{
    if (self.call != NULL) [KDSLinphoneManager sharedManager].speakerEnabled = speakerEnabled;
}

- (BOOL)takeSnapshotToPath:(NSString *)path
{
    if (self.call == NULL || !path.length || ![[NSFileManager defaultManager] isWritableFileAtPath:[path stringByDeletingLastPathComponent]]) return NO;
    linphone_call_set_user_data(self.call, (__bridge void*)self);
    LinphoneFactory* factory = linphone_factory_get();
    LinphoneCallCbs* cbs = linphone_call_get_current_callbacks(self.call);
    if (cbs == NULL) cbs = linphone_factory_create_call_cbs(factory);
    else cbs = linphone_call_cbs_ref(cbs);
    linphone_call_cbs_set_snapshot_taken(cbs, linphone_call_did_take_a_snapshot);
    LinphoneStatus status = linphone_call_take_video_snapshot(self.call, path.UTF8String);
    linphone_call_cbs_unref(cbs);
    return status == 0;
}

- (BOOL)startRecording
{
    if (self.call == NULL) return NO;
    linphone_call_start_recording(self.call);
    return YES;
}

- (BOOL)stopRecording
{
    if (self.call == NULL) return NO;
    linphone_call_stop_recording(self.call);
    return YES;
}

- (BOOL)showIncomingView:(BOOL)enabled
{
    if (self.call == NULL) return NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showCallIncomingView:self.call enableSound:enabled];
    });
    return YES;
}

- (int)getCallDuration
{
    if (self.call == NULL) return -1;
    return linphone_call_get_duration(self.call);
}

@end


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
 *  Foundation, Inc., 5
 9 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/sysctl.h>
#import <asl.h>
#import <os/log.h>

#import <AVFoundation/AVFoundation.h>

#import <AVFoundation/AVCaptureDevice.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "LinphoneManager.h"
#import <CallKit/CallKit.h>

#include "linphone/linphonecore_utils.h"
#include "linphone/lpconfig.h"

#include "mediastreamer2/mscommon.h"
#import "KDSGWCateyeParam.h"
#import "logging.h"
//#import "Log.h"

//#import "Utils.h"
#import "KDSDBManager.h"
#import <UserNotifications/UserNotifications.h>
//#import "MainTool.h"

//#define SIPhostrelease          @"120.76.73.193"
//#define SIPhostrelease        @"sip-kaadas.juziwulian.com"
//#define SIPhostdebug          @"121.201.57.214"
#define SIPportrelease          @"5061"

static LinphoneCore *theLinphoneCore = nil;
static LinphoneManager *theLinphoneManager = nil;

NSString *const LINPHONERC_APPLICATION_KEY = @"app";

NSString *const kLinphoneCoreUpdate = @"LinphoneCoreUpdate";
NSString *const kLinphoneDisplayStatusUpdate = @"LinphoneDisplayStatusUpdate";
NSString *const kLinphoneMessageReceived = @"LinphoneMessageReceived";
NSString *const kLinphoneTextComposeEvent = @"LinphoneTextComposeStarted";
NSString *const kLinphoneCallUpdate = @"LinphoneCallUpdate";
NSString *const kLinphoneRegistrationUpdate = @"LinphoneRegistrationUpdate";
NSString *const kLinphoneAddressBookUpdate = @"LinphoneAddressBookUpdate";
NSString *const kLinphoneMainViewChange = @"LinphoneMainViewChange";
NSString *const kLinphoneLogsUpdate = @"LinphoneLogsUpdate";
NSString *const kLinphoneSettingsUpdate = @"LinphoneSettingsUpdate";
NSString *const kLinphoneBluetoothAvailabilityUpdate = @"LinphoneBluetoothAvailabilityUpdate";
NSString *const kLinphoneConfiguringStateUpdate = @"LinphoneConfiguringStateUpdate";
NSString *const kLinphoneGlobalStateUpdate = @"LinphoneGlobalStateUpdate";
NSString *const kLinphoneNotifyReceived = @"LinphoneNotifyReceived";
NSString *const kLinphoneNotifyPresenceReceivedForUriOrTel = @"LinphoneNotifyPresenceReceivedForUriOrTel";
NSString *const kLinphoneCallEncryptionChanged = @"LinphoneCallEncryptionChanged";
NSString *const kLinphoneFileTransferSendUpdate = @"LinphoneFileTransferSendUpdate";
NSString *const kLinphoneFileTransferRecvUpdate = @"LinphoneFileTransferRecvUpdate";

const int kLinphoneAudioVbrCodecDefaultBitrate = 36; /*you can override this from linphonerc or linphonerc-factory*/

extern void libmsamr_init(MSFactory *factory);
extern void libmsx264_init(MSFactory *factory);
extern void libmsopenh264_init(MSFactory *factory);
extern void libmssilk_init(MSFactory *factory);
extern void libmsbcg729_init(MSFactory *factory);
extern void libmswebrtc_init(MSFactory *factory);

#define FRONT_CAM_NAME                                                                                                 \
"AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:1" /*"AV Capture: Front Camera"*/
#define BACK_CAM_NAME                                                                                                  \
"AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:0" /*"AV Capture: Back Camera"*/

NSString *const kLinphoneOldChatDBFilename = @"chat_database.sqlite";
NSString *const kLinphoneInternalChatDBFilename = @"linphone_chats.db";

@implementation LinphoneCallAppData
- (id)init {
    if ((self = [super init])) {
        batteryWarningShown = FALSE;
        notification = nil;
        videoRequested = FALSE;
        userInfos = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

@end

@interface LinphoneManager ()

//@property ProviderDelegate *providerDelegate;

@end

@implementation LinphoneManager


@synthesize connectivity;

struct codec_name_pref_table {
    const char *name;
    int rate;
    const char *prefname;
};

struct codec_name_pref_table codec_pref_table[] = {{"speex", 8000, "speex_8k_preference"},
    {"speex", 16000, "speex_16k_preference"},
    {"silk", 24000, "silk_24k_preference"},
    {"silk", 16000, "silk_16k_preference"},
    {"amr", 8000, "amr_preference"},
    {"gsm", 8000, "gsm_preference"},
    {"ilbc", 8000, "ilbc_preference"},
    {"isac", 16000, "isac_preference"},
    {"pcmu", 8000, "pcmu_preference"},
    {"pcma", 8000, "pcma_preference"},
    {"g722", 8000, "g722_preference"},
    {"g729", 8000, "g729_preference"},
    {"mp4v-es", 90000, "mp4v-es_preference"},
    {"h264", 90000, "h264_preference"},
    {"vp8", 90000, "vp8_preference"},
    {"mpeg4-generic", 16000, "aaceld_16k_preference"},
    {"mpeg4-generic", 22050, "aaceld_22k_preference"},
    {"mpeg4-generic", 32000, "aaceld_32k_preference"},
    {"mpeg4-generic", 44100, "aaceld_44k_preference"},
    {"mpeg4-generic", 48000, "aaceld_48k_preference"},
    {"opus", 48000, "opus_preference"},
    {"BV16", 8000, "bv16_preference"},
    {NULL, 0, Nil}
};

+ (NSString *)getPreferenceForCodec:(const char *)name withRate:(int)rate {
    int i;
    for (i = 0; codec_pref_table[i].name != NULL; ++i) {
        if (strcasecmp(codec_pref_table[i].name, name) == 0 && codec_pref_table[i].rate == rate)
            return [NSString stringWithUTF8String:codec_pref_table[i].prefname];
    }
    return Nil;
}

+ (NSSet *)unsupportedCodecs {
    
    NSMutableSet *set = [NSMutableSet set];
    for (int i = 0; codec_pref_table[i].name != NULL; ++i) {
        LinphonePayloadType *available = linphone_core_get_payload_type(
                                                                        theLinphoneCore, codec_pref_table[i].name, codec_pref_table[i].rate, LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS);
        if ((available == NULL)
            // these two codecs should not be hidden, even if not supported
            && strcmp(codec_pref_table[i].prefname, "h264_preference") != 0 &&
            strcmp(codec_pref_table[i].prefname, "mp4v-es_preference") != 0) {
            [set addObject:[NSString stringWithUTF8String:codec_pref_table[i].prefname]];
        }
    }
    return set;
}
//设置米米网VPN返回的设备虚拟ip
//-(void)configSdpAttribute{
//    KDSLog(@"[DataManager sharedSingleton].device_ip==%@",[DataManager sharedSingleton].device_ip);
//    linphone_core_set_device_ip(theLinphoneCore,[[DataManager sharedSingleton].device_ip UTF8String]);
//}
+ (BOOL)isCodecSupported:(const char *)codecName {
    return (codecName != NULL) &&
    (NULL != linphone_core_get_payload_type(theLinphoneCore, codecName, LINPHONE_FIND_PAYLOAD_IGNORE_RATE,
                                            LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS));
}

+ (BOOL)runningOnIpad {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isRunningTests {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
+ (LinphoneManager *)instance {
    @synchronized(self) {
        if (theLinphoneManager == nil) {
            NSLog(@"{KAADAS}--创建LinphoneManager(instance)");
            theLinphoneManager = [[LinphoneManager alloc] init];
            LinphoneLoggingService *service = linphone_logging_service_get();
            linphone_logging_service_set_log_level(service, LinphoneLogLevelFatal);
        }
    }
    return theLinphoneManager;
}

#pragma mark - Lifecycle Functions

- (id)init {
    
    if ((self = [super init])) {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(audioRouteChangeListenerCallback:)
                                                   name:AVAudioSessionRouteChangeNotification
                                                 object:nil];
        
        _sounds.vibrate = kSystemSoundID_Vibrate;
        
        _logs = [[NSMutableArray alloc] init];
        _pushDict = [[NSMutableDictionary alloc] init];
        _database = NULL;
        _speakerEnabled = FALSE;
        _bluetoothEnabled = FALSE;
        _conf = FALSE;
        _fileTransferDelegates = [[NSMutableArray alloc] init];
        
        pushCallIDs = [[NSMutableArray alloc] init];
        _photoLibrary = [[ALAssetsLibrary alloc] init];
        _isTesting = [LinphoneManager isRunningTests];
        [self renameDefaultSettings];
        [self copyDefaultSettings];
        [self overrideDefaultSettings];
        
        // set default values for first boot
        if ([self lpConfigStringForKey:@"debugenable_preference"] == nil) {
#ifdef DEBUG
            [self lpConfigSetInt:1 forKey:@"debugenable_preference"];
#else
            [self lpConfigSetInt:0 forKey:@"debugenable_preference"];
#endif
        }
        
        // by default if handle_content_encoding is not set, we use plain text for debug purposes only
        if ([self lpConfigStringForKey:@"handle_content_encoding" inSection:@"misc"] == nil) {
#ifdef DEBUG
            [self lpConfigSetString:@"none" forKey:@"handle_content_encoding" inSection:@"misc"];
#else
            [self lpConfigSetString:@"conflate" forKey:@"handle_content_encoding" inSection:@"misc"];
#endif
        }
        
        [self migrateFromUserPrefs];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma deploymate push "ignored-api-availability"
//静默推送
- (void)silentPushFailed:(NSTimer *)timer {
    if (_silentPushCompletion) {
        KDSLog(@"silentPush failed, silentPushCompletion block: %p", _silentPushCompletion);
        _silentPushCompletion(UIBackgroundFetchResultNoData);
        _silentPushCompletion = nil;
    }
}
#pragma deploymate pop

#pragma mark - Migration
- (void)migrationAllPost {
    [self migrationLinphoneSettings];
    [self migratePushNotificationPerAccount];
}

- (void)migrationAllPre {
    // migrate xmlrpc URL if needed
    if ([self lpConfigBoolForKey:@"migration_xmlrpc"] == NO) {
        [self lpConfigSetString:@"https://subscribe.linphone.org:444/wizard.php"
                         forKey:@"xmlrpc_url"
                      inSection:@"assistant"];
        [self lpConfigSetString:@"sip:rls@sip.linphone.org" forKey:@"rls_uri" inSection:@"sip"];
        [self lpConfigSetBool:YES forKey:@"migration_xmlrpc"];
    }
    [self lpConfigSetBool:NO forKey:@"store_friends" inSection:@"misc"]; //so far, storing friends in files is not needed. may change in the future.
}
#pragma mark 检查是否转移图片
static int check_should_migrate_images(void *data, int argc, char **argv, char **cnames) {
    *((BOOL *)data) = TRUE;
    return 0;
}
#pragma mark 数据库移植
- (BOOL)migrateChatDBIfNeeded:(LinphoneCore *)lc {
    sqlite3 *newDb;
    char *errMsg;
    NSError *error;
    NSString *oldDbPath = [LinphoneManager documentFile:kLinphoneOldChatDBFilename];
    NSString *newDbPath = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
    BOOL shouldMigrate = [[NSFileManager defaultManager] fileExistsAtPath:oldDbPath];
    BOOL shouldMigrateImages = FALSE;
    const char *identity = NULL;
    BOOL migrated = FALSE;
    char *attach_stmt = NULL;
    LinphoneProxyConfig *default_proxy = linphone_core_get_default_proxy_config(lc);
    
    if (sqlite3_open([newDbPath UTF8String], &newDb) != SQLITE_OK) {
        KDSLog(@"Can't open \"%@\" sqlite3 database.", newDbPath);
        return FALSE;
    }
    
    const char *check_appdata =
    "SELECT url,message FROM history WHERE url LIKE 'assets-library%' OR message LIKE 'assets-library%' LIMIT 1;";
    // will set "needToMigrateImages to TRUE if a result comes by
    sqlite3_exec(newDb, check_appdata, check_should_migrate_images, &shouldMigrateImages, NULL);
    if (!shouldMigrate && !shouldMigrateImages) {
        sqlite3_close(newDb);
        return FALSE;
    }
    
    KDSLog(@"Starting migration procedure");
    
    if (shouldMigrate) {
        
        // attach old database to the new one:
        attach_stmt = sqlite3_mprintf("ATTACH DATABASE %Q AS oldchats", [oldDbPath UTF8String]);
        if (sqlite3_exec(newDb, attach_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            KDSLog(@"Can't attach old chat table, error[%s] ", errMsg);
            sqlite3_free(errMsg);
            goto exit_dbmigration;
        }
        
        // migrate old chats to the new db. The iOS stores timestamp in UTC already, so we can directly put it in the
        // 'utc' field and set 'time' to -1
        const char *migration_statement =
        "INSERT INTO history (localContact,remoteContact,direction,message,utc,read,status,time) "
        "SELECT localContact,remoteContact,direction,message,time,read,state,'-1' FROM oldchats.chat";
        
        if (sqlite3_exec(newDb, migration_statement, NULL, NULL, &errMsg) != SQLITE_OK) {
            KDSLog(@"DB migration failed, error[%s] ", errMsg);
            sqlite3_free(errMsg);
            goto exit_dbmigration;
        }
        
        // invert direction of old messages, because iOS was storing the direction flag incorrectly
        const char *invert_direction = "UPDATE history SET direction = NOT direction";
        if (sqlite3_exec(newDb, invert_direction, NULL, NULL, &errMsg) != SQLITE_OK) {
            KDSLog(@"Inverting direction failed, error[%s]", errMsg);
            sqlite3_free(errMsg);
            goto exit_dbmigration;
        }
        
        // replace empty from: or to: by the current identity.
        if (default_proxy) {
            identity = linphone_proxy_config_get_identity_address(default_proxy);
        }
        if (!identity) {
            identity = "sip:unknown@sip.linphone.org";
        }
        
        char *from_conversion =
        sqlite3_mprintf("UPDATE history SET localContact = %Q WHERE localContact = ''", identity);
        if (sqlite3_exec(newDb, from_conversion, NULL, NULL, &errMsg) != SQLITE_OK) {
            KDSLog(@"FROM conversion failed, error[%s] ", errMsg);
            sqlite3_free(errMsg);
        }
        sqlite3_free(from_conversion);
        
        char *to_conversion =
        sqlite3_mprintf("UPDATE history SET remoteContact = %Q WHERE remoteContact = ''", identity);
        if (sqlite3_exec(newDb, to_conversion, NULL, NULL, &errMsg) != SQLITE_OK) {
            KDSLog(@"DB migration failed, error[%s] ", errMsg);
            sqlite3_free(errMsg);
        }
        sqlite3_free(to_conversion);
    }
    
    // local image paths were stored in the 'message' field historically. They were
    // very temporarily stored in the 'url' field, and now we migrated them to a JSON-
    // encoded field. These are the migration steps to migrate them.
    
    // move already stored images from the messages to the appdata JSON field
    const char *assetslib_migration = "UPDATE history SET appdata='{\"localimage\":\"'||message||'\"}' , message='' "
    "WHERE message LIKE 'assets-library%'";
    if (sqlite3_exec(newDb, assetslib_migration, NULL, NULL, &errMsg) != SQLITE_OK) {
        KDSLog(@"Assets-history migration for MESSAGE failed, error[%s] ", errMsg);
        sqlite3_free(errMsg);
    }
    
    // move already stored images from the url to the appdata JSON field
    const char *assetslib_migration_fromurl =
    "UPDATE history SET appdata='{\"localimage\":\"'||url||'\"}' , url='' WHERE url LIKE 'assets-library%'";
    if (sqlite3_exec(newDb, assetslib_migration_fromurl, NULL, NULL, &errMsg) != SQLITE_OK) {
        KDSLog(@"Assets-history migration for URL failed, error[%s] ", errMsg);
        sqlite3_free(errMsg);
    }
    
    // We will lose received messages with remote url, they will be displayed in plain. We can't do much for them..
    migrated = TRUE;
    
exit_dbmigration:
    
    if (attach_stmt)
        sqlite3_free(attach_stmt);
    
    sqlite3_close(newDb);
    
    // in any case, we should remove the old chat db
    if (shouldMigrate && ![[NSFileManager defaultManager] removeItemAtPath:oldDbPath error:&error]) {
        KDSLog(@"Could not remove old chat DB: %@", error);
    }
    
    KDSLog(@"Message storage migration finished: success = %@", migrated ? @"TRUE" : @"FALSE");
    return migrated;
}
#pragma mark 转移linphone UserpRefs
- (void)migrateFromUserPrefs {
    static NSString *migration_flag = @"userpref_migration_done";
    
    if (_configDb == nil)
        return;
    
    if ([self lpConfigIntForKey:migration_flag withDefault:0]) {
        return;
    }
    
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSArray *defaults_keys = [defaults allKeys];
    NSDictionary *values =
    @{ @"backgroundmode_preference" : @YES,
       @"debugenable_preference" : @NO,
       @"start_at_boot_preference" : @YES };
    BOOL shouldSync = FALSE;
    
    KDSLog(@"%lu user prefs", (unsigned long)[defaults_keys count]);
    
    for (NSString *userpref in values) {
        if ([defaults_keys containsObject:userpref]) {
            KDSLog(@"Migrating %@ from user preferences: %d", userpref, [[defaults objectForKey:userpref] boolValue]);
            [self lpConfigSetBool:[[defaults objectForKey:userpref] boolValue] forKey:userpref];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:userpref];
            shouldSync = TRUE;
        } else if ([self lpConfigStringForKey:userpref] == nil) {
            // no default value found in our linphonerc, we need to add them
            [self lpConfigSetBool:[[values objectForKey:userpref] boolValue] forKey:userpref];
        }
    }
    
    if (shouldSync) {
        KDSLog(@"Synchronizing...");
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // don't get back here in the future
    [self lpConfigSetBool:YES forKey:migration_flag];
}
#pragma 对于登录/注册封装
- (void)addProxyConfig:(NSString*)username password:(NSString*)password displayName:(NSString *)displayName domain:(NSString*)domain port:(NSString *)port withTransport:(NSString*)transport {
    LinphoneCore* lc = [LinphoneManager getLc]; //初始化
    if (lc == nil) {
        [[LinphoneManager instance] startLinphoneCore];
//        NSLog(@"{KAADAS}--Linphone--登录/注册--LinphoneCore初始化");
        lc = [LinphoneManager getLc];
    }
    //设置来电超时
    linphone_core_set_inc_timeout(LC, 60);
    //创建代理配置表
    LinphoneProxyConfig *proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    //初始化电话号码
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, domain] cStringUsingEncoding:NSUTF8StringEncoding];//官网测试OK
    
    //    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, @"120.76.73.193"] cStringUsingEncoding:NSUTF8StringEncoding];//官网测试OK
    //    const char *identity = [@"sip:User name@IP:端口" cStringUsingEncoding:NSUTF8StringEncoding];
    //    const char* identity = linphone_proxy_config_get_identity(proxyCfg);
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    if (displayName && displayName.length != 0) {
        linphone_address_set_display_name(linphoneAddress, (displayName.length ? displayName.UTF8String : NULL));
    }
    if( domain && [domain length] != 0) {
        // if(!port) port = @"5060";
        if( transport != nil ){
            //第一个是原生的
            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, port, [transport lowercaseString]];
            //            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, @"端口", [transport lowercaseString]];
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    identity = linphone_address_as_string(linphoneAddress);
    linphone_address_destroy(linphoneAddress);
    //生成认证信息
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , linphone_proxy_config_get_realm(proxyCfg)
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    LinphoneManager* lm = [LinphoneManager instance];
    [lm configurePushTokenForProxyConfig:proxyCfg];
    //清空认证信息
    //    [self clearProxyConfig];
    //添加认证信息
    //    [[[LinphoneCoreSettingsStore alloc] init] synchronize];
    
    //    linphone_core_clear_all_auth_info(lc);
    linphone_proxy_config_set_identity(proxyCfg, identity);
    //设置sip账号在线时长 当等于0时马上移除sip账号在线状态，当等于7200时设置sip账号在线时长为7200s
//    KDSLog(@"---00---==online=====");
   
    const MSList *proxies = linphone_core_get_proxy_config_list(lc);
    int i = 0;
    while (proxies) {
//        NSLog(@"{KAADAS}--Linphone--proxies--登录/注册--%d",++i);

        proxies = proxies->next;
        
    }
    if ( i < 1 ) {
        linphone_proxy_config_set_expires(proxyCfg, 10);
//        NSLog(@"{KAADAS}--Linphone--登录/注册--linphone_proxy_config_set_expires--10");
        linphone_proxy_config_enable_register(proxyCfg, true);
       
        linphone_core_add_auth_info(lc, info);
        linphone_core_add_proxy_config(lc, proxyCfg);
//        NSLog(@"{KAADAS}--Linphone--登录/注册--linphone_core_add_proxy_config");
        linphone_core_set_default_proxy_config(lc, proxyCfg);
    }
    
    ms_free(identity);
    
    // 配置最大接入通话数(多人的话就在这里设置)
    linphone_core_set_max_calls(LC, 1);
    //设置视频分辨率
    [self setVideoesolution];
    
}

-(void)setSipAcountStatus:(BOOL)isOnline{
      NSLog(@"{KAADAS}--Linphone--setSipAcountStatus");
    NSString *domain = nil;

//    if (KDSEnvironment == 1) {
        domain = [[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigSipServer];
//    }else if (KDSEnvironment == 0){
//        domain = SIPhostdebug;
//    }
  
    NSString *displayName = nil;
    NSString *transport = @"UDP";
    NSString *port = SIPportrelease;
    NSString *password = @"123456";
    NSString *username = [[KDSDBManager sharedManager] queryUser].uid;
    
    LinphoneCore* lc = [LinphoneManager getLc]; //初始化
    //创建代理配置表
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    
    if (lc == nil) {
        [[LinphoneManager instance] startLinphoneCore];
        lc = [LinphoneManager getLc];
    }
    else{
        if ([LinphoneManager instance].hasPushkit) {
            //推送来的
//            linphone_proxy_config_set_expires(proxyCfg, 0);
//            NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_set_expires--0");
//            [LinphoneManager instance].hasPushkit = NO;
//            linphone_proxy_config_enable_register(proxyCfg, true);
//            linphone_core_add_auth_info(lc, info);
//            linphone_core_add_proxy_config(lc, proxyCfg);
//            linphone_core_set_default_proxy_config(lc, proxyCfg);
//            linphone_core_clear_proxy_config(lc);
//            NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_core_clear_proxy_config");
//            linphone_proxy_config_set_expires(proxyCfg, 0);
//            NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_set_expires--0");
//            [LinphoneManager instance].hasPushkit = NO;
        }
//        linphone_core_clear_proxy_config(lc);
//        NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_core_clear_proxy_config");
    }
    char normalizedUserName[256];
//    //创建代理配置表
//    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
//    linphone_proxy_config_normalize_phone_number(proxyCfg,[username cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, domain] cStringUsingEncoding:NSUTF8StringEncoding];//官网测试OK
    //    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, @"120.76.73.193"] cStringUsingEncoding:NSUTF8StringEncoding];//官网测试OK
    //        const char *identity = [@"sip:User name@IP:端口" cStringUsingEncoding:NSUTF8StringEncoding];
    //    const char* identity = linphone_proxy_config_get_identity(proxyCfg);
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    if (linphoneAddress == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[LinphoneManager instance] setSipAcountStatus:YES];//APP退出到后台后sip账号下线 这里保证推送过来时sip账号上线
        });
    }else{
        linphone_address_set_username(linphoneAddress, normalizedUserName);
    }
    if (displayName && displayName.length != 0) {
        linphone_address_set_display_name(linphoneAddress, (displayName.length ? displayName.UTF8String : NULL));
    }
    if( domain && [domain length] != 0) {
        // if(!port) port = @"5060";
        if( transport != nil ){
            //第一个是原生的
            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, port, [transport lowercaseString]];
            //server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, @"端口", [transport lowercaseString]];
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    identity = linphone_address_as_string(linphoneAddress);
    linphone_address_destroy(linphoneAddress);
    //生成认证信息
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , linphone_proxy_config_get_realm(proxyCfg)
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    LinphoneManager* lm = [LinphoneManager instance];
    [lm configurePushTokenForProxyConfig:proxyCfg];
    //清空认证信息
    //    [self clearProxyConfig];
    //添加认证信息
    //    [[[LinphoneCoreSettingsStore alloc] init] synchronize];
    
    //    linphone_core_clear_all_auth_info(lc);
    linphone_proxy_config_set_identity(proxyCfg, identity);
    //设置sip账号在线时长 当等于0时马上移除sip账号在线状态，当等于7200时设置sip账号在线时长为7200s
    if (isOnline) {
        KDSLog(@"---00---==online");
//        if (![LinphoneManager instance].hasPushkit) {
            //不是推送过来的
            const MSList *proxies = linphone_core_get_proxy_config_list(lc);
            int i = 0;
            while (proxies) {
//                LinphoneProxyConfig *ProxyConfig  = proxies->data;
//
//                NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_get_state==%d", linphone_proxy_config_get_state(ProxyConfig));
//                NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_get_expires==%d",linphone_proxy_config_get_expires(ProxyConfig));
//                NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_register_enabled==%d",linphone_proxy_config_register_enabled(ProxyConfig));
//
//                linphone_proxy_config_set_expires(ProxyConfig, 10);

//                NSLog(@"{KAADAS}--Linphone--proxies--setSipAcountStatus--%d",++i);
                proxies = proxies->next;
                
            }
      
        if ( i < 1 ) {
            linphone_proxy_config_set_expires(proxyCfg, 10);
//            NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_set_expires--10");
            linphone_proxy_config_enable_register(proxyCfg, true);
            if (lc == nil) {
//                NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--LinphoneCore--nil");

                [[LinphoneManager instance] startLinphoneCore];
                lc = [LinphoneManager getLc];
                return;
            }
            linphone_core_add_auth_info(lc, info);
            linphone_core_add_proxy_config(lc, proxyCfg);
//            NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_core_add_proxy_config");
            linphone_core_set_default_proxy_config(lc, proxyCfg);
        }
    }else{
//        KDSLog(@"---00---==offline");
//        linphone_proxy_config_set_expires(proxyCfg, 0);
//        NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_proxy_config_set_expires--0");

    }
//    if (![LinphoneManager instance].hasPushkit) {
//        不是推送过来的
//        linphone_proxy_config_enable_register(proxyCfg, true);
//        linphone_core_add_auth_info(lc, info);
//        linphone_core_add_proxy_config(lc, proxyCfg);
//        NSLog(@"{KAADAS}--Linphone--setSipAcountStatus--linphone_core_add_proxy_config");
//        linphone_core_set_default_proxy_config(lc, proxyCfg);
//        const MSList *proxies = linphone_core_get_proxy_config_list(lc);
//        int i = 0;
//        while (proxies) {
//            NSLog(@"{KAADAS}--Linphone--proxies--setSipAcountStatus--%d",++i);
//            proxies = proxies->next;
//        }
//    }
    if (!isOnline) {
        //清空认证信息(以解决退到后台时，sip呼叫接听没音视频的问题)
        [self clearProxyConfig];
    }
}
-(void)sendInfoMessage{
    LinphoneInfoMessage *info;
    LinphoneContent *content;
    info = linphone_core_create_info_message(theLinphoneCore);
    content = linphone_core_create_content(theLinphoneCore);
    const char * iOSsipsState = "iOSsipsState";
    const char * online = "online";
    linphone_info_message_add_header(info,iOSsipsState,online);
    linphone_info_message_set_content(info,content );
    linphone_call_send_info_message([self currentCall],info);
    linphone_info_message_unref(info);
}
- (void)clearProxyConfig {
//    NSLog(@"{KAADAS}--Linphone--clearProxyConfig--linphone_core_clear_proxy_config");
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
//    NSLog(@"{KAADAS}--Linphone--clearProxyConfig--linphone_core_clear_all_auth_info");
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}
#pragma mark - 注销登陆信息
- (void)removeAccount {
    
    if (theLinphoneCore != nil) {
//        NSLog(@"{KAADAS}--Linphone--removeAccount--注销登陆信息");

        [self clearProxyConfig];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"pushnotification_preference"];
        LinphoneCore *lc = [LinphoneManager getLc];
        LCSipTransports transportValue={5060,5060,-1,-1};
        if (linphone_core_set_sip_transports(lc, &transportValue)) {
            
        }
        [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"sharing_server_preference"];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"ice_preference"];
        [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"stun_preference"];
        linphone_core_set_stun_server(lc, NULL);
        linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
        
    }
}
#pragma mark 获取当前会话
- (LinphoneCall *)currentCall {
//    NSLog(@"{KAADAS}--Linphone获取当前会话(linphone_core_get_current_call)");
    if (!LC) {
        return nil;
    }
    return linphone_core_get_current_call(LC) ? linphone_core_get_current_call(LC) : nil;
}
#pragma mark 获取通话时长
- (int)getCallDuration {
    if (LC == nil) {
        return 0;
    }
    int duration =
    linphone_core_get_current_call(LC) ? linphone_call_get_duration(linphone_core_get_current_call(LC)) : 0;
    return duration;
}
/**将int转为标准格式的NSString时间*/
+ (NSString *)durationToString:(int)duration {
    NSMutableString *result = [[NSMutableString alloc] init];
    if (duration / 3600 > 0) {
        [result appendString:[NSString stringWithFormat:@"%02i:", duration / 3600]];
        duration = duration % 3600;
    }
    return [result stringByAppendingString:[NSString stringWithFormat:@"%02i:%02i", (duration / 60), (duration % 60)]];
}
#pragma mark 挂断电话
- (void)hangUpCall {
    KDSLog(@"memenet------------------------hangUpCall (LinphoneManager)");
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* currentcall = linphone_core_get_current_call(lc);
    if (linphone_core_is_in_conference(lc) || // In conference
        (linphone_core_get_conference_size(lc) > 0) // Only one conf
        ) {
        linphone_core_terminate_conference(lc);
    } else if(currentcall != NULL) { // In a call
        linphone_core_terminate_call(lc, currentcall);
    } else {
        const MSList* calls = linphone_core_get_calls(lc);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }
}
#pragma mark  通过一个字符串生成LinphoneAddress
- (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)value andNickName:(NSString *)NickName{
    if (!value) {
        return NULL;
    }
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
    const char * normvalue;
    if (linphone_proxy_config_is_phone_number(cfg, value.UTF8String)) {
        normvalue = linphone_proxy_config_normalize_phone_number(cfg, value.UTF8String);
    } else {
        normvalue = value.UTF8String;
    }
    LinphoneAddress *addr = linphone_proxy_config_normalize_sip_uri(cfg, normvalue);
    
    // since user wants to escape plus, we assume it expects to have phone numbers by default
    if (addr && cfg && (linphone_proxy_config_get_dial_escape_plus(cfg))) {
        linphone_address_set_username(addr, normvalue);
    } else {
        linphone_address_set_username(addr, value.UTF8String);
    }
    
    if (NickName) {
        linphone_address_set_display_name(addr, NickName.UTF8String);
    }
    
    return addr;
}
#pragma mark -接听电话
- (void)acceptCall:(LinphoneCall *)call evenWithVideo:(BOOL)video {
    LinphoneCallParams *lcallParams = linphone_core_create_call_params(theLinphoneCore, call);
    if (!lcallParams) {
        KDSLog(@"Could not create call parameters for %p, call has probably already ended.", call);
        return;
    }
    //接通默认设置语音外放
//    [self setVoiceEnabled:YES];
    //设置视频录制的保存路径
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString * pathDir1 = [pathDocuments stringByAppendingPathComponent:[KDSUserManager sharedManager].getCurrentCateyeId];//将需要创建的串拼接到后面
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
    NSString *videoSaveName = [NSString stringWithFormat:@"/%@.mkv",@"tempRecordName"];
    NSString *videoSaveStr = [pathDir3 stringByAppendingPathComponent:videoSaveName];
    [KDSUserManager sharedManager].currentCallRecordPathName = videoSaveStr;
    NSLog(@"pathDir1 = %@",videoSaveStr);
    linphone_call_params_set_record_file(lcallParams,videoSaveStr.UTF8String);
    
    if ([self lpConfigBoolForKey:@"edge_opt_preference"]) {
        bool low_bandwidth = self.network == network_2g;
        if (low_bandwidth) {
            KDSLog(@"Low bandwidth mode");
        }
        linphone_call_params_enable_low_bandwidth(lcallParams, low_bandwidth);
    }
//    [self configSdpAttribute];
    linphone_call_params_enable_video(lcallParams, video);
    linphone_core_accept_call_with_params(theLinphoneCore, call, lcallParams);
}

- (void)call:(const LinphoneAddress *)iaddr showVideo:(BOOL)video {
    //如果当前正在通话中
    LinphoneCall *call = [[LinphoneManager instance] currentCall];
    if (call) {
        LinphoneCallAppData *callAppData = (__bridge LinphoneCallAppData *)linphone_call_get_user_pointer(call);
        LinphoneCallParams *call_params = linphone_call_params_copy(linphone_call_get_current_params(call));
        
        if (linphone_call_params_low_bandwidth_enabled(call_params)) {
            KDSLog(@"linphone_call_params_low_bandwidth_enabled");
        }
        callAppData->videoRequested = TRUE; /* will be used later to notify user if video was not activated because of the linphone core*/
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(LC, call, call_params);
        linphone_call_params_destroy(call_params);
        return;
    }
    //        else {
    //            KDSLog(@"Cannot toggle video button, because no current call");
    //        }
    //当前没有在通话 走下面打电话的流程
    // First verify that network is available, abort otherwise.
    if (!linphone_core_is_network_reachable(theLinphoneCore)) {
        KDSLog(@"Network Error", nil);
        return;
    }
    // Then check that no GSM calls are in progress, abort otherwise.
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    if ([callCenter currentCalls] != nil && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        KDSLog(@"GSM call in progress, cancelling outgoing SIP call request");
        return;
    }
    // Then check that the supplied address is valid
    if (!iaddr) {
        KDSLog(@"Invalid SIP address");
        return;
    }
    if (linphone_core_get_calls_nb(theLinphoneCore) < 1 &&
        floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max ){
        [self doCall:iaddr showVideo:video];
    } else {
        [self doCall:iaddr showVideo:video];
    }
}

- (BOOL)doCall:(const LinphoneAddress *)iaddr showVideo:(BOOL)video{
    LinphoneAddress *addr = linphone_address_clone(iaddr);
    const char* lDisplayName = linphone_address_get_display_name(addr);
    const char* lUserName = linphone_address_get_username(addr);
    NSString *displayName = @"";
    if (lDisplayName)
        displayName = [NSString stringWithUTF8String:lDisplayName];
    else if(lUserName)
        displayName = [NSString stringWithUTF8String:lUserName];
    //    NSString *displayName = [FastAddressBook displayNameForAddress:addr];
    
    // Finally we can make the call
    LinphoneCallParams *lcallParams = linphone_core_create_call_params(theLinphoneCore, NULL);
    //设置视频录制的保存路径
    if ([self lpConfigBoolForKey:@"edge_opt_preference"] && (self.network == network_2g)) {
        KDSLog(@"Enabling low bandwidth mode");
        linphone_call_params_enable_low_bandwidth(lcallParams, YES);
    }
    
    //能否拨打视频
    linphone_core_enable_video_display(theLinphoneCore, true);
    //    linphone_core_enable_video_capture(theLinphoneCore, true);
    
    //视频开启 自己加的
    linphone_call_params_enable_video(lcallParams, video);
    
    if (displayName != nil) {
        linphone_address_set_display_name(addr, displayName.UTF8String);
    }
    if ([LinphoneManager.instance lpConfigBoolForKey:@"override_domain_with_default_one"]) {
        linphone_address_set_domain(
                                    addr, [[LinphoneManager.instance lpConfigStringForKey:@"domain" inSection:@"assistant"] UTF8String]);
    }
//    [self configSdpAttribute];
    LinphoneCall *call;
    if (LinphoneManager.instance.nextCallIsTransfer) {
        char *caddr = linphone_address_as_string(addr);
        call = linphone_core_get_current_call(theLinphoneCore);
        linphone_core_transfer_call(theLinphoneCore, call, caddr);
        LinphoneManager.instance.nextCallIsTransfer = NO;
        ms_free(caddr);
    } else {
        call = linphone_core_invite_address_with_params(theLinphoneCore, addr, lcallParams);
        if (call) {
            // The LinphoneCallAppData object should be set on call creation with callback
            // - (void)onCall:StateChanged:withMessage:. If not, we are in big trouble and expect it to crash
            // We are NOT responsible for creating the AppData.
            LinphoneCallAppData *data = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
            if (data == nil) {
                KDSLog(@"New call instanciated but app data was not set. Expect it to crash.");
                /* will be used later to notify user if video was not activated because of the linphone core*/
            } else {
                data->videoRequested = linphone_call_params_video_enabled(lcallParams);
            }
        }
    }
    linphone_address_destroy(addr);
    linphone_call_params_destroy(lcallParams);
    
    return TRUE;
}

#pragma mark 转移linphone设置
- (void)migrationLinphoneSettings {
    // we need to proceed to the migration *after* the chat database was opened, so that we know it is in consistent
    // state
    NSString *chatDBFileName = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
    if ([self migrateChatDBIfNeeded:theLinphoneCore]) {
        // if a migration was performed, we should reinitialize the chat database
        linphone_core_set_chat_database_path(theLinphoneCore, [chatDBFileName UTF8String]);
    }
    
    /* AVPF migration */
    if ([self lpConfigBoolForKey:@"avpf_migration_done"] == FALSE) {
        const MSList *proxies = linphone_core_get_proxy_config_list(theLinphoneCore);
        while (proxies) {
            LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)proxies->data;
            const char *addr = linphone_proxy_config_get_addr(proxy);
            // we want to enable AVPF for the proxies
            if (addr &&
                strstr(addr, [LinphoneManager.instance lpConfigStringForKey:@"domain_name"
                                                                  inSection:@"app"
                                                                withDefault:@"sip.linphone.org"]
                       .UTF8String) != 0) {
                    KDSLog(@"Migrating proxy config to use AVPF");
                    linphone_proxy_config_set_avpf_mode(proxy, TRUE);
                }
            proxies = proxies->next;
        }
        [self lpConfigSetBool:TRUE forKey:@"avpf_migration_done"];
    }
    /* Quality Reporting migration */
    if ([self lpConfigBoolForKey:@"quality_report_migration_done"] == FALSE) {
        const MSList *proxies = linphone_core_get_proxy_config_list(theLinphoneCore);
        while (proxies) {
            LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)proxies->data;
            const char *addr = linphone_proxy_config_get_addr(proxy);
            // we want to enable quality reporting for the proxies that are on linphone.org
            if (addr &&
                strstr(addr, [LinphoneManager.instance lpConfigStringForKey:@"domain_name"
                                                                  inSection:@"app"
                                                                withDefault:@"sip.linphone.org"]
                       .UTF8String) != 0) {
                    KDSLog(@"Migrating proxy config to send quality report");
                    linphone_proxy_config_set_quality_reporting_collector(
                                                                          proxy, "sip:voip-metrics@sip.linphone.org;transport=tls");
                    linphone_proxy_config_set_quality_reporting_interval(proxy, 180);
                    linphone_proxy_config_enable_quality_reporting(proxy, TRUE);
                }
            proxies = proxies->next;
        }
        [self lpConfigSetBool:TRUE forKey:@"quality_report_migration_done"];
    }
    /* File transfer migration */
    if ([self lpConfigBoolForKey:@"file_transfer_migration_done"] == FALSE) {
        const char *newURL = "https://www.linphone.org:444/lft.php";
        KDSLog(@"Migrating sharing server url from %s to %s", linphone_core_get_file_transfer_server(LC), newURL);
        linphone_core_set_file_transfer_server(LC, newURL);
        [self lpConfigSetBool:TRUE forKey:@"file_transfer_migration_done"];
    }
}
#pragma mark 转移推送通知当前用户
- (void)migratePushNotificationPerAccount {
    NSString *s = [self lpConfigStringForKey:@"pushnotification_preference"];
    if (s && s.boolValue) {
        KDSLog(@"Migrating push notification per account, enabling for ALL");
        [self lpConfigSetBool:NO forKey:@"pushnotification_preference"];
        const MSList *proxies = linphone_core_get_proxy_config_list(LC);
        while (proxies) {
            linphone_proxy_config_set_ref_key(proxies->data, "push_notification");
            [self configurePushTokenForProxyConfig:proxies->data];
            proxies = proxies->next;
        }
    }
}
#pragma mark 转移向导到助手
static void migrateWizardToAssistant(const char *entry, void *user_data) {
    LinphoneManager *thiz = (__bridge LinphoneManager *)(user_data);
    NSString *key = [NSString stringWithUTF8String:entry];
    [thiz lpConfigSetString:[thiz lpConfigStringForKey:key inSection:@"wizard"] forKey:key inSection:@"assistant"];
}


static OSStatus extracted(CFStringRef *newRoute, UInt32 *newRouteSize) {
    return AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, newRouteSize, newRoute);
}

- (OSStatus)extracted:(CFStringRef *)newRoute newRouteSize:(UInt32 *)newRouteSize {
    return extracted(newRoute, newRouteSize);
}

- (void)extracted:(NSDictionary *)dict {
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneBluetoothAvailabilityUpdate
                                                      object:self
                                                    userInfo:dict];
}

- (void)audioRouteChangeListenerCallback:(NSNotification *)notif {
    if (IPAD)
        return;
    
    // there is at least one bug when you disconnect an audio bluetooth headset
    // since we only get notification of route having changed, we cannot tell if that is due to:
    // -bluetooth headset disconnected or
    // -user wanted to use earpiece
    // the only thing we can assume is that when we lost a device, it must be a bluetooth one (strong hypothesis though)
    if ([[notif.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue] ==
        AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        _bluetoothAvailable = NO;
    }
    
    CFStringRef newRoute = CFSTR("Unknown");
    UInt32 newRouteSize = sizeof(newRoute);
    
#warning deprecated
    OSStatus status = [self extracted:&newRoute newRouteSize:&newRouteSize];
    
    if (!status && newRouteSize > 0) {
        NSString *route = (__bridge NSString *)newRoute;
        KDSLog(@"Current audio route is [%s]", [route UTF8String]);
        
        _speakerEnabled = [route isEqualToString:@"Speaker"] || [route isEqualToString:@"SpeakerAndMicrophone"];
        if ([route isEqualToString:@"HeadsetBT"] && !_speakerEnabled) {
            _bluetoothAvailable = TRUE;
            _bluetoothEnabled = TRUE;
        } else {
            _bluetoothEnabled = FALSE;
        }
        NSDictionary *dict = [NSDictionary
                              dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:_bluetoothAvailable], @"available", nil];
        [self extracted:dict];
        CFRelease(newRoute);
    }
}

#pragma mark - Audio route Functions

- (bool)allowSpeaker {
    if (IPAD)
        return true;
    
    bool allow = true;
    CFStringRef lNewRoute = CFSTR("Unknown");
    UInt32 lNewRouteSize = sizeof(lNewRoute);
#warning deprecated
    OSStatus lStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &lNewRouteSize, &lNewRoute);
    if (!lStatus && lNewRouteSize > 0) {
        NSString *route = (__bridge NSString *)lNewRoute;
        allow = ![route containsString:@"Heads"] && ![route isEqualToString:@"Lineout"];
        CFRelease(lNewRoute);
    }
    return allow;
}

- (void)setVoiceEnabled:(BOOL)enable {
    OSStatus ret;
    _speakerEnabled = enable;
    UInt32 override = kAudioSessionUnspecifiedError;
    
    if (!enable && _bluetoothAvailable) {
        UInt32 bluetoothInputOverride = _bluetoothEnabled;
#warning deprecated
        ret = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
                                      sizeof(bluetoothInputOverride), &bluetoothInputOverride);
        // if setting bluetooth failed, it must be because the device is not available
        // anymore (disconnected), so deactivate bluetooth.
        if (ret != kAudioSessionNoError) {
            _bluetoothAvailable = _bluetoothEnabled = FALSE;
        }
    }
    if (override != kAudioSessionNoError) {
        if (enable && [self allowSpeaker]) {
            override = kAudioSessionOverrideAudioRoute_Speaker;
#warning deprecated
            ret = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(override), &override);
            _bluetoothEnabled = FALSE;
        } else {
            override = kAudioSessionOverrideAudioRoute_None;
#warning deprecated
            ret = AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(override), &override);
        }
    }
}

- (void)setBluetoothEnabled:(BOOL)enable {
    if (_bluetoothAvailable) {
        // The change of route will be done in setSpeakerEnabled
        _bluetoothEnabled = enable;
        [self setSpeakerEnabled:!_bluetoothEnabled && _speakerEnabled];
    }
}

- (void)overrideDefaultSettings {
    
    NSString *factory = [LinphoneManager bundleFile:@"linphonerc-factory"];
    NSString *factoryIpad = [LinphoneManager bundleFile:@"linphonerc-factory~ipad"];
    if (IPAD && [[NSFileManager defaultManager] fileExistsAtPath:factoryIpad]) {
        factory = factoryIpad;
    }
    NSString *confiFileName = [LinphoneManager documentFile:@"linphonerc"];
    _configDb = lp_config_new_with_factory([confiFileName UTF8String], [factory UTF8String]);
}

- (void)copyDefaultSettings {
    NSString *src = [LinphoneManager bundleFile:@"linphonerc"];
    NSString *srcIpad = [LinphoneManager bundleFile:@"linphonerc~ipad"];
    if (IPAD && [[NSFileManager defaultManager] fileExistsAtPath:srcIpad]) {
        src = srcIpad;
    }
    NSString *dst = [LinphoneManager documentFile:@"linphonerc"];
    [LinphoneManager copyFile:src destination:dst override:FALSE];
}

#pragma mark - Linphone Core Functions
+ (LinphoneCore *)getLc {

//    if (theLinphoneCore == nil) {
        //        @throw([NSException exceptionWithName:@"LinphoneCoreException"
        //                                       reason:@"Linphone core not initialized yet"
        //                                     userInfo:nil]);
//    }
//    return theLinphoneCore;
    if (theLinphoneCore == nil) {
        NSLog(@"theLinphoneCore == nil");
    }
    return theLinphoneCore?:nil;
}
#pragma mark Debug functions
+ (void)dumpLcConfig {
    if (theLinphoneCore) {
        LpConfig *conf = LinphoneManager.instance.configDb;
        char *config = lp_config_dump(conf);
        KDSLog(@"\n%s", config);
        ms_free(config);
    }
}
#pragma mark - Logs Functions handlers
static void linphone_iphone_log_user_info(struct _LinphoneCore *lc, const char *message) {
    //    linphone_core_set_log_handler(NULL, ORTP_MESSAGE, message, NULL);
}
static void linphone_iphone_log_user_warning(struct _LinphoneCore *lc, const char *message) {
    //    linphone_iphone_log_handler(NULL, ORTP_WARNING, message, NULL);
}
#pragma mark - Display Status Functions

- (void)displayStatus:(NSString *)message {
    // Post event
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneDisplayStatusUpdate
                                                      object:self
                                                    userInfo:@{
                                                               @"message" : message
                                                               }];
}

static void linphone_iphone_display_status(struct _LinphoneCore *lc, const char *message) {
    NSString *status = [[NSString alloc] initWithCString:message encoding:[NSString defaultCStringEncoding]];
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) displayStatus:status];
}
#pragma mark - Call State Functions

- (void)localNotifContinue:(NSTimer *)timer {
    UILocalNotification *notif = [timer userInfo];
    if (notif) {
        KDSLog(@"cancelling/presenting local notif");
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    }
}

- (void)userNotifContinue:(NSTimer *)timer {
    if (0) {
        UNNotificationContent *content = [timer userInfo];
        if (content && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            KDSLog(@"cancelling/presenting user notif");
            UNNotificationRequest *req =
            [UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req
                                                                   withCompletionHandler:^(NSError *_Nullable error) {
                                                                       // Enable or disable features based on authorization.
                                                                       if (error) {
                                                                           KDSLog(@"Error while adding notification request :");
                                                                           KDSLog(@"%@", error.description);
                                                                       }
                                                                   }];
        }
    } else {
        // Fallback on earlier versions
    }
    
}


- (void)onCall:(LinphoneCall *)call StateChanged:(LinphoneCallState)state withMessage:(const char *)message {
    // Handling wrapper
    LinphoneCallAppData *data = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
    if (!data) {
        data = [[LinphoneCallAppData alloc] init];
        linphone_call_set_user_data(call, (void *)CFBridgingRetain(data));
    }
    NSLog(@"linphone---------------------------LinphoneCallState%u",state);
#pragma deploymate push "ignored-api-availability"
    if (_silentPushCompletion) {
        // we were woken up by a silent push. Call the completion handler with NEWDATA
        // so that the push is notified to the user
        KDSLog(@"onCall - handler %p", _silentPushCompletion);
        _silentPushCompletion(UIBackgroundFetchResultNewData);
        _silentPushCompletion = nil;
    }
#pragma deploymate pop
    if (state == LinphoneCallIncomingReceived) {
        // TESTING !!
        // linphone_call_accept_early_media(call);
        LinphoneCallLog *callLog = linphone_call_get_call_log(call);
        NSString *callId = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
        int index = [(NSNumber *)[_pushDict objectForKey:callId] intValue] - 1;
        [_pushDict setValue:[NSNumber numberWithInt:index] forKey:callId];
        BOOL need_bg_task = FALSE;
        for (NSString *key in [_pushDict allKeys]) {
            int value = [(NSNumber *)[_pushDict objectForKey:key] intValue];
            if (value > 0) {
                need_bg_task = TRUE;
                break;
            }
        }
        if (pushBgTask && !need_bg_task) {
            KDSLog(@"Call received, stopping background task");
            [[UIApplication sharedApplication] endBackgroundTask:pushBgTask];
            pushBgTask = 0;
        }
        /*first step is to re-enable ctcall center*/
        CTCallCenter *lCTCallCenter = [[CTCallCenter alloc] init];
        /*should we reject this call ?*/
        if ([lCTCallCenter currentCalls] != nil &&
            floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            char *tmp = linphone_call_get_remote_address_as_string(call);
            if (tmp) {
                KDSLog(@"Mobile call ongoing... rejecting call from [%s]", tmp);
                ms_free(tmp);
            }
            linphone_call_decline(call, LinphoneReasonBusy);
            return;
        }
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call &&
            (linphone_core_get_calls_nb(LC) < 2)) {
#if !TARGET_IPHONE_SIMULATOR
            //            NSString *callId =
            //            [NSString stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(call))];
            //
            //            NSUUID *uuid = [NSUUID UUID];
            //            [LinphoneManager.instance.providerDelegate.calls setObject:callId forKey:uuid];
            //            [LinphoneManager.instance.providerDelegate.uuids setObject:uuid forKey:callId];
            //            BOOL video = FALSE;
            //            video = (([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) &&
            //                     linphone_core_get_video_policy(LC)->automatically_accept &&
            //                     linphone_call_params_video_enabled(linphone_call_get_remote_params(call)));
            //            [LinphoneManager.instance.providerDelegate reportIncomingCallwithUUID:uuid handle:address video:video];
#else
            //            [PhoneMainView.instance displayIncomingCall:call];
#endif
        } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            // Create a UNNotification
            //            if (0) {
            //                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            //                content.title = NSLocalizedString(@"Incoming call", nil);
            //                //            content.body = address;
            //                content.sound = [UNNotificationSound soundNamed:@"notes_of_the_optimistic.caf"];
            //                content.categoryIdentifier = @"call_cat";
            //                content.userInfo = @{ @"CallId" : callId };
            //                UNNotificationRequest *req =
            //                [UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
            //                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req
            //                                                                       withCompletionHandler:^(NSError *err){
            //                                                                       }];
            //            } else {
            //                // Fallback on earlier versions
            //            }
        }
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            // if (![LinphoneManager.instance popPushCallID:callId]) {
            // case where a remote notification is not already received
            // Create a new local notification
            if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_x_Max) {
                UIMutableUserNotificationAction *answer = [[UIMutableUserNotificationAction alloc] init];
                answer.identifier = @"answer";
                answer.title = NSLocalizedString(@"Answer", nil);
                answer.activationMode = UIUserNotificationActivationModeForeground;
                answer.destructive = NO;
                answer.authenticationRequired = YES;
                
                UIMutableUserNotificationAction *decline = [[UIMutableUserNotificationAction alloc] init];
                decline.identifier = @"decline";
                decline.title = NSLocalizedString(@"Decline", nil);
                decline.activationMode = UIUserNotificationActivationModeBackground;
                decline.destructive = YES;
                decline.authenticationRequired = NO;
                NSArray *callactions = @[ decline, answer ];
                UIMutableUserNotificationCategory *callcat = [[UIMutableUserNotificationCategory alloc] init];
                callcat.identifier = @"incoming_call";
                [callcat setActions:callactions forContext:UIUserNotificationActionContextDefault];
                [callcat setActions:callactions forContext:UIUserNotificationActionContextMinimal];
                
                NSSet *categories = [NSSet setWithObjects:callcat, nil];
                
                UIUserNotificationSettings *set = [UIUserNotificationSettings
                                                   settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                                                     UIUserNotificationTypeSound)
                                                   categories:categories];
                [[UIApplication sharedApplication] registerUserNotificationSettings:set];
                data->notification = [[UILocalNotification alloc] init];
                if (data->notification) {
                    // iOS8 doesn't need the timer trick for the local notification.
                    data->notification.category = @"incoming_call";
                    //                    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8 &&
                    //                        [self lpConfigBoolForKey:@"repeat_call_notification"] == NO) {
                    //                        NSString *ring =
                    //                        ([LinphoneManager bundleFile:[self lpConfigStringForKey:@"local_ring" inSection:@"sound"].lastPathComponent]
                    //                         ?: [LinphoneManager bundleFile:@"notes_of_the_optimistic1.caf"])
                    //                        .lastPathComponent;
                    //                        data->notification.soundName = ring;
                    //                    } else {
                    //                        data->notification.soundName = @"shortring.caf";
                    //                        data->timer = [NSTimer scheduledTimerWithTimeInterval:5
                    //                                                                       target:self
                    //                                                                     selector:@selector(localNotifContinue:)
                    //                                                                     userInfo:data->notification
                    //                                                                      repeats:TRUE];
                    //                    }
                    
                    //                    data->notification.repeatInterval = 0;
                    
                    //                    data->notification.alertBody =
                    //                    [NSString stringWithFormat:NSLocalizedString(@"IC_MSG", nil), address];
                    //data->notification.alertAction = NSLocalizedString(@"Answer", nil);
                    //                    data->notification.userInfo = @{ @"callId" : callId, @"timer" : [NSNumber numberWithInt:1] };
                    //                    data->notification.applicationIconBadgeNumber = 1;
                    //                    UIApplication *app = [UIApplication sharedApplication];
                    //                    KDSLog(@"linphone6666-----------%@", [app currentUserNotificationSettings].description);
                    //                    [app presentLocalNotificationNow:data->notification];
                    
                    if (!incallBgTask) {
                        incallBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                            KDSLog(@"Call cannot ring any more, too late");
                            [[UIApplication sharedApplication] endBackgroundTask:incallBgTask];
                            incallBgTask = 0;
                        }];
                        
                        if (data->timer) {
                            [[NSRunLoop currentRunLoop] addTimer:data->timer forMode:NSRunLoopCommonModes];
                        }
                    }
                }
            }
            
        }
    }
    
    
    // we keep the speaker auto-enabled state in this static so that we don't
    // force-enable it on ICE re-invite if the user disabled it.
    static BOOL speaker_already_enabled = FALSE;
    
    // Disable speaker when no more call
    if ((state == LinphoneCallEnd || state == LinphoneCallError)) {
        NSLog(@"{KAADAS}--Linphone--linphoneManager--LinphoneCallEnd");

        speaker_already_enabled = FALSE;
        if (linphone_core_get_calls_nb(theLinphoneCore) == 0) {
            [self setSpeakerEnabled:FALSE];
            [self removeCTCallCenterCb];
            // disable this because I don't find anygood reason for it: _bluetoothAvailable = FALSE;
            // furthermore it introduces a bug when calling multiple times since route may not be
            // reconfigured between cause leading to bluetooth being disabled while it should not
            _bluetoothEnabled = FALSE;
            /*IOS specific*/
            linphone_core_start_dtmf_stream(theLinphoneCore);
        }
        
        if (incallBgTask) {
            [[UIApplication sharedApplication] endBackgroundTask:incallBgTask];
            incallBgTask = 0;
        }
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                if (data->timer) {
                    [data->timer invalidate];
                    data->timer = nil;
                }
                LinphoneCallLog *UNlog = linphone_call_get_call_log(call);
                if (UNlog == NULL || linphone_call_log_get_status(UNlog) == LinphoneCallMissed) {
                    if (0) {
                        UNMutableNotificationContent *missed_content = [[UNMutableNotificationContent alloc] init];
                        missed_content.title = NSLocalizedString(@"Missed call", nil);
                        //                    missed_content.body = address;
                        UNNotificationRequest *missed_req = [UNNotificationRequest requestWithIdentifier:@"call_request"
                                                                                                 content:missed_content
                                                                                                 trigger:NULL];
                        [[UNUserNotificationCenter currentNotificationCenter]
                         addNotificationRequest:missed_req
                         withCompletionHandler:^(NSError *_Nullable error) {
                             // Enable or disable features based on authorization.
                             if (error) {
                                 KDSLog(@"Error while adding notification request :");
                                 KDSLog(@"%@", error.description);
                             }
                         }];
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }
                linphone_core_set_network_reachable(LC, FALSE);
                LinphoneManager.instance.connectivity = none;
            }
            //            LinphoneCallLog *callLog2 = linphone_call_get_call_log(call);
            //            NSString *callId2 = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog2)];
            //            NSUUID *uuid = (NSUUID *)[self.providerDelegate.uuids objectForKey:callId2];
            //            if (uuid) {
            //                // For security reasons do not display name
            //                // CXCallUpdate *update = [[CXCallUpdate alloc] init];
            //                // update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:@"Unknown"];
            //                //[LinphoneManager.instance.providerDelegate.provider reportCallWithUUID:uuid updated:update];
            //
            //                if (linphone_core_get_calls_nb(LC) > 0 && !_conf) {
            //                    // Create a CallKit call because there's not !
            //                    _conf = FALSE;
            //                    LinphoneCall *callKit_call = (LinphoneCall *)linphone_core_get_calls(LC)->data;
            //                    NSString *callKit_callId = [NSString
            //                                                stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(callKit_call))];
            //                    NSUUID *callKit_uuid = [NSUUID UUID];
            //                    [LinphoneManager.instance.providerDelegate.uuids setObject:callKit_uuid forKey:callKit_callId];
            //                    [LinphoneManager.instance.providerDelegate.calls setObject:callKit_callId forKey:callKit_uuid];
            //                    NSString *address =
            //                    [FastAddressBook displayNameForAddress:linphone_call_get_remote_address(callKit_call)];
            //                    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:address];
            //                    CXStartCallAction *act = [[CXStartCallAction alloc] initWithCallUUID:callKit_uuid handle:handle];
            //                    CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
            //                    [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
            //                                                                                  completion:^(NSError *err){
            //                                                                                  }];
            //                    [LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:callKit_uuid
            //                                                                           startedConnectingAtDate:nil];
            //                    [LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:callKit_uuid
            //                                                                                   connectedAtDate:nil];
            //                }
            //
            //                [self.providerDelegate.uuids removeObjectForKey:callId2];
            //                [self.providerDelegate.calls removeObjectForKey:uuid];
            //                CXEndCallAction *act = [[CXEndCallAction alloc] initWithCallUUID:uuid];
            //                CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
            //                [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
            //                                                                              completion:^(NSError *err){
            //                                                                              }];
            //            }
        } else {
            if (data != nil && data->notification != nil) {
                LinphoneCallLog *log = linphone_call_get_call_log(call);
                
                // cancel local notif if needed
                if (data->timer) {
                    [data->timer invalidate];
                    data->timer = nil;
                }
                [[UIApplication sharedApplication] cancelLocalNotification:data->notification];
                
                data->notification = nil;
                
                if (log == NULL || linphone_call_log_get_status(log) == LinphoneCallMissed) {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.repeatInterval = 0;
                    notification.alertBody =
                    //                    [NSString stringWithFormat:NSLocalizedString(@"You missed a call from %@", nil), address];
                    notification.alertAction = NSLocalizedString(@"Show", nil);
                    notification.userInfo = [NSDictionary
                                             dictionaryWithObject:[NSString stringWithUTF8String:linphone_call_log_get_call_id(log)]
                                             forKey:@"callLog"];
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
            }
        }
        if (state == LinphoneCallError) {
            //            [PhoneMainView.instance popCurrentView];
        }
    }
    
    if (state == LinphoneCallReleased) {
        if (data != NULL) {
            linphone_call_set_user_data(call, NULL);
            CFBridgingRelease((__bridge CFTypeRef)(data));
        }
    }
    
    // Enable speaker when video
    if (state == LinphoneCallIncomingReceived || state == LinphoneCallOutgoingInit || state == LinphoneCallConnected ||
        state == LinphoneCallStreamsRunning) {
        if (linphone_call_params_video_enabled(linphone_call_get_current_params(call)) && !speaker_already_enabled) {
            [self setSpeakerEnabled:TRUE];
            speaker_already_enabled = TRUE;
        }
    }
    
    if (state == LinphoneCallConnected && !mCallCenter) {
        /*only register CT call center CB for connected call*/
        [self setupGSMInteraction];
    }
    // Post event
    NSDictionary *dict = @{
                           @"call" : [NSValue valueWithPointer:call],
                           @"state" : [NSNumber numberWithInt:state],
                           @"message" : [NSString stringWithUTF8String:message]
                           };
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self userInfo:dict];
    
}
static void linphone_iphone_call_state(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state,
                                       const char *message) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onCall:call StateChanged:state withMessage:message];
}

#pragma mark - Transfert State Functions

static void linphone_iphone_transfer_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state) {
}

#pragma mark - Global state change

static void linphone_iphone_global_state_changed(LinphoneCore *lc, LinphoneGlobalState gstate, const char *message) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onGlobalStateChanged:gstate withMessage:message];
}

- (void)onGlobalStateChanged:(LinphoneGlobalState)state withMessage:(const char *)message {
    KDSLog(@"onGlobalStateChanged: %d (message: %s)", state, message);
    
    NSDictionary *dict = [NSDictionary
                          dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state], @"state",
                          [NSString stringWithUTF8String:message ? message : ""], @"message", nil];
    
    // dispatch the notification asynchronously
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneGlobalStateUpdate object:self userInfo:dict];
    });
}

- (void)globalStateChangedNotificationHandler:(NSNotification *)notif {
    if ((LinphoneGlobalState)[[[notif userInfo] valueForKey:@"state"] integerValue] == LinphoneGlobalOn) {
        NSLog(@"{KAADAS}--Linphone--初始化完成--LinphoneGlobalOn");
        [self finishCoreConfiguration];
    }
}

#pragma mark - Configuring status changed

static void linphone_iphone_configuring_status_changed(LinphoneCore *lc, LinphoneConfiguringState status,
                                                       const char *message) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onConfiguringStatusChanged:status withMessage:message];
}

- (void)onConfiguringStatusChanged:(LinphoneConfiguringState)status withMessage:(const char *)message {
    KDSLog(@"onConfiguringStatusChanged: %s %@", linphone_configuring_state_to_string(status),
           message ? [NSString stringWithFormat:@"(message: %s)", message] : @"");
    
    NSDictionary *dict = [NSDictionary
                          dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:status], @"state",
                          [NSString stringWithUTF8String:message ? message : ""], @"message", nil];
    
    // dispatch the notification asynchronously
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneConfiguringStateUpdate
                                                          object:self
                                                        userInfo:dict];
    });
}

- (void)configuringStateChangedNotificationHandler:(NSNotification *)notif {
    _wasRemoteProvisioned = ((LinphoneConfiguringState)[[[notif userInfo] valueForKey:@"state"] integerValue] ==
                             LinphoneConfiguringSuccessful);
    if (_wasRemoteProvisioned) {
        LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
        if (cfg) {
            [self configurePushTokenForProxyConfig:cfg];
        }
    }
}

#pragma mark - Registration State Functions
- (void)onRegister:(LinphoneCore *)lc
               cfg:(LinphoneProxyConfig *)cfg
             state:(LinphoneRegistrationState)state
           message:(const char *)cmessage {
    NSLog(@"New registration state: %s (message: %s)", linphone_registration_state_to_string(state), cmessage);
    LinphoneReason reason = linphone_proxy_config_get_error(cfg);
    NSString *message = nil;
    switch (reason) {
        case LinphoneReasonBadCredentials:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonBadCredentials");

            message = NSLocalizedString(@"Bad credentials, check your account settings", nil);
            break;
        case LinphoneReasonNoResponse:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNoResponse");

            message = NSLocalizedString(@"No response received from remote", nil);
            break;
        case LinphoneReasonUnsupportedContent:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonUnsupportedContent");

            message = NSLocalizedString(@"Unsupported content", nil);
            break;
        case LinphoneReasonIOError:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonIOError");

            message = NSLocalizedString(
                                        @"Cannot reach the server: either it is an invalid address or it may be temporary down.", nil);
            break;
            
        case LinphoneReasonUnauthorized:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonUnauthorized");

            message = NSLocalizedString(@"Operation is unauthorized because missing credential", nil);
            break;
        case LinphoneReasonNoMatch:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNoMatch");

            message = NSLocalizedString(@"Operation could not be executed by server or remote client because it "
                                        @"didn't have any context for it",
                                        nil);
            break;
        case LinphoneReasonMovedPermanently:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonMovedPermanently");

            message = NSLocalizedString(@"Resource moved permanently", nil);
            break;
        case LinphoneReasonGone:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonGone");

            message = NSLocalizedString(@"Resource no longer exists", nil);
            break;
        case LinphoneReasonTemporarilyUnavailable:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonTemporarilyUnavailable");

            message = NSLocalizedString(@"Temporarily unavailable", nil);
            break;
        case LinphoneReasonAddressIncomplete:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonAddressIncomplete");

            message = NSLocalizedString(@"Address incomplete", nil);
            break;
        case LinphoneReasonNotImplemented:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNotImplemented");

            message = NSLocalizedString(@"Not implemented", nil);
            break;
        case LinphoneReasonBadGateway:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonBadGateway");

            message = NSLocalizedString(@"Bad gateway", nil);
            break;
        case LinphoneReasonServerTimeout:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonServerTimeout");

            message = NSLocalizedString(@"Server timeout", nil);
            break;
        case LinphoneReasonNotAcceptable:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNotAcceptable");

        case LinphoneReasonDoNotDisturb:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonDoNotDisturb");

        case LinphoneReasonDeclined:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonDeclined");

        case LinphoneReasonNotFound:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNotFound");

        case LinphoneReasonNotAnswered:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNotAnswered");

        case LinphoneReasonBusy:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonBusy");

        case LinphoneReasonNone:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonNone");

        case LinphoneReasonUnknown:
//            NSLog(@"{KAADAS}--Linphone--onRegister--LinphoneReasonUnknown");

            message = NSLocalizedString(@"Unknown error", nil);
            break;
    }
    
    // Post event
    NSDictionary *dict =
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state], @"state",
     [NSValue valueWithPointer:cfg], @"cfg", message, @"message", nil];
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneRegistrationUpdate object:self userInfo:dict];
    
}

static void linphone_iphone_registration_state(LinphoneCore *lc, LinphoneProxyConfig *cfg,
                                               LinphoneRegistrationState state, const char *message) {
    
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onRegister:lc cfg:cfg state:state message:message];
    
}
#pragma mark - Auth info Function

static void linphone_iphone_popup_password_request(LinphoneCore *lc, const char *realmC, const char *usernameC,
                                                   const char *domainC) {
    
}

#pragma mark - Text Received Functions
//IM消息接收
- (void)onMessageReceived:(LinphoneCore *)lc room:(LinphoneChatRoom *)room message:(LinphoneChatMessage *)msg {
    
}

static void linphone_iphone_message_received(LinphoneCore *lc, LinphoneChatRoom *room, LinphoneChatMessage *message) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onMessageReceived:lc room:room message:message];
}

static void linphone_iphone_message_received_unable_decrypt(LinphoneCore *lc, LinphoneChatRoom *room,
                                                            LinphoneChatMessage *message) {
    
    NSString *msgId = [NSString stringWithUTF8String:linphone_chat_message_get_custom_header(message, "Call-ID")];
    int index = [(NSNumber *)[LinphoneManager.instance.pushDict objectForKey:msgId] intValue] - 1;
    [LinphoneManager.instance.pushDict setValue:[NSNumber numberWithInt:index] forKey:msgId];
    BOOL need_bg_task = FALSE;
    for (NSString *key in [LinphoneManager.instance.pushDict allKeys]) {
        int value = [(NSNumber *)[LinphoneManager.instance.pushDict objectForKey:key] intValue];
        if (value > 0) {
            need_bg_task = TRUE;
            break;
        }
    }
    if (theLinphoneManager->pushBgTask && !need_bg_task) {
        KDSLog(@"Message received, stopping background task");
        [[UIApplication sharedApplication] endBackgroundTask:theLinphoneManager->pushBgTask];
        theLinphoneManager->pushBgTask = 0;
    }
    //    const LinphoneAddress *address = linphone_chat_message_get_peer_address(message);
    //    NSString *strAddr = [FastAddressBook displayNameForAddress:address];
    NSString *title = NSLocalizedString(@"LIME warning", nil);
    //    NSString *body = [NSString
    //                      stringWithFormat:NSLocalizedString(@"You have received an encrypted message you are unable to decrypt from "
    //                                                         @"%@.\nYou need to call your correspondant in order to exchange your ZRTP "
    //                                                         @"keys if you want to decrypt the future messages you will receive.",
    //                                                         nil),
    //                      strAddr];
    //    NSString *action = NSLocalizedString(@"Call", nil);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
            if (0) {
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = title;
                //            content.body = body;
                UNNotificationRequest *req =
                [UNNotificationRequest requestWithIdentifier:@"decrypt_request" content:content trigger:NULL];
                [[UNUserNotificationCenter currentNotificationCenter]
                 addNotificationRequest:req
                 withCompletionHandler:^(NSError *_Nullable error) {
                     // Enable or disable features based on authorization.
                     if (error) {
                         KDSLog(@"Error while adding notification request :");
                         KDSLog(@"%@", error.description);
                     }
                 }];
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.repeatInterval = 0;
            if (0) {
                notification.alertTitle = title;
            } else {
                // Fallback on earlier versions
            }
            //            notification.alertBody = body;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    } else {
        
    }
}

- (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)value {
    
    if (!value) {
        return NULL;
    }
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
    const char * normvalue;
    if (linphone_proxy_config_is_phone_number(cfg, value.UTF8String)) {
        normvalue = linphone_proxy_config_normalize_phone_number(cfg, value.UTF8String);
    } else {
        normvalue = value.UTF8String;
    }
    LinphoneAddress *addr = linphone_proxy_config_normalize_sip_uri(cfg, normvalue);
    
    // first try to find a friend with the given address
    
    // since user wants to escape plus, we assume it expects to have phone numbers by default
    if (addr && cfg && (linphone_proxy_config_get_dial_escape_plus(cfg))) {
        linphone_address_set_username(addr, normvalue);
    } else {
        linphone_address_set_username(addr, value.UTF8String);
    }
    
    return addr;
}
- (void)onNotifyReceived:(LinphoneCore *)lc
                   event:(LinphoneEvent *)lev
             notifyEvent:(const char *)notified_event
                 content:(const LinphoneContent *)body {
    // Post event
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSValue valueWithPointer:lev] forKey:@"event"];
    [dict setObject:[NSString stringWithUTF8String:notified_event] forKey:@"notified_event"];
    if (body != NULL) {
        [dict setObject:[NSValue valueWithPointer:body] forKey:@"content"];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneNotifyReceived object:self userInfo:dict];
}

static void linphone_iphone_notify_received(LinphoneCore *lc, LinphoneEvent *lev, const char *notified_event,
                                            const LinphoneContent *body) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onNotifyReceived:lc
                                                                            event:lev
                                                                      notifyEvent:notified_event
                                                                          content:body];
}

- (void)onNotifyPresenceReceivedForUriOrTel:(LinphoneCore *)lc
                                     friend:(LinphoneFriend *)lf
                                        uri:(const char *)uri
                              presenceModel:(const LinphonePresenceModel *)model {
    // Post event
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSValue valueWithPointer:lf] forKey:@"friend"];
    [dict setObject:[NSValue valueWithPointer:uri] forKey:@"uri"];
    [dict setObject:[NSValue valueWithPointer:model] forKey:@"presence_model"];
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneNotifyPresenceReceivedForUriOrTel
                                                      object:self
                                                    userInfo:dict];
}

static void linphone_iphone_notify_presence_received_for_uri_or_tel(LinphoneCore *lc, LinphoneFriend *lf,
                                                                    const char *uri_or_tel,
                                                                    const LinphonePresenceModel *presence_model) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onNotifyPresenceReceivedForUriOrTel:lc
                                                                                              friend:lf
                                                                                                 uri:uri_or_tel
                                                                                       presenceModel:presence_model];
}

static void linphone_iphone_call_encryption_changed(LinphoneCore *lc, LinphoneCall *call, bool_t on,
                                                    const char *authentication_token) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onCallEncryptionChanged:lc
                                                                                    call:call
                                                                                      on:on
                                                                                   token:authentication_token];
}

- (void)onCallEncryptionChanged:(LinphoneCore *)lc
                           call:(LinphoneCall *)call
                             on:(BOOL)on
                          token:(const char *)authentication_token {
    // Post event
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSValue valueWithPointer:call] forKey:@"call"];
    [dict setObject:[NSNumber numberWithBool:on] forKey:@"on"];
    if (authentication_token) {
        [dict setObject:[NSString stringWithUTF8String:authentication_token] forKey:@"token"];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallEncryptionChanged object:self userInfo:dict];
}

- (void)onMessageComposeReceived:(LinphoneCore *)core forRoom:(LinphoneChatRoom *)room {
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneTextComposeEvent
                                                      object:self
                                                    userInfo:@{
                                                               @"room" : [NSValue valueWithPointer:room]
                                                               }];
}

static void linphone_iphone_is_composing_received(LinphoneCore *lc, LinphoneChatRoom *room) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onMessageComposeReceived:lc forRoom:room];
}

#pragma mark - Network Functions

- (SCNetworkReachabilityRef)getProxyReachability {
    return proxyReachability;
}
+ (void)kickOffNetworkConnection {
    static BOOL in_progress = FALSE;
    if (in_progress) {
        KDSLog(@"Connection kickoff already in progress");
        return;
    }
    in_progress = TRUE;
    /* start a new thread to avoid blocking the main ui in case of peer host failure */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static int sleep_us = 10000;
        static int timeout_s = 5;
        BOOL timeout_reached = FALSE;
        int loop = 0;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef) @"192.168.0.200" /*"linphone.org"*/, 15000, nil,
                                           &writeStream);
        BOOL res = CFWriteStreamOpen(writeStream);
        const char *buff = "hello";
        time_t start = time(NULL);
        time_t loop_time;
        
        if (res == FALSE) {
            KDSLog(@"Could not open write stream, backing off");
            CFRelease(writeStream);
            in_progress = FALSE;
            return;
        }
        
        // check stream status and handle timeout
        CFStreamStatus status = CFWriteStreamGetStatus(writeStream);
        while (status != kCFStreamStatusOpen && status != kCFStreamStatusError) {
            usleep(sleep_us);
            status = CFWriteStreamGetStatus(writeStream);
            loop_time = time(NULL);
            if (loop_time - start >= timeout_s) {
                timeout_reached = TRUE;
                break;
            }
            loop++;
        }
        
        if (status == kCFStreamStatusOpen) {
            CFWriteStreamWrite(writeStream, (const UInt8 *)buff, strlen(buff));
        } else if (!timeout_reached) {
            CFErrorRef error = CFWriteStreamCopyError(writeStream);
            KDSLog(@"CFStreamError: %@", error);
            CFRelease(error);
        } else if (timeout_reached) {
            KDSLog(@"CFStream timeout reached");
        }
        CFWriteStreamClose(writeStream);
        CFRelease(writeStream);
        in_progress = FALSE;
    });
}

+ (NSString *)getCurrentWifiSSID {
#if TARGET_IPHONE_SIMULATOR
    return @"Sim_err_SSID_NotSupported";
#else
    NSString *data = nil;
    CFDictionaryRef dict = CNCopyCurrentNetworkInfo((CFStringRef) @"en0");
    if (dict) {
        KDSLog(@"AP Wifi: %@", dict);
        data = [NSString stringWithString:(NSString *)CFDictionaryGetValue(dict, @"SSID")];
        CFRelease(dict);
    }
    return data;
#endif
}

static void showNetworkFlags(SCNetworkReachabilityFlags flags) {
    NSMutableString *log = [[NSMutableString alloc] initWithString:@"Network connection flags: "];
    if (flags == 0)
        [log appendString:@"no flags."];
    if (flags & kSCNetworkReachabilityFlagsTransientConnection)
        [log appendString:@"kSCNetworkReachabilityFlagsTransientConnection, "];
    if (flags & kSCNetworkReachabilityFlagsReachable)
        [log appendString:@"kSCNetworkReachabilityFlagsReachable, "];
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired)
        [log appendString:@"kSCNetworkReachabilityFlagsConnectionRequired, "];
    if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)
        [log appendString:@"kSCNetworkReachabilityFlagsConnectionOnTraffic, "];
    if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)
        [log appendString:@"kSCNetworkReachabilityFlagsConnectionOnDemand, "];
    if (flags & kSCNetworkReachabilityFlagsIsLocalAddress)
        [log appendString:@"kSCNetworkReachabilityFlagsIsLocalAddress, "];
    if (flags & kSCNetworkReachabilityFlagsIsDirect)
        [log appendString:@"kSCNetworkReachabilityFlagsIsDirect, "];
    if (flags & kSCNetworkReachabilityFlagsIsWWAN)
        [log appendString:@"kSCNetworkReachabilityFlagsIsWWAN, "];
    KDSLog(@"%@", log);
}

//This callback keeps tracks of wifi SSID changes.
static void networkReachabilityNotification(CFNotificationCenterRef center, void *observer, CFStringRef name,
                                            const void *object, CFDictionaryRef userInfo) {
    LinphoneManager *mgr = LinphoneManager.instance;
    SCNetworkReachabilityFlags flags;
    
    // for an unknown reason, we are receiving multiple time the notification, so
    // we will skip each time the SSID did not change
    NSString *newSSID = [LinphoneManager getCurrentWifiSSID];

    if ([newSSID compare:mgr.SSID] == NSOrderedSame)
        return;
    
    
    if (newSSID != Nil && newSSID.length > 0 && mgr.SSID != Nil && newSSID.length > 0){
        if (SCNetworkReachabilityGetFlags([mgr getProxyReachability], &flags)) {
            KDSLog(@"Wifi SSID changed, resesting transports.");
            mgr.connectivity=none; //this will trigger a connectivity change in networkReachabilityCallback.
            networkReachabilityCallBack([mgr getProxyReachability], flags, nil);
        }
    }
    mgr.SSID = newSSID;
    
    
}

void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *nilCtx) {
    showNetworkFlags(flags);
    LinphoneManager *lm = LinphoneManager.instance;
    SCNetworkReachabilityFlags networkDownFlags = kSCNetworkReachabilityFlagsConnectionRequired |
    kSCNetworkReachabilityFlagsConnectionOnTraffic |
    kSCNetworkReachabilityFlagsConnectionOnDemand;
    
    if (theLinphoneCore != nil) {
        LinphoneProxyConfig *proxy = linphone_core_get_default_proxy_config(theLinphoneCore);
        
        struct NetworkReachabilityContext *ctx = nilCtx ? ((struct NetworkReachabilityContext *)nilCtx) : 0;
        if ((flags == 0) || (flags & networkDownFlags)) {
            linphone_core_set_network_reachable(theLinphoneCore, false);
            lm.connectivity = none;
            [LinphoneManager kickOffNetworkConnection];
        } else {
            Connectivity newConnectivity;
            BOOL isWifiOnly = [lm lpConfigBoolForKey:@"wifi_only_preference" withDefault:FALSE];
            if (!ctx || ctx->testWWan)
                newConnectivity = flags & kSCNetworkReachabilityFlagsIsWWAN ? wwan : wifi;
            else
                newConnectivity = wifi;
            
            if (newConnectivity == wwan && proxy && isWifiOnly &&
                (lm.connectivity == newConnectivity || lm.connectivity == none)) {
                linphone_proxy_config_expires(proxy, 0);
            } else if (proxy) {
                NSInteger defaultExpire = [lm lpConfigIntForKey:@"default_expires"];
                if (defaultExpire >= 0)
                    linphone_proxy_config_expires(proxy, (int)defaultExpire);

                // else keep default value from linphonecore
            }
            
            if (lm.connectivity != newConnectivity) {
                // connectivity has changed
                linphone_core_set_network_reachable(theLinphoneCore, false);
                if (newConnectivity == wwan && proxy && isWifiOnly) {
                    linphone_proxy_config_expires(proxy, 0);

                }
                linphone_core_set_network_reachable(theLinphoneCore, true);
                linphone_core_iterate(theLinphoneCore);
                KDSLog(@"Network connectivity changed to type [%s]", (newConnectivity == wifi ? "wifi" : "wwan"));
                lm.connectivity = newConnectivity;
            }
        }
        if (ctx && ctx->networkStateChanged) {
            (*ctx->networkStateChanged)(lm.connectivity);
        }
    }
}

#pragma mark - 设置网络状态回调
- (void)setupNetworkReachabilityCallback {
    SCNetworkReachabilityContext *ctx = NULL;
    // any internet cnx
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    if (proxyReachability) {
        KDSLog(@"Cancelling old network reachability");
        SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(proxyReachability);
        proxyReachability = nil;
    }
    
    // This notification is used to detect SSID change (switch of Wifi network). The ReachabilityCallback is
    // not triggered when switching between 2 private Wifi...
    // Since we cannot be sure we were already observer, remove ourself each time... to be improved
    _SSID = [LinphoneManager getCurrentWifiSSID];
    NSLog(@"猫眼呼叫的时候网络地址SSID：%@",_SSID);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self),
                                       CFSTR("com.apple.system.config.network_change"), NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self),
                                    networkReachabilityNotification, CFSTR("com.apple.system.config.network_change"),
                                    NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    proxyReachability =
    SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    
    if (!SCNetworkReachabilitySetCallback(proxyReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack,
                                          ctx)) {
        KDSLog(@"Cannot register reachability cb: %s", SCErrorString(SCError()));
        return;
    }
    if (!SCNetworkReachabilityScheduleWithRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
        KDSLog(@"Cannot register schedule reachability cb: %s", SCErrorString(SCError()));
        return;
    }
    
    // this check is to know network connectivity right now without waiting for a change. Don'nt remove it unless you
    // have good reason. Jehan
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(proxyReachability, &flags)) {
        networkReachabilityCallBack(proxyReachability, flags, nil);
    }
}

- (NetworkType)network {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
        NSNumber *dataNetworkItemView = nil;
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                dataNetworkItemView = subview;
                break;
            }
        }
        
        NSNumber *number = (NSNumber *)[dataNetworkItemView valueForKey:@"dataNetworkType"];
        return [number intValue];
    } else {
#pragma deploymate push "ignored-api-availability"
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentRadio = info.currentRadioAccessTechnology;
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge]) {
            return network_2g;
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            return network_4g;
        }
#pragma deploymate pop
        return network_3g;
    }
}

#pragma mark - VTable

static LinphoneCoreVTable linphonec_vtable = {
    .call_state_changed = (LinphoneCoreCallStateChangedCb)linphone_iphone_call_state,
    .registration_state_changed = linphone_iphone_registration_state,
    .notify_presence_received_for_uri_or_tel = linphone_iphone_notify_presence_received_for_uri_or_tel,
    .auth_info_requested = linphone_iphone_popup_password_request,
    .message_received = linphone_iphone_message_received,
    .message_received_unable_decrypt = linphone_iphone_message_received_unable_decrypt,
    .transfer_state_changed = linphone_iphone_transfer_state_changed,
    .is_composing_received = linphone_iphone_is_composing_received,
    .configuring_status = linphone_iphone_configuring_status_changed,
    .global_state_changed = linphone_iphone_global_state_changed,
    .notify_received = linphone_iphone_notify_received,
    .call_encryption_changed = linphone_iphone_call_encryption_changed,
};

#pragma mark -

- (void)audioSessionInterrupted:(NSNotification *)notification {
    int interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self beginInterruption];
    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        [self endInterruption];
    }
}

static BOOL libStarted = FALSE;

/**
 scheduling loop循环调度
 描述：iterate process迭代过程
 1:video stream process
 2:Audio stream process
 3:
 */
- (void)iterate {
//    NSLog(@"{KAADAS}--iterate--定时器在执行==111");
    if (theLinphoneCore == nil) {
        //初始化theLinphoneCore
        [[LinphoneManager instance] startLinphoneCore];
    }
    else{
//        NSLog(@"{KAADAS}--iterate--定时器在执行==222");
        linphone_core_iterate(theLinphoneCore);
    }
}

/** Should be called once per linphone_core_new() */
- (void)finishCoreConfiguration {
    
    // get default config from bundle
    NSString *zrtpSecretsFileName = [LinphoneManager documentFile:@"zrtp_secrets"];
    NSString *chatDBFileName = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
    
    NSString *device = [[NSMutableString alloc]
                        initWithString:[NSString
                                        stringWithFormat:@"%@_iOS%@",
                                        [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                                        UIDevice.currentDevice.systemVersion]];
    device = [device stringByReplacingOccurrencesOfString:@"," withString:@"."];
    device = [device stringByReplacingOccurrencesOfString:@" " withString:@"."];
    device = @"";
    linphone_core_set_user_agent(theLinphoneCore, device.UTF8String, "relay");///正式与测试环境切换时linphone库中也需要修改
    
    //linphone_core_set_user_agent(theLinphoneCore, device.UTF8String, "3.16-122-g79a8bb2");
    
    _contactSipField = [self lpConfigStringForKey:@"contact_im_type_value" withDefault:@"SIP"];
    
    //    if (_fastAddressBook == nil) {
    //        _fastAddressBook = [[FastAddressBook alloc] init];
    //    }
    
    linphone_core_set_zrtp_secrets_file(theLinphoneCore, [zrtpSecretsFileName UTF8String]);
    linphone_core_set_chat_database_path(theLinphoneCore, [chatDBFileName UTF8String]);
    linphone_core_set_call_logs_database_path(theLinphoneCore, [chatDBFileName UTF8String]);
    
    [self setupNetworkReachabilityCallback];
    
    NSString *path = [LinphoneManager bundleFile:@"nowebcamCIF.jpg"];
    if (path) {
        const char *imagePath = [path UTF8String];
        KDSLog(@"Using '%s' as source image for no webcam", imagePath);
        linphone_core_set_static_picture(theLinphoneCore, imagePath);
    }
    
    /*DETECT cameras*///检测摄像头
    _frontCamId = _backCamId = nil;
    char **camlist = (char **)linphone_core_get_video_devices(theLinphoneCore);
    if (camlist) {
        for (char *cam = *camlist; *camlist != NULL; cam = *++camlist) {
            if (strcmp(FRONT_CAM_NAME, cam) == 0) {
                _frontCamId = cam;
                // great set default cam to front
                KDSLog(@"Setting default camera [%s]", _frontCamId);
                linphone_core_set_video_device(theLinphoneCore, _frontCamId);
            }
            if (strcmp(BACK_CAM_NAME, cam) == 0) {
                _backCamId = cam;
            }
        }
    } else {
        KDSLog(@"No camera detected!");
    }
    //    if (![LinphoneManager isNotIphone3G]) {
    //        PayloadType *pt = linphone_core_find_payload_type(theLinphoneCore, "SILK", 24000, -1);
    //        if (pt) {
    //            linphone_core_enable_payload_type(theLinphoneCore, pt, FALSE);
    //            KDSLog(@"SILK/24000 and video disabled on old iPhone 3G");
    //        }
    //        linphone_core_enable_video_display(theLinphoneCore, FALSE);
    //        linphone_core_enable_video_capture(theLinphoneCore, FALSE);
    //    }
    //视频格式 用vp8才能看到门口机的视频
    [self synchronizeCodecs:linphone_core_get_video_codecs(theLinphoneCore)];
    
    [self enableProxyPublish:([UIApplication sharedApplication].applicationState == UIApplicationStateActive)];
    
    KDSLog(@"Linphone [%s]  started on [%s]", linphone_core_get_version(), [[UIDevice currentDevice].model UTF8String]);
    
    // Post event
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSValue valueWithPointer:theLinphoneCore] forKey:@"core"];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCoreUpdate
                                                      object:LinphoneManager.instance
                                                    userInfo:dict];
//    NSLog(@"{KAADAS}--Linphone--finishCoreConfiguration--kLinphoneCoreUpdate");

}
#pragma mark - 设置视频编码格式
- (void)synchronizeCodecs:(const MSList *)codecs {
    PayloadType *pt;
    const MSList *elem;
    for (elem = codecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if ([sreung isEqualToString:@"VP8"]) {
            linphone_core_enable_payload_type(LC, pt, 0);
        }else {
            linphone_core_enable_payload_type(LC, pt, 1);
        }
    }
    
}
#pragma mark - 设置视频分辨率
- (void)setVideoesolution{
    //设置视频分辨率
    NSString *videoPreset = @"Custom";
    linphone_core_set_video_preset(LC, [videoPreset UTF8String]);
    int bw;
    MSVideoSize vsize;
    switch (0) {
        case 0:
            MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
            // 128 = margin for audio, the BW includes both video and audio
            bw = 1024 + 128;
            break;
        case 1:
            MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
            // no margin for VGA or QVGA, because video encoders can encode the
            // target resulution in less than the asked bandwidth
            bw = 660;
            break;
        case 2:
        default:
            MS_VIDEO_SIZE_ASSIGN(vsize, QVGA);
            bw = 380;
            break;
    }
    linphone_core_set_preferred_video_size(LC, vsize);  //设置画质
    linphone_core_set_preferred_framerate(LC, 0);       //设置FPS
    linphone_core_set_download_bandwidth(LC, bw);       //设置下载宽带
    linphone_core_set_upload_bandwidth(LC, 1000);        //设置上传宽带
}
- (void)startLinphoneCore {
    
    if (libStarted) {
        KDSLog(@"Liblinphone is already initialized!");
        return;
    }
    //    linphone_proxy_config_refresh_register(<#LinphoneProxyConfig *cfg#>);
    libStarted = TRUE;
    
    connectivity = none;
    signal(SIGPIPE, SIG_IGN);
    
    // create linphone core
    [self createLinphoneCore];
    if (!self.udpSocket) {
        [self createUDPSocket];
    }
    //    [self.providerDelegate config];
    //    _iapManager = [[InAppProductsManager alloc] init];
    
    // - Security fix - remove multi transport migration, because it enables tcp or udp, if by factoring settings only
    // tls is enabled.     This is a problem for new installations.
    // linphone_core_migrate_to_multi_transport(theLinphoneCore);
    
    // init audio session (just getting the instance will init)
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL bAudioInputAvailable = audioSession.inputAvailable;
    NSError *err;
    
    if (![audioSession setActive:NO error:&err] && err) {
        KDSLog(@"audioSession setActive failed: %@", [err description]);
    }
    if (!bAudioInputAvailable) {
        UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No microphone", nil)
                                                                         message:NSLocalizedString(@"You need to plug a microphone to your device to use the application.", nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [errView addAction:defaultAction];
        //        [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
    }
    
    // Disable notify policy
    LinphoneImNotifPolicy *im_notif_policy;
    im_notif_policy = linphone_core_get_im_notif_policy(theLinphoneCore);
    if (im_notif_policy != NULL) {
        /* The IM notification policy can be NULL at this point in case of remote provisioning. */
        linphone_im_notif_policy_clear(im_notif_policy);
        linphone_im_notif_policy_set_send_is_composing(im_notif_policy, TRUE);
        linphone_im_notif_policy_set_recv_is_composing(im_notif_policy, TRUE);
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // go directly to bg mode
        [self enterBackgroundMode];
    }
}

- (BOOL)enterBackgroundMode {
    LinphoneProxyConfig *proxyCfg = linphone_core_get_default_proxy_config(theLinphoneCore);
    BOOL shouldEnterBgMode = FALSE;
    
    // disable presence
    [self enableProxyPublish:NO];
    
    // handle proxy config if any
    if (proxyCfg) {
        const char *refkey = proxyCfg ? linphone_proxy_config_get_ref_key(proxyCfg) : NULL;
        BOOL pushNotifEnabled = (refkey && strcmp(refkey, "push_notification") == 0);
        if ([LinphoneManager.instance lpConfigBoolForKey:@"backgroundmode_preference"] || pushNotifEnabled) {
            if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_x_Max) {
                // For registration register
                //                [self refreshRegisters]; //进入后台不刷新注册
            }
        }
        
        if ([LinphoneManager.instance lpConfigBoolForKey:@"backgroundmode_preference"]) {
            // register keepalive
            if ([[UIApplication sharedApplication]
                 setKeepAliveTimeout:600 /*(NSTimeInterval)linphone_proxy_config_get_expires(proxyCfg)*/
                 handler:^{
                     KDSLog(@"keepalive handler");
                     mLastKeepAliveDate = [NSDate date];
                     if (theLinphoneCore == nil) {
                         KDSLog(@"It seems that Linphone BG mode was deactivated, just skipping");
                         return;
                     }
                     //                     [_iapManager check];
                     if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
                         // For registration register
                         //                         [self refreshRegisters]; //进入后台不刷新注册
                     }
                     linphone_core_iterate(theLinphoneCore);
                 }]) {
                     
                     KDSLog(@"keepalive handler succesfully registered");
                 } else {
                     KDSLog(@"keepalive handler cannot be registered");
                 }
            shouldEnterBgMode = TRUE;
        }
    }
    
    LinphoneCall *currentCall = linphone_core_get_current_call(theLinphoneCore);
    const bctbx_list_t *callList = linphone_core_get_calls(theLinphoneCore);
    if (!currentCall // no active call
        && callList  // at least one call in a non active state
        && bctbx_list_find_custom(callList, (bctbx_compare_func)comp_call_state_paused, NULL)) {
        [self startCallPausedLongRunningTask];
    }
    if (callList) {
        /*if at least one call exist, enter normal bg mode */
        shouldEnterBgMode = TRUE;
    }
    /*stop the video preview*/
    if (theLinphoneCore) {
        linphone_core_enable_video_preview(theLinphoneCore, FALSE);
        linphone_core_iterate(theLinphoneCore);
    }
    linphone_core_stop_dtmf_stream(theLinphoneCore);
    
    KDSLog(@"Entering [%s] bg mode", shouldEnterBgMode ? "normal" : "lite");
    
    if (!shouldEnterBgMode && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        const char *refkey = proxyCfg ? linphone_proxy_config_get_ref_key(proxyCfg) : NULL;
        BOOL pushNotifEnabled = (refkey && strcmp(refkey, "push_notification") == 0);
        if (pushNotifEnabled) {
            KDSLog(@"Keeping lc core to handle push");
            /*destroy voip socket if any and reset connectivity mode*/
            connectivity = none;
            linphone_core_set_network_reachable(theLinphoneCore, FALSE);
            return YES;
        }
        return NO;
        
    } else
        return YES;
}

- (void)refreshRegisters {
    if (connectivity == none) {
        // don't trust ios when he says there is no network. Create a new reachability context, the previous one might
        // be mis-functionning.
        KDSLog(@"None connectivity");
        [self setupNetworkReachabilityCallback];
    }
    NSLog(@"Network reachability callback setup222");
    KDSLog(@"Network reachability callback setup11111");
    if (theLinphoneCore) {
        linphone_core_refresh_registers(theLinphoneCore); // just to make sure REGISTRATION is up to date
    }
}

- (void)becomeActive {
    // enable presence
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_x_Max || self.connectivity == none) {
        [self refreshRegisters];
    }
    if (pausedCallBgTask) {
        [[UIApplication sharedApplication] endBackgroundTask:pausedCallBgTask];
        pausedCallBgTask = 0;
    }
    if (incallBgTask) {
        [[UIApplication sharedApplication] endBackgroundTask:incallBgTask];
        incallBgTask = 0;
    }
    /*IOS specific*/
    linphone_core_start_dtmf_stream(theLinphoneCore);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted){
                             }];
    
    /*start the video preview in case we are in the main view*/
    if (linphone_core_video_display_enabled(theLinphoneCore) && [self lpConfigBoolForKey:@"preview_preference"]) {
        linphone_core_enable_video_preview(theLinphoneCore, TRUE);
    }
    /*check last keepalive handler date*/
    if (mLastKeepAliveDate != Nil) {
        NSDate *current = [NSDate date];
        if ([current timeIntervalSinceDate:mLastKeepAliveDate] > 700) {
            NSString *datestr = [mLastKeepAliveDate description];
            KDSLog(@"keepalive handler was called for the last time at %@", datestr);
        }
    }
    
    [self enableProxyPublish:YES];
}
- (void)createLinphoneCore {
    
    [self migrationAllPre];
    if (theLinphoneCore != nil) {
        KDSLog(@"linphonecore is already created");
        return;
    }
    //[Log enableLogs:[self lpConfigIntForKey:@"debugenable_preference"]];
    //日志输出相关
    [self enableLogs:BCTBX_LOG_FATAL];
    connectivity = none;
    
    // Set audio assets
    NSString *ring =
    ([LinphoneManager bundleFile:[self lpConfigStringForKey:@"local_ring" inSection:@"sound"].lastPathComponent]
     ?: [LinphoneManager bundleFile:@"notes_of_the_optimistic1.caf"])
    .lastPathComponent;
    NSString *ringback =
    ([LinphoneManager bundleFile:[self lpConfigStringForKey:@"remote_ring" inSection:@"sound"].lastPathComponent]
     ?: [LinphoneManager bundleFile:@"ringback.wav"])
    .lastPathComponent;
    NSString *hold =
    ([LinphoneManager bundleFile:[self lpConfigStringForKey:@"hold_music" inSection:@"sound"].lastPathComponent]
     ?: [LinphoneManager bundleFile:@"hold.mkv"])
    .lastPathComponent;
    [self lpConfigSetString:[LinphoneManager bundleFile:ring] forKey:@"local_ring" inSection:@"sound"];
    [self lpConfigSetString:[LinphoneManager bundleFile:ringback] forKey:@"remote_ring" inSection:@"sound"];
    [self lpConfigSetString:[LinphoneManager bundleFile:hold] forKey:@"hold_music" inSection:@"sound"];
    
    theLinphoneCore = linphone_core_new_with_config(&linphonec_vtable, _configDb, (__bridge void *)(self));
    KDSLog(@"Create linphonecore %p", theLinphoneCore);
    // Load plugins if available in the linphone SDK - otherwise these calls will do nothing
    MSFactory *f = linphone_core_get_ms_factory(theLinphoneCore);
    libmssilk_init(f);
    libmsamr_init(f);
    libmsx264_init(f);
    libmsopenh264_init(f);
    //    libmsbcg729_init(f);
    libmswebrtc_init(f);
    linphone_core_reload_ms_plugins(theLinphoneCore, NULL);
    [self migrationAllPost];
    //设置CA证书
    /* set the CA file no matter what, since the remote provisioning could be hitting an HTTPS server */
    linphone_core_set_root_ca(theLinphoneCore, [LinphoneManager bundleFile:@"rootca.pem"].UTF8String);
    linphone_core_set_user_certificates_path(theLinphoneCore, [LinphoneManager cacheDirectory].UTF8String);
    
    /* The core will call the linphone_iphone_configuring_status_changed callback when the remote provisioning is loaded
     (or skipped).
     Wait for this to finish the code configuration */
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(audioSessionInterrupted:)
                                               name:AVAudioSessionInterruptionNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(globalStateChangedNotificationHandler:)
                                               name:kLinphoneGlobalStateUpdate
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(configuringStateChangedNotificationHandler:)
                                               name:kLinphoneConfiguringStateUpdate
                                             object:nil];
    
    /*call iterate once immediately in order to initiate background connections with sip server or remote provisioning
     * grab, if any */
    linphone_core_iterate(theLinphoneCore);

    // start scheduler
    mIterateTimer =
    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(iterate) userInfo:nil repeats:YES];
}

- (void)resetLinphoneCore {
    [self destroyLinphoneCore];
    [self createLinphoneCore];
    // reload friends
    //    [self.fastAddressBook reload];
    
    // reset network state to trigger a new network connectivity assessment
    linphone_core_set_network_reachable(theLinphoneCore, FALSE);
}

static int comp_call_id(const LinphoneCall *call, const char *callid) {
    if (linphone_call_log_get_call_id(linphone_call_get_call_log(call)) == nil) {
        ms_error("no callid for call [%p]", call);
        return 1;
    }
    return strcmp(linphone_call_log_get_call_id(linphone_call_get_call_log(call)), callid);
}

- (LinphoneCall *)callByCallId:(NSString *)call_id {
    const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
    if (!calls) {
        return NULL;
    }
    bctbx_list_t *call_tmp = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [call_id UTF8String]);
    if (!call_tmp) {
        return NULL;
    }
    LinphoneCall *call = (LinphoneCall *)call_tmp->data;
    return call;
}
- (void)cancelLocalNotifTimerForCallId:(NSString *)callid {
    // first, make sure this callid is not already involved in a call
    const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
    bctbx_list_t *call = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String]);
    if (call != NULL) {
        LinphoneCallAppData *data =
        (__bridge LinphoneCallAppData *)(linphone_call_get_user_data((LinphoneCall *)call->data));
        if (data->timer)
            [data->timer invalidate];
        data->timer = nil;
        return;
    }
}
#pragma mark - LOG
- (void)enableLogs:(OrtpLogLevel)level {
    BOOL enabled = (level >= ORTP_DEBUG && level < ORTP_ERROR);
    static BOOL stderrInUse = NO;
    if (!stderrInUse) {
        asl_add_log_file(NULL, STDERR_FILENO);
        stderrInUse = YES;
    }
    //    linphone_core_set_log_collection_path([self cacheDirectory].UTF8String);
    //    linphone_core_enable_logs_with_cb(linphone_iphone_log_handler);
    //    linphone_core_enable_log_collection(enabled);
    if (level == 0) {
        linphone_core_set_log_level(ORTP_FATAL);
        ortp_set_log_level("ios", ORTP_FATAL);
        KDSLog(@"I/%s/Disabling all logs", ORTP_LOG_DOMAIN);
    } else {
        KDSLog(@"I/%s/Enabling %s logs", ORTP_LOG_DOMAIN, (enabled ? "all" : "application only"));
        linphone_core_set_log_level(level);
        ortp_set_log_level("ios", level == ORTP_DEBUG ? ORTP_DEBUG : ORTP_MESSAGE);
    }
}
- (void)acceptCallForCallId:(NSString *)callid {
    // first, make sure this callid is not already involved in a call
    const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
    bctbx_list_t *call = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String]);
    
    
    
    
    if (call != NULL) {
        const LinphoneVideoPolicy *video_policy = linphone_core_get_video_policy(theLinphoneCore);
        bool with_video = video_policy->automatically_accept;
        [self acceptCall:(LinphoneCall *)call->data evenWithVideo:with_video];
        return;
    };
}
- (void)addPushCallId:(NSString *)callid {
    // first, make sure this callid is not already involved in a call
    const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
    if (bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String])) {
        KDSLog(@"Call id [%@] already handled", callid);
        return;
    };
    if ([pushCallIDs count] > 10 /*max number of pending notif*/)
        [pushCallIDs removeObjectAtIndex:0];
    
    [pushCallIDs addObject:callid];
}

- (BOOL)popPushCallID:(NSString *)callId {
    for (NSString *pendingNotif in pushCallIDs) {
        if ([pendingNotif compare:callId] == NSOrderedSame) {
            [pushCallIDs removeObject:pendingNotif];
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)resignActive {
    linphone_core_stop_dtmf_stream(theLinphoneCore);
    
    return YES;
}


- (void)call:(const LinphoneAddress *)iaddr {
    
    // First verify that network is available, abort otherwise.
    if (!linphone_core_is_network_reachable(theLinphoneCore)) {
        KDSLog(@"Network Error", nil);
        return;
    }
    
    // Then check that no GSM calls are in progress, abort otherwise.
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    if ([callCenter currentCalls] != nil && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        KDSLog(@"GSM call in progress, cancelling outgoing SIP call request");
        return;
    }
    
    // Then check that the supplied address is valid
    if (!iaddr) {
        KDSLog(@"Invalid SIP address");
        return;
    }
    
    if (linphone_core_get_calls_nb(theLinphoneCore) < 1 &&
        floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max ){
        
        /*
         self.providerDelegate.callKitCalls++;
         NSUUID *uuid = [NSUUID UUID];
         [LinphoneManager.instance.providerDelegate.uuids setObject:uuid forKey:@""];
         LinphoneManager.instance.providerDelegate.pendingAddr = linphone_address_clone(iaddr);
         NSString *address = [FastAddressBook displayNameForAddress:iaddr];
         CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:address];
         CXStartCallAction *act = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
         CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
         [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
         completion:^(NSError *err){
         }];
         */
        [self doCall:iaddr];
    } else {
        [self doCall:iaddr];
    }
}

- (BOOL)doCall:(const LinphoneAddress *)iaddr {
    
    LinphoneAddress *addr = linphone_address_clone(iaddr);
    //    NSString *displayName = [FastAddressBook displayNameForAddress:addr];
    
    // Finally we can make the call
    LinphoneCallParams *lcallParams = linphone_core_create_call_params(theLinphoneCore, NULL);
    if ([self lpConfigBoolForKey:@"edge_opt_preference"] && (self.network == network_2g)) {
        KDSLog(@"Enabling low bandwidth mode");
        linphone_call_params_enable_low_bandwidth(lcallParams, YES);
    }
    
    //    if (displayName != nil) {
    //        linphone_address_set_display_name(addr, displayName.UTF8String);
    //    }
    if ([LinphoneManager.instance lpConfigBoolForKey:@"override_domain_with_default_one"]) {
        linphone_address_set_domain(
                                    addr, [[LinphoneManager.instance lpConfigStringForKey:@"domain" inSection:@"assistant"] UTF8String]);
    }
    
    LinphoneCall *call;
    if (LinphoneManager.instance.nextCallIsTransfer) {
        char *caddr = linphone_address_as_string(addr);
        call = linphone_core_get_current_call(theLinphoneCore);
        linphone_call_transfer(call, caddr);
        LinphoneManager.instance.nextCallIsTransfer = NO;
        ms_free(caddr);
    } else {
        call = linphone_core_invite_address_with_params(theLinphoneCore, addr, lcallParams);
        if (call) {
            
            // The LinphoneCallAppData object should be set on call creation with callback
            // - (void)onCall:StateChanged:withMessage:. If not, we are in big trouble and expect it to crash
            // We are NOT responsible for creating the AppData.
            LinphoneCallAppData *data = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
            if (data == nil) {
                KDSLog(@"New call instanciated but app data was not set. Expect it to crash.");
                /* will be used later to notify user if video was not activated because of the linphone core*/
            } else {
                data->videoRequested = linphone_call_params_video_enabled(lcallParams);
                //                linphone_core_invite(LC, linphone_address_as_string(iaddr));
            }
        }
    }
    linphone_address_unref(addr);
    linphone_call_params_unref(lcallParams);
    
    return TRUE;
}
#pragma mark - 拨打电话 是否开启视频
- (void)callPhoneWithPhoneNumber:(NSString *)phone wihtVideo:(BOOL)video{
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
    if (!cfg) {
        return;
    }
    LinphoneAddress *address = [LinphoneManager.instance normalizeSipOrPhoneAddress:phone andNickName:nil];
    linphone_core_enable_video_display(LC, video);
    [LinphoneManager.instance call:address showVideo:video];
    if (address) {
        linphone_address_unref(address);
    }
}
#pragma mark - 关闭话筒 Yes：关闭，NO：打开
- (void)closeOrOnSpeak:(BOOL)close{
    if (close) {
        linphone_core_enable_mic(LC, true);
    }else{
        linphone_core_enable_mic(LC, false);
        
    }
}
#pragma mark - 打开视频
- (void)openVideo{
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        //        LinphoneCallAppData *callAppData = (__bridge LinphoneCallAppData *)linphone_call_get_user_pointer(call);
        //        callAppData->videoRequested =
        //        TRUE; /* will be used later to notify user if video was not activated because of the linphone core*/
        LinphoneCallParams *call_params = linphone_core_create_call_params(LC,call);
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(LC, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        KDSLog(@"Cannot toggle video button, because no current call");
    }
}
#pragma mark - 关闭视频 保留通话
- (void)closeVideoOnly{
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        LinphoneCallParams *call_params = linphone_core_create_call_params(LC,call);
        linphone_call_params_enable_video(call_params, FALSE);
        linphone_core_update_call(LC, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        KDSLog(@"Cannot toggle video button, because no current call");
    }
}
#pragma mark - Property Functions

- (void)setPushNotificationToken:(NSData *)apushNotificationToken {
    if (apushNotificationToken == _pushNotificationToken) {
        return;
    }
    _pushNotificationToken = apushNotificationToken;
    
    @try {
        const MSList *proxies = linphone_core_get_proxy_config_list(LC);
        while (proxies) {
            [self configurePushTokenForProxyConfig:proxies->data];
            proxies = proxies->next;
        }
    } @catch (NSException* e) {
        KDSLog(@"%s: linphone core not ready yet, ignoring push token", __FUNCTION__);
    }
}

- (void)configurePushTokenForProxyConfig:(LinphoneProxyConfig *)proxyCfg {
    linphone_proxy_config_edit(proxyCfg);
    
    NSData *tokenData = _pushNotificationToken;
    const char *refkey = linphone_proxy_config_get_ref_key(proxyCfg);
    BOOL pushNotifEnabled = (refkey && strcmp(refkey, "push_notification") == 0);
    if (tokenData != nil && pushNotifEnabled) {
        const unsigned char *tokenBuffer = [tokenData bytes];
        NSMutableString *tokenString = [NSMutableString stringWithCapacity:[tokenData length] * 2];
        for (int i = 0; i < [tokenData length]; ++i) {
            [tokenString appendFormat:@"%02X", (unsigned int)tokenBuffer[i]];
        }
        // NSLocalizedString(@"IC_MSG", nil); // Fake for genstrings
        // NSLocalizedString(@"IM_MSG", nil); // Fake for genstrings
        // NSLocalizedString(@"IM_FULLMSG", nil); // Fake for genstrings
#ifdef DEBUG
#define APPMODE_SUFFIX @"dev"
#else
#define APPMODE_SUFFIX @"prod"
#endif
        NSString *ring =
        ([LinphoneManager bundleFile:[self lpConfigStringForKey:@"local_ring" inSection:@"sound"].lastPathComponent]
         ?: [LinphoneManager bundleFile:@"notes_of_the_optimistic1.caf"])
        .lastPathComponent;
        NSString * notif_type;
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
            //IOS 8 and more
            notif_type = @".voip";
        } else {
            // IOS 7 and below
            notif_type = @"";
        }
        NSString *timeout;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
            timeout = @";pn-timeout=0";
        } else {
            timeout = @"";
        }
        
        NSString *silent;
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
            silent = @";pn-silent=1";
        } else {
            silent = @"";
        }
        
        NSString *params = [NSString
                            stringWithFormat:@"app-id=%@%@.%@;pn-type=apple;pn-tok=%@;pn-msg-str=IM_MSG;pn-call-str=IC_MSG;pn-"
                            @"call-snd=%@;pn-msg-snd=msg.caf%@%@",
                            [[NSBundle mainBundle] bundleIdentifier], notif_type, APPMODE_SUFFIX, tokenString, ring, timeout, silent];
        
        //        KDSLog(@"Proxy config %s configured for push notifications with contact: %@",
        //             linphone_proxy_config_get_identity_address(proxyCfg), params);
        linphone_proxy_config_set_contact_uri_parameters(proxyCfg, [params UTF8String]);
        linphone_proxy_config_set_contact_parameters(proxyCfg, NULL);
    } else {
        //        KDSLog(@"Proxy config %s NOT configured for push notifications", linphone_proxy_config_get_identity_address(proxyCfg));
        // no push token:
        linphone_proxy_config_set_contact_uri_parameters(proxyCfg, NULL);
        linphone_proxy_config_set_contact_parameters(proxyCfg, NULL);
    }
    
    linphone_proxy_config_done(proxyCfg);
}

#pragma mark - Misc Functions

+ (NSString *)bundleFile:(NSString *)file {
    return [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
}

+ (NSString *)documentFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:file];
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    // cache directory must be created if not existing
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
    }
    return cachePath;
}

+ (int)unreadMessageCount {
    int count = 0;
    const MSList *rooms = linphone_core_get_chat_rooms(LC);
    const MSList *item = rooms;
    while (item) {
        LinphoneChatRoom *room = (LinphoneChatRoom *)item->data;
        if (room) {
            count += linphone_chat_room_get_unread_messages_count(room);
        }
        item = item->next;
    }
    
    return count;
}

+ (BOOL)copyFile:(NSString *)src destination:(NSString *)dst override:(BOOL)override {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:src] == NO) {
        KDSLog(@"Can't find \"%@\": %@", src, [error localizedDescription]);
        return FALSE;
    }
    if ([fileManager fileExistsAtPath:dst] == YES) {
        if (override) {
            [fileManager removeItemAtPath:dst error:&error];
            if (error != nil) {
                KDSLog(@"Can't remove \"%@\": %@", dst, [error localizedDescription]);
                return FALSE;
            }
        } else {
            KDSLog(@"\"%@\" already exists", dst);
            return FALSE;
        }
    }
    [fileManager copyItemAtPath:src toPath:dst error:&error];
    if (error != nil) {
        KDSLog(@"Can't copy \"%@\" to \"%@\": %@", src, dst, [error localizedDescription]);
        return FALSE;
    }
    return TRUE;
}

- (void)configureVbrCodecs {
    PayloadType *pt;
    int bitrate = lp_config_get_int(
                                    _configDb, "audio", "codec_bitrate_limit",
                                    kLinphoneAudioVbrCodecDefaultBitrate); /*default value is in linphonerc or linphonerc-factory*/
    const MSList *audio_codecs = linphone_core_get_audio_codecs(theLinphoneCore);
    const MSList *codec = audio_codecs;
    while (codec) {
        pt = codec->data;
        if (linphone_payload_type_is_vbr(pt)) {
            linphone_core_set_payload_type_bitrate(theLinphoneCore, pt, bitrate);
        }
        codec = codec->next;
    }
}


+ (id)getMessageAppDataForKey:(NSString *)key inMessage:(LinphoneChatMessage *)msg {
    
    if (msg == nil)
        return nil;
    
    id value = nil;
    const char *appData = linphone_chat_message_get_appdata(msg);
    if (appData) {
        NSDictionary *appDataDict =
        [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:appData length:strlen(appData)]
                                        options:0
                                          error:nil];
        value = [appDataDict objectForKey:key];
    }
    return value;
}

+ (void)setValueInMessageAppData:(id)value forKey:(NSString *)key inMessage:(LinphoneChatMessage *)msg {
    
    NSMutableDictionary *appDataDict = [NSMutableDictionary dictionary];
    const char *appData = linphone_chat_message_get_appdata(msg);
    if (appData) {
        appDataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:appData length:strlen(appData)]
                                                      options:NSJSONReadingMutableContainers
                                                        error:nil];
    }
    
    [appDataDict setValue:value forKey:key];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:appDataDict options:0 error:nil];
    NSString *appdataJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    linphone_chat_message_set_appdata(msg, [appdataJSON UTF8String]);
}

#pragma mark - LPConfig Functions

- (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key {
    [self lpConfigSetString:value forKey:key inSection:LINPHONERC_APPLICATION_KEY];
}
- (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section {
    if (!key)
        return;
    lp_config_set_string(_configDb, [section UTF8String], [key UTF8String], value ? [value UTF8String] : NULL);
}
- (NSString *)lpConfigStringForKey:(NSString *)key {
    return [self lpConfigStringForKey:key withDefault:nil];
}
- (NSString *)lpConfigStringForKey:(NSString *)key withDefault:(NSString *)defaultValue {
    return [self lpConfigStringForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue];
}
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section {
    return [self lpConfigStringForKey:key inSection:section withDefault:nil];
}
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section withDefault:(NSString *)defaultValue {
    if (!key)
        return defaultValue;
    const char *value = lp_config_get_string(_configDb, [section UTF8String], [key UTF8String], NULL);
    return value ? [NSString stringWithUTF8String:value] : defaultValue;
}

- (void)lpConfigSetInt:(int)value forKey:(NSString *)key {
    [self lpConfigSetInt:value forKey:key inSection:LINPHONERC_APPLICATION_KEY];
}
- (void)lpConfigSetInt:(int)value forKey:(NSString *)key inSection:(NSString *)section {
    if (!key)
        return;
    lp_config_set_int(_configDb, [section UTF8String], [key UTF8String], (int)value);
}
- (int)lpConfigIntForKey:(NSString *)key {
    return [self lpConfigIntForKey:key withDefault:-1];
}
- (int)lpConfigIntForKey:(NSString *)key withDefault:(int)defaultValue {
    return [self lpConfigIntForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue];
}
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section {
    return [self lpConfigIntForKey:key inSection:section withDefault:-1];
}
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section withDefault:(int)defaultValue {
    if (!key)
        return defaultValue;
    return lp_config_get_int(_configDb, [section UTF8String], [key UTF8String], (int)defaultValue);
}

- (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key {
    [self lpConfigSetBool:value forKey:key inSection:LINPHONERC_APPLICATION_KEY];
}
- (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key inSection:(NSString *)section {
    [self lpConfigSetInt:(int)(value == TRUE) forKey:key inSection:section];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key {
    return [self lpConfigBoolForKey:key withDefault:FALSE];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key withDefault:(BOOL)defaultValue {
    return [self lpConfigBoolForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section {
    return [self lpConfigBoolForKey:key inSection:section withDefault:FALSE];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section withDefault:(BOOL)defaultValue {
    if (!key)
        return defaultValue;
    int val = [self lpConfigIntForKey:key inSection:section withDefault:-1];
    return (val != -1) ? (val == 1) : defaultValue;
}


#pragma mark - GSM management

- (void)removeCTCallCenterCb {
    if (mCallCenter != nil) {
        KDSLog(@"Removing CT call center listener [%p]", mCallCenter);
        mCallCenter.callEventHandler = NULL;
    }
    mCallCenter = nil;
}


static int comp_call_state_paused(const LinphoneCall *call, const void *param) {
    return linphone_call_get_state(call) != LinphoneCallPaused;
}
- (void)startPushLongRunningTask:(BOOL)msg {
    [[UIApplication sharedApplication] endBackgroundTask:pushBgTask];
    pushBgTask = 0;
    pushBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            if (msg) {
                KDSLog(@"Incomming message couldn't be received");
                if (0) {
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.title = NSLocalizedString(@"Message received", nil);
                    content.body = NSLocalizedString(@"You have received a message.", nil);
                    content.categoryIdentifier = @"push_msg";
                    
                    UNNotificationRequest *req =
                    [UNNotificationRequest requestWithIdentifier:@"push_msg" content:content trigger:NULL];
                    [[UNUserNotificationCenter currentNotificationCenter]
                     addNotificationRequest:req
                     withCompletionHandler:^(NSError *_Nullable error) {
                         // Enable or disable features based on authorization.
                         if (error) {
                             KDSLog(@"Error while adding notification request :");
                             KDSLog(@"%@", error.description);
                         }
                     }];
                } else {
                    // Fallback on earlier versions
                }
                
            } else {
                KDSLog(@"Incomming call couldn't be received");
                if (0) {
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.title = NSLocalizedString(@"Missed call", nil);
                    content.body = NSLocalizedString(@"You have missed a call.", nil);
                    content.categoryIdentifier = @"push_call";
                    
                    UNNotificationRequest *req =
                    [UNNotificationRequest requestWithIdentifier:@"push_call" content:content trigger:NULL];
                    [[UNUserNotificationCenter currentNotificationCenter]
                     addNotificationRequest:req
                     withCompletionHandler:^(NSError *_Nullable error) {
                         // Enable or disable features based on authorization.
                         if (error) {
                             KDSLog(@"Error while adding notification request :");
                             KDSLog(@"%@", error.description);
                         }
                     }];
                } else {
                    // Fallback on earlier versions
                }
                
            }
        }
        for (NSString *key in [LinphoneManager.instance.pushDict allKeys]) {
            [LinphoneManager.instance.pushDict setValue:[NSNumber numberWithInt:0] forKey:key];
        }
        [[UIApplication sharedApplication] endBackgroundTask:pushBgTask];
        pushBgTask = 0;
        
    }];
    KDSLog(@"Long running task started, remaining [%g s] because a push has been received",
    [[UIApplication sharedApplication] backgroundTimeRemaining]);
}
- (void)destroyLinphoneCore {
    [mIterateTimer invalidate];
    // just in case
    [self removeCTCallCenterCb];
    if (theLinphoneCore != nil) { // just in case application terminate before linphone core initialization
        
        linphone_core_unref(theLinphoneCore);
        KDSLog(@"Destroy linphonecore %p", theLinphoneCore);
        theLinphoneCore = nil;
        
        // Post event
        NSDictionary *dict =
        [NSDictionary dictionaryWithObject:[NSValue valueWithPointer:theLinphoneCore] forKey:@"core"];
        [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCoreUpdate
                                                          object:LinphoneManager.instance
                                                        userInfo:dict];
        
        SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (proxyReachability)
            CFRelease(proxyReachability);
        proxyReachability = nil;
    }
    libStarted = FALSE;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (void)removeAllAccounts {
    linphone_core_clear_proxy_config(LC);
    linphone_core_clear_all_auth_info(LC);
}

+ (BOOL)isMyself:(const LinphoneAddress *)addr {
    if (!addr)
        return NO;
    
    const MSList *it = linphone_core_get_proxy_config_list(LC);
    while (it) {
        if (linphone_address_weak_equal(addr, linphone_proxy_config_get_identity_address(it->data))) {
            return YES;
        }
        it = it->next;
    }
    return NO;
}
//通话被打断
- (void)beginInterruption {
    LinphoneCall *c = linphone_core_get_current_call(theLinphoneCore);
    KDSLog(@"Sound interruption detected!");
    if (c && linphone_call_get_state(c) == LinphoneCallStreamsRunning) {
        linphone_call_pause(c);
    }
}
//被截断状态结束
- (void)endInterruption {
    KDSLog(@"Sound interruption ended!");
}
- (void)enableProxyPublish:(BOOL)enabled {
    if (linphone_core_get_global_state(LC) != LinphoneGlobalOn || !linphone_core_get_default_friend_list(LC)) {
        KDSLog(@"Not changing presence configuration because linphone core not ready yet");
        return;
    }
    
    if ([self lpConfigBoolForKey:@"publish_presence"]) {
        // set present to "tv", because "available" does not work yet
        if (enabled) {
            linphone_core_set_presence_model(
                                             LC, linphone_core_create_presence_model_with_activity(LC, LinphonePresenceActivityTV, NULL));
        }
        
        const MSList *proxies = linphone_core_get_proxy_config_list(LC);
        while (proxies) {
            LinphoneProxyConfig *cfg = proxies->data;
            linphone_proxy_config_edit(cfg);
            linphone_proxy_config_enable_publish(cfg, enabled);
            linphone_proxy_config_done(cfg);
            proxies = proxies->next;
        }
        // force registration update first, then update friend list subscription
        linphone_core_iterate(theLinphoneCore);
    }
    
    linphone_friend_list_enable_subscriptions(linphone_core_get_default_friend_list(LC),
                                              enabled &&
                                              [LinphoneManager.instance lpConfigBoolForKey:@"use_rls_presence"]);
}

- (void)setupGSMInteraction {
    
    [self removeCTCallCenterCb];
    mCallCenter = [[CTCallCenter alloc] init];
    KDSLog(@"Adding CT call center listener [%p]", mCallCenter);
    __block __weak LinphoneManager *weakSelf = self;
    __block __weak CTCallCenter *weakCCenter = mCallCenter;
    mCallCenter.callEventHandler = ^(CTCall *call) {
        // post on main thread
        [weakSelf performSelectorOnMainThread:@selector(handleGSMCallInteration:)
                                   withObject:weakCCenter
                                waitUntilDone:YES];
    };
}

- (NSString *)contactFilter {
    NSString *filter = @"*";
    if ([self lpConfigBoolForKey:@"contact_filter_on_default_domain"]) {
        LinphoneProxyConfig *proxy_cfg = linphone_core_get_default_proxy_config(theLinphoneCore);
        if (proxy_cfg && linphone_proxy_config_get_addr(proxy_cfg)) {
            return [NSString stringWithCString:linphone_proxy_config_get_domain(proxy_cfg)
                                      encoding:[NSString defaultCStringEncoding]];
        }
    }
    return filter;
}
#pragma mark- 被电话中断了

- (void)handleGSMCallInteration:(id)cCenter {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        CTCallCenter *ct = (CTCallCenter *)cCenter;
        // pause current call, if any
        LinphoneCall *call = linphone_core_get_current_call(theLinphoneCore);
        if ([ct currentCalls] != nil) {
            if (call) {
                KDSLog(@"Pausing SIP call because GSM call");
                linphone_call_pause(call);
                [self startCallPausedLongRunningTask];
            } else if (linphone_core_is_in_conference(theLinphoneCore)) {
                KDSLog(@"Leaving conference call because GSM call");
                linphone_core_leave_conference(theLinphoneCore);
                [self startCallPausedLongRunningTask];
            }
        } // else nop, keep call in paused state
    }
}
- (void)startCallPausedLongRunningTask {
    
    pausedCallBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        KDSLog(@"Call cannot be paused any more, too late");
        [[UIApplication sharedApplication] endBackgroundTask:pausedCallBgTask];
    }];
    KDSLog(@"Long running task started, remaining [%g s] because at least one call is paused",
           [[UIApplication sharedApplication] backgroundTimeRemaining]);
}
#pragma mark - GSM management
- (void)renameDefaultSettings {
    // rename .linphonerc to linphonerc to ease debugging: when downloading
    // containers from MacOSX, Finder do not display hidden files leading
    // to useless painful operations to display the .linphonerc file
    NSString *src = [LinphoneManager documentFile:@".linphonerc"];
    NSString *dst = [LinphoneManager documentFile:@"linphonerc"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileError = nil;
    if ([fileManager fileExistsAtPath:src]) {
        if ([fileManager fileExistsAtPath:dst]) {
            [fileManager removeItemAtPath:src error:&fileError];
            KDSLog(@"%@ already exists, simply removing %@ %@", dst, src,
                   fileError ? fileError.localizedDescription : @"successfully");
        } else {
            [fileManager moveItemAtPath:src toPath:dst error:&fileError];
            KDSLog(@"%@ moving to %@ %@", dst, src, fileError ? fileError.localizedDescription : @"successfully");
        }
    }
}

// ugly hack to export symbol from liblinphone so that they are available for the linphoneTests target
// linphoneTests target do not link with liblinphone but instead dynamically link with ourself which is
// statically linked with liblinphone, so we must have exported required symbols from the library to
// have them available in linphoneTests
// DO NOT INVOKE THIS METHOD

- (void)exportSymbolsForUITests {
    linphone_address_set_header(NULL, NULL, NULL);
}
#pragma mark - 清除path文件夹下缓存大小
+(BOOL)clearCacheWithFilePath:(NSString *)path{
    
    //拿到path路径的下一级目录的子文件夹
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    NSString *filePath = nil;
    
    NSError *error = nil;
    
    for (NSString *subPath in subPathArr)
    {
        filePath = [path stringByAppendingPathComponent:subPath];
        
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"删除shi'bai");
            return NO;
        }
    }
    return YES;
}
#pragma mark - 获取当前时间的 时间戳
-(NSInteger)getNowTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间
    NSLog(@"设备当前的时间:%@",[formatter stringFromDate:datenow]);
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    return timeSp;
}

#pragma mark -创建一个udp socket
- (void)createUDPSocket
{
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    //绑定端口号 , qu别与TCP ， UDP不需要连接
    LinphoneTransports *transport = nil;
    transport = linphone_core_get_transports_used(theLinphoneCore);
    int port = linphone_transports_get_udp_port(transport);
    NSError *error = nil;
    if (![self.udpSocket bindToPort:port error:&error])
    {
        NSLog(@"Error binding(_sendTextUdpSocket):%@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving(_sendTextUdpSocket): %@", error);
        return;
    }
}
#pragma mark -GCDAsyncUdpSocketDelegate
- (void)sendMsg:(NSString *)msg
{
    LinphoneTransports *transport = nil;
    transport = linphone_core_get_transports_used(theLinphoneCore);
    int port = linphone_transports_get_udp_port(transport);
    linphone_transports_unref(transport);
//    NSLog(@"--{Kaadas}--自己给自己发送invite包");
    NSLog(@"--{Kaadas}--udp_port=%d",port);
    NSLog(@"--{Kaadas}--sipmsg=%@",msg);
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:data toHost:@"127.0.0.1" port:port withTimeout:-1 tag:1001];
    NSLog(@"--{Kaadas}--self.udpSocket sendData:=%@",msg);
}
//发送成功回调
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"did Send Data");
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    //接收到的数据
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"GCDAsyncUdpSocket Recevive%@", msg);
}
@end

#pragma mark - -------categary
@implementation NSString (md5)

- (BOOL)containsSubstring:(NSString *)str {
    if (UIDevice.currentDevice.systemVersion.doubleValue >= 8.0) {
#pragma deploymate push "ignored-api-availability"
        return [self containsString:str];
#pragma deploymate pop
    }
    return ([self rangeOfString:str].location != NSNotFound);
}
@end

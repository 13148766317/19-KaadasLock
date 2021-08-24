//
//  AppDelegate.m
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "AppDelegate.h"
#import "KDSTabBarController.h"
#import "KDSLoginViewController.h"
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import "KDSHttpManager.h"
#import "KDSDBManager.h"
#import "KDSNavigationController.h"
#import "KDSWelcomeVC.h"
#import "LinphoneManager.h"
#import "KDSSecurityAuthenticationVC.h"
#import "MBProgressHUD+MJ.h"
#import <Bugly/Bugly.h>
#import "XMPlayController.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate,PKPushRegistryDelegate>


///监听用户长时间不活动的定时器。
@property (nonatomic, strong) NSTimer *timer;
///记录是否在后台
@property (nonatomic, assign) BOOL isBackground;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"--{Kaadas}--didFinishLaunchingWithOptions");
    
    // Override point for customization after application launch.
    //判断是否有远程消息通知触发应用程序启动
    //配置日志
    [KDSAppLog defaultConfig];
    //指定应用配置文件与解密数据密码
    [KDSAppSettings setConfigFilePath:[[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"json"] passwd:[@[@"kds",@"3456789abc",@"ios"] componentsJoinedByString:@""]];
    //设置应用使用那个配置，对应AppConfig.json data.settingValues下的key名称
#define kSettingValuesDebugNameKey  @"Debug"
    //正式发布，配置相关服务器
#define kSettingValuesAppStoreNameKey  @"AppStore"
    //给测试人员测试，配置相关服务器
#define kSettingValuesAdHotNameKey  @"AdHot"

#ifdef DEBUG
    NSString *settingName = kSettingValuesAppStoreNameKey;
#else
    NSString *settingName = kSettingValuesAppStoreNameKey;
#endif
    

    [[KDSAppSettings sharedInstance] applySettingValuesWithName:settingName];
   
    KDSLog(@"KDSToolKitConfigHttpServer: %@",[[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigHttpServer]);
    self.isBackground = NO;
    
    
    if (launchOptions) {
        NSDictionary *pushInfo =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"--{Kaadas}--程序未启动pushInfo==%@",pushInfo);
        if (pushInfo) {
            NSString * wifiSn = [[pushInfo objectForKey:@"extras"] objectForKey:@"wifiSN"];
            if ([[[pushInfo objectForKey:@"extras"] objectForKey:@"func"] isEqualToString:@"doorbell"]){
                ///门铃呼叫
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDSXMMediaDoorBeellNotification object:nil userInfo:@{@"wifiSn":wifiSn}];
                });
            }
        }
    }
    

    /*判断当前系统语言
    NSArray  *languages = [NSLocale preferredLanguages];
    NSString *language = [languages objectAtIndex:0];
    if ([language hasPrefix:@"zh-Hans"]) {
        [KDSTool setLanguage:JianTiZhongWen];
    } else{
        [KDSTool setLanguage:English];
    }
     */
    
    //不管系统是啥语言app都是显示中文
    [KDSTool setLanguage:JianTiZhongWen];
    [Bugly startWithAppId:@"b9cbfc9022"];
    [self timer];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginTokenExpired:) name:KDSHttpTokenExpiredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:KDSLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegatelicantionDidBecomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmMediamqttNotification:) name:KDSMQTTEventNotification object:nil];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [UITabBar appearance].translucent = NO;
    //为了避免push和pop时导航条出现的黑块，给window设置一个背景色
    self.window.backgroundColor = [UIColor whiteColor];
    
    //注册VoIP推送服务
    [self registPushkit];
    //申请推送通知权限
    [self replyPushNotificationAuthorization:application];

    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
    }
    
    [WXApi registerApp:shareSDKWXAppID];
    
    [self.window makeKeyAndVisible];
    
    [self applicationWillEnterForeground:application];
    
    return YES;
}

#pragma mark - 本地推送
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    KDSLog(@"%@",notification.userInfo);
    //这里，你就可以通过notification的useinfo，干一些你想做的事情了
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - 通知
///登录token过期通知。
- (void)loginTokenExpired:(NSNotification *)noti
{
    //如果以后需要清空一些变量等，可以在这个方法执行。
    KDSUser *user = [KDSUserManager sharedManager].user;
    NSString *token = user.token;
    user.token = nil;
    [[KDSDBManager sharedManager] updateUser:user];
    [[KDSUserManager sharedManager] resetManager];
    [[KDSDBManager sharedManager] resetDatabase];
    if (!token) return;
    [self setRootViewController];
    [[LinphoneManager instance] setSipAcountStatus:NO];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tokenExpired") message:Localized(@"pleaseRelogin") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}

///退出登录通知。
- (void)logout:(NSNotification *)noti
{
    //启动时安全验证页选择使用密码登录时，用户管理单例的user属性为空。
    KDSUser *user = [KDSUserManager sharedManager].user ?: [[KDSDBManager sharedManager] queryUser];
    user.token = nil;
    [[LinphoneManager instance] setSipAcountStatus:NO];
    [[LinphoneManager instance] enterBackgroundMode];
    [[KDSDBManager sharedManager] updateUser:user];
    [[KDSDBManager sharedManager] resetDatabase];
    [[KDSDBManager sharedManager] clearDiskCache];
    [[KDSUserManager sharedManager] resetManager];
    [[LinphoneManager instance] destroyLinphoneCore];
    [self setRootViewController];
}
-(void)appDelegatelicantionDidBecomActive:(NSNotification *)notification
{
    //监听网络状态
    [[KDSUserManager sharedManager] monitorNetWork];
}
///收到讯美相关的报警信息
- (void)xmMediamqttNotification:(NSNotification *)noti
{
    //0x60：门铃报警
    if (!self.isBackground) {
        MQTTSubEvent event = noti.userInfo[MQTTEventKey];
        NSDictionary *param = noti.userInfo[MQTTEventParamKey];
        if ([event isEqualToString:MQTTSubEventWIfiLockAlarm])
        {
            for (KDSLock * lock in [KDSUserManager sharedManager].locks)
            {
                if (lock.wifiDevice) {
                    if ([param[@"wfId"] isEqualToString: lock.wifiDevice.wifiSN]){
                        int alarmCode = [param[@"alarmCode"] intValue];
                        if (alarmCode == 96 && [KDSUserManager sharedManager].doorbellProgress == NO) {
                            NSLog(@"当前收到门铃推送");
                            [self pushXMPlayVCWithLock:lock];
                        }
                    }
                }
            }
        }
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.isForceLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }else if(self.isForcePortrait){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma  mark - 获取device Token回调
//获取DeviceToken成功，IOS13之前的devicetoken在这获取
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken{
    
    if (!deviceToken || ![deviceToken isKindOfClass:[NSData class]] || deviceToken.length==0) {
        return;
    }
    NSString *(^getDeviceToken)(void) = ^() {
        if (@available(iOS 13.0, *)) {
            const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
            NSMutableString *myToken  = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
            for (int i = 0; i < deviceToken.length; i++) {
                [myToken appendFormat:@"%02x", dataBuffer[i]];
            }
            return (NSString *)[myToken copy];
        }else {
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
            NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:characterSet];
            return [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    };
    NSString *deviceTokenString = getDeviceToken();
    if (deviceTokenString) {
        [KDSTool saveDeviceToken:deviceTokenString];
    }
    KDSLog(@"--{Kaadas}--token-deviceTokenString=%@",deviceTokenString);

}

//获取DeviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    KDSLog(@"[DeviceToken Error]:%@\n",error.description);
}
//这个代理方法是获取了设备的唯一tokenStr，是要给服务器的,IOS13的devicetoken从这获取
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
//    NSString *str = [NSString stringWithFormat:@"%@",credentials.token];
//    NSLog(@"--{Kaadas}--VoIPtoken=========== %@",str);
    NSLog(@"--{Kaadas}--type=========== %@",type);
    NSMutableString *pushkiDevietokenStr = [NSMutableString string];
    const char *bytes = credentials.token.bytes;
    NSInteger count = credentials.token.length;
    for (int i = 0; i < count; i++) {
        [pushkiDevietokenStr appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    if ([type isEqual:@"PKPushTypeVoIP"]) {

        if([pushkiDevietokenStr length] != 0)
        {
            [KDSTool saveVoIPDeviceToken:pushkiDevietokenStr];
        }
    }
    if ([type isEqual:@"PKPushTypeUserNotifications"]) {

        if([pushkiDevietokenStr length] != 0)
        {
            NSLog(@"--{Kaadas}--devicetoken=========== %@",pushkiDevietokenStr);
            [KDSTool saveDeviceToken:pushkiDevietokenStr];

        }
    }
}
#pragma mark  app状态
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"--{Kaadas}--applicationWillResignActive");

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
///
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"--{Kaadas}--进入到后台休眠状态");
    NSLog(@"--{Kaadas}--{KAADAS}--Linphone--applicationDidEnterBackground--进入到后台休眠状态");
    self.isBackground = YES;
    if ([LinphoneManager instance].currentCall) {
        [[LinphoneManager instance] hangUpCall];
    }
    [LinphoneManager instance].hasPushkit  = NO;
    NSInteger i = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = i;
    //移除sip账号在线状态
    if ([KDSUserManager sharedManager].user.uid != 0) {
        [[LinphoneManager instance] setSipAcountStatus:NO];
        [[LinphoneManager instance] enterBackgroundMode];
    }
}
///
- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"--{Kaadas}--applicationWillEnterForeground");

    KDSDBManager *manager = [KDSTool getDefaultLoginAccount].length ? [KDSDBManager sharedManager] : nil;
    UIViewController *vc = self.window.rootViewController;
    
    if (!vc && [manager queryUser].token.length==0)//当且仅当token为空时才设置登录界面，否则必须先判断是否需要验证。
    {
        [self setRootViewController];
        return;
    }
    if ([vc isKindOfClass:UINavigationController.class])/**登录页面的导航控制器*/
    {
        return;
    }
    //剩下的有3种情况：1、根控制器是登录后的UITabBarController；2、APP刚启动，根控制器为nil；3、根控制器是安全验证控制器。
    BOOL after = [manager queryAuthenticationState];
    if (!after)
    {
        NSDate *date = [manager queryUserAuthDate];
        after = !date ?: (date.timeIntervalSinceNow<-60 || date.timeIntervalSinceNow>=0);//1分钟后
        if (after)
        {
            [manager updateAuthenticationState:YES];
        }
    }
    BOOL tEnable = [manager queryUserTouchIDState];
    BOOL gEnagle = [manager queryUserGesturePwdState];
    if ([vc isKindOfClass:UITabBarController.class])
    {
        vc = ((UITabBarController *)vc).selectedViewController;
        while (vc.presentedViewController)
        {
            vc = vc.presentedViewController;
            if ([vc isKindOfClass:[KDSNavigationController class]] && [((KDSNavigationController*)vc).topViewController isKindOfClass:KDSSecurityAuthenticationVC.class])/**已经是验证控制器*/
            {
                after = NO;
                break;
            }
        }
    }
    if ((tEnable || gEnagle) && after)
    {
        KDSSecurityAuthenticationVC *savc = [KDSSecurityAuthenticationVC new];
        savc.finishBlock = ^(BOOL success) {
            vc ?: [self setRootViewController];
        };
        UIAlertController *ac = nil;
        while ([vc isKindOfClass:UIAlertController.class])//alert弹框验证完毕后会移动到左上角。
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            ac = vc;
#pragma clang diagnostic pop
            vc = vc.presentingViewController;
            [ac dismissViewControllerAnimated:NO completion:nil];
        }
        KDSNavigationController *nav = [[KDSNavigationController alloc] initWithRootViewController:savc];
       
        vc ?  (void)(nav.modalPresentationStyle = 0),[vc presentViewController:nav animated:NO completion:nil] : (void)(self.window.rootViewController = nav);

    }
    else if (!vc)//没有满足安全验证条件且刚启动时
    {
        [self setRootViewController];
    }
    KDSLog(@"从后台返回到活动状态");
    self.isBackground = NO;
    //取消本地消息提醒
    if (_backgroudMsg) {
        [[UIApplication sharedApplication] cancelLocalNotification:_backgroudMsg];
        //        _backgroudMsg.applicationIconBadgeNumber = 0;
    }
    //账号不为空并且没有收到推送消息
    if ([manager queryUser].token.length != 0
        && [manager queryUser].uid.length != 0
        && [[KDSUserDefaults objectForKey:KDSUserBindingedCateye] isEqualToString:@"true"]
        && ![LinphoneManager instance].hasPushkit
        && [KDSUserManager sharedManager].cateyes.count > 0) {
        
        NSLog(@"{KAADAS}--Linphone--设置linphone 账号上线--从后台返回到活动状态");
        //设置linphone 账号上线
        [[LinphoneManager instance] setSipAcountStatus:YES];
        [[LinphoneManager instance] becomeActive];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OTAStateNotify"  object:nil];//通知OTA页面

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"--{Kaadas}--applicationDidBecomeActive");

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (_timer)
    {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:70];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"--{Kaadas}--applicationWillTerminate");

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ([LinphoneManager instance].currentCall) {
        [[LinphoneManager instance] hangUpCall];
    }
    [LinphoneManager instance].hasPushkit  = NO;
    NSInteger i = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = i;
    //移除sip账号在线状态
    if ([KDSUserManager sharedManager].user.uid != 0) {
        [[LinphoneManager instance] setSipAcountStatus:NO];
        [[LinphoneManager instance] enterBackgroundMode];
    }
}
#pragma mark - 其它方法
/**
 *@abstract 设置应用窗口的根控制器。
 */
- (void)setRootViewController
{
    BOOL haveBeanLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"have_bean_launch"];
    if (!haveBeanLaunch) {
        //如果没有启动过，则先进入欢迎页
        KDSWelcomeVC *welcomevc = [KDSWelcomeVC new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:welcomevc];
        nav.navigationBar.hidden = YES;
        self.window.rootViewController = nav;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"have_bean_launch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    NSString *account = [KDSTool getDefaultLoginAccount];  //从本地获取登录信息
    if (account.length)
    {
        KDSUser *user = [[KDSDBManager sharedManager] queryUser];
        if (user.token.length)
        {
            [KDSUserManager sharedManager].user = user;
            [KDSUserManager sharedManager].userNickname = [[KDSDBManager sharedManager] queryUserNickname];
            [KDSHttpManager sharedManager].token = user.token;
            KDSTabBarController *tab = [KDSTabBarController new];
            self.window.rootViewController = tab;
            return;
        }
    }
    
    KDSLoginViewController *loginVC = [KDSLoginViewController new];
    KDSNavigationController *nav = [[KDSNavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
}
// 获取 VoIPDeviceToken
-(void)registPushkit{
    
    //    注册通知与pushkit，pushkit要ios8 及以后才可以使用
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
       
        PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
        pushRegistry.delegate = self;
        pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    }

}

// 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{

        //iOS 10 later
        if (@available(iOS 10.0, *)) {
            
            UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            //必须写代理，不然无法监听通知的接收与点击事件
            center.delegate = self;
           
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {

                if (!error && granted) {
                    //用户点击允许
                    KDSLog(@"--{Kaadas}--token-注册成功");
//                    [application registerForRemoteNotifications];

                }else{
                    //用户点击不允许
                    KDSLog(@"--{Kaadas}--token-注册失败");
                }
            }];
            
            // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
            //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//                KDSLog(@"--{Kaadas}--token-settings-%@",settings);

            }];

        }else if ([[UIDevice currentDevice].systemVersion floatValue] >=8.0){
                //iOS8 - iOS10
                UIUserNotificationType type = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
                [application registerUserNotificationSettings:settings];
                [application registerForRemoteNotifications];
        }else{
                //iOS8系统以下
                [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];

        }
        [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 此代理方法iOS8及以上会调用，iOS10 使用UNNotification.framewrok不会调用
//    [application registerForRemoteNotifications];
}
#pragma  mark ---------收到pushkit推送消息
//实测IOS13之前收到推送的回调
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type API_DEPRECATED_WITH_REPLACEMENT("-pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion", ios(8.0, 11.0)) API_UNAVAILABLE(macos, watchos, tvos){
    NSLog(@"--{Kaadas}--收到pushkit推送消息-类型=%@",type);
    NSDictionary * reciveDic= payload.dictionaryPayload;
    NSLog(@"--{KAADAS}--收到信息reciveDic = %@",reciveDic);
    [LinphoneManager instance].hasPushkit = YES;
    NSString *dataStr = [[reciveDic objectForKey:@"extras"] objectForKey:@"data"];
    [[LinphoneManager instance] startLinphoneCore];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;

        if (theType == UIUserNotificationTypeNone) {

            UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];

            [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];

        }
        NSString *cateyeIDStr = [[reciveDic objectForKey:@"extras"] objectForKey:@"deviceId"];

        _backgroudMsg = [[UILocalNotification alloc] init];

        _backgroudMsg.timeZone = [NSTimeZone defaultTimeZone];

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

        _backgroudMsg.regionTriggersOnce = YES;

        _backgroudMsg.alertBody = [NSString stringWithFormat:@"猫眼:%@来电",cateyeIDStr];

        _backgroudMsg.soundName = @"notes_of_the_optimistic.caf";

        _backgroudMsg.applicationIconBadgeNumber = 1;

        _backgroudMsg.alertAction = @"查看"; //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息

        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];

        _backgroudMsg.userInfo = infoDic;

        [[UIApplication sharedApplication] presentLocalNotificationNow:_backgroudMsg];

        NSLog(@"--{KAADAS}--收到pushkit推送消息--发invite包");
        NSLog(@"--{KAADAS}--发invite包dataStr=%@",dataStr);
        [[LinphoneManager instance] sendMsg:dataStr];

    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[LinphoneManager instance] setSipAcountStatus:YES];//APP退出到后台后sip账号会下线 这里保证推送过来时sip账号上线
    });
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"--{KAADAS}--userInfo=%@",userInfo);
    [[LinphoneManager instance] startLinphoneCore];
    NSString * timeStr = [[userInfo objectForKey:@"extras"] objectForKey:@"time"];
    NSString * wifiSn = [[userInfo objectForKey:@"extras"] objectForKey:@"wifiSN"];
    if ([[[userInfo objectForKey:@"extras"] objectForKey:@"func"] isEqualToString:@"doorbell"]){
        ///门铃呼叫
        for (KDSLock *lock in [KDSUserManager sharedManager].locks)
        {
            if (lock.wifiDevice) {
                if ([lock.wifiDevice.wifiSN isEqualToString:wifiSn]){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self pushXMPlayVCWithLock:lock];
                    });
                }
            }
        }
    }else{
        
        if ([KDSTool getNowTimeTimestamp].intValue - timeStr.longLongValue/1000 <= 20) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([LinphoneManager instance].SIPAcountLoginSuccess) {
                NSLog(@"--{Kaadas}--自己给自己发送invite包");
                [LinphoneManager instance].hasPushkit = YES;
                [[LinphoneManager instance] sendMsg:[[userInfo objectForKey:@"extras"] objectForKey:@"data"]];
            }else{
                if ([[[userInfo objectForKey:@"extras"] objectForKey:@"func"] isEqualToString:@"alarm"]) {
                    //
                }
                else if ([[[userInfo objectForKey:@"extras"] objectForKey:@"func"] isEqualToString:@"catEyeCall"])
                {
                    [MBProgressHUD showError:@"接听失败，视频通道繁忙"];
                }
            }
            });
        }else{
    //        [MBProgressHUD showError:@"猫眼已经休眠"];
        }
        
    }
}

- (void)pushXMPlayVCWithLock:(KDSLock *)lock
{
    ///门铃报警
    XMPlayController *vc = [[XMPlayController alloc] initWithType:XMPlayTypeLive];
    vc.lock = lock;
    vc.isActive = NO;
    vc.hidesBottomBarWhenPushed = YES;
    KDSNavigationController *nav = [[KDSNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}


/*
 //IOS13之后收到推送的回调--禁用，不用删用来警示
 - (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion API_AVAILABLE(macos(10.15), macCatalyst(13.0), ios(11.0), watchos(6.0), tvos(13.0)){
     
     NSLog(@"--{Kaadas}--收到pushkit推送消息-withCompletionHandler-类型=%@",type);

     if ([type isEqual:@"PKPushTypeVoIP"]) {
         CXCallUpdate* update = [[CXCallUpdate alloc] init];
         update.supportsDTMF = false;
         update.supportsHolding = false;
         update.supportsGrouping = false;
         update.supportsUngrouping = false;
         update.hasVideo = false;
         update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:@"智能"];
         update.localizedCallerName = @"凯迪仕";
         NSUUID *uuid = [NSUUID UUID];
         //弹出电话页面，不调用reportNewIncomingCallWithUUID的话，IOS13会杀掉App，多次不调用的话，会被苹果禁止收到推送
         [self.provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
         }];
     }
    
 }

//iOS10.0以后的方法，App从后台进入的时候回调,无论App进程是否存在
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler{
    
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"--{Kaadas}--App在后台时候-%@", userInfo);
    
    completionHandler();
    
}

//App在前台模式下接受消息,正常推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"--{Kaadas}--App在前台时候回调-%@", userInfo);
    
    //可以设置当收到通知后, 有哪些效果呈现(声音/提醒/数字角标)
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    
}
- (void)reportNewIncomingCallWithUUID:(NSUUID *)UUID update:(CXCallUpdate *)update completion:(void (^)(NSError *_Nullable error))completion API_AVAILABLE(ios(10.0)){
    NSLog(@"--{Kaadas}--reportNewIncomingCallWithUUID");

}
*/

@end

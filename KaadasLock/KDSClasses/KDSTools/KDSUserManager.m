//
//  KDSUserManager.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSUserManager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "LinphoneManager.h"

NSString * const KDSLockHasBeenDeletedNotification = @"KDSLockHasBeenDeletedNotification";
NSString * const KDSLockHasBeenAddedNotification = @"KDSLockHasBeenAddedNotification";
NSString * const KDSLogoutNotification = @"KDSLogoutNotification";
NSString * const KDSUserUnlockNotification = @"KDSUserUnlockNotification";
NSString * const KDSDeviceSyncNotification = @"KDSDeviceSyncNotification";
NSString * const KDSUserBindingedCateye = @"KDSUserBindingedCateye";
NSString * const KDSUserLongtimeNoOperationNotification = @"KDSUserLongtimeNoOperationNotification";
NSString * const KDSUserActivateOperationNotification = @"KDSUserActivateOperationNotification";
NSString * const KDSGWLockPwdNotification = @"KDSGWLockPwdNotification";
NSString * const KDSGWOnlineNotification = @"KDSGWOnlineNotification";
NSString * const KDSCatEyeHasBeenDeletedNotification = @"KDSCatEyeHasBeenDeletedNotification";
NSString * const KDSLockUpdateBleVersionNotification = @"KDSLockUpdateBleVersionNotification";
NSString * const KDSBleLockUpdateDataSourceNotification = @"KDSBleLockUpdateDataSourceNotification";
NSString * const KDSXMMediaDoorBeellNotification = @"KDSXMMediaDoorBeellNotification";

@interface KDSUserManager ()

///记录报警数据的数组，每个对象为字典，字典的key保存蓝牙名称，value保存蓝牙返回的报警数据。
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSData *> *> *alarms;
///轮询报警数据的定时器。当有报警数据添加时就会启动该定时器，当报警数据处理完毕时应该销毁该定时器。
@property (nonatomic, strong) NSTimer *alarmTimer;
///报警标签的背景视图。
@property (nonatomic, strong) UIView *bgView;
///报警标签，展示报警信息。
@property (nonatomic, strong) UILabel *alarmLabel;

@end

@implementation KDSUserManager

+ (instancetype)sharedManager
{
    static KDSUserManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSUserManager alloc] init];
    });
    return _manager;
}

#pragma mark - 懒加载
- (NSMutableArray<KDSLock *> *)locks
{
    if (!_locks)
    {
        _locks = [NSMutableArray array];
    }
    return _locks;
}

- (NSMutableArray<KDSCatEye *> *)cateyes
{
    if (!_cateyes) {
        _cateyes = ({
            NSMutableArray * arr = [NSMutableArray array];
            arr;
        });
    }
    return _cateyes;
}

- (NSMutableArray<KDSDeviceHangerModel *> *)hangers {
    if (!_hangers) {
        self.hangers = [[NSMutableArray alloc] init];
    }
    return _hangers;
}

- (NSMutableArray *)gateways
{
    if (!_gateways) {
        _gateways = ({
            NSMutableArray * gws = [NSMutableArray array];
            gws;
        });
    }
    return _gateways;
}

- (NSMutableArray<KDSProductInfoList *> *)productInfoList
{
    if (!_productInfoList) {
        
        _productInfoList = [NSMutableArray array];
    }
    return _productInfoList;
}

- (NSMutableArray<NSDictionary<NSString *,NSData *> *> *)alarms
{
    if (!_alarms)
    {
        _alarms = [NSMutableArray array];
    }
    return _alarms;
}

- (NSTimer *)alarmTimer
{
    if (!_alarmTimer)
    {
        _alarmTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(alarmTimerHandleAlarm:) userInfo:nil repeats:YES];
    }
    return _alarmTimer;
}

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -(kStatusBarHeight + kNavBarHeight), kScreenWidth, kStatusBarHeight + kNavBarHeight)];
        _bgView.backgroundColor = UIColor.lightGrayColor;
        [_bgView addSubview:self.alarmLabel];
    }
    return _bgView;
}

- (UILabel *)alarmLabel
{
    if (!_alarmLabel)
    {
        _alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kStatusBarHeight, kScreenWidth - 40, kNavBarHeight)];
        _alarmLabel.numberOfLines = 0;
    }
    return _alarmLabel;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

#pragma mark - 内部接口。
///报警定时器触发时，每执行一次处理第一个报警记录，然后将其从记录中删除，当报警记录处理完毕后销毁定时器。
- (void)alarmTimerHandleAlarm:(NSTimer *)timer
{
    NSDictionary<NSString *, NSData *> *dict = self.alarms.firstObject;
    NSData *data = dict.allValues.firstObject;
    const Byte *bytes = data.bytes;
    if (!bytes)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.bgView.frame;
            frame.origin.y -= frame.size.height;
            self.bgView.frame = frame;
        } completion:^(BOOL finished) {
            
            [self.bgView removeFromSuperview];
            self.bgView = nil;
            self.alarmLabel = nil;
            
        }];
        [self.alarmTimer invalidate];
        self.alarmTimer = nil;
        return;
    }
    unsigned info = *(unsigned*)(bytes + 8);//00000000 00000000 00000000 0010 0110
    NSLog(@"info==%d",info);//132->1000 0100 84->0101 0100
    printf("\n");
    for (int i = 0; i < 32; ++i)
    {
        printf("%d", (info>>(31 - i)) & 0x1);
        if (i %4 == 0 && i > 0) printf("  ");
    }
    printf("\n");
    BOOL lowPower = info & 0x1;//低电量报警。
    BOOL locked = (info >> 1) & 0x1;//锁定报警。
    BOOL error3Times = (info >> 2) & 0x1;//3次错误报警。
    BOOL defence = (info >> 3) & 0x1;//布防报警。
    BOOL temperature = (info >> 4) & 0x1;//温度报警。
    BOOL force = (info >> 5) & 0x1;//胁迫报警。
    BOOL reset = (info >> 6) & 0x1;//恢复出厂设置报警。
    BOOL violence = (info >> 7) & 0x1;//暴力开锁报警。
    BOOL leave = (info >> 8) & 0x1;//钥匙遗落在锁上报警。
    BOOL security = NO;//(info >> 9) & 0x1;//安全模式报警。新版废弃。
    BOOL uncomplete = (info >> 10) & 0x1;//未完全上锁报警。
    BOOL teardown = (info >> 11) & 0x1;//防拆报警。
    BOOL lockedRotor = (info >> 12) & 0x1;//堵转报警。
    BOOL machine = (info >> 13) & 0x1;//机械方式开锁报警。
    NSString *nickname = dict.allKeys.firstObject;
    for (KDSLock *lock in self.locks)
    {
        if ([lock.device.lockName isEqualToString:dict.allKeys.firstObject])
        {
            nickname = lock.device.lockNickName ?: lock.device.lockName;
        }
    }
    
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"%@%@%@: ", Localized(@"lock"), nickname, Localized(@"alarm")];
    NSInteger length = mStr.length;
    !lowPower ?: [mStr appendString:Localized(@"lowPowerAlarm")];
    !locked ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"systemLockedAlarm")];
    !error3Times ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"multiVerifyFailAlarm")];
    !defence ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"activeDefenceAlarm")];
    !temperature ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"",Localized(@"temperatureExceptionAlarm")];
    !force ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"forceUnlockAlarm")];
    !reset ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"lockHasBeenResetAlarm")];
    !violence ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"violenceUnlockAlarm")];
    !leave ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"keyLeftInLock")];
    !security ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"securityModeOpenAlarm")];
    !uncomplete ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"lockUncompleteAlarm")];
    !teardown ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"lockTeardownAlarm")];
    !lockedRotor ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"lockedRotorAlarm")];
    !machine ?: [mStr appendFormat:@"%@%@", mStr.length>length ? @"; " : @"", Localized(@"machineUnlockAlarm")];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:mStr attributes:@{NSForegroundColorAttributeName : UIColor.redColor}];
    CGRect bounds = [mStr boundingRectWithSize:CGSizeMake(kScreenWidth - 40, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil];
    [attrStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(0x2d, 0xd9, 0xba) range:[mStr rangeOfString:nickname]];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:bounds.size.height > kNavBarHeight ? 12 : 16] range:NSMakeRange(0, mStr.length)];
    
    self.alarmLabel.attributedText = attrStr;
    if (!self.bgView.superview)
    {
        [[UIApplication sharedApplication].keyWindow addSubview:self.bgView];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = self.bgView.bounds;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.bgView.frame;
                frame.origin.y -= frame.size.height;
                self.bgView.frame = frame;
            } completion:^(BOOL finished) {
                if (self.alarms.count)
                {
                    [self.alarms removeObjectAtIndex:0];
                }
                if (!self.alarms.count)
                {
                    [self.bgView removeFromSuperview];
                    self.bgView = nil;
                    self.alarmLabel = nil;
                    [self.alarmTimer invalidate];
                    self.alarmTimer = nil;
                }
                
            }];
            
        });
    }];
}
-(NSString *)getCurrentCateyeId{
    LinphoneCall *call = [LinphoneManager instance].currentCall;
    NSString * displayNameStr;
    if (call) {
        //确保LinphoneCall存在
        const LinphoneAddress * address = linphone_call_get_remote_address(call);
        const char * str = linphone_address_get_username(address);
        displayNameStr = [NSString stringWithUTF8String:str];
    }
    return displayNameStr;
}
-(NSString *)getCurrentCallTimeStamp{
    NSString *currentCallTimeS = [KDSTool getNowTimeTimestamp];
    return currentCallTimeS;
}
#pragma mark - 对外接口。
- (void)addAlarmForLockWithBleName:(NSString *)bleName data:(NSData *)alarmData
{
    if (alarmData.length != 20) return;
    /*const Byte *bytes = alarmData.bytes;
    unsigned info = *(unsigned*)(bytes + 8);
    BOOL lowPower = info & 0x1;//低电量报警。
    BOOL attempt = (info >> 1) & 0x1;//试开报警。
    BOOL teardown = (info >> 2) & 0x1;//防拆报警。
    BOOL defence = (info >> 3) & 0x1;//布防报警。
    BOOL temperature = (info >> 4) & 0x1;//温度报警。
    BOOL force = (info >> 5) & 0x1;//胁迫报警。
    BOOL reset = (info >> 6) & 0x1;//恢复出厂设置报警。
    BOOL violence = (info >> 7) & 0x1;//暴力开锁报警。
    BOOL leave = (info >> 8) & 0x1;//钥匙遗落在锁上报警。
    BOOL security = NO;//(info >> 9) & 0x1;//安全模式报警。新版废弃。
    BOOL uncomplete = (info >> 10) & 0x1;//未完全上锁报警。
    BOOL teardown = (info >> 11) & 0x1;//防拆报警。
    BOOL lockedRotor = (info >> 12) & 0x1;//堵转报警。
    BOOL machine = (info >> 13) & 0x1;//机械方式开锁报警。*/
    if (![KDSTool getNotificationOnForDevice:bleName])
    {
        
    }
    [self.alarms addObject:@{bleName : alarmData}];
    if (!_alarmTimer)
    {
        self.alarmTimer.fireDate = NSDate.date;
    }
}

- (void)monitorNetWork{
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    //        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(afNetworkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];//这个可以放在需要侦听的页面
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                KDSLog(@"网络状态：当前手机断网了-%@",@(status) );
                [KDSUserManager sharedManager].netWorkIsAvailable = NO;
                [KDSUserManager sharedManager].netWorkIsWiFi = NO;
                //无网络的时候不让添加密码
                if (![KDSUserManager sharedManager].netWorkIsAvailable) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    hud.mode =MBProgressHUDModeText;
                    hud.detailsLabel.text = @"当前网络不可用，请检查手机网络";
                    hud.bezelView.backgroundColor = [UIColor blackColor];
                    hud.detailsLabel.textColor = [UIColor whiteColor];
                    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                }
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                KDSLog(@"网络状态：通过WIFI连接-%@",@(status));
                [KDSUserManager sharedManager].netWorkIsAvailable = YES;
                [KDSUserManager sharedManager].netWorkIsWiFi = YES;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                KDSLog(@"网络状态：通过手机网络连接-%@",@(status) );
                [KDSUserManager sharedManager].netWorkIsAvailable = YES;
                [KDSUserManager sharedManager].netWorkIsWiFi = NO;
                break;
            }
            default:
                break;
        }
    }];
    [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
}

- (void)resetManager
{
    [_alarmTimer invalidate];
    _alarmTimer = nil;
    [_bgView removeFromSuperview];
    unsigned count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (unsigned i = 0; i < count; ++i)
    {
        if ([[NSString stringWithUTF8String:ivar_getName(ivars[i])] containsString:@"netWorkIsAvailable"] || [[NSString stringWithUTF8String:ivar_getName(ivars[i])] containsString:@"netWorkIsWiFi"]
            || [[NSString stringWithUTF8String:ivar_getName(ivars[i])] containsString:@"doorbellProgress"]) {
            continue;
        }
        object_setIvar(self, ivars[i], nil);
        NSString* memberName = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
        NSLog(@"-----ivarsName==%@",memberName);
    }
    free(ivars);
}
// 字典转化成字符串
-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
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

//获取当前时间戳有两种方法(以秒为单位)

-(NSString *)getNowTimeTimestamp{

NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

[formatter setDateStyle:NSDateFormatterMediumStyle];

[formatter setTimeStyle:NSDateFormatterShortStyle];

[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

//设置时区,这个对于时间的处理有时很重要

NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

[formatter setTimeZone:timeZone];

NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

return timeSp;

}


@end

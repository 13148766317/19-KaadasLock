//
//  KDSDeviceConnectionStep1VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDeviceConnectionStep1VC.h"
#import "KDSWifiLockHelpVC.h"
#import "CYCircularSlider.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "KDSInPutAdminiPwdVC.h"
#import "KDSAddNewWiFiLockFailVC.h"


@interface KDSDeviceConnectionStep1VC ()<senderValueChangeDelegate>

@property (nonatomic,strong)CYCircularSlider *circularSlider;
@property (nonatomic,strong)UILabel * sliderValueLb;
///是否允许跳转到下一个页面默认允许
@property (nonatomic,assign)BOOL isJumped;
///交换数据后如果15秒内有网络且请求成功即成功反之失败（绑定过程会切换两次网络，交换数据用锁广播的热点）
@property (nonatomic,strong)NSString * currentSsid;
///定时，每1.0秒增加10%的进度3秒没有跳转页面停留在99%
@property (nonatomic,strong)NSTimer * changeTimer;
@property (nonatomic,assign)int currentNum;

@end

@implementation KDSDeviceConnectionStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"设备连接";
    [self setRightButton];
    [self setUI];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isJumped = YES;
    NSDictionary *netInfo = [self fetchNetInfo];
    self.currentSsid = [netInfo objectForKey:@"SSID"];
    if ([self.currentSsid hasPrefix:@"kaadas_"]) {
        NSLog(@"9999999999页面将要展示的时候跳转");
        [self jumpTempPwd];
    }
    else{
        self.currentNum = 70;
        [self startConnectAP];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.changeTimer invalidate];
    self.changeTimer = nil;
}
-(void)startConnectAP{
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(animationTimerActionChangeTimer:) userInfo:nil repeats:YES];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",20];
    if (@available(iOS 11.0, *)) {
            NEHotspotConfiguration *hotspotConfig = [[NEHotspotConfiguration alloc] initWithSSID:@"kaadas_AP" passphrase:@"88888888" isWEP:NO];
            [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotspotConfig completionHandler:^(NSError * _Nullable error) {
            if (error) {
                if (error.code == NEHotspotConfigurationErrorAlreadyAssociated) {
                    //已连接
                    NSLog(@"9999999999--{Kaadas}--已经连接热点，%@",error);
                    [self jumpTempPwd];
                }
                else if (error.code == NEHotspotConfigurationErrorUserDenied) {
                    //用户点击取消
                    NSLog(@"--{Kaadas}--用户点击取消，%@",error);
                    KDSAddNewWiFiLockFailVC * vc = [KDSAddNewWiFiLockFailVC new];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else{
                    NSLog(@"--{Kaadas}--无法连接热点，%@",error);
                    KDSAddNewWiFiLockFailVC * vc = [KDSAddNewWiFiLockFailVC new];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{
                NSLog(@"--{Kaadas}--error为空");
                //获取配置过的WIFI列表：
    //            if (@available(iOS 11.0, *)) {
    //                    [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray * array) {
    ////                        NSLog(@"--{Kaadas}--配置过的array=%@",array);
    //                    }];
    //                }
                /*
                 注：1、这个方法存在一个问题，如果你加入一个不存在的WiFi，会弹出无法加入WiFi的弹框，但是本方法的回调error没有值；
                 2、在这里，通过判断当前wifi是否是我要加入的wifi来解决这个问题的；
                 3、若手机无手机卡，并正连其他wifi，会存在切换wifi时，短暂无网络的情况；
                */
               NSDictionary *netInfo = [self fetchNetInfo];
               self.currentSsid = [netInfo objectForKey:@"SSID"];
               NSLog(@"--{Kaadas}--currentSsid=%@,class=%@",self.currentSsid,[self.currentSsid class]);
                if ([self.currentSsid isEqualToString:@"kaadas_AP"]) {
                    NSLog(@"9999999999获取配置过的WIFI列表");
                    [self jumpTempPwd];
                }
                else{
                    KDSAddNewWiFiLockFailVC * vc = [KDSAddNewWiFiLockFailVC new];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            }];
        } else {
            [KDSTool openSettingsURLString];
        }
}
-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 10;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"唤醒门锁确保数字键盘灯亮";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentCenter;
    [supView addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(supView.mas_top).offset(KDSScreenHeight > 667 ? 68 : 48);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(supView);
    }];
    
    UIImageView * sliderBgImgView = [UIImageView new];
    sliderBgImgView.image = [UIImage imageNamed:@"Wi-Fi-changeSliderValueImg"];
    [supView insertSubview:sliderBgImgView atIndex:0];
    sliderBgImgView.hidden = YES;
    [sliderBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(149.5);
        make.width.height.equalTo(@235);
        make.centerX.equalTo(supView);
    }];
    
    CGRect sliderFrame = CGRectMake((KDSScreenWidth-295)/2, 120, 275,275);
    self.circularSlider =[[CYCircularSlider alloc]initWithFrame:sliderFrame];
    self.circularSlider.delegate = self;
    [self.circularSlider setAngleCurrent:70];
    [supView addSubview:self.circularSlider];
    
    UIImageView * tipsImgView = [UIImageView new];
    tipsImgView.image = [UIImage imageNamed:@"addWiFiLockConnectingIcon"];
    [supView addSubview:tipsImgView];
    [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@180);
        make.centerX.equalTo(supView);
        make.center.equalTo(self.circularSlider);
    }];
    
    self.sliderValueLb = [UILabel new];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"0"];
    self.sliderValueLb.textColor = UIColor.blackColor;
    self.sliderValueLb.textAlignment = NSTextAlignmentCenter;
    self.sliderValueLb.font = [UIFont systemFontOfSize:27];
    [supView addSubview:self.sliderValueLb];
    [self.sliderValueLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@25);
        make.centerX.equalTo(supView);
        make.center.equalTo(tipsImgView);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"loading...";
    tipsLb.textColor = KDSRGBColor(202, 202, 202);
    tipsLb.font = [UIFont systemFontOfSize:13];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [supView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sliderValueLb.mas_bottom).offset(5);
        make.centerX.equalTo(supView);
        make.height.equalTo(@15);
        
    }];
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"请将手机和设备尽量靠近路由器";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(25);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
        
    }];
    
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"自动搜索门锁热点中，请稍等...";
    tipsLb2.textColor = KDSRGBColor(143, 143, 143);
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    tipsLb2.font = [UIFont systemFontOfSize:17];
    [supView addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(50);
        make.height.equalTo(@25);
        make.centerX.equalTo(supView);
           
    }];
    
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
    
//    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",num];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}
#pragma mark 定时器方法回调
-(void)animationTimerActionChangeTimer:(NSTimer *)overTimer
{
    self.currentNum += 1;
    if (self.currentNum > 190) {
        [_circularSlider setAngleCurrent:195];
        self.currentNum = 190;
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",99];
    }else{
        [_circularSlider setAngleCurrent:self.currentNum];
        float sliderValue = (self.currentNum - 70)/((200-70)/100.0f);
        self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",(int)sliderValue];
    }
}
//
-(void)jumpTempPwd
{
    if (self.isJumped) {
        self.isJumped = NO;
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        [_circularSlider setAngleCurrent:200];
        self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"100"];
        KDSInPutAdminiPwdVC * vc = [KDSInPutAdminiPwdVC new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.navigationController pushViewController:vc animated:YES];
        });
       
    }
}



@end

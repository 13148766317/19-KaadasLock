//
//  KDSAddSmartHangerStep1VC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/6.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAddSmartHangerStep1VC.h"


@interface KDSAddSmartHangerStep1VC ()

@end

@implementation KDSAddSmartHangerStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDevice");
//    [self setRightButton];
//    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    //先判断是否连接上wifi
    [[KDSUserManager sharedManager] monitorNetWork];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(3);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第一步：";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 40);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.view).offset(65);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
   
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 确认晾衣机已安装好，并通电;";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 14);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(65);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 如未安装，请联系经销商上门安装;";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(65);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    ///添加晾衣机的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"add_smart_hanger_1"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(206));
        make.width.mas_equalTo(KDSSSALE_WIDTH(206));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 30 : 14);
    }];

    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 20;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@265);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -45 : -65);
    }];
    
}


///网络状态改变的通知。当网络不可用时，会将网关、猫眼和网关锁的状态设置为离线后发出通知KDSDeviceSyncNotification
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    NSNumber *number = noti.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = number.integerValue;
    switch (status)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN://2G,3G,4G...
            [KDSUserManager sharedManager].netWorkIsWiFi = NO;
            [KDSUserManager sharedManager].netWorkIsAvailable = YES;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi://wifi网络
            [KDSUserManager sharedManager].netWorkIsWiFi = YES;
            [KDSUserManager sharedManager].netWorkIsAvailable = YES;
            break;
        case AFNetworkReachabilityStatusNotReachable://无网络
            [KDSUserManager sharedManager].netWorkIsAvailable = NO;
            [KDSUserManager sharedManager].netWorkIsWiFi = NO;
            break;
        default://未识别的网络/不可达的网络
            break;
    }
}

#pragma mark - 通知中心

-(void)applicationBecomeActive:(NSNotification *)no{
    [self setBssi];
}

- (void)dealloc{
    [KDSNotificationCenter removeObserver:self];
}
-(void)setBssi
{
    [[KDSAMapLocationManager sharedManager] initWithLocationManager];
    
}

#pragma mark 控件点击事件

-(void)navRightClick
{
//    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
//    [self.navigationController pushViewController:vc animated:YES];
}
-(void)nextBtnClick:(UIButton *)sender
{
    KDSAddSmartHangerStep2VC * vc = [KDSAddSmartHangerStep2VC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)navBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showAlerterView
{
    if (![KDSUserManager sharedManager].netWorkIsWiFi) {
        UIAlertController * aler = [UIAlertController alertControllerWithTitle:nil message:@"手机未连接WiFi，无法添加设备" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * connectAction = [UIAlertAction actionWithTitle:@"去连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [KDSTool openSettingsURLString];
        }];
        [aler addAction:connectAction];
        [self presentViewController:aler animated:YES completion:nil];
        return;
    }
    if (![KDSTool determineWhetherTheAPPOpensTheLocation]){///没有打开定位
       [self setBssi];
        return;
    }
}


@end

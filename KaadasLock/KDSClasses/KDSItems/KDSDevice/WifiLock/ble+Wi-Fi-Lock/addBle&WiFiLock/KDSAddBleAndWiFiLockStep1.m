//
//  KDSAddBleAndWiFiLockStep1.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddBleAndWiFiLockStep1.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSConnectedReconnectVC.h"
#import "KDSAMapLocationManager.h"
#import "KDSAddBleAndWiFiLockStep2.h"
#import "KDSBluetoothTool.h"


@interface KDSAddBleAndWiFiLockStep1 ()<KDSBluetoothToolDelegate>
{
    KDSBluetoothTool *_bleTool;
}
@property (nonatomic,assign)BOOL bleIsOpen;

@end

@implementation KDSAddBleAndWiFiLockStep1

#pragma mark - getter setter
- (KDSBluetoothTool *)bleTool
{
    if (!_bleTool)
    {
        _bleTool = [[KDSBluetoothTool alloc] initWithVC:self];
    }
    return _bleTool;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    //先判断是否连接上wifi
    [[KDSUserManager sharedManager] monitorNetWork];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     
    if (self.bleTool.connectedPeripheral)
    {
        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    }
    [self.bleTool beginScanForPeripherals];
    self.bleTool.delegate = self;
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
    tipMsgLabe1.text = @"第一步：门锁配网准备";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
   
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 按照说明书安装完门锁";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 检查后面板Wi-Fi模块是否插紧";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 电池仓装上4节或8节电池";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        
    }];
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加网关智能锁1"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(199));
        make.width.mas_equalTo(KDSSSALE_WIDTH(81));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 30 : 65);
    }];
//
//   UIView *routerProtocolView = [UIView new];
//   routerProtocolView.backgroundColor = UIColor.clearColor;
//   UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(connectedReconnectClickTap:)];
//   [routerProtocolView addGestureRecognizer:tap];
//    //暂时没有用到先隐藏
//    routerProtocolView.hidden = YES;
//   [self.view addSubview:routerProtocolView];
//   [routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
//       make.height.equalTo(@30);
//       make.left.right.equalTo(self.view);
//       make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -28 : -68);
//   }];
    
//    UILabel * routerProtocolLb = [UILabel new];
//    routerProtocolLb.text = @"门锁已联网，重新配网";
//    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
//    routerProtocolLb.textAlignment = NSTextAlignmentCenter;
//    routerProtocolLb.font = [UIFont systemFontOfSize:14];
//    [routerProtocolView addSubview:routerProtocolLb];
//    NSRange strRange = {0,[routerProtocolLb.text length]};
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
//    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
//    routerProtocolLb.attributedText = str;
//    [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.left.right.equalTo(routerProtocolView);
//    }];
    
    UIButton * reNetworkBtn = [UIButton new];
    [reNetworkBtn setTitle:@"门锁已联网，重新配网" forState:UIControlStateNormal];
    [reNetworkBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [reNetworkBtn addTarget:self action:@selector(reNetworkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    reNetworkBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    reNetworkBtn.backgroundColor = UIColor.whiteColor;
    reNetworkBtn.layer.borderWidth = 1;
    reNetworkBtn.layer.masksToBounds = YES;
    reNetworkBtn.layer.cornerRadius = 20;
    reNetworkBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    [self.view addSubview:reNetworkBtn];
    [reNetworkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -45 : -65);
    }];
    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"门锁安装好，去配网" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(connectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 20;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(reNetworkBtn.mas_top).offset(KDSScreenHeight > 667 ? -30 : -16);
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
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

//-(void)connectedReconnectClickTap:(UITapGestureRecognizer *)tap
//{
//    KDSConnectedReconnectVC * vc = [KDSConnectedReconnectVC new];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//已联网，重新连接
-(void)reNetworkBtnClick:(UIButton *)sender
{
    [self showAlerterView];
    KDSConnectedReconnectVC * vc = [KDSConnectedReconnectVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

//门锁安装好，去配网
-(void)connectBtnClick:(UIButton *)sender
{
    [self showAlerterView];
    KDSAddBleAndWiFiLockStep2 * vc = [KDSAddBleAndWiFiLockStep2 new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)navBackClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    if (!self.bleIsOpen) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"手机未连接蓝牙，无法添加设备" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * connectAction = [UIAlertAction actionWithTitle:@"去连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [KDSTool openSettingsURLString];
        }];
        [ac addAction:connectAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

#pragma mark - KDSBluetoothToolDelegate
- (void)discoverManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        self.bleIsOpen = NO;
    }else{
        self.bleIsOpen = YES;
    }
}

@end

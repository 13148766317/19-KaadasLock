//
//  KDSAddVideoWifiLockStep1VC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/7.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddVideoWifiLockStep1VC.h"
#import "KDSXMMediaLockHelpVC.h"
#import "KDSAddVideoWifiLockStep3VC.h"
#import "KDSAddNewWiFiLockStep2VC.h"
#import "KDSAMapLocationManager.h"
#import "KDSAddDeviceVC.h"


@interface KDSAddVideoWifiLockStep1VC ()

@end

///label之间多行显示的行间距
#define labelWidth  10

@implementation KDSAddVideoWifiLockStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    [self  backButton];

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
    tipMsgLabe1.text = @"第一步：门锁配网准备";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
        make.height.mas_equalTo(20);
        make.width.equalTo(@235);
        make.centerX.equalTo(self.view.mas_centerX);
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
        make.width.equalTo(@235);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 电池仓上装上锂电池（锂电池需要保证电池充足）";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    tipMsg1Labe.numberOfLines = 0;
    [self setLabelSpace:tipMsg1Labe withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
        make.width.equalTo(@235);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
//    UILabel * tipMsg2Labe = [UILabel new];
//    tipMsg2Labe.text = @"③ 电池仓装上4节或8节电池";
//    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
//    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
//    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
//    [self.view addSubview:tipMsg2Labe];
//    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
//        make.height.mas_equalTo(16);
//        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
//        make.right.mas_equalTo(self.view.mas_right).offset(-10);
//
//    }];
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"xmMediaBindingDevStep1Icon"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(223));
        make.width.mas_equalTo(KDSSSALE_WIDTH(50));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(KDSScreenHeight <= 667 ? 30 : 65);
    }];
    
    UIButton * reNetworkBtn = [UIButton new];
    [reNetworkBtn setTitle:@"门锁已联网，重新配网" forState:UIControlStateNormal];
    [reNetworkBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [reNetworkBtn addTarget:self action:@selector(reNetworkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    reNetworkBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    reNetworkBtn.backgroundColor = UIColor.whiteColor;
    reNetworkBtn.layer.borderWidth = 1;
    reNetworkBtn.layer.masksToBounds = YES;
    reNetworkBtn.layer.cornerRadius = 22;
    reNetworkBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    [self.view addSubview:reNetworkBtn];
    [reNetworkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -45 : -65);
    }];

    
    UIButton * connectBtn = [UIButton new];
    [connectBtn setTitle:@"门锁安装好，去配网" forState:UIControlStateNormal];
    [connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(connectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    connectBtn.layer.masksToBounds = YES;
    connectBtn.layer.cornerRadius = 22;
    [self.view addSubview:connectBtn];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(reNetworkBtn.mas_top).offset(KDSScreenHeight > 667 ? -30+6 : -16+6);
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
    KDSXMMediaLockHelpVC * vc = [KDSXMMediaLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
//已联网，重新连接
-(void)reNetworkBtnClick:(UIButton *)sender
{
    [self showAlerterView];
    KDSAddVideoWifiLockStep3VC * vc = [KDSAddVideoWifiLockStep3VC new];
    vc.isAgainNetwork = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//门锁安装好，去配网
-(void)connectBtnClick:(UIButton *)sender
{
    [self showAlerterView];
    KDSAddNewWiFiLockStep2VC * vc = [KDSAddNewWiFiLockStep2VC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)navBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

//亲测可行的办法：
-(void)removeSelf {
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in marr) {
        if (vc == self) {
            [marr removeObject:vc];
            break;//break一定要加，不加有时候有bug
        }
    }
    self.navigationController.viewControllers = marr;
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

-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font  {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:label.text attributes:dic];
    label.attributedText = attributeStr;
}

@end

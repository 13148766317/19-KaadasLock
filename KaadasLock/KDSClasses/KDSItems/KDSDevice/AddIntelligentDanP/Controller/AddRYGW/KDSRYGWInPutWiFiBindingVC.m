//
//  KDSRYGWInPutWiFiBindingVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSRYGWInPutWiFiBindingVC.h"
#import "KDSHomeRoutersVC.h"
#import "UIView+Extension.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSRYGWPairIngVC.h"
#import "KDSAMapLocationManager.h"

@interface KDSRYGWInPutWiFiBindingVC ()

///确认入网的按钮
@property (nonatomic,strong) UIButton * connectBtn;
///wifi的ssid
@property (nonatomic, strong) UILabel * wifiNameLb;
///wifi的bssid：MAC地址
@property (nonatomic, strong) NSString * bssidLb;
///wifi的密码
@property (nonatomic, strong) UITextField * pwdtf;
@property (nonatomic,strong) UIButton * pwdPlaintextSwitchingBtn;

@end

@implementation KDSRYGWInPutWiFiBindingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"Enter home WiFi");
    [self setUI];
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
  
}

-(void)navRightClick
{
    KDSWifiLockHelpVC *vc = [[KDSWifiLockHelpVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)setUI{
    
    
    UILabel * tips2b = [UILabel new];
    tips2b.text = @"连接Wi-Fi,绑定网关";
    tips2b.font = [UIFont systemFontOfSize:15];
    tips2b.textColor = KDSRGBColor(86, 86, 86);
    tips2b.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tips2b];
    [tips2b mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(30);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
    }];
    
    UIView * contentView = [UIView new];
    contentView.backgroundColor = UIColor.whiteColor;
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 10;
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tips2b.mas_bottom).offset(KDSScreenHeight <= 667 ? 20 : KDSSSALE_HEIGHT(43));
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@153);
    }];
    UIView * line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(220, 220, 220);
    [contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(KDSSSALE_WIDTH(39));
        make.right.mas_equalTo(contentView.mas_right).offset(-KDSSSALE_WIDTH(52));
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-29);
        make.height.equalTo(@1);
        
    }];
    UIImageView * pwdIconImg = [UIImageView new];
    pwdIconImg.image = [UIImage imageNamed:@"wifi-Lock-pwdIcon"];
    [contentView addSubview:pwdIconImg];
    [pwdIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.left.mas_equalTo(contentView.mas_left).offset(KDSSSALE_WIDTH(38.5));
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-35.5);
    }];
    self.pwdPlaintextSwitchingBtn = [UIButton new];
    [self.pwdPlaintextSwitchingBtn setImage:[UIImage imageNamed:@"眼睛闭Hight"] forState:UIControlStateNormal];
    [self.pwdPlaintextSwitchingBtn setImage:[UIImage imageNamed:@"眼睛开Hight"] forState:UIControlStateSelected];
    [self.pwdPlaintextSwitchingBtn addTarget:self action:@selector(plaintextClick:) forControlEvents:UIControlEventTouchUpInside];
    self.pwdPlaintextSwitchingBtn.selected = YES;
    [contentView addSubview:self.pwdPlaintextSwitchingBtn];
    [self.pwdPlaintextSwitchingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@18);
        make.height.equalTo(@11);
        make.right.mas_equalTo(contentView.mas_right).offset(-50.0);
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-38.5);
    }];
    _pwdtf = [UITextField new];
    _pwdtf.placeholder=@"请输入密码";
    _pwdtf.secureTextEntry = NO;
    _pwdtf.keyboardType = UIKeyboardTypeDefault;
    _pwdtf.textAlignment = NSTextAlignmentLeft;
    _pwdtf.font = [UIFont systemFontOfSize:13];
    _pwdtf.textColor = UIColor.blackColor;
    [_pwdtf addTarget:self action:@selector(pwdtextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [contentView addSubview:_pwdtf];
    [_pwdtf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pwdIconImg.mas_right).offset(7);
        make.right.mas_equalTo(self.pwdPlaintextSwitchingBtn.mas_left).offset(-5);
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-30);
        make.height.equalTo(@30);
    }];
    
    
    UIView * line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(220, 220, 220);
    [contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(KDSSSALE_WIDTH(39));
        make.right.mas_equalTo(contentView.mas_right).offset(-KDSSSALE_WIDTH(52));
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-83.5);
        make.height.equalTo(@1);
        
    }];
    UIImageView * wifiNameIconImg = [UIImageView new];
    wifiNameIconImg.image = [UIImage imageNamed:@"wifi-Lock-NameIcon"];
    [contentView addSubview:wifiNameIconImg];
    [wifiNameIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.left.mas_equalTo(contentView.mas_left).offset(KDSSSALE_WIDTH(38.5));
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-90.5);
    }];
    UIImageView * wifiNameRigthIcon = [UIImageView new];
    wifiNameRigthIcon.image = [UIImage imageNamed:@"取消_icon"];
    [contentView addSubview:wifiNameRigthIcon];
    [wifiNameRigthIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@14);
        make.height.equalTo(@14);
        make.right.mas_equalTo(contentView.mas_right).offset(-50.0);
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-92.5);
    }];
    _wifiNameLb = [UILabel new];
    _wifiNameLb.textAlignment = NSTextAlignmentLeft;
    _wifiNameLb.font = [UIFont systemFontOfSize:13];
    _wifiNameLb.textColor = UIColor.blackColor;
//    [_wifiNameLb addTarget:self action:@selector(wifiNametextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [contentView addSubview:_wifiNameLb];
    [_wifiNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wifiNameIconImg.mas_right).offset(7);
        make.right.mas_equalTo(contentView.mas_right).offset(-45.0);
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(-85);
        make.height.equalTo(@30);
    }];
    
    UILabel * wifiTipsLb = [UILabel new];
    wifiTipsLb.text = @"请使用手机连接2.4G  Wi-Fi";
    wifiTipsLb.font = [UIFont systemFontOfSize:14];
    wifiTipsLb.textColor = KDSRGBColor(86, 86, 86);
    wifiTipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:wifiTipsLb];
    [wifiTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView.mas_bottom).offset(15.5);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view);
    }];
    
    _connectBtn = [UIButton new];
    _connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    _connectBtn.layer.masksToBounds = YES;
    _connectBtn.layer.cornerRadius = 22;
    [_connectBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_connectBtn addTarget:self action:@selector(confirmBtnClicl:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectBtn];
    [_connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.top.mas_equalTo(wifiTipsLb.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UIView *routerProtocolView = [UIView new];
    routerProtocolView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportedHomeRoutersClickTap:)];
    [routerProtocolView addGestureRecognizer:tap];
    [self.view addSubview:routerProtocolView];
    [routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(_connectBtn.mas_bottom).offset(KDSScreenHeight < 667 ? 60 : KDSSSALE_HEIGHT(108));
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"查看门锁WiFi支持家庭路由器";
    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
    routerProtocolLb.textAlignment = NSTextAlignmentCenter;
    routerProtocolLb.font = [UIFont systemFontOfSize:14];
    [routerProtocolView addSubview:routerProtocolLb];
    NSRange strRange = {0,[routerProtocolLb.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    routerProtocolLb.attributedText = str;
    [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(routerProtocolView);
    }];
    
    UILabel * tipLb3 = [UILabel new];
    tipLb3.text = @"目前暂不支持5G频段的Wi-Fi以及酒店机场需认证的Wi-Fi";
    tipLb3.textColor = KDSRGBColor(31, 31, 31);
    tipLb3.textAlignment = NSTextAlignmentCenter;
    tipLb3.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:tipLb3];
    [tipLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(routerProtocolView.mas_top).offset(-10);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view);
    }];
    [self setBssi];
    
}
#pragma 控件事件
///确认入网按钮
-(void)confirmBtnClicl:(UIButton *)btn
{
    //smartconfig配网
    if (_wifiNameLb.text.length == 0) {
        ///有可能用户不同意访问定位，就无法获取wifi的ssid，所以只要点击配网就提示先去设备开启定位服务
         [MBProgressHUD showError:@"Wi-Fi名称不能为空"];
        return;
    }
    if (self.pwdtf.text.length == 0) {
        [MBProgressHUD showError:@"不支持无密码wifi"];
        return;
    }
    KDSRYGWPairIngVC * vc = [KDSRYGWPairIngVC new];
    vc.bleTool = self.bleTool;
    vc.bleTool.delegate = vc;
    vc.destPeripheral = self.destPeripheral;
    vc.model = self.model;
    vc.wifissid = self.wifiNameLb.text;
    vc.wifipwd = self.pwdtf.text;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
///点击更多子功能视图。
- (void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)sender
{
   KDSHomeRoutersVC * VC = [KDSHomeRoutersVC new];
   [self.navigationController pushViewController:VC animated:YES];
}

///密码昵称文本输入框，长度不能超过16
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}
-(void)plaintextClick:(UIButton *)sender
{
    self.pwdPlaintextSwitchingBtn.selected = !self.pwdPlaintextSwitchingBtn.selected;
    if (self.pwdPlaintextSwitchingBtn.selected) {
        self.pwdtf.secureTextEntry = NO;
    }else{
        self.pwdtf.secureTextEntry = YES;
    }
}

#pragma mark - 通知中心

-(void)applicationBecomeActive:(NSNotification *)no{
    [self setBssi];
}

///wifi账户的名称(32个字节)
- (void)wifiNametextFieldDidChange:(UITextField *)textField{
    if (textField.text.length > 32) {
        textField.text = [textField.text substringToIndex:12];
        [MBProgressHUD showError:@"Wi-Fi账户不能超过32个字节"];
    }
}
///wifi账户的名称的密码（64个字节）
-(void)pwdtextFieldDidChange:(UITextField *)textField{
    if (textField.text.length > 64) {
        textField.text = [textField.text substringToIndex:12];
        [MBProgressHUD showError:@"Wi-Fi名称的密码不能超过64个字节"];
    }
}

-(void)setBssi
{
    [[KDSAMapLocationManager sharedManager] initWithLocationManager];
    if ([KDSAMapLocationManager sharedManager].ssid.length != 0) {
        _wifiNameLb.text = [KDSAMapLocationManager sharedManager].ssid;
    }else{
        _wifiNameLb.text=@"";
    }
    self.bssidLb = [KDSAMapLocationManager sharedManager].bssid;
}
#pragma mark - KDSBluetoothToolDelegate
- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    if (!self.bleTool.connectedPeripheral)
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"connectFailed") message:Localized(@"clickOKReconnect") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MBProgressHUD showMessage:Localized(@"connectingLock") toView:self.view];
            NSLog(@"--{Kaadas}--beginConnectPeripheral--BleBindVC22");
            [self.bleTool beginConnectPeripheral:self.destPeripheral];
        }];
        [ac addAction:cancel];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral
{
    /**保存蓝牙uuid*/
    //[LoginTool saveBleDeviceUUIDWithPeripheral:peripheral];
//    [MBProgressHUD hideHUDForView:self.view animated:NO];

}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self centralManagerDidStopScan:central];
}

- (void)didDisConnectPeripheral:(CBPeripheral *)peripheral
{
    /*
     在绑定界面，当蓝牙断开自动连接蓝牙
     //    [MBProgressHUD showMessage:[Localized(@"bleNotConnect") stringByAppendingFormat:@", %@", Localized(@"connectingLock")] toView:self.view];
     //[self.bleTool beginConnectPeripheral:self.destPeripheral];
     */
    /*
     在绑定界面，当蓝牙断开，返回搜索页面
     */
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"UnableToBind") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:KDSWifiLockHelpVC.class]) {
                    //帮助页面不上推
                    return;
                }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
    
}
-(void)dealloc
{
//    if (self.bleTool.connectedPeripheral)
//    {
//        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
//    }
      
}
@end

//
//  KDSRYGWPairIngVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSRYGWPairIngVC.h"
#import "KDSBindingRYGWFailVC.h"
#import "KDSBindingRYGWSuccessVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSBleAssistant.h"
#import "NSString+extension.h"

@interface KDSRYGWPairIngVC ()

@property (nonatomic,strong)NSTimer * timer;

@end

@implementation KDSRYGWPairIngVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addWg");
    [self setUI];
//     self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerClick) userInfo:nil repeats:NO];
    //传输账户密码
    [self transferAccount];
}

-(void)setUI
{
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"正在进行设备配对";
    tipsLb.textColor = KDSRGBColor(51, 51, 51);
    tipsLb.font = [UIFont systemFontOfSize:17];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(56);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
    }];
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"addRYGWStep2Pairing_pic"];
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(180));
        make.width.equalTo(@219);
        make.height.equalTo(@127);
        make.centerX.equalTo(self.view);
    }];
    UILabel * tipsLb4 = [UILabel new];
    tipsLb4.text = @"设备连接网络中...";
    tipsLb4.font = [UIFont systemFontOfSize:13];
    tipsLb4.textColor = KDSRGBColor(102, 102, 102);
    tipsLb4.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb4];
    [tipsLb4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight < 667 ? -40 : -75);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view);
    }];
    UILabel * tipsLb3 = [UILabel new];
    tipsLb3.text = @"设备验证Wi-Fi账号密码";
    tipsLb3.font = [UIFont systemFontOfSize:13];
    tipsLb3.textColor = KDSRGBColor(51, 51, 51);
    tipsLb3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tipsLb4.mas_top).offset(-20);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view);
    }];
//    UIImageView * tipsImgIcon3 = [UIImageView new];
//    tipsImgIcon3.image = [UIImage imageNamed:@"selected22x22"];
//    [self.view addSubview:tipsImgIcon3];
//    [tipsImgIcon3 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.equalTo(@17);
//        make.right.mas_equalTo(tipsLb3.mas_left).offset(-5);
//        make.bottom.mas_equalTo(tipsLb4.mas_top).offset(-20);
//    }];
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"手机发送Wi-Fi账号密码";
    tipsLb2.font = [UIFont systemFontOfSize:13];
    tipsLb2.textColor = KDSRGBColor(51, 51, 51);
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tipsLb3.mas_top).offset(-20);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view);
    }];
    UIImageView * tipsImgIcon2 = [UIImageView new];
    tipsImgIcon2.image = [UIImage imageNamed:@"selected22x22"];
    [self.view addSubview:tipsImgIcon2];
    [tipsImgIcon2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@17);
        make.right.mas_equalTo(tipsLb2.mas_left).offset(-5);
        make.bottom.mas_equalTo(tipsLb3.mas_top).offset(-20);
    }];
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"配对过程中避免设备断电和App退出";
    tipsLb1.font = [UIFont systemFontOfSize:13];
    tipsLb1.textColor = KDSRGBColor(102, 102, 102);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tipsLb2.mas_top).offset(-40);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel * tipsLb11 = [UILabel new];
    tipsLb11.text = @"提示：";
    tipsLb11.font = [UIFont systemFontOfSize:15];
    tipsLb11.textColor = KDSRGBColor(31, 150, 247);
    tipsLb11.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:tipsLb11];
    [tipsLb11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(tipsLb1.mas_left).offset(0);
        make.bottom.mas_equalTo(tipsLb2.mas_top).offset(-38);
        make.width.equalTo(@60);
        
    }];
}

/*
 基于蓝牙通道发送wifi ssid/passwd:（APP--->网关）
     "REXWIFI"+ssidlen+ssid+passwdlen+passwd
 例：
     SSID:kaadas12345678
     PWD:12345678
     (十六进制)52455857494649 0E 6B61616461733132333435363738 08 3132333435363738
  */
-(void)transferAccount{
    //wifissid;
    //wifipwd;
//    NSString *ssid = [KDSBleAssistant convertDataToHexStr:[self.wifissid dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *REXWIFI = [KDSBleAssistant convertDataToHexStr:[@"REXWIFI" dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *ssid = [KDSBleAssistant convertDataToHexStr:[self.wifissid dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *ssidlen = [NSString ToHex:self.wifissid.length];

    NSString *pwd = [KDSBleAssistant convertDataToHexStr:[self.wifipwd dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *pwdlen = [NSString ToHex:self.wifipwd.length];
    
    NSString *account = [NSString stringWithFormat:@"%@%@%@%@%@",REXWIFI,ssidlen,ssid,pwdlen,pwd];

    NSString *uReceipt ;
    
    NSLog(@"--{Kaadas}--sendaccount=%@",account);
    
    uReceipt = [self.bleTool sendaccountData:account completion:^(KDSBleError error) {
        NSLog(@"--{Kaadas}--sendaccountData===");
    }];
    NSLog(@"--{Kaadas}--senduReceipt=%@",uReceipt);
    
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
#pragma mark 响应事件
-(void)timerClick
{
    KDSBindingRYGWSuccessVC * vc = [KDSBindingRYGWSuccessVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)dealloc
{
//    [self.timer invalidate];
//    self.timer = nil;
}

@end

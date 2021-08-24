//
//  KDSSmartHangerConnectedVC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/8.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSmartHangerConnectedVC.h"

@interface KDSSmartHangerConnectedVC ()

@end

@implementation KDSSmartHangerConnectedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addDevice");
    [self setUI];
    //[self performSelector:@selector(WiFiPwdVerification) withObject:nil afterDelay:2];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.bleTool.connectedPeripheral)
    {
        [MBProgressHUD showMessage:Localized(@"connectingLock") toView:self.view];

        [self.bleTool beginConnectPeripheral:self.destPeripheral];

    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}
-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.bleTool endConnectPeripheral:self.destPeripheral];
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

    self.smartHangerConnectedImg = [UIImageView new];
    self.smartHangerConnectedImg.image = [UIImage imageNamed:@"SmartHangerConnected.jpg"];
//    self.smartHangerConnectedImg.backgroundColor = UIColor.yellowColor;
    [supView addSubview:self.smartHangerConnectedImg];
    [self.smartHangerConnectedImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(supView.mas_top).offset(60);
        make.centerX.equalTo(supView);
        make.height.equalTo(@54);
        make.width.equalTo(@188);
    }];


    self.label = [[UILabel alloc] init];
    self.label.text = Localized(@"Pairing Success");
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    [supView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smartHangerConnectedImg.mas_bottom).offset(42);
        make.centerX.equalTo(supView);
        make.height.mas_equalTo(ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName : self.label.font}].height));
    }];
    
}
#pragma mark
-(void)WiFiPwdVerification
{
    KDSSmartHangerWiFiPwdVerificationVC * vc = [KDSSmartHangerWiFiPwdVerificationVC new];
    vc.destPeripheral = self.destPeripheral;
    vc.bleTool = self.bleTool;
    vc.bleTool.delegate = self.bleTool.delegate;
    [self.navigationController pushViewController:vc animated:YES];
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
            [self.bleTool beginConnectPeripheral:self.destPeripheral];
        }];
        [ac addAction:cancel];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    KDSLog(@"连接成功");
    [self WiFiPwdVerification];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self centralManagerDidStopScan:central];
}
@end

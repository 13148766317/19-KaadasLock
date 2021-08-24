//
//  KDSRYGWPairVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSRYGWPairVC.h"
#import "KDSRYGWInPutWiFiBindingVC.h"
#import "KDSBLEBindHelpVC.h"

@interface KDSRYGWPairVC ()

///连接蓝牙超时（提示框消失）
@property (nonatomic,strong) NSTimer * overTimer;

@end

@implementation KDSRYGWPairVC

#pragma mark - getter setter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addWg");
    [self setUI];
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerClick) userInfo:nil repeats:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    
    if (!self.bleTool.connectedPeripheral)
    {
        [MBProgressHUD showMessage:Localized(@"connectingRYGW") toView:self.view];

        [self.bleTool beginConnectPeripheral:self.destPeripheral];

        self.overTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(animationTimerActionOverTimer:) userInfo:nil repeats:NO];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    [self.bleTool endConnectPeripheral:self.destPeripheral];
    [self.overTimer invalidate];
    self.overTimer = nil;
}
-(void)setUI
{
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"addRYGWStep2Pairing_pic"];
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(85));
        make.width.equalTo(@219);
        make.height.equalTo(@127);
        make.centerX.equalTo(self.view);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"正在配对中，请稍等...";
    tipsLb.textColor = KDSRGBColor(153, 153, 153);
    tipsLb.font = [UIFont systemFontOfSize:17];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsImg.mas_bottom).offset(25);
        make.height.equalTo(@20);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
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
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    KDSRYGWInPutWiFiBindingVC * vc = [KDSRYGWInPutWiFiBindingVC new];
    vc.bleTool = self.bleTool;
    vc.bleTool.delegate = vc;
    vc.destPeripheral = peripheral;
    vc.model = self.model;
    [self.navigationController pushViewController:vc animated:YES];
    
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
                if ([vc isKindOfClass:KDSBLEBindHelpVC.class]) {
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
-(void)animationTimerActionOverTimer:(NSTimer *)overTimer
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

-(void)dealloc
{
   
      
}

@end

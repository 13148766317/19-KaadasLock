//
//  KDSBleAndWiFiDeviceConnectionStep1VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/15.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAndWiFiDeviceConnectionStep1VC.h"
#import "KDSWifiLockHelpVC.h"
#import "CYCircularSlider.h"
#import "KDSHttpManager+Ble.h"
#import "KDSBleInfoCell.h"
#import "MBProgressHUD+MJ.h"
#import "KDSBleAndWiFiInPutAdminiPwdVC.h"
#import "KDSBluetoothPairFailedVC.h"


@interface KDSBleAndWiFiDeviceConnectionStep1VC ()<senderValueChangeDelegate>
@property (nonatomic,strong)CYCircularSlider *circularSlider;
@property (nonatomic,strong)UILabel * sliderValueLb;
///是否允许跳转到下一个页面默认允许
@property (nonatomic,assign)BOOL isJumped;
///交换数据后如果15秒内有网络且请求成功即成功反之失败（绑定过程会切换两次网络，交换数据用锁广播的热点）
@property (nonatomic,strong)NSString * currentSsid;
///定时，每1.0秒增加10%的进度3秒没有跳转页面停留在99%
@property (nonatomic,strong)NSTimer * changeTimer;
///蓝牙连接上超时没有收到密码因子（失败）100秒
@property (nonatomic,strong)NSTimer * outTimer;
@property (nonatomic,assign)int currentNum;

@end

@implementation KDSBleAndWiFiDeviceConnectionStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"设备连接";
    self.currentNum = 70;
    self.isJumped = YES;
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(animationTimerActionChangeTimer:) userInfo:nil repeats:YES];
    self.outTimer = [NSTimer scheduledTimerWithTimeInterval:100.0f target:self selector:@selector(outTimer:) userInfo:nil repeats:NO];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",20];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.bleTool.connectedPeripheral)
    {
        [MBProgressHUD showMessage:Localized(@"connectingLock") toView:self.view];
        NSLog(@"--{Kaadas}--beginConnectPeripheral--BleBindVC11");
        [self.bleTool beginConnectPeripheral:self.destPeripheral];
        NSLog(@"----self.destPeripheral---%@",self.destPeripheral.functionSet);
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.changeTimer invalidate];
    self.changeTimer = nil;
    self.bleTool.isBinding = NO;
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
    
    ///保持门锁数字键盘灯亮
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"保持门锁数字键盘灯亮";
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
    tipsLb1.text = @"请将手机尽量靠近门锁";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(25);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
        
    }];
    
    UILabel * tipsLb11 = [UILabel new];
    tipsLb11.text = @"手机、门锁、路由器的最佳适配范围是5米";
    tipsLb11.textColor = KDSRGBColor(151, 151, 151);
    tipsLb11.textAlignment = NSTextAlignmentCenter;
    tipsLb11.font = [UIFont systemFontOfSize:11];
    [supView addSubview:tipsLb11];
    [tipsLb11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(10);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
        
    }];
    
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"正在配对中，请稍等...";
    tipsLb2.textColor = KDSRGBColor(143, 143, 143);
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    tipsLb2.font = [UIFont systemFontOfSize:17];
    [supView addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb11.mas_bottom).offset(50);
        make.height.equalTo(@25);
        make.centerX.equalTo(supView);
           
    }];
    
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
    
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
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
-(void)outTimer:(NSTimer *)t
{
    [self.outTimer invalidate];
    self.outTimer = nil;
    // 连接超时
    KDSBluetoothPairFailedVC * vc = [KDSBluetoothPairFailedVC new];
    if (self.bleTool.connectedPeripheral) {
        ///已经链接上蓝牙由于未知原因超时没有收到密码因子
        [self.bleTool endConnectPeripheral:self.destPeripheral];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KDSBluetoothToolDelegate
- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{ // 停止蓝牙扫描
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
    
}

-(void)replyBleAndWiFiACKWithValue:(int)value Cmd:(unsigned char)cmd tsn:(int)tsn
{
    if (cmd == KDSBleTunnelOrderSendCipherFactor && self.isJumped) {
        self.isJumped = NO;
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        [self.outTimer invalidate];
        self.outTimer = nil;
        [_circularSlider setAngleCurrent:200];
        self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"100"];
        KDSBleAndWiFiInPutAdminiPwdVC * vc = [KDSBleAndWiFiInPutAdminiPwdVC new];
        vc.crcData = self.bleTool.bleWiFiCRCData;
        vc.bleTool = self.bleTool;
        vc.tsn = tsn;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.navigationController pushViewController:vc animated:YES];
        });
    }
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self centralManagerDidStopScan:central];
}


@end

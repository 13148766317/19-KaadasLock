//
//  KDSSmartHangerSendSSIDAndPwdVC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSmartHangerSendSSIDAndPwdVC.h"
#import "KDSTool.h"
@interface KDSSmartHangerSendSSIDAndPwdVC ()<senderValueChangeDelegate,CLLocationManagerDelegate,KDSBluetoothToolDelegate>


@property(nonatomic, strong) NSString *deviceSN;
//重复收到配网成功消息，保存lastTSN，如果一样不重复执行
@property(nonatomic, assign) NSUInteger lastTSN;

@end
@implementation KDSSmartHangerSendSSIDAndPwdVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"connecting");
    self.wifiSuccess = NO; // wifi 是否连接成功
    self.ispushing = YES; // 是否跳转
    self.currentStepNum = 0; // 当前的步骤
    self.sliderCurrentNum = 70; // 进度条当前的值
    self.bleTool.delegate = self; // 蓝牙代理
    //self.isCanSendPwd = YES; // 是否可以发送pwd

    [self setUI];
    
    // 绘制100秒超时连接超时了就连接失败
    self.ReceiveDataOutTimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(receiveDataOutTimer:) userInfo:nil repeats:NO];
    ///_auto2Hand为yes，则使用原始SSID数据，不做编码转换
    NSMutableData * ssidData =  _auto2Hand?[[NSMutableData alloc] initWithData:[self.wifiNameStr dataUsingEncoding:NSUTF8StringEncoding]]:[[NSMutableData alloc] initWithData:[KDSAMapLocationManager sharedManager].originalSsid];
    ssidData.length = 42;
    self.pwdData = [[NSMutableData alloc] initWithData:[self.pwdStr dataUsingEncoding:NSUTF8StringEncoding]];
    self.pwdData.length = 70;
    
    KDSLog(@"ssid %@ %d %@",self.wifiNameStr,ssidData.length,ssidData);
    KDSLog(@"pwd %@ %d",self.pwdStr, self.pwdData);

    ///蓝牙发送SSID分3包发送每包14字节最后一包不够补0
    
    
    if (self.bleTool.connectedPeripheral) {
        for (int i = 0; i < 3; i ++) {
            NSData * sendData = [ssidData subdataWithRange:NSMakeRange(i*14, 14)];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.bleTool sendWiFiSSIDWithSSID_len:32 SSID_index:i cmd:KDSBleTunnelOrderSendSSID SSIDData:sendData completion:nil];
                if (i==2) {
                    self.isCanSendPwd = YES; // 是否可以发送pwd
                }
           });
            NSLog(@"配网发送ssid数据：%@",sendData);
        }
    }else{
        ///蓝牙断开，需要重新链接
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"门锁断开连接，无法验证 " preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[KDSAddSmartHangerStep2VC class]]) {
                    KDSAddSmartHangerStep2VC *A =(KDSAddSmartHangerStep2VC *)controller;
                    [self.navigationController popToViewController:A animated:YES];
                }
            }
        }];
        [alerVC addAction:okAction];
        [self presentViewController:alerVC animated:YES completion:nil];
    }
    ///ssid分3包发送不够补0
    self.currentStepNum = 1;
    // 开始动画
    [self startImgRotatingWidthImg:self.showTipsImg1];
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:0.10f target:self selector:@selector(animationTimerActionChangeTimer:) userInfo:nil repeats:YES];
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
    
    CGRect sliderFrame = CGRectMake((KDSScreenWidth-295)/2, 55, 275,275);
    self.circularSlider =[[CYCircularSlider alloc]initWithFrame:sliderFrame];
    self.circularSlider.delegate = self;
    [_circularSlider setAngleCurrent:80];
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
    self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"10"];
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
    tipsLb1.text = @"配网中，请稍后...";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(0);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
    }];
}
-(void)setUI1
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
    
    CGRect sliderFrame = CGRectMake((KDSScreenWidth-295)/2, 55, 275,275);
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
    tipsLb1.text = @"配网中，请稍后...";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(0);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
    }];

}

// 开始旋转
- (void)startImgRotatingWidthImg:(UIImageView *)imgView {
    self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    self.rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    self.rotateAnimation.duration = 1.0;
    self.rotateAnimation.repeatCount = MAXFLOAT;
    [imgView.layer addAnimation:self.rotateAnimation forKey:nil];
}
// 停止旋转
- (void)stopImgRotatingWidthImg:(UIImageView *)imgView
{
    CFTimeInterval pausedTime = [imgView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    imgView.layer.speed = 0.0;
    imgView.layer.timeOffset = pausedTime;
    self.rotateAnimation.removedOnCompletion = NO;
    self.rotateAnimation.fillMode = kCAFillModeRemoved;
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
  //  self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",num];
}
#pragma mark 控件点击事件
-(void)navRightClick
{
//    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
//    [self.navigationController pushViewController:vc animated:YES];
}
// 返回按钮
-(void)navBackClick
{
    ESWeakSelf
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (UIViewController *controller in __weakSelf.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddSmartHangerStep2VC class]]) {
                [__weakSelf endConnectPeripheral];
                KDSAddSmartHangerStep2VC *vc =(KDSAddSmartHangerStep2VC *)controller;
                [__weakSelf.navigationController popToViewController:vc animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}

-(void)recvDataTimeOut
{
    //[self addDeviceFail];
}
-(void) endConnectPeripheral {
    [self.bleTool endConnectPeripheral];
}
-(void)bindSmartHangerWithWifiSN:(KDSSmartHangerModel *)device randomCode:(NSString *)randomCode
{
    
    NSLog(@"zhu ==发送绑定晾衣机的list成功");
    
    if (self.currentNum > 10) {
        NSLog(@"网络请求10次没有成功失败");
        [self addDeviceFail];
        return;
    }
    
    self.currentNum ++;
    ///ble+wifi配网
    ESWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[KDSHttpManager sharedManager] bindSmartHangerDeviceSN:self.deviceSN  uid:[KDSUserManager sharedManager].user.uid success:^{
            //重新读取设备列表，如果在设备列表页面添加（没有调用读取设备列表），以便设备列表可以马上显示晾衣机
            [[KDSMQTTManager sharedManager] getGatewayAndDeviceList:^(NSError * _Nullable error, NSArray<GatewayModel *> * _Nullable w1, NSArray<MyDevice *> * _Nullable w2, NSArray<KDSWifiLockModel *> * _Nullable w3, NSArray<KDSProductInfoList *> * _Nullable w4, NSArray<KDSDeviceHangerModel *> * _Nonnull hangerList) {
                
            }];
            [__weakSelf addDeviceSuccessWidth:device];
        } error:^(NSError * _Nonnull error) {
            if (__weakSelf.currentNum > 10) {
                NSLog(@"网络请求10次没有成功失败");
                [__weakSelf addDeviceFail];
                return;
            }
        } failure:^(NSError * _Nonnull error) {
            if (__weakSelf.currentNum > 10) {
                NSLog(@"网络请求10次没有成功失败");
                [__weakSelf addDeviceFail];
                return;
            }
            
        }];
    });
}

#pragma mark 定时器方法回调
-(void)animationTimerActionOverTimer:(NSTimer *)overTimer
{
    NSLog(@"zhu ===晾衣机项目定时器回调 ");
    if (self.currentNum == 0) {
        [self stopImgRotatingWidthImg:self.showTipsImg2];
        self.showTipsImg3.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
        self.showHidenImg2.hidden = NO;
        self.showTipsImg2.hidden = YES;
        self.showTipsLb3.textColor = KDSRGBColor(31, 31, 31);
        [self startImgRotatingWidthImg:self.showTipsImg3];
    }

    [self bindSmartHangerWithWifiSN:nil  randomCode:self.model.randomCode];
}

-(void)animationTimerActionChangeTimer:(NSTimer *)overTimer
{
    //KDSLog(@"animationTimerActionChangeTimer %d %d", self.sliderCurrentNum, self.currentStepNum);
   //界面图画的更改
    self.sliderCurrentNum += 1;
    if (self.sliderCurrentNum > 195) {
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        [_circularSlider setAngleCurrent:195];
        self.sliderCurrentNum = 195;
        self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",99];
    }else{
        [_circularSlider setAngleCurrent:self.sliderCurrentNum];
        if (self.currentStepNum == 1) {
            [_circularSlider setAngleCurrent:70];
            self.sliderCurrentNum = 90;
            self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"0"];
        }else{
            if (self.currentStepNum == 2 && self.sliderCurrentNum >= 135) {
                self.sliderValueLb.text = @"50%";
                self.sliderCurrentNum = 135;
            }else{
                float sliderValue = (self.sliderCurrentNum - 70)/((200-70)/100.0f);
                self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",(int)sliderValue];
                
                
                //NSLog(@"当前进度条值：%@以及弧度：%d",self.sliderValueLb.text,self.sliderCurrentNum);
            }
        }
    }
    
}
-(void)receiveDataOutTimer:(NSTimer *)receiceDataOutTimer
{
    NSLog(@"超时s配网失败");
    [self.bleTool sendBleAndWiFiResponseInOrOutNet:0 tsn:self.tsn cmd:KDSBleTunnelOrderGetDisNetworkStatus value:1];
    [self addDeviceFail];
}

-(void)addDeviceFail
{
    [self.overTimer invalidate];
    self.overTimer = nil;
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    [self.bleTool sendBleAndWiFiResponseInOrOutNet:0 tsn:self.tsn cmd:KDSBleTunnelOrderGetDisNetworkStatus value:1];
    KDSAddSmartHangerFailVC * vc = [KDSAddSmartHangerFailVC new];
    if (self.ispushing) {
        self.ispushing = NO;
        [self endConnectPeripheral];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)addDeviceSuccessWidth:(KDSSmartHangerModel *)smartHangerModel
{
    [self.overTimer invalidate];
    self.overTimer = nil;
    [self.changeTimer invalidate];
    self.changeTimer = nil;
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    [self stopImgRotatingWidthImg:self.showTipsImg3];
    self.currentStepNum = 4;
    self.showTipsImg3.hidden = YES;
    self.showHidenImg3.hidden = NO;
    [_circularSlider setAngleCurrent:200];
    
    self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"100"];
    //[self.bleTool sendBleAndWiFiResponseInOrOutNet:0 tsn:self.tsn cmd:KDSBleTunnelOrderGetDisNetworkStatus value:0];
    
    [self endConnectPeripheral];
    KDSAddSmartHangerSuccessVC * vc = [KDSAddSmartHangerSuccessVC new];
//    vc.model = smartHangerModel;
    if (self.ispushing) {
        self.ispushing = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark --KDSBluetoothToolDelegate

-(void)replyBleAndWiFiACKWithValue:(int)value Cmd:(uint)cmd tsn:(int)tsn
{
    KDSLog(@"replyBleAndWiFiACKWithValue %d %x %d",value,cmd,tsn);
    //  蓝牙代理监听执行的时机
    if (value == 0 && cmd == KDSBleTunnelOrderSendSSID && self.isCanSendPwd) {
        //下发密码
        ///蓝牙发送SSID分3包发送每包14字节最后一包不够补0
        self.isCanSendPwd = NO;
        for (int k = 0; k < 5; k ++) {
            NSData * sendPwdData = [self.pwdData subdataWithRange:NSMakeRange(k*14, 14)];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 
                [self.bleTool sendWiFiSSIDWithSSID_len:64 SSID_index:k cmd:KDSBleTunnelOrderSendPwd SSIDData:sendPwdData completion:nil];
            });
            
            NSLog(@"replyBleAndWiFiACKWithValue ===页面发送pwd数据：%@",sendPwdData);
        }
        ///pwd分5包发送不够补0
        self.currentStepNum = 2;
    }else if (value == 0 && cmd == KDSBleTunnelOrderGetDisNetworkStatus){
        ///配网成功
        [self bindSmartHangerWithWifiSN:self.model randomCode:self.model.randomCode];
        NSLog(@"zhu 晾衣机配网成功收到的配网成功");
        [self.ReceiveDataOutTimer invalidate];
        self.ReceiveDataOutTimer = nil;
        [self stopImgRotatingWidthImg:self.showTipsImg1];
        self.showTipsLb2.textColor = KDSRGBColor(31, 31, 31);
        self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
        self.showHidenImg1.hidden = NO;
        self.showTipsImg1.hidden = YES;
        [self startImgRotatingWidthImg:self.showTipsImg2];
        self.currentStepNum = 3;
        self.wifiSuccess = YES;
        self.overTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(animationTimerActionOverTimer:) userInfo:nil repeats:YES];
        self.currentNum = 0;
        self.tsn = tsn;
    }else if (value == 1 && cmd == KDSBleTunnelOrderGetDisNetworkStatus){
        ///收到模块发来的配网失败的消息
        NSLog(@"zhu晾衣机配网成功收到的配网失败 ");
        [self.ReceiveDataOutTimer invalidate];
        self.ReceiveDataOutTimer = nil;
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        self.bleTool.currentBleNetworkNum++;
        if (self.bleTool.currentBleNetworkNum >= 5) {
            self.bleTool.currentBleNetworkNum = 0;
            NSLog(@"发送SSID、密码超过5次绑定失败");
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"Wi-Fi账号或密码输错已超过5次" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self addDeviceFail];
            }];
            [alerVC addAction:okAction];
            [self presentViewController:alerVC animated:YES completion:nil];
            return;
        } else if (value == 0 && cmd ==  KDSReportResponseRemainingTimes97){
            [MBProgressHUD  showError:@"晾衣机联网成功"];
        }else if (value == 1 && cmd ==  KDSReportResponseRemainingTimes97){
            [MBProgressHUD  showError:@"晾衣机联网失败"];
        }
        else{

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.mode =MBProgressHUDModeText;
            hud.detailsLabel.text = Localized(@"accountPasswordError");
            hud.bezelView.backgroundColor = [UIColor blackColor];
            hud.detailsLabel.textColor = [UIColor whiteColor];
            hud.detailsLabel.font = [UIFont systemFontOfSize:15];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self.navigationController popViewControllerAnimated:NO];
            });
        }
    }else if (value == 0 && cmd ==  KDSReportResponseRemainingTimes97) {

        //重复收到配网成功消息，保存lastTSN，如果一样不重复执行
        if (self.lastTSN == tsn ) {
            KDSLog(@"重复记录")
            return;
        }else {
            self.lastTSN = tsn;
        }
        //保存wifi ssid 与密码
        [KDSTool saveSSID:self.wifiNameStr pwd:self.pwdStr];
        
        self.deviceSN = self.bleTool.connectedPeripheral.serialNumber;
        
        [self bindSmartHangerWithWifiSN:nil randomCode:nil];
        //NSLog(@"zhu 晾衣机配网成功收到的配网成功");
        [self.ReceiveDataOutTimer invalidate];
        
        self.ReceiveDataOutTimer = nil;
        [self stopImgRotatingWidthImg:self.showTipsImg1];
        self.showTipsLb2.textColor = KDSRGBColor(31, 31, 31);
        self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
        self.showHidenImg1.hidden = NO;
        self.showTipsImg1.hidden = YES;
        [self startImgRotatingWidthImg:self.showTipsImg2];
        self.currentStepNum = 3;
        self.wifiSuccess = YES;
        //self.overTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(animationTimerActionOverTimer:) userInfo:nil repeats:YES];
        self.currentNum = 0;
        self.tsn = tsn;
        [self animationTimerActionOverTimer:nil];
        
    }
}
@end

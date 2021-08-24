//
//  KDSSendPwdAndSSIDVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSendPwdAndSSIDVC.h"
#import "KDSWifiLockHelpVC.h"
#import "CYCircularSlider.h"
#import "KDSGCDSocketManager.h"
#import "KDSAddWiFiLockSuccessVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "KDSHttpManager+WifiLock.h"
#import "KDSAddWiFiLockFailVC.h"
#import "NSData+JKEncrypt.h"
#import "NSString+extension.h"
#import "UIView+Extension.h"
#import "KDSAMapLocationManager.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import <CoreLocation/CoreLocation.h>


@interface KDSSendPwdAndSSIDVC ()<senderValueChangeDelegate,CLLocationManagerDelegate,TcpRecvDelegate>

@property (nonatomic,strong)CYCircularSlider *circularSlider;
///进度条百分比
@property (nonatomic,strong)UILabel * sliderValueLb;
///发送门锁管理员密码
@property (nonatomic,strong)UILabel * showTipsLb1;
///门锁验证管理员密码
@property (nonatomic,strong)UILabel * showTipsLb2;
///门锁设备验证中
@property (nonatomic,strong)UILabel * showTipsLb3;
///第一步
@property (nonatomic,strong)UIImageView * showTipsImg1;
@property (nonatomic,strong)UIImageView * showHidenImg1;
///第二步
@property (nonatomic,strong)UIImageView * showTipsImg2;
@property (nonatomic,strong)UIImageView * showHidenImg2;
///第三步
@property (nonatomic,strong)UIImageView * showTipsImg3;
@property (nonatomic,strong)UIImageView * showHidenImg3;
///交换数据后如果15秒内有网络且请求成功即成功反之失败（绑定过程会切换两次网络，交换数据用锁广播的热点）
@property (nonatomic,strong) NSString * currentSsid;
///收到绑定成功的消息每6秒请求一次服务器绑定设备
@property (nonatomic,strong) NSTimer * overTimer;
//与Wi-Fi模块数据交互成功
@property (nonatomic,assign) BOOL wifiSuccess;
///每6秒请求一个服务器10次失败即添加失败（热点断开的瞬间会没有网络，手机重连的过程中设备添加到服务器不会中断所以，循环之行定时器）
@property (nonatomic, assign) int currentNum;
///是否已经push过（只能执行一次）
@property (nonatomic, assign) BOOL ispushing;
///100秒没有收到模块发来成功的字符串，就失败
@property (nonatomic,strong) NSTimer * ReceiveDataOutTimer;
///定时，每0.2秒增加20%的进度3秒没有跳转页面停留在99%
@property (nonatomic,strong)NSTimer * changeTimer;
///进度条的值。默认是70，每0.2秒增加10
@property (nonatomic,assign)int sliderCurrentNum;
///当前是进行的第几步：第一步（发送SSID、pwd）第二步（收到模块发来的数据：成功/失败）第三步（正在请求服务器绑定设备）
@property (nonatomic,assign)int currentStepNum;
@property (nonatomic,strong)CABasicAnimation * rotateAnimation;


@end

@implementation KDSSendPwdAndSSIDVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"设备连接";
    self.wifiSuccess = NO;
    self.ispushing = YES;
    self.currentStepNum = 0;
    self.sliderCurrentNum = 70;
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    self.ReceiveDataOutTimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(receiveDataOutTimer:) userInfo:nil repeats:NO];
    KDSGCDSocketManager * socketManger = [KDSGCDSocketManager sharedManager];
    socketManger.delegate = self;
    socketManger.wifiSuccess = YES;
    ///字节不够的话，等3秒，把接收的拼接在一起
    //        NSMutableData * ssidData = [[NSMutableData alloc] initWithData:[self.wifiNameStr dataUsingEncoding:NSUTF8StringEncoding]];
    //        ///_auto2Hand为yes，则使用原始SSID数据，不做编码转换
    NSMutableData * ssidData =  _auto2Hand?[[NSMutableData alloc] initWithData:[self.wifiNameStr dataUsingEncoding:NSUTF8StringEncoding]]:[[NSMutableData alloc] initWithData:[KDSAMapLocationManager sharedManager].originalSsid];
    ssidData.length = 32;
    NSMutableData * pwdData = [[NSMutableData alloc] initWithData:[self.pwdStr dataUsingEncoding:NSUTF8StringEncoding]];
    pwdData.length = 64;
    NSMutableData * data = [NSMutableData new];
    [data appendData:ssidData];
    [data appendData:pwdData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [socketManger.serverSocket writeData:data withTimeout:15 tag:10000];
        NSLog(@"发送出去的数据流：%@====socket：%@",data,socketManger.serverSocket);
        self.currentStepNum = 1;
    });
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
        make.top.equalTo(self.circularSlider.mas_bottom).offset(0);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
    }];
    
    self.showTipsImg1 =[UIImageView new];
    self.showTipsImg1.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
    [supView addSubview:self.showTipsImg1];
    [self.showTipsImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 123 : 73);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    //showHidenImg1
    self.showHidenImg1 =[UIImageView new];
    self.showHidenImg1.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    self.showHidenImg1.hidden = YES;
    [supView addSubview:self.showHidenImg1];
    [self.showHidenImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 123 : 73);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb1 = [UILabel new];
    self.showTipsLb1.text = @"发送Wi-Fi账号、密码";
    self.showTipsLb1.textColor = KDSRGBColor(31, 31, 31);
    self.showTipsLb1.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb1.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb1];
    [self.showTipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 120 : 70);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    UIView * line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showTipsLb1.mas_bottom).offset(0);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    UIView * line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(45);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    self.showTipsImg2 =[UIImageView new];
    self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOffImg"];
    [supView addSubview:self.showTipsImg2];
    [self.showTipsImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line2.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHidenImg2 =[UIImageView new];
    self.showHidenImg2.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHidenImg2];
    self.showHidenImg2.hidden = YES;
    [self.showHidenImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line2.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb2 = [UILabel new];
    self.showTipsLb2.text = @"配网成功";
    self.showTipsLb2.textColor = KDSRGBColor(205, 205, 205);
    self.showTipsLb2.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb2.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb2];
    [self.showTipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line2.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    UIView * line3 = [UIView new];
    line3.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line2.mas_bottom).offset(45);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    self.showTipsImg3 =[UIImageView new];
    self.showTipsImg3.image = [UIImage imageNamed:@"addWiFiLockStatusOffImg"];
    [supView addSubview:self.showTipsImg3];
    [self.showTipsImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line3.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHidenImg3 =[UIImageView new];
    self.showHidenImg3.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHidenImg3];
    self.showHidenImg3.hidden = YES;
    [self.showHidenImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line3.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb3 = [UILabel new];
    self.showTipsLb3.text = @"绑定成功";
    self.showTipsLb3.textColor = KDSRGBColor(205, 205, 205);
    self.showTipsLb3.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb3.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb3];
    [self.showTipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line3.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
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
    
    //    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",num];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)navBackClick
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddNewWiFiLockStep1VC class]]) {
                 [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
                KDSAddNewWiFiLockStep1VC *A =(KDSAddNewWiFiLockStep1VC *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}

-(void)recv:(NSData *)data withTag:(long)tag
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSData * apSuccess = [data subdataWithRange:NSMakeRange(0, data.length)];
        NSString * apSuccessStr = [[NSString alloc] initWithData:apSuccess encoding:NSUTF8StringEncoding];
        NSLog(@"最后解析锁发过来的数据：%@",apSuccessStr);
        if ([apSuccessStr containsString:@"APSuccess"]) {
            [self.ReceiveDataOutTimer invalidate];
            self.ReceiveDataOutTimer = nil;
            [self stopImgRotatingWidthImg:self.showTipsImg1];
            self.showTipsLb2.textColor = KDSRGBColor(31, 31, 31);
            self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
//            self.showTipsImg1.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
            self.showHidenImg1.hidden = NO;
            self.showTipsImg1.hidden = YES;
            [self startImgRotatingWidthImg:self.showTipsImg2];
            self.currentStepNum = 2;
            self.wifiSuccess = YES;
            self.overTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(animationTimerActionOverTimer:) userInfo:nil repeats:YES];
            ///断开链接
            [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
            self.currentNum = 0;
        }else if([apSuccessStr containsString:@"APError"]){
            [self.ReceiveDataOutTimer invalidate];
            self.ReceiveDataOutTimer = nil;
            [KDSGCDSocketManager sharedManager].currentNetworkNum ++;
            if ([KDSGCDSocketManager sharedManager].currentNetworkNum > 5) {
                [KDSGCDSocketManager sharedManager].currentNetworkNum = 0;
                [[KDSGCDSocketManager sharedManager].serverSocket writeData:[@"************************************************************************************************APClose" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:10002];
                NSLog(@"发送SSID、密码超过5次绑定失败");
                UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"Wi-Fi账号或密码输错已超过5次" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self addDeviceFail];
                }];
                [alerVC addAction:okAction];
                [self presentViewController:alerVC animated:YES completion:nil];
                return;
            }
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
        else{
            NSLog(@"不知道模块发的啥导致失败：%@",apSuccessStr);
            [self addDeviceFail];
        }
        
    });
}

-(void)recvDataTimeOut
{
    //    [self addDeviceFail];
}

-(void)bindWifiLockWithWifiSN:(KDSWifiLockModel *)wifiLockModel randomCode:(NSString *)randomCode
{
    if (self.currentNum > 10) {
        NSLog(@"网络请求10次没有成功失败");
        [self addDeviceFail];
        return;
    }
    NSMutableArray * hasBeensn = [NSMutableArray array];
    for (KDSLock * lock in [KDSUserManager sharedManager].locks) {
        if (lock.wifiDevice && lock.wifiDevice.isAdmin.intValue == 1) {
            [hasBeensn addObject:lock.wifiDevice.wifiSN];
        }
    }
    BOOL isContentWifiSN = [hasBeensn containsObject:wifiLockModel.wifiSN];
    self.currentNum ++;
    ///wifi配网
    wifiLockModel.distributionNetwork = 1;
    if (isContentWifiSN) {
        ///主用户绑定的是相同的一个锁，更新锁信息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KDSHttpManager sharedManager] updateBindWifiDevice:wifiLockModel uid:[KDSUserManager sharedManager].user.uid success:^{
                //处理请求 返回数据
                [self addDeviceSuccessWidth:wifiLockModel];
                
            } error:^(NSError * _Nonnull error) {
                if (self.currentNum > 10) {
                    NSLog(@"网络请求10次没有成功失败");
                    [self addDeviceFail];
                    return;
                }
            } failure:^(NSError * _Nonnull error) {
                if (self.currentNum > 10) {
                    NSLog(@"网络请求10次没有成功失败");
                    [self addDeviceFail];
                    return;
                }
            }];
        });
        
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KDSHttpManager sharedManager] bindWifiDevice:wifiLockModel uid:[KDSUserManager sharedManager].user.uid success:^{
                //处理请求 返回数据
                [self addDeviceSuccessWidth:wifiLockModel];
            } error:^(NSError * _Nonnull error) {
                if (self.currentNum > 10) {
                    NSLog(@"网络请求10次没有成功失败");
                    [self addDeviceFail];
                    return;
                }
            } failure:^(NSError * _Nonnull error) {
                if (self.currentNum > 10) {
                    NSLog(@"网络请求10次没有成功失败");
                    [self addDeviceFail];
                    return;
                }
                
            }];
        });
    }
}

#pragma mark 定时器方法回调
-(void)animationTimerActionOverTimer:(NSTimer *)overTimer
{
    if (self.currentNum == 0) {
        [self stopImgRotatingWidthImg:self.showTipsImg2];
        self.showTipsImg3.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
//        self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
        self.showHidenImg2.hidden = NO;
        self.showTipsImg2.hidden = YES;
        self.showTipsLb3.textColor = KDSRGBColor(31, 31, 31);
        self.currentStepNum = 3;
        [self startImgRotatingWidthImg:self.showTipsImg3];
    }
    
    [self bindWifiLockWithWifiSN:self.model randomCode:self.model.randomCode];
}

-(void)animationTimerActionChangeTimer:(NSTimer *)overTimer
{
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
            float sliderValue = (self.sliderCurrentNum - 70)/((200-70)/100.0f);
            self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",(int)sliderValue];
        }
    }
    
}
-(void)receiveDataOutTimer:(NSTimer *)receiceDataOutTimer
{
    NSLog(@"超时s配网失败");
    [self addDeviceFail];
}

-(void)addDeviceFail
{
    [self.overTimer invalidate];
    self.overTimer = nil;
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
    KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
    if (self.ispushing) {
        self.ispushing = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)addDeviceSuccessWidth:(KDSWifiLockModel *)wifiLockModel
{
    [self.overTimer invalidate];
    self.overTimer = nil;
    [self stopImgRotatingWidthImg:self.showTipsImg3];
    self.currentStepNum = 4;
//    self.showTipsImg3.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    self.showTipsImg3.hidden = YES;
    self.showHidenImg3.hidden = NO;
    [_circularSlider setAngleCurrent:200];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"100"];
    [self.changeTimer invalidate];
    self.changeTimer = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        KDSAddWiFiLockSuccessVC * vc = [KDSAddWiFiLockSuccessVC new];
        vc.model = wifiLockModel;
        if (self.ispushing) {
            self.ispushing = NO;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    });
}

@end

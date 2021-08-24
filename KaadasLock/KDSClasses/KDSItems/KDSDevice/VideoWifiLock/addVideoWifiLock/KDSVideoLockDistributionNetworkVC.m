//
//  KDSVideoLockDistributionNetworkVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSVideoLockDistributionNetworkVC.h"
#import "KDSXMMediaLockHelpVC.h"
#import "CYCircularSlider.h"
#import "KDSAddWiFiLockFailVC.h"
#import "KDSMediaLockInPutAdminPwdVC.h"
#import "KDSAddVideoWifiLockStep1VC.h"

@interface KDSVideoLockDistributionNetworkVC ()<senderValueChangeDelegate>

@property (nonatomic,strong)CYCircularSlider *circularSlider;
@property (nonatomic,strong)UILabel * sliderValueLb;
///是否允许跳转到下一个页面默认允许
@property (nonatomic,assign)BOOL isJumped;
///交换数据后如果15秒内有网络且请求成功即成功反之失败（绑定过程会切换两次网络，交换数据用锁广播的热点）
@property (nonatomic,strong)NSString * currentSsid;
///定时，60秒超时
@property (nonatomic,strong)NSTimer * changeTimer;
@property (nonatomic,assign)int currentNum;
///计时器的值
@property (nonatomic,assign)int numValue;
///是否已经push过（只能执行一次）
@property (nonatomic, assign) BOOL ispushing;

@end

@implementation KDSVideoLockDistributionNetworkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self setUI];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.ispushing = YES;
    self.currentNum = 76;
    self.numValue = 0;
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(animationTimerActionChangeTimer:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaLockBindStatus:) name:KDSMQTTEventNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.changeTimer invalidate];
    self.changeTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDSMQTTEventNotification object:nil];
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
    
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"正在配网中，请稍后...";
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
    tipsLb1.text = @"请将手机和设备尽量靠近路由器";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(25);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
        
    }];
    
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"自动搜索门锁热点中，请稍等...";
    tipsLb2.textColor = KDSRGBColor(143, 143, 143);
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    tipsLb2.hidden = YES;
    tipsLb2.font = [UIFont systemFontOfSize:17];
    [supView addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(50);
        make.height.equalTo(@25);
        make.centerX.equalTo(supView);
           
    }];
    
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
    
//    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",num];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSXMMediaLockHelpVC * vc = [KDSXMMediaLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navBackClick
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddVideoWifiLockStep1VC class]]) {
                KDSAddVideoWifiLockStep1VC *A =(KDSAddVideoWifiLockStep1VC *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}

#pragma mark 定时器方法回调
-(void)animationTimerActionChangeTimer:(NSTimer *)overTimer
{
    self.numValue ++;
    self.currentNum += 130/60;
    [_circularSlider setAngleCurrent:self.currentNum];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%dS",self.numValue];
    if ([self.sliderValueLb.text isEqualToString:@"60S"]) {
        [_circularSlider setAngleCurrent:200];
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        //60秒超时没有收到mqtt上报锁添加消息即失败
        KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self.navigationController pushViewController:vc animated:YES];
        });
    }
}

#pragma mark -- 视频锁绑定结果的通知
- (void)mediaLockBindStatus:(NSNotification *)noti
{
    KDSWifiLockModel * model = [KDSWifiLockModel new];
    MQTTSubEvent  subevent = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if ([subevent isEqualToString:MQTTSubEventMdeiaLockBindSucces]) {//视频锁绑定成功
        model.device_sn = param[@"device_sn"];
        model.mac = param[@"mac"];
        model.device_did = param[@"device_did"];
        model.p2p_password = param[@"p2p_password"];
        model.wifiName = self.ssid;
        model.wifiSN = param[@"wfId"];
        //    视屏验证管理员密码
        KDSMediaLockInPutAdminPwdVC * vc = [KDSMediaLockInPutAdminPwdVC new];
        vc.model = model;
        vc.crcData = param[@"randomCode"];
        if (self.ispushing) {
            self.ispushing = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if ([subevent isEqualToString:MQTTSubEventMdeiaLockBindErrorNotity]){
        //不管超时还是其他错误，都结束配网且失败
        [self.changeTimer invalidate];
         self.changeTimer = nil;
        KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end

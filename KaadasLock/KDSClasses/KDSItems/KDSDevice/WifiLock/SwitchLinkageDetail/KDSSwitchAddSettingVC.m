//
//  KDSSwitchAddSettingVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/6/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSwitchAddSettingVC.h"
#import "CYCircularSlider.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTTManager+SmartHome.h"
#import "KDSSwitchLinkageDetailVC.h"

@interface KDSSwitchAddSettingVC ()<senderValueChangeDelegate>

@property (nonatomic,strong)CYCircularSlider *circularSlider;
@property (nonatomic,strong)UILabel * sliderValueLb;
///是否允许跳转到下一个页面默认允许
@property (nonatomic,assign)BOOL isJumped;
///交换数据后如果15秒内有网络且请求成功即成功反之失败（绑定过程会切换两次网络，交换数据用锁广播的热点）
@property (nonatomic,strong)NSString * currentSsid;
///定时，每1.0秒增加10%的进度3秒没有跳转页面停留在99%
@property (nonatomic,strong)NSTimer * changeTimer;
@property (nonatomic,assign)int currentNum;

@end

@implementation KDSSwitchAddSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"添加设置";
    self.currentNum = 70;
    self.isJumped = YES;
    [self setUI];
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(animationTimerActionChangeTimer:) userInfo:nil repeats:YES];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",0];
    ///发送setSwitch请求
    NSString * switchEn = self.tempSwitchDev[@"switchEn"] ?: self.lock.wifiDevice.switchDev[@"switchEn"];
    [[KDSMQTTManager sharedManager] setSwitchWithWf:self.lock.wifiDevice stParams:self.tempSwitchDev[@"switchArray"]?:self.lock.wifiDevice.switchDev[@"switchArray"] switchEn:switchEn.intValue completion:^(NSError * _Nullable error, BOOL success) {
        if (success) {
            [_circularSlider setAngleCurrent:200];
            self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"100"];
            [MBProgressHUD show:@"设置成功" icon:@"showSuccessImg.png" view:nil];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[KDSSwitchLinkageDetailVC class]]) {
                    KDSSwitchLinkageDetailVC * vc = (KDSSwitchLinkageDetailVC *)controller;
                    vc.isRefreshPage = YES;
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }else{
            [MBProgressHUD show:@"设置失败，请重新设置" icon:@"showErrorIconImg.png" view:nil];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[KDSSwitchLinkageDetailVC class]]) {
                    KDSSwitchLinkageDetailVC * vc = (KDSSwitchLinkageDetailVC *)controller;
                    vc.isRefreshPage = YES;
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.changeTimer invalidate];
    self.changeTimer = nil;
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
    tipsLb11.text = @"添加过程中避免手机断电和App退出";
    tipsLb11.textColor = KDSRGBColor(151, 151, 151);
    tipsLb11.textAlignment = NSTextAlignmentCenter;
    tipsLb11.font = [UIFont systemFontOfSize:11];
    [supView addSubview:tipsLb11];
    [tipsLb11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(10);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
        
    }];
    
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
    
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




@end

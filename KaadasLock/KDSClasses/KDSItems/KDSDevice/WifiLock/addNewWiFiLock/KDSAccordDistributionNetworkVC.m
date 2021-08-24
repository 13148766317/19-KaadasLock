//
//  KDSAccordDistributionNetworkVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAccordDistributionNetworkVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSDeviceConnectionStep1VC.h"
#import "KDSAddBleAndWiFiLockStep1.h"
#import "KDSBleAndWiFiSearchBluToothVC.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSWIfiLockMoreSettingVC.h"
#import "KDSAddVideoWifiLockStep1VC.h"
#import "KDSAddVideoWifiLockConfigureWiFiVC.h"
#import "KDSMediaLockMoreSettingVC.h"

@interface KDSAccordDistributionNetworkVC ()

@property (nonatomic,strong) UIImageView * addZigBeeLocklogoImg;

@end

@implementation KDSAccordDistributionNetworkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    [self startAnimation4Connection];
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
    
    //① 根据语音提示，按“4”选择“扩展功能” ② 再按“1”，选择“加入网络”
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 根据语音提示，按“4”选择“扩展功能”";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 81 : 50);
        make.height.mas_equalTo(16);
        make.centerX.equalTo(self.view);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第二步：进入配网模式";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tipMsgLabe.mas_top).offset(-20);
        make.height.mas_equalTo(20);
        make.left.equalTo(tipMsgLabe);
    }];
    
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 再按“1”，选择“加入网络”";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.equalTo(tipMsgLabe);
    }];
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 语音播报：“配网中，请稍后”";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.equalTo(tipMsgLabe);
        
    }];
    ///添加门锁的logo
    self.addZigBeeLocklogoImg = [UIImageView new];
    self.addZigBeeLocklogoImg.image = [UIImage imageNamed:@"changeAdminiPwdImg"];
    [self.view addSubview:self.addZigBeeLocklogoImg];
    [self.addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(201.5);
        make.width.mas_equalTo(99.5);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 54 : 84);
    }];
    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"已进入配网，下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 20;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -46 : -66);
    }];
    
}

//NSArray *_arrayImages4Connecting; 几张图片按顺序切换
- (void)startAnimation4Connection {
    NSArray * _arrayImages4Connecting = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"havedAdminiModelImg1.jpg"],
                                         [UIImage imageNamed:@"havedAdminiModelImg2.jpg"],
                                         [UIImage imageNamed:@"havedAdminiModelImg3.jpg"],
                                         [UIImage imageNamed:@"havedAdminiModelImg4.jpg"],
                                         [UIImage imageNamed:@"havedAdminiModelImg5.jpg"],
                                         nil];
    [self.addZigBeeLocklogoImg setAnimationImages:_arrayImages4Connecting];
    [self.addZigBeeLocklogoImg setAnimationRepeatCount:0];
    [self.addZigBeeLocklogoImg setAnimationDuration:5.0f];
    [self.addZigBeeLocklogoImg startAnimating];
    
}

//停止删除
-(void)imgAnimationStop{
    [self.addZigBeeLocklogoImg.layer removeAllAnimations];
}

-(void)dealloc
{
    [self imgAnimationStop];
}


#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)nextBtnClick:(UITapGestureRecognizer *)tap
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddBleAndWiFiLockStep1 class]]) {
            //ble+Wi-Fi配网
            KDSBleAndWiFiSearchBluToothVC *A = [KDSBleAndWiFiSearchBluToothVC new];
            [self.navigationController pushViewController:A animated:YES];
            return;
        }else if ([controller isKindOfClass:[KDSAddNewWiFiLockStep1VC class]]){
            //新的添加Wi-Fi锁流程
            KDSDeviceConnectionStep1VC * vc = [KDSDeviceConnectionStep1VC new];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }else if ([controller isKindOfClass:[KDSAddVideoWifiLockStep1VC class]]){
            //视频锁的配网流程
            KDSAddVideoWifiLockConfigureWiFiVC * vc = [KDSAddVideoWifiLockConfigureWiFiVC new];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        else if ([controller isKindOfClass:[KDSWIfiLockMoreSettingVC class]]){
            //根据设备的distributionNetwork值判断是wif还是ble+wifi
            if (self.lock.wifiDevice.distributionNetwork == 2) {
                 //ble+Wi-Fi配网
                KDSBleAndWiFiSearchBluToothVC *A = [KDSBleAndWiFiSearchBluToothVC new];
                [self.navigationController pushViewController:A animated:YES];
                return;
            }else if (self.lock.wifiDevice.distributionNetwork == 3){
                //视频锁的配网流程
                KDSAddVideoWifiLockConfigureWiFiVC * vc = [KDSAddVideoWifiLockConfigureWiFiVC new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }else{
                //新的添加Wi-Fi锁流程
                KDSDeviceConnectionStep1VC * vc = [KDSDeviceConnectionStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
                
            }
        }else if ([controller isKindOfClass:[KDSMediaLockMoreSettingVC class]]){
            if (self.lock.wifiDevice.distributionNetwork == 3) {
                //视频锁的配网流程
                KDSAddVideoWifiLockConfigureWiFiVC * vc = [KDSAddVideoWifiLockConfigureWiFiVC new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
    }
}


@end

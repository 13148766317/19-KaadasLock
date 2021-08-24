//
//  KDSAddCatEyeVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/9.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddCatEyeVC.h"
#import "UIView+BlockGesture.h"
#import "KDSScanGatewayVC.h"
#import <AVFoundation/AVFoundation.h>
#import "KDSMQTT.h"
#import<SystemConfiguration/CaptiveNetwork.h>
#import "KDSCatEyeMobilePhoneVC.h"
#import "RHScanViewController.h"
#import "KDSCateyeHelpVC.h"


@interface KDSAddCatEyeVC ()

@property (nonatomic,strong)NSString * deviceConfiSsid;

@end

@implementation KDSAddCatEyeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addCatEye");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    
}

-(void)setUI
{
    ///猫眼扫描添加
    UIButton * cateyeScanAddBtn = [UIButton new];
    [cateyeScanAddBtn setTitle:@"猫眼扫描添加" forState:UIControlStateNormal];
    [cateyeScanAddBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    cateyeScanAddBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cateyeScanAddBtn addTarget:self action:@selector(cateyeScanAddBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    NSRange strRange = {0,[cateyeScanAddBtn.titleLabel.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cateyeScanAddBtn.titleLabel.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [cateyeScanAddBtn setAttributedTitle:str forState:UIControlStateNormal];
    [self.view addSubview:cateyeScanAddBtn];
    [cateyeScanAddBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@25);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    
    ///下一步
    UIView * nextStepView = [UIView new];
    nextStepView.backgroundColor = KDSRGBColor(31, 150, 247);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecoginzer:)];
    [nextStepView addGestureRecognizer:tap];
    nextStepView.layer.cornerRadius = 22;
    [self.view addSubview:nextStepView];
    [nextStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(cateyeScanAddBtn.mas_top).offset(-25);
    }];
    ///扫描图标
    UIImageView * scanningIcon = [UIImageView new];
    scanningIcon .image = [UIImage imageNamed:@"scanning_icon"];
    [nextStepView addSubview:scanningIcon];
    [scanningIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@18);
        make.left.mas_equalTo(nextStepView.mas_left).offset(27);
        make.centerY.mas_equalTo(nextStepView.mas_centerY).offset(0);
    }];
    ///去扫描设备二维码
    
    UILabel * scanningLb = [UILabel new];
    scanningLb.text = Localized(@"codeforScanner");
    scanningLb.font = [UIFont systemFontOfSize:15];
    scanningLb.textColor = UIColor.whiteColor;
    scanningLb.backgroundColor = UIColor.clearColor;
    [nextStepView addSubview:scanningLb];
    [scanningLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@15);
        make.left.mas_equalTo(scanningIcon.mas_right).offset(10);
        make.centerY.mas_equalTo(nextStepView.mas_centerY).offset(0);
    }];
    ///提示语：第一步：打开猫眼后盖二维码进行扫描
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = Localized(@"OpenBoxtwoDimensionalCode");
    tipMsgLabe.font = [UIFont systemFontOfSize:17];
    tipMsgLabe.textColor = UIColor.blackColor;
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(self.view.mas_top).offset(65);
    }];
    
    ///添加猫眼的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加添加ZigBee_网关猫眼_打开包装盒扫描猫眼"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@84);
        make.width.mas_equalTo(@192);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
    
}

#pragma mark 控件点击事件
-(void)gestureRecoginzer:(UITapGestureRecognizer *)tap
{
    ///鉴权相机权限
    [self tunnelOrderCamera];
    
}
-(void)tunnelOrderCamera
{
    //判断权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                //配置扫描view
                [self loadScanVC];
                
            } else {
                
                UIAlertController *actionSheet=[UIAlertController alertControllerWithTitle:Localized(@"Camera privileges not opened") message:Localized(@"Settings-Privacy-Camera") preferredStyle:UIAlertControllerStyleAlert];
                
                // 创建action，这里action1只是方便编写，以后再编程的过程中还是以命名规范为主
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                //把action添加到actionSheet里
                [actionSheet addAction:action1];
                
                UIAlertAction *cancel=[UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
                [actionSheet addAction:cancel];
                if (actionSheet) {
                    [self presentViewController:actionSheet animated:YES completion:nil];
                    
                }
            }
        });
    }];
}
-(void)loadScanVC
{
    KDSScanGatewayVC *vc = [[KDSScanGatewayVC alloc] init];
    vc.fromWhereVC = @"CatEyeVC";
    vc.wifiPwd = self.gwConfigPwd;
    vc.gwSid = self.gwConfigWifiSsid;
    vc.gatewayModel = self.gateway.model;
    [self.navigationController pushViewController:vc animated:YES];
}

///猫眼扫描添加按钮事件
-(void)cateyeScanAddBtnClick:(UIButton *)sender
{
    KDSCatEyeMobilePhoneVC *vc = [[KDSCatEyeMobilePhoneVC alloc] init];
    vc.gwConfigPwd = self.gwConfigPwd;
    vc.gwConfigWifiSsid = self.gwConfigWifiSsid;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

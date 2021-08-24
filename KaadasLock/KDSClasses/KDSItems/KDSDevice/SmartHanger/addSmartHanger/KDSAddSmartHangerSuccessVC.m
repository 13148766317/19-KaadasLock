//
//  KDSAddSmartHangerSuccessVC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAddSmartHangerSuccessVC.h"


#import "KDSAddBleAndWiFiLockSuccessVC.h"
#import "UIButton+Color.h"
#import "KDSHttpManager+WifiLock.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import "KDSHomeRoutersVC.h"
#import "KDSShowBleAndWiFiLockView.h"
#import "KDSBleAddWiFiLockDetailsVC.h"
#import "SYAlertView.h"


@interface KDSAddSmartHangerSuccessVC ()

@end

@implementation KDSAddSmartHangerSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationTitleLabel.text = Localized(@"addSuccess");
    [self setUI];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(jumpRootVC) userInfo:nil repeats:NO];
}

-(void)jumpRootVC{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)navBackClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setUI{
    
    UIImageView * addWifiLockSuccessImg = [UIImageView new];
    addWifiLockSuccessImg.image = [UIImage imageNamed:@"add_smart_hanger_success"];
    [self.view addSubview:addWifiLockSuccessImg];
    [addWifiLockSuccessImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(72));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.width.equalTo(@65);
        make.height.equalTo(@45);
    }];
    
    self.successTipsLb = [UILabel new];
    self.successTipsLb.text = @"配网成功，您可以体验产品了~";
    self.successTipsLb.textColor = KDSRGBColor(86, 86, 86);
    self.successTipsLb.font = [UIFont systemFontOfSize:14];
    self.successTipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.successTipsLb];
    [self.successTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addWifiLockSuccessImg.mas_bottom).offset(23);
        make.height.equalTo(@20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
}


@end

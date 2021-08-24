//
//  KDSAddCatEyeVCStep1.m
//  KaadasLock
//
//  Created by zhaona on 2019/7/2.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddCatEyeVCStep1.h"
#import "KDSAddCatEye2VC.h"
#import "KDSCateyeHelpVC.h"

@interface KDSAddCatEyeVCStep1 ()
///提示语：第一步
@property (weak, nonatomic) IBOutlet UILabel *stepTips1Lb;
///提示语：开启猫眼
@property (weak, nonatomic) IBOutlet UILabel *stepStip2Lb;
///提示语：拨动猫眼背后开关
@property (weak, nonatomic) IBOutlet UILabel *stepTips3Lb;
///下一步按钮
@property (weak, nonatomic) IBOutlet UIButton *stepBtn;

@end

@implementation KDSAddCatEyeVCStep1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.stepBtn.layer.cornerRadius = 22;
    self.navigationTitleLabel.text = Localized(@"addCatEye");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
}


- (IBAction)stepBtn:(id)sender {
    
    KDSAddCatEye2VC * vc = [KDSAddCatEye2VC new];
    vc.gateway = self.gateway;
    vc.wifiPwd = self.gwConfigPwd;
    vc.gwSid = self.gwConfigWifiSsid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

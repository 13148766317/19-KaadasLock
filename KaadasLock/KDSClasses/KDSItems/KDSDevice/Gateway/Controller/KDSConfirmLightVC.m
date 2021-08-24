//
//  KDSConfirmLightVC.m
//  KaadasLock
//
//  Created by wzr on 2019/3/29.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSConfirmLightVC.h"


@interface KDSConfirmLightVC ()

@property (weak, nonatomic) IBOutlet UILabel *tips1Lb;
@property (weak, nonatomic) IBOutlet UILabel *tips2Lb;
@property (weak, nonatomic) IBOutlet UILabel *tips3Lb;

@property (weak, nonatomic) IBOutlet UIButton *confirmClickBtn;

@end

@implementation KDSConfirmLightVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addWg");
    self.tips1Lb.text = Localized(@"Network connection router LAN and gateway WAN, power on, confirm that the light is always on");
    self.tips2Lb.text = Localized(@"ConfirmDistributionNetwork");
    self.tips3Lb.text = Localized(@"(If the indicator press the reset key)");
    
    [self.confirmClickBtn setTitle:Localized(@"Confirm indicator lights up") forState:UIControlStateNormal];
    
}
- (IBAction)confirmClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end

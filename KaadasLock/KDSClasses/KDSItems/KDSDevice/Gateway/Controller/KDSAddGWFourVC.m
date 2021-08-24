//
//  KDSAddGWFourVC.m
//  KaadasLock
//
//  Created by wzr on 2019/3/29.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddGWFourVC.h"

@interface KDSAddGWFourVC ()

@end

@implementation KDSAddGWFourVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addWg");
    // Do any additional setup after loading the view from its nib.
}
///暂时不添加
- (IBAction)noAddClick:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
  
}
///前去添加zigbee设备
- (IBAction)addZigBeeDeviceBtn:(id)sender {
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}


@end

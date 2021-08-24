//
//  KDSBindingSuccVC.m
//  KaadasLock
//
//  Created by wzr on 2019/3/29.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBindingSuccVC.h"
#import "KDSAddGWFourVC.h"

@interface KDSBindingSuccVC ()

@end

@implementation KDSBindingSuccVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addWg");
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)succClick:(id)sender {
    KDSAddGWFourVC *vc = [[KDSAddGWFourVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

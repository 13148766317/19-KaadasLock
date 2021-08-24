//
//  KDSAddGWVCTwo.m
//  KaadasLock
//
//  Created by wzr on 2019/3/28.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddGWVCTwo.h"
#import "KDSAddGWThreVC.h"

@interface KDSAddGWVCTwo ()
@property (weak, nonatomic) IBOutlet UIView *addKdsGWView;
@property (weak, nonatomic) IBOutlet UITextField *KdsWIFILab;
@property (weak, nonatomic) IBOutlet UITextField *WIFIPwdLab;

@end

@implementation KDSAddGWVCTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addWg");
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)nextStepClick:(id)sender {
    KDSAddGWThreVC *vc = [[KDSAddGWThreVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)closeEyeClick:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
    }else{
        sender.selected = NO;
    }
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

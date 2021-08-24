//
//  KDSAddGWVCOne.m
//  KaadasLock
//
//  Created by wzr on 2019/3/28.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddGWVCOne.h"
#import "KDSAddGWVCTwo.h"
#import "KDSConfirmLightVC.h"
#import "KDSScanPreviousStepVC.h"


@interface KDSAddGWVCOne ()
///如何将指示灯设置为长亮
@property (weak, nonatomic) IBOutlet UIButton *howLightBtn;
///提示语
@property (weak, nonatomic) IBOutlet UILabel *tipsLb;
///下一步
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation KDSAddGWVCOne

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationTitleLabel.text = Localized(@"addWg");
    self.tipsLb.text = Localized(@"Turn on the power and make sure the light is always on");
    [self.nextBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [self.howLightBtn setTitle:Localized(@"How to Set the Indicator Light Always on") forState:UIControlStateNormal];
    [self setUI];

}
-(void)setUI{
    
    NSRange strRange = {0,[_howLightBtn.titleLabel.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:_howLightBtn.titleLabel.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_howLightBtn setAttributedTitle:str forState:UIControlStateNormal];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(44));
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    
}
- (IBAction)nextStepClick:(id)sender {
    
    ///扫描二维码添加网关
    KDSScanPreviousStepVC *vc = [[KDSScanPreviousStepVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
   
}

- (IBAction)howLightBtn:(id)sender {
    KDSConfirmLightVC *VC = [[KDSConfirmLightVC alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

@end

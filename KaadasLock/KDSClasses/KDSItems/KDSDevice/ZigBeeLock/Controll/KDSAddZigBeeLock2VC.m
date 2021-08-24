//
//  KDSAddZigBeeLock2VC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAddZigBeeLock2VC.h"
#import "KDSAddZigBeeLock3VC.h"
#import "KDSBLEBindHelpVC.h"

@interface KDSAddZigBeeLock2VC ()

@end

@implementation KDSAddZigBeeLock2VC

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSBLEBindHelpVC *vc = [[KDSBLEBindHelpVC alloc] init];
    vc.helpFromStr = @"ZigeBeeLock";
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)nextStepBtnClick:(UIButton *)sender
{
    KDSAddZigBeeLock3VC * zb3VC = [KDSAddZigBeeLock3VC new];
    zb3VC.gw = self.gw;
    [self.navigationController pushViewController:zb3VC animated:YES];
}

-(void)setUI
{
    UILabel *tips2Label = [self createLabelWithText:Localized(@"bindBleTips7") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:17]];
    tips2Label.numberOfLines = 0;
    [self.view addSubview:tips2Label];
    [tips2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight < 667 ? 20 : KDSSSALE_HEIGHT(44));
        make.height.mas_equalTo(18);
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
    }];
    UILabel *tips3Label = [self createLabelWithText:Localized(@"bindBleTips2") color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13]];
    tips3Label.numberOfLines = 0;
    [self.view addSubview:tips3Label];
    [tips3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tips2Label.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
    }];

    UILabel *tips4Label = [self createLabelWithText:Localized(@"bindBleTips3") color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13]];
    tips4Label.numberOfLines = 0;
    [self.view addSubview:tips4Label];
    [tips4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tips3Label.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
    }];
    UILabel *tips5Label = [self createLabelWithText:Localized(@"bindBleTips4") color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13]];
    tips5Label.numberOfLines = 0;
    [self.view addSubview:tips5Label];
    [tips5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tips4Label.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
    }];
    
    ///锁icon
    UIImageView *tipsIV= [UIImageView new];
    tipsIV.image = [UIImage imageNamed:@"lockOperateKeyboard"];
    [self.view addSubview:tipsIV];
    [tipsIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(tipsIV.image.size);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(KDSSSALE_HEIGHT(25));
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
    
    ///提示：初始用户管理密码：12345678
    UIView *view = [UIView new];
    view.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsIV.mas_bottom).offset(KDSSSALE_HEIGHT(45));
        make.height.mas_equalTo(13);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    
    }];
    
    UILabel *label = [self createLabelWithText:Localized(@"initialAdminPwd1-8") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    label.numberOfLines = 0;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(14);
        make.left.equalTo(view).offset(35);
        make.right.equalTo(view).offset(-35);
    }];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamationMark"]];
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(label.mas_left).offset(-7);
        make.centerY.equalTo(label);
        make.width.height.equalTo(@12);
    }];
    
    ///下一步
    UIButton * nextStepBtn = [UIButton new];
    nextStepBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextStepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextStepBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextStepBtn];
    [nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight < 667 ? -20 : -KDSSSALE_HEIGHT(50));
    }];
}

- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}

@end

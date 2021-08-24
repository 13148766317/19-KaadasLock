//
//  KDSBingdingGWFailVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBingdingGWFailVC.h"
#import "RHScanViewController.h"
#import "KDSAddDeviceVC.h"


@interface KDSBingdingGWFailVC ()

@property (nonatomic,readwrite,strong) UIImageView * failIconImg;

@property (nonatomic,readwrite,strong) UILabel * failLabel;
///1～2步骤提示
@property (nonatomic,readwrite,strong) UIView * tipsView;
///再试一次
@property (nonatomic,readwrite,strong) UIButton * tryAgainBtn;
///取消绑定
@property (nonatomic,readwrite,strong) UIButton * cancelBtn;
@property (nonatomic,readwrite,strong) UILabel * tips1Label;
@property (nonatomic,readwrite,strong) UILabel * tips2Label;
@property (nonatomic,readwrite,strong) UILabel * tips3Label;
@property (nonatomic,readwrite,strong) UILabel * tipsBz1Label;
@property (nonatomic,readwrite,strong) UILabel * tipsBz2Label;
@property (nonatomic,readwrite,strong) UILabel * tipsBz3Label;

@end

@implementation KDSBingdingGWFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addWg");
    [self.view addSubview:self.failIconImg];
    [self.view addSubview:self.failLabel];
    [self.view addSubview:self.tipsView];
    [self.view addSubview:self.tryAgainBtn];
    [self.view addSubview:self.cancelBtn];
    [self.tipsView addSubview:self.tips1Label];
    [self.tipsView addSubview:self.tips2Label];
    [self.tipsView addSubview:self.tips3Label];
    [self.tipsView addSubview:self.tipsBz1Label];
    [self.tipsView addSubview:self.tipsBz2Label];
    [self.tipsView addSubview:self.tipsBz3Label];
    [self makeConstraints];

}

-(void)makeConstraints
{
    [self.failIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(53);
        make.width.mas_equalTo(66);
        make.top.mas_equalTo(kNavBarHeight+kStatusBarHeight+46);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    [self.failLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.failIconImg.mas_bottom).offset(20);
        make.height.mas_equalTo(16);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-32);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    [self.tryAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.bottom.mas_equalTo(self.cancelBtn.mas_top).offset(-25);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    CGFloat height = kScreenHeight<667 ? 150 : 225;
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.mas_equalTo(@(height));
        make.bottom.mas_equalTo(self.tryAgainBtn.mas_top).offset(-68);
    }];
    
    [self.tips1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipsView).offset(23);
        make.centerY.equalTo(self.tipsView.mas_top).offset(height / 6);
        make.width.height.equalTo(@17);
    }];
   
    [self.tipsBz1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tips1Label.mas_right).offset(17);
        make.centerY.equalTo(self.tips1Label);
    }];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [self.tipsView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsView).offset(height / 3 - 1);
        make.left.equalTo(self.tips1Label);
        make.right.equalTo(self.tipsView);
        make.height.equalTo(@1);
    }];
    
    [self.tips2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipsView).offset(23);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@17);
    }];
   
    [self.tipsBz2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tips2Label.mas_right).offset(17);
        make.centerY.equalTo(self.tips2Label);
    }];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [self.tipsView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(height / 3 - 1);
        make.left.equalTo(self.tips2Label);
        make.right.equalTo(self.tipsView);
        make.height.equalTo(@1);
    }];

    [self.tips3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipsView).offset(23);
        make.centerY.equalTo(self.tipsView.mas_bottom).offset(-height / 6);
        make.width.height.equalTo(@17);
    }];

    [self.tipsBz3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tips3Label.mas_right).offset(17);
        make.centerY.equalTo(self.tips3Label);
    }];
 
    
}

#pragma mark 控件点击事件
 ///再试一次---返回到添加网关页面
-(void)tryClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[RHScanViewController class]]) {
            RHScanViewController * vc =(RHScanViewController *)controller;
            vc.isOpenInterestRect = YES;
            vc.isVideoZoom = YES;
            vc.fromWhereVC = @"AddDeviceVC";//添加设备
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    
}
///取消绑定
-(void)cancleClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddDeviceVC class]]) {
            KDSAddDeviceVC *A =(KDSAddDeviceVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}

-(void)navBackClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark --Lazy load

- (UIImageView *)failIconImg
{
    if (!_failIconImg) {
        _failIconImg = ({
            UIImageView * f = [UIImageView new];
            f.image = [UIImage imageNamed:@"gatewayConnectFail"];
            f;
        });
    }
    
    return _failIconImg;
}

- (UILabel *)failLabel
{
    if (!_failLabel) {
        _failLabel = ({
            UILabel * lb = [UILabel new];
            lb.text =Localized(@"connectBLEFailed");
            lb.font = [UIFont systemFontOfSize:15];
            lb.textColor = KDSRGBColor(153, 153, 153);
            lb.textAlignment = NSTextAlignmentCenter;
            lb;
        });
    }
    return _failLabel;
}

-(UIView *)tipsView
{
    if (!_tipsView) {
        _tipsView = ({
            UIView * v = [UIView new];
            v.backgroundColor = UIColor.whiteColor;
            v.layer.masksToBounds = YES;
            v.layer.cornerRadius = 4;
            
            v;
        });
    }
    return _tipsView;
}

- (UIButton *)tryAgainBtn
{
    if (!_tryAgainBtn) {
        _tryAgainBtn = ({
            UIButton * tryB = [UIButton new];
            [tryB setTitle:Localized(@"tryBtn") forState:UIControlStateNormal];
            tryB.backgroundColor = KDSRGBColor(31, 150, 247);
            tryB.layer.masksToBounds = YES;
            tryB.titleLabel.font = [UIFont systemFontOfSize:15];
            [tryB setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            tryB.layer.cornerRadius = 22;
            [tryB addTarget:self action:@selector(tryClick:) forControlEvents:UIControlEventTouchUpInside];
            tryB;
        });
    }
    
    return _tryAgainBtn;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = ({
            UIButton  * c = [UIButton new];
            [c setTitle:Localized(@"cancleBingding") forState:UIControlStateNormal];
            c.backgroundColor = UIColor.whiteColor;
            c.layer.masksToBounds = YES;
            c.titleLabel.font = [UIFont systemFontOfSize:15];
            [c setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
            [c addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
            c.layer.cornerRadius = 22;
            c;
        });
    }
    return _cancelBtn;
}

-(UILabel *)tips1Label
{
    if (!_tips1Label) {
        _tips1Label = ({
            UILabel * Lb1 = [UILabel new];
            Lb1.text = @"1";
            Lb1.font = [UIFont systemFontOfSize:12];
            Lb1.textColor = UIColor.whiteColor;
            Lb1.textAlignment = NSTextAlignmentCenter;
            Lb1.backgroundColor = KDSRGBColor(31, 150, 247);
            Lb1.layer.masksToBounds = YES;
            Lb1.layer.cornerRadius = 17/2;
            Lb1;
        });
    }
    return _tips1Label;
}
-(UILabel *)tips2Label
{
    if (!_tips2Label) {
        _tips2Label = ({
            UILabel * Lb1 = [UILabel new];
            Lb1.text = @"2";
            Lb1.font = [UIFont systemFontOfSize:12];
            Lb1.textColor = UIColor.whiteColor;
            Lb1.textAlignment = NSTextAlignmentCenter;
            Lb1.backgroundColor = KDSRGBColor(31, 150, 247);
            Lb1.layer.masksToBounds = YES;
            Lb1.layer.cornerRadius = 17/2;
            Lb1;
        });
    }
    return _tips2Label;
}
- (UILabel *)tips3Label
{
    if (!_tips3Label) {
        _tips3Label = ({
            UILabel * L3 = [UILabel new];
            L3.text = @"3";
            L3.font = [UIFont systemFontOfSize:12];
            L3.textColor = UIColor.whiteColor;
            L3.textAlignment = NSTextAlignmentCenter;
            L3.backgroundColor = KDSRGBColor(31, 150, 247);
            L3.layer.masksToBounds = YES;
            L3.layer.cornerRadius = 17/2;
            L3;
        });
    }
    return _tips3Label;
}
-(UILabel *)tipsBz1Label
{
    if (!_tipsBz1Label) {
        _tipsBz1Label = ({
            UILabel * Lb1 = [UILabel new];
            Lb1.text = Localized(@"The gateway has been bound");
            Lb1.font = [UIFont systemFontOfSize:13];
            Lb1.textColor = KDSRGBColor(51, 51, 51);
            Lb1.textAlignment = NSTextAlignmentLeft;
            Lb1;
        });
    }
    return _tipsBz1Label;
}
-(UILabel *)tipsBz2Label
{
    if (!_tipsBz2Label) {
        _tipsBz2Label = ({
            UILabel * Lb1 = [UILabel new];
            Lb1.text = Localized(@"thisGWNotIsKaadas");
            Lb1.font = [UIFont systemFontOfSize:13];
            Lb1.textColor = KDSRGBColor(51, 51, 51);
            Lb1.textAlignment = NSTextAlignmentLeft;
            Lb1;
        });
    }
    return _tipsBz2Label;
}
- (UILabel *)tipsBz3Label
{
    if (!_tipsBz3Label) {
        _tipsBz3Label = ({
            UILabel * lab3 = [UILabel new];
            lab3.text = Localized(@"checkMobileNetworkConnectedProperly");
            lab3.font = [UIFont systemFontOfSize:13];
            lab3.textColor = KDSRGBColor(51, 51, 51);
            lab3.textAlignment = NSTextAlignmentLeft;
            lab3;
        });
    }
    return _tipsBz3Label;
}

@end

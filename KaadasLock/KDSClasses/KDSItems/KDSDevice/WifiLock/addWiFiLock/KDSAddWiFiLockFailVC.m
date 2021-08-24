//
//  KDSAddWiFiLockFailVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/13.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddWiFiLockFailVC.h"
#import "KDSHomeRoutersVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSXMMediaLockHelpVC.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSAddBleAndWiFiLockStep1.h"
#import "KDSAddVideoWifiLockStep1VC.h"

@interface KDSAddWiFiLockFailVC ()

@end

@implementation KDSAddWiFiLockFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    self.navigationTitleLabel.text = Localized(@"addFail");
    [self setUI];
}

- (void)navBackClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)navRightClick
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
         if ([controller isKindOfClass:[KDSAddVideoWifiLockStep1VC class]]){
            //视频锁配网的帮助页面
             KDSXMMediaLockHelpVC * vc = (KDSXMMediaLockHelpVC *)controller;
             [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }
    KDSWifiLockHelpVC *vc = [[KDSWifiLockHelpVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)setUI{
    
    UIImageView * failImg = [UIImageView new];
    failImg.image = [UIImage imageNamed:@"wifi-Lock-addFailIcon"];
    [self.view addSubview:failImg];
    [failImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight < 667 ? 20 : KDSSSALE_HEIGHT(72));
        make.width.equalTo(@159);
        make.height.equalTo(@81);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        
    }];
    
    UILabel * failTipsLb = [UILabel new];
    failTipsLb.text = Localized(@"Pairing failure");
    failTipsLb.font = [UIFont systemFontOfSize:15];
    failTipsLb.textColor = KDSRGBColor(86, 86, 86);
    failTipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:failTipsLb];
    [failTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(failImg.mas_bottom).offset(15);
        make.height.equalTo(@20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UIView * tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.masksToBounds = YES;
    tipsView.layer.cornerRadius = 10;
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(failTipsLb.mas_bottom).offset(KDSSSALE_HEIGHT(32));
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@135);
        
    }];
    UIView * dotView1 = [UIView new];
    dotView1.backgroundColor = KDSRGBColor(181, 181, 181);
    dotView1.layer.masksToBounds = YES;
    dotView1.layer.cornerRadius = 3.5;
    [tipsView addSubview:dotView1];
    [dotView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsView.mas_top).offset(21.5);
        make.left.mas_equalTo(tipsView.mas_left).offset(11);
        make.width.height.equalTo(@7);
    }];
    UILabel * dotLb1 = [UILabel new];
    dotLb1.text = @"确保Wi-Fi是2.4G频率";
    dotLb1.font= [UIFont systemFontOfSize:13];
    dotLb1.textColor = KDSRGBColor(149, 149, 149);
    dotLb1.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:dotLb1];
    [dotLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(26);
        make.top.mas_equalTo(tipsView.mas_top).offset(19);
        make.right.mas_equalTo(tipsView.mas_right).offset(-26);
        make.height.equalTo(@15);
        
    }];
    
    UIView * dotView2 = [UIView new];
    dotView2.backgroundColor = KDSRGBColor(181, 181, 181);
    dotView2.layer.masksToBounds = YES;
    dotView2.layer.cornerRadius = 3.5;
    [tipsView addSubview:dotView2];
    [dotView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(dotView1.mas_bottom).offset(23.5);
        make.left.mas_equalTo(tipsView.mas_left).offset(11);
        make.width.height.equalTo(@7);
    }];
    UILabel * dotLb2 = [UILabel new];
    dotLb2.text = @"确保已经输入正确的WiFi账号和密码";
    dotLb2.font= [UIFont systemFontOfSize:13];
    dotLb2.textColor = KDSRGBColor(149, 149, 149);
    dotLb2.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:dotLb2];
    [dotLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(26);
        make.top.mas_equalTo(dotLb1.mas_bottom).offset(15);
        make.right.mas_equalTo(tipsView.mas_right).offset(-26);
        make.height.equalTo(@15);
        
    }];
    
    UIView * dotView3 = [UIView new];
    dotView3.backgroundColor = KDSRGBColor(181, 181, 181);
    dotView3.layer.masksToBounds = YES;
    dotView3.layer.cornerRadius = 3.5;
    [tipsView addSubview:dotView3];
    [dotView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(dotView2.mas_bottom).offset(23.5);
        make.left.mas_equalTo(tipsView.mas_left).offset(11);
        make.width.height.equalTo(@7);
    }];
    UILabel * dotLb3 = [UILabel new];
    dotLb3.text = @"确保连接的Wi-Fi 路由处于联网状态";
    dotLb3.font= [UIFont systemFontOfSize:13];
    dotLb3.textColor = KDSRGBColor(149, 149, 149);
    dotLb3.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:dotLb3];
    [dotLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(26);
        make.top.mas_equalTo(dotLb2.mas_bottom).offset(15);
        make.right.mas_equalTo(tipsView.mas_right).offset(-26);
        make.height.equalTo(@15);
        
    }];
    
    UIView * dotView4 = [UIView new];
    dotView4.backgroundColor = KDSRGBColor(32, 154, 253);
    dotView4.layer.masksToBounds = YES;
    dotView4.layer.cornerRadius = 3.5;
    [tipsView addSubview:dotView4];
    [dotView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(dotView3.mas_bottom).offset(28.5);
        make.left.mas_equalTo(tipsView.mas_left).offset(11);
        make.width.height.equalTo(@7);
    }];
    
    UIView *routerProtocolView = [UIView new];
    routerProtocolView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportedHomeRoutersClickTap:)];
    [routerProtocolView addGestureRecognizer:tap];
    [self.view addSubview:routerProtocolView];
    [routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(26);
        make.right.mas_equalTo(tipsView.mas_right).offset(-20);
        make.top.mas_equalTo(dotLb3.mas_bottom).offset(15);
        make.height.equalTo(@15);
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"查看门锁Wi-Fi支持家庭路由器";
    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
    routerProtocolLb.textAlignment = NSTextAlignmentLeft;
    routerProtocolLb.font = [UIFont systemFontOfSize:14];
    [routerProtocolView addSubview:routerProtocolLb];
    NSRange strRange = {0,[routerProtocolLb.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    routerProtocolLb.attributedText = str;
    [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(routerProtocolView);
    }];
    
    
    UIButton * otherConFigBtn = [UIButton new];
    [otherConFigBtn setTitle:@"取消" forState:UIControlStateNormal];
    otherConFigBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [otherConFigBtn setTitleColor:KDSRGBColor(112, 112, 112)/*KDSRGBColor(31, 150, 247) */forState:UIControlStateNormal];
    [otherConFigBtn addTarget:self action:@selector(otherConFigBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherConFigBtn];
    NSRange otherConFigstrRange = {0,[otherConFigBtn.titleLabel.text length]};
    NSMutableAttributedString * otherConFigstr = [[NSMutableAttributedString alloc] initWithString:otherConFigBtn.titleLabel.text];
    [otherConFigstr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:otherConFigstrRange];
    [otherConFigBtn setAttributedTitle:otherConFigstr forState:UIControlStateNormal];
    NSString * otherConFigcontent = otherConFigBtn.titleLabel.text;
    UIFont * otherConFigfont = otherConFigBtn.titleLabel.font;
    CGSize otherConFigsize = CGSizeMake(MAXFLOAT, 12.0f);
    CGSize otherConFigbuttonSize = [otherConFigcontent boundingRectWithSize:otherConFigsize
                          options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                       attributes:@{ NSFontAttributeName:otherConFigfont}
                                               context:nil].size;
    [otherConFigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(otherConFigbuttonSize));
        make.height.equalTo(@(44));
        make.width.equalTo(@80);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -40 : -KDSSSALE_HEIGHT(60));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    
    UIButton * rematchBtn = [UIButton new];
    [rematchBtn setTitle:@"重新配网" forState:UIControlStateNormal];
    rematchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rematchBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    rematchBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    rematchBtn.layer.masksToBounds = YES;
    rematchBtn.layer.cornerRadius = 22;
    [rematchBtn addTarget:self action:@selector(rematchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rematchBtn];
    [rematchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@(44));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(otherConFigBtn.mas_top).offset(-KDSSSALE_HEIGHT(23));
    }];
    UIButton * apConfigBtn = [UIButton new];
    [apConfigBtn setTitle:@"AP配网" forState:UIControlStateNormal];
    apConfigBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [apConfigBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    apConfigBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    apConfigBtn.layer.masksToBounds = YES;
    apConfigBtn.layer.cornerRadius = 22;
    apConfigBtn.hidden = YES;
    [apConfigBtn addTarget:self action:@selector(apConfigBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:apConfigBtn];
    [apConfigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(rematchBtn.mas_top).offset(-17);
        make.width.equalTo(@200);
        make.height.equalTo(@(44));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        
    }];
    
}

#pragma 点击事件
///wifi路由器支持品牌解说
-(void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)btn{
    
    KDSHomeRoutersVC * VC = [KDSHomeRoutersVC new];
    [self.navigationController pushViewController:VC animated:YES];
}
///取消--回到设备首页
-(void)otherConFigBtnClick:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
///(返回提示语第一步重新配网)ap配网
-(void)rematchBtnClick:(UIButton *)sender
{
       [self removeKnownViewController];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddNewWiFiLockStep1VC class]]) {
            //纯wifi配网
            KDSAddNewWiFiLockStep1VC *A =(KDSAddNewWiFiLockStep1VC *)controller;
            [self.navigationController popToViewController:A animated:YES];
            return;
        }else if ([controller isKindOfClass:[KDSAddBleAndWiFiLockStep1 class]]) {
            //蓝牙+wifi配网
            KDSAddBleAndWiFiLockStep1 * C = (KDSAddBleAndWiFiLockStep1 *)controller;
            [self.navigationController popToViewController:C animated:YES];
            return;
        }else if ([controller isKindOfClass:[KDSAddVideoWifiLockStep1VC class]]){
            //视频锁配网
            KDSAddVideoWifiLockStep1VC * B = (KDSAddVideoWifiLockStep1VC *)controller;
            [self.navigationController popToViewController:B animated:YES];
            return;
        }
    }
}


//  移除指定的控制器
- (void)removeKnownViewController{
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    for (UIViewController  * viewController in self.navigationController.viewControllers) {
        NSLog(@"zhushiqi= 所有的控制器==%@",[viewController class]);
        if([viewController isKindOfClass:[KDSAddVideoWifiLockStep1VC class]])
         {
          [navigationArray  removeObject:viewController];
         }
        
    }
  self.navigationController.viewControllers = navigationArray;
}

///ap配网
-(void)apConfigBtnClick:(UIButton *)sender
{
//    [MBProgressHUD showError:@"功能暂未开放"];
    
}



@end

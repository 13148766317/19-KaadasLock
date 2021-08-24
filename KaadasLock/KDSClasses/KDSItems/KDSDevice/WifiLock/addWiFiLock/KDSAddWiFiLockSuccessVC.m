//
//  KDSAddWiFiLockSuccessVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/13.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//
#import "KDSAddWiFiLockSuccessVC.h"
#import "UIButton+Color.h"
#import "KDSHttpManager+WifiLock.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import "KDSHomeRoutersVC.h"
#import "KDSHomeViewController.h"
#import "KDSAddVideoWifiLockStep1VC.h"
@interface KDSAddWiFiLockSuccessVC ()

@property (nonatomic,strong)UITextField * nameTf;
@property (nonatomic,strong) UIButton * selectedBtn;

@end

@implementation KDSAddWiFiLockSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addSuccess");
    [self setUI];
    
}
-(void)dealloc{

}
- (void)navBackClick
{
    // 方案二使用通知 调用getallbind 方法  queryP2P_passwordNotication
       NSNotification *notification =[NSNotification notificationWithName:@"queryP2P_passwordNotication" object:nil userInfo:nil];
       [[NSNotificationCenter defaultCenter] postNotification:notification];
       NSLog(@"zhu-- 发送通知--back方法");
    [self.navigationController popToRootViewControllerAnimated:YES];

}

-(void)setUI{
    
    UIImageView * addWifiLockSuccessImg = [UIImageView new];
    addWifiLockSuccessImg.image = [UIImage imageNamed:@"wifi-Lock-addSuccessIcon"];
    [self.view addSubview:addWifiLockSuccessImg];
    [addWifiLockSuccessImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(72));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.width.equalTo(@65);
        make.height.equalTo(@45);
    }];
    
    UILabel * successTipsLb = [UILabel new];
    successTipsLb.text = @"您已添加成功，取个名字吧！";
    successTipsLb.textColor = KDSRGBColor(86, 86, 86);
    successTipsLb.font = [UIFont systemFontOfSize:15];
    successTipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:successTipsLb];
    [successTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addWifiLockSuccessImg.mas_bottom).offset(28.5);
        make.height.equalTo(@20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UIView * inPutNameView = [UIView new];
    inPutNameView.backgroundColor = UIColor.whiteColor;
    inPutNameView.layer.masksToBounds = YES;
    inPutNameView.layer.cornerRadius = 4;
    [self.view addSubview:inPutNameView];
    [inPutNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(successTipsLb.mas_bottom).offset(26);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.equalTo(@50);
    }];
    UIImageView * editImg = [UIImageView new];
    editImg.image = [UIImage imageNamed:@"edit"];
    [inPutNameView addSubview:editImg];
    [editImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(inPutNameView.mas_centerY).offset(0);
        make.right.mas_equalTo(inPutNameView.mas_right).offset(-15);
        
    }];
    
    _nameTf= [UITextField new];
    _nameTf.placeholder = @"手动输入或从下面已有名称选择";
    _nameTf.textColor = UIColor.blackColor;
    _nameTf.font = [UIFont systemFontOfSize:15];
    _nameTf.textAlignment = NSTextAlignmentLeft;
    _nameTf.borderStyle=UITextBorderStyleNone;
    [_nameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [inPutNameView addSubview:_nameTf];
    [_nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(inPutNameView.mas_left).offset(10);
        make.right.mas_equalTo(inPutNameView.mas_right).offset(-10);
        make.top.bottom.mas_equalTo(0);
        
    }];
    
    UIButton * myHomeBtn = [UIButton new];
    [myHomeBtn setTitle:@"我的家" forState:UIControlStateNormal];
    [myHomeBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [myHomeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [myHomeBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [myHomeBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    myHomeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.selectedBtn = myHomeBtn;
    myHomeBtn.layer.masksToBounds = YES;
    myHomeBtn.layer.cornerRadius = 15;
    [myHomeBtn addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myHomeBtn];
    [myHomeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(10);
        make.width.equalTo(@62);
        make.height.equalTo(@30);
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        
    }];
    UIButton * bedroomBtn = [UIButton new];
    [bedroomBtn setTitle:@"卧室" forState:UIControlStateNormal];
    [bedroomBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [bedroomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [bedroomBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [bedroomBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    bedroomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    bedroomBtn.layer.masksToBounds = YES;
    bedroomBtn.layer.cornerRadius = 15;
    [bedroomBtn addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bedroomBtn];
    [bedroomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(myHomeBtn.mas_right).offset(10);
        
    }];
    UIButton * companyBtn = [UIButton new];
    [companyBtn setTitle:@"公司" forState:UIControlStateNormal];
    [companyBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [companyBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [companyBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [companyBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    companyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    companyBtn.layer.masksToBounds = YES;
    companyBtn.layer.cornerRadius = 15;
    [companyBtn addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:companyBtn];
    [companyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(bedroomBtn.mas_right).offset(10);
        
    }];
    
    UIView *routerProtocolView = [UIView new];
    routerProtocolView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportedHomeRoutersClickTap:)];
    [routerProtocolView addGestureRecognizer:tap];
    [self.view addSubview:routerProtocolView];
    [routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight < 667 ? -20 : -KDSSSALE_HEIGHT(40));
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"查看门锁Wi-Fi支持家庭路由器";
    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
    routerProtocolLb.textAlignment = NSTextAlignmentCenter;
    routerProtocolLb.font = [UIFont systemFontOfSize:14];
    [routerProtocolView addSubview:routerProtocolLb];
    NSRange strRange = {0,[routerProtocolLb.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    routerProtocolLb.attributedText = str;
    [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(routerProtocolView);
    }];
    
    UIButton * finishBtn = [UIButton new];
    [finishBtn setTitle:@"完  成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    finishBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    finishBtn.layer.masksToBounds = YES;
    finishBtn.layer.cornerRadius = 22;
    [finishBtn addTarget:self action:@selector(finishClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    [finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(routerProtocolView.mas_top).offset(-KDSSSALE_HEIGHT(28));
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        
    }];
    
    
}

#pragma mark button点击事件

-(void)finishClick:(UIButton *)btn
{
    NSLog(@"点击了完成按钮");
    if (self.nameTf.text.length == 0) {
        [MBProgressHUD showError:@"设备昵称不能为空"];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [[KDSHttpManager sharedManager] alterWifiBindedDeviceNickname:self.nameTf.text withUid:[KDSUserManager sharedManager].user.uid wifiModel:self.model success:^{
        [hud hideAnimated:NO];
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        [self.navigationController popToRootViewControllerAnimated:NO];
        UITabBarController *vc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([vc isKindOfClass:UITabBarController.class] && vc.viewControllers.count)
        {
            vc.selectedIndex = 0;
        }
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:Localized(@"saveFailed")];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:Localized(@"saveFailed")];
    }];
    
    // 输出navgiation中所有的视图控制器的个数
       NSInteger  count=   self.navigationController.viewControllers.count;
    NSLog(@"zhushiqi= 所有的控制器个数==%ld",(long)count);
    for (UIViewController  * viewController in self.navigationController.viewControllers) {
        NSLog(@"zhushiqi= 所有的控制器==%@",[viewController class]);
    }
    //  移除指定的控制器
    [self removeKnownViewController];
}

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


-(void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)sender
{
    KDSHomeRoutersVC * VC = [KDSHomeRoutersVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)selectedClick:(UIButton *)sender
{
    if (sender!= self.selectedBtn)
    {
        self.selectedBtn.selected = NO;
        sender.selected = YES;
        self.selectedBtn = sender;
    }else{
        self.selectedBtn.selected = YES;
    }
    self.nameTf.text = sender.titleLabel.text;
}
///锁昵称文本框文字改变后，限制长度不超过16个字符。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

@end

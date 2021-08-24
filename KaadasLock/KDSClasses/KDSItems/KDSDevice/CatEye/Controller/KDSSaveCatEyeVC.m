//
//  KDSSaveCatEyeVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/11.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSSaveCatEyeVC.h"
#import "KDSMQTTManager.h"
#import "MBProgressHUD+MJ.h"
#import "GatewayDeviceModel.h"

@interface KDSSaveCatEyeVC ()
@property (nonatomic,readwrite,strong)UITextField * nameTf;
///6个预设昵称的按钮数组。
@property (nonatomic, strong) NSArray<UIButton *> *nicknameButtons;

@end

@implementation KDSSaveCatEyeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addCatEye");
    [self setUI];
}

-(void)setUI
{
    
    ///下一步
    UIButton * nextStepBtn = [UIButton new];
    nextStepBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextStepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextStepBtn setTitle:Localized(@"save") forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextStepBtn];
    [nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"add cat eye_pic"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(37);
        make.width.mas_equalTo(33);
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight+40);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    ///给锁起个名字
    UILabel * nameLb = [UILabel new];
    nameLb.text = @"您已添加成功，取个名字吧！";
    nameLb.textAlignment = NSTextAlignmentCenter;
    nameLb.textColor = KDSRGBColor(153, 153, 153);
    nameLb.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:nameLb];
    [nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addZigBeeLocklogoImg.mas_bottom).offset(26);
        make.height.mas_equalTo(18);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    ///提示视图
    UIView * tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.cornerRadius = 4;
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(nameLb.mas_bottom).offset(36);
    }];
    UIImageView * tipImg = [UIImageView new];
    tipImg.image = [UIImage imageNamed:@"我的 未选中"];
    [tipsView addSubview:tipImg];
    [tipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(16);
        make.centerY.mas_equalTo(tipsView.mas_centerY).offset(0);
        make.left.mas_equalTo(tipsView.mas_left).offset(15);
    }];
    
    
    self.nameTf = [UITextField new];
    self.nameTf.placeholder = Localized(@"inputOrSelectAName");
    self.nameTf.font = [UIFont systemFontOfSize:15];
    self.nameTf.textColor = KDSRGBColor(177, 177, 177);
    self.nameTf.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:self.nameTf];
    [self.nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipImg.mas_right).offset(10);
        make.right.mas_equalTo(tipsView.mas_right).offset(0);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(tipsView.mas_centerY).offset(0);
    }];
    
    UIView *pwdNameCornerView = [UIView new];
    [self.view addSubview:pwdNameCornerView];
    pwdNameCornerView.backgroundColor = UIColor.clearColor;
    [pwdNameCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(tipsView.mas_bottom).offset(10);
    }];
    
    self.nicknameButtons = [self createNicknameButtonsConstraintView:pwdNameCornerView];
    
}

///创建预设的6个昵称按钮，根据密码名称圆角视图添加约束。最后返回按钮数组。
- (NSArray<UIButton *> *)createNicknameButtonsConstraintView:(UIView *)constraintView
{
    NSArray *names = @[Localized(@"father"), Localized(@"mother"), Localized(@"oldBrother"), Localized(@"youngBrother"), Localized(@"oldSister"), Localized(@"other")];
    NSMutableArray<NSNumber *> *lengths = [NSMutableArray arrayWithCapacity:names.count];//文字宽度
    CGFloat totalLength = 0;
    CGFloat maxWidth = 0;//最大文字宽度。
    NSMutableArray<UIButton *> *btns = [NSMutableArray arrayWithCapacity:names.count];
    UIFont *font = [UIFont systemFontOfSize:12];
    for (int i = 0; i < names.count; ++i)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 15;
        btn.backgroundColor = UIColor.whiteColor;
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        btn.titleLabel.font = font;
        [btn addTarget:self action:@selector(selectNickname:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = [names[i] sizeWithAttributes:@{NSFontAttributeName : font}].width;
        totalLength  += width;
        maxWidth = MAX(maxWidth, width);
        [lengths addObject:@(width)];
        [self.view addSubview:btn];
        [btns addObject:btn];
    }
    btns.firstObject.selected = YES;
    self.nameTf.text = names[0];
    btns.firstObject.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    self.nicknameButtons = btns.copy;
    CGFloat topOffset = 15;
    //正常的按钮高30，间距最小5。
    if (totalLength + 26*btns.count + 30 + btns.count*5-5 < kScreenWidth)//一行
    {
        CGFloat space = (kScreenWidth - 30 - totalLength - 26*btns.count) / 5;
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(constraintView.mas_top).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@(lengths[0].intValue + 26));
            make.height.equalTo(@30);
        }];
        [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[0].mas_right).offset(space);
            make.width.equalTo(@(lengths[1].intValue + 26));
        }];
        [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[1].mas_right).offset(space);
            make.width.equalTo(@(lengths[2].intValue + 26));
        }];
        [btns[3] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[2].mas_right).offset(space);
            make.width.equalTo(@(lengths[3].intValue + 26));
        }];
        [btns[4] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[3].mas_right).offset(space);
            make.width.equalTo(@(lengths[4].intValue + 26));
        }];
        [btns[5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.right.equalTo(self.view).offset(-15);
            make.width.equalTo(@(lengths[5].intValue + 26));
        }];
    }
    else if ((maxWidth + 26) * 3 + 30 + 10 < kScreenWidth)//2行，宽按最大文字宽度+26
    {
        CGFloat space = (kScreenWidth - (maxWidth + 26) * 3 - 30) / 2;
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(constraintView.mas_top).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@(maxWidth + 26));
            make.height.equalTo(@30);
        }];
        [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[0]);
            make.left.equalTo(btns[0].mas_right).offset(space);
        }];
        [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[0]);
            make.left.equalTo(btns[1].mas_right).offset(space);
        }];
        [btns[3] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btns[0].mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.height.equalTo(btns[0]);
        }];
        [btns[4] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[3]);
            make.left.equalTo(btns[3].mas_right).offset(space);
        }];
        [btns[5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[3]);
            make.left.equalTo(btns[1].mas_right).offset(space);
        }];
        CGRect frame = self.view.frame;
        frame.size.height += (30 + topOffset);
        self.view.frame = frame;
    }
    else//3行
    {
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(constraintView.mas_top).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@((kScreenWidth - 60) / 2));
            make.height.equalTo(@30);
        }];
        [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[0]);
            make.right.equalTo(self.view).offset(-15);
        }];
        [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btns[0].mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.height.equalTo(btns[0]);
        }];
        [btns[3] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[2]);
            make.right.equalTo(self.view).offset(-15);
        }];
        [btns[4] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btns[2].mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.height.equalTo(btns[0]);
        }];
        [btns[5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[4]);
            make.right.equalTo(self.view).offset(-15);
        }];
        CGRect frame = self.view.frame;
        frame.size.height += (30 + topOffset) * 2;
        self.view.frame = frame;
    }
    
    return btns.copy;
}
#pragma mark 控件点击事件
-(void)saveBtnClick:(UIButton *)sender
{
    if (self.nameTf.text.length == 0)
    {
        [MBProgressHUD showError:Localized(@"inputOrSelectNicknameFirst")];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    GatewayDeviceModel * gatewayDeviceModel = [GatewayDeviceModel new];
    gatewayDeviceModel.nickName = self.nameTf.text;
    gatewayDeviceModel.deviceId = self.deviceId;
    gatewayDeviceModel.gatewayId = self.gatewayModel.deviceSN;
    [[KDSMQTTManager sharedManager] updateDeviceNickname:gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success) {
         [hud hideAnimated:NO];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
            UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([vc isKindOfClass:UITabBarController.class])
            {
                [self.navigationController popToRootViewControllerAnimated:NO];
                ((UITabBarController *)vc).selectedIndex = 0;
            }
           
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
            [MBProgressHUD showError:Localized(@"saveFailed")];
        }
    }];
}

-(void)navBackClick
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc isKindOfClass:UITabBarController.class])
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
        ((UITabBarController *)vc).selectedIndex = 0;
    }
}

-(void)selectNickname:(UIButton *)sender
{
    for (UIButton *btn in self.nicknameButtons)
    {
        if (btn.selected && btn == sender)
        {
            self.nameTf.text = sender.currentTitle;
            return;
        }
        btn.backgroundColor = UIColor.whiteColor;
        btn.selected = NO;
    }
    sender.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    sender.selected = YES;
    self.nameTf.text = sender.currentTitle;
}


@end

//
//  KDSModifyPwdVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSModifyPwdVC.h"
#import "KDSHttpManager+Login.h"
#import "MBProgressHUD+MJ.h"

@interface KDSModifyPwdVC ()

///旧密码文本框。
@property (nonatomic, weak) UITextField *oldPwdTF;
///新密码文本框。
@property (nonatomic, weak) UITextField *nPwdTF;
///二次确认密码文本框。
@property (nonatomic, weak) UITextField *tPwdTF;

@end

@implementation KDSModifyPwdVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"modifyPassword");
    CGFloat height = 60;
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, height * 3 + 1)];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 5;
    [self.view addSubview:cornerView];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    UIImage *pwdImg = [UIImage imageNamed:@"数字密码"];
    UIImage *twiceImg = [UIImage imageNamed:@"meTwicePwd"];
    
    UIImageView *oiv = [[UIImageView alloc] initWithImage:pwdImg];
    oiv.frame = (CGRect){18, (height - pwdImg.size.height) / 2, pwdImg.size};
    [cornerView addSubview:oiv];
    UITextField *otf = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(oiv.frame) + 15, 0, CGRectGetWidth(cornerView.bounds) - CGRectGetMaxX(oiv.frame) - 15 - 15, height)];
    otf.font = font;
    otf.placeholder = Localized(@"inputOldPwd");
    otf.secureTextEntry = YES;
    [otf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cornerView addSubview:otf];
    self.oldPwdTF = otf;
    UIView *underlineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(otf.frame), cornerView.bounds.size.width, 0.5)];
    underlineView1.backgroundColor = KDSRGBColor(0xf0, 0xf0, 0xf0);
    [cornerView addSubview:underlineView1];
    
    UIImageView *niv = [[UIImageView alloc] initWithImage:pwdImg];
    niv.frame = (CGRect){18, CGRectGetMaxY(underlineView1.frame) + (height - pwdImg.size.height) / 2, pwdImg.size};
    [cornerView addSubview:niv];
    UITextField *ntf = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(niv.frame) + 15, CGRectGetMaxY(underlineView1.frame), CGRectGetWidth(cornerView.bounds) - CGRectGetMaxX(niv.frame) - 15 - 15, height)];
    ntf.font = font;
    ntf.placeholder = Localized(@"inputNewPwd");
    ntf.secureTextEntry = YES;
    [ntf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cornerView addSubview:ntf];
    self.nPwdTF = ntf;
    UIView *underlineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(ntf.frame), cornerView.bounds.size.width, 0.5)];
    underlineView2.backgroundColor = KDSRGBColor(0xf0, 0xf0, 0xf0);
    [cornerView addSubview:underlineView2];
    
    UIImageView *tiv = [[UIImageView alloc] initWithImage:twiceImg];
    tiv.frame = (CGRect){18, CGRectGetMaxY(underlineView2.frame) + (height - twiceImg.size.height) / 2, pwdImg.size};
    [cornerView addSubview:tiv];
    UITextField *ttf = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tiv.frame) + 15, CGRectGetMaxY(underlineView2.frame), CGRectGetWidth(cornerView.bounds) - CGRectGetMaxX(tiv.frame) - 15 - 15, height)];
    ttf.font = font;
    ttf.placeholder = Localized(@"inputPwdAgain");
    ttf.secureTextEntry = YES;
    [ttf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cornerView addSubview:ttf];
    self.tPwdTF = ttf;
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setTitle:Localized(@"done") forState:UIControlStateNormal];
    [doneBtn setTitle:Localized(@"done") forState:UIControlStateHighlighted];
    [doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    doneBtn.backgroundColor = KDSRGBColor(0x2d, 0xd9, 0xba);
    doneBtn.layer.cornerRadius = height / 2;
    doneBtn.layer.shadowColor = [UIColor colorWithRed:0x53/255.0 green:0xd3/255.0 blue:0xbc/255.0 alpha:0.5].CGColor;
    doneBtn.layer.shadowOffset = CGSizeMake(3, 3);
    doneBtn.layer.shadowOpacity = 1;
    [doneBtn addTarget:self action:@selector(doneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.bounds = CGRectMake(0, 0, kScreenWidth < 375 ? (kScreenWidth - 76) : 300, height);
    doneBtn.center = CGPointMake(kScreenWidth / 2, kScreenHeight - kStatusBarHeight - kNavBarHeight - 164 - height / 2);
    [self.view addSubview:doneBtn];
}

///密码文本框文字改变后，限制长度不超过16。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    if (sender.text.length > 16)
    {
        sender.text = [sender.text substringToIndex:16];
        [MBProgressHUD showError:Localized(@"requireValidPwd")];
    }
}

///点击完成按钮修改密码。
- (void)doneBtnAction:(UIButton *)sender
{
    NSString *oldPwd = self.oldPwdTF.text;
    NSString *newPwd = self.nPwdTF.text;
    NSString *twicePwd = self.tPwdTF.text;
    if (!oldPwd.length || !newPwd.length || !twicePwd.length)
    {
        return;
    }
    if (oldPwd.length < 6 || oldPwd.length > 16)
    {
        [MBProgressHUD showError:Localized(@"oldPwdLengthIncorrect")];
        return;
    }
    if (![twicePwd isEqualToString:newPwd])
    {
        [MBProgressHUD showError:Localized(@"twiceInputPwdDifferent")];
        return;
    }
    if ([twicePwd isEqualToString:oldPwd])
    {
        [MBProgressHUD showError:Localized(@"pwdSameBetweenOldAndNew")];
        return;
    }
    if (![KDSTool isValidPassword:twicePwd])
    {
        [MBProgressHUD showError:Localized(@"requireValidPwd")];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    [[KDSHttpManager sharedManager] updatePwd:[KDSUserManager sharedManager].user.name oldPwd:oldPwd newPwd:newPwd success:^{
        [hud hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"modifyPwdSuccess")];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"modifyPwdFailed") stringByAppendingFormat:@": %@", error.localizedDescription]];
    }];
}


@end

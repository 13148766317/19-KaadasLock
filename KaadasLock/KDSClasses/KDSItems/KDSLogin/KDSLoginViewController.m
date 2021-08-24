//
//  KDSLoginViewController.m
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSLoginViewController.h"
#import "KDSSignupVC.h"
#import "KDSHttpManager+Login.h"
#import "MBProgressHUD+MJ.h"
#import "KDSDBManager.h"
#import "KDSTabBarController.h"
#import "KDSNavigationController.h"
#import "XWCountryCodeController.h"
#import <objc/runtime.h>


@interface KDSLoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *supView;
///用户名的输入框
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
///密码的输入框
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
///登录按钮
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
///注册按钮
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
///您还没有账号label
@property (weak, nonatomic) IBOutlet UILabel *arlterLabel;
@property (nonatomic, strong) NSString *code;//国际代码
///忘记密码按钮
@property (weak, nonatomic) IBOutlet UIButton *forgetPwdBtn;
///密码明文切换
@property (weak, nonatomic) IBOutlet UIButton *visibleBtn;

@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCode;
@property (weak, nonatomic) IBOutlet UIButton *selectCountry;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;

@end

@implementation KDSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.code = @"86";
    self.supView.backgroundColor = KDSRGBColor(17, 117, 231);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [self setUI];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}
-(void)setUI{
    
    self.viewTopConstraint.constant = 88 + kStatusBarHeight;
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *userNamePlaceholderLabel = object_getIvar(self.userNameTextField, ivar);
    userNamePlaceholderLabel.textColor = KDSRGBColor(138, 213, 252);
    UILabel *pwdNamePlaceholderLabel = object_getIvar(self.pwdTextField, ivar);
    pwdNamePlaceholderLabel.textColor = KDSRGBColor(138, 213, 252);
    self.loginBtn.backgroundColor = KDSRGBColor(138, 213, 252);
    self.arlterLabel.textColor = KDSRGBColor(138, 213, 252);
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 22;
    self.userNameTextField.textColor = [UIColor whiteColor];
    [self.userNameTextField addTarget:self action:@selector(userNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.pwdTextField.textColor = [UIColor whiteColor];
    self.pwdTextField.secureTextEntry = NO;
    self.pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.pwdTextField addTarget:self action:@selector(pwdtextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    self.visibleBtn.selected = YES;
    [self.visibleBtn setImage:[UIImage imageNamed:@"眼睛闭Hight"] forState:UIControlStateNormal];
    [self.visibleBtn setImage:[UIImage imageNamed:@"眼睛开Hight"] forState:UIControlStateSelected];
    NSRange strRange = {0,[self.registBtn.titleLabel.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.registBtn.titleLabel.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.registBtn setAttributedTitle:str forState:UIControlStateNormal];
    UITapGestureRecognizer *selectCountryCodeTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountryCodeClick:)];
    UITapGestureRecognizer *selectCountryCodeTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountryCodeClick:)];

    self.countryLabel.userInteractionEnabled = YES;
    self.selectCountry.userInteractionEnabled = YES;

    [self.countryLabel addGestureRecognizer:selectCountryCodeTap1];
    [self.selectCountry addGestureRecognizer:selectCountryCodeTap2];

    //用户登录过 保存用户名
    
    NSArray<NSString *> *comps = [self.code componentsSeparatedByString:@"+"];
    NSString *account = [KDSTool getDefaultLoginAccount];
    if (comps.lastObject && [account hasPrefix:comps.lastObject])
    {
        account = [account substringFromIndex:comps.lastObject.length];
    }
    if (comps.count > 0) {
        self.userNameTextField.text = account;
    }else{
        self.userNameTextField.placeholder =@"请输入手机号码或邮箱";
    }

  
}

//MARK:登录点击事件
- (IBAction)loginBtn:(id)sender {

    if ([self.userNameTextField.text isEqualToString:@""]) {
      
        [MBProgressHUD showError:Localized(@"AccountIsEmpty")];
        return;
    }
    
    if (self.pwdTextField.text.length == 0) {
        [MBProgressHUD showError:Localized(@"PwdcannotBeEmpty")];
        return;
    }
    if (self.userNameTextField.text.length == 0)
    {
        [MBProgressHUD showError:Localized(@"usernameCan'tBeNull")];
        return;
    }
    
    if (![KDSTool isValidPassword:self.pwdTextField.text])
    {
        [MBProgressHUD showError:Localized(@"requireValidPwd")];
        return;
    }
    int source = 1;
    NSString *username = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];// self.userNameTextField.text;
    NSString *passWord = self.pwdTextField.text;
    NSString *crcCode = [self.countryCode.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    if ([KDSTool isValidateEmail:username])
    {
        source = 2;
    }
    else if (crcCode.intValue != 86 || [KDSTool isValidatePhoneNumber:username])
    {
        
        username = [crcCode stringByAppendingString:username];
    }
    else
    {
        [MBProgressHUD showError:Localized(@"inputValidEmailOrPhoneNumber")];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"logining") toView:self.view];

    [[KDSHttpManager sharedManager] login:source username:username password:passWord success:^(KDSUser * _Nonnull user) {
        /*
         商城
         NSString *atoken = [NSString stringWithFormat:@"%@" ,[[responseObject objectForKey:@"data"] objectForKey:@"token"]];
         [userDefaults setObject:atoken forKey:USER_TOKEN];
         [userDefaults synchronize];
         */
        NSLog(@"userid==%@",user.uid);
        NSString *account = [KDSTool getDefaultLoginAccount];
        if (![account isEqualToString:username])
        {
            [[KDSDBManager sharedManager] resetDatabase];
        }
        [KDSTool setDefaultLoginAccount:username];
        [KDSTool setDefaultLoginPassWord:passWord];
        KDSTool.crc = crcCode;
        [KDSUserManager sharedManager].user = user;
        [[KDSDBManager sharedManager] updateUser:user];
        
        [KDSUserManager sharedManager].userNickname = [[KDSDBManager sharedManager] queryUserNickname];
        [KDSHttpManager sharedManager].token = user.token;
        [hud hideAnimated:YES];
        KDSTabBarController *tab = [KDSTabBarController new];
        [UIApplication sharedApplication].keyWindow.rootViewController = tab;
        
    } error:^(NSError * _Nonnull error) {

        [hud hideAnimated:YES];
        NSString *msg;
        msg = error.localizedDescription;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:action];
        [self presentViewController:ac animated:YES completion:nil];

    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
    [self.view endEditing:YES];
}

///注册按钮
- (IBAction)registBtn:(id)sender {
    
    KDSSignupVC * signupVc = [[KDSSignupVC alloc] init];
    signupVc.countryCodeString = self.countryCode.text;
    signupVc.countryName = self.countryLabel.text;
    KDSNavigationController *nav = [[KDSNavigationController alloc ] initWithRootViewController:signupVc];
    [self presentViewController:nav animated:YES completion:nil];
}
///忘记密码
- (IBAction)forgetPwd:(id)sender {
    
    KDSSignupVC *forgetVC = [KDSSignupVC new];
    forgetVC.registerType = RegisteredTypeForgetPwd;
    forgetVC.countryCodeString = self.countryCode.text;
    forgetVC.countryName = self.countryLabel.text;
    __weak typeof(self) safaSelf = self;
    forgetVC.registeredSucessBlock = ^(NSString *username,NSString *code,NSString *pwd){
        safaSelf.userNameTextField.text = username;
        safaSelf.pwdTextField.text = pwd;
        safaSelf.code = code;
    };
    KDSNavigationController *nav = [[KDSNavigationController alloc ] initWithRootViewController:forgetVC];
    [self presentViewController:nav animated:YES completion:nil];
   
}
-(void)selectCountryCodeClick:(UITapGestureRecognizer *)tap
{
    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryCodeStr) {
        NSArray<NSString *> *comps = [countryCodeStr componentsSeparatedByString:@"+"];
        self.countryCode.text = comps.count >1 ? [@"+" stringByAppendingString:comps.lastObject] : @"+86";
        self.countryLabel.text = comps.count > 1 ? comps.firstObject : @"中国大陆";
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:countryCodeVC];
    [self presentViewController:navi animated:YES completion:nil];
}

///密码是否显示出来
- (IBAction)visibleBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
         self.pwdTextField.secureTextEntry = NO;
    }else{
     
        self.pwdTextField.secureTextEntry = YES;
    }
     [self.pwdTextField becomeFirstResponder];

}
///用户名输入框限制条件
-(void)userNameTextFieldDidChange:(UITextField *)sender
{
    sender.text = [[sender.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
}
///密码输入框限制条件6~12位数字+密码
- (void)pwdtextFieldDidChange:(UITextField *)textField{
    textField.text = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    if (textField.text.length > 12) {
        textField.text = [textField.text substringToIndex:12];
        [MBProgressHUD showError:Localized(@"PwdLength6BitsAndNotMoreThan12bits")];
    }
}
+ (BOOL)isValidPassword:(NSString *)text
{
    NSString *expr = @"^(?=.*\\d)(?=.*[a-zA-Z])[0-9a-zA-Z]{6,12}$";
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expr];
    return [p evaluateWithObject:text];
}

#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    //取出键盘动画的时间
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //取得键盘最后的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.supView.frame.size.height;
    NSLog(@"键盘上移的高度：%f-----取出键盘动画时间：%f",transformY,duration);
    [UIView animateWithDuration:duration animations:^{
        [self.supView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight <= 667 ? -130 : -100);
            make.height.equalTo(@(KDSScreenHeight));
        }];
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [self.supView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self.view);
        }];
    }];
}

@end

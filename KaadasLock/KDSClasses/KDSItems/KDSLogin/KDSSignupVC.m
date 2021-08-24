//
//  KDSSignupVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/3/25.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSSignupVC.h"
#import "MBProgressHUD+MJ.h"
#import "Masonry.h"
#import "KDSHttpManager+Login.h"
#import "KDSUserAgreementVC.h"
#import "XWCountryCodeController.h"
#import "NSTimer+KDSBlock.h"
#import "KDSPrivacyPolicyVC.h"


@interface KDSSignupVC ()
///用户名输入框
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
///验证码输入框
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
///密码输入框
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIView *declarationView;
@property (weak, nonatomic) IBOutlet UIView *topView;
///注册按钮
@property (weak, nonatomic) IBOutlet UIButton *signupBtn;
///获取验证码
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
///返回按钮
@property (weak, nonatomic) IBOutlet UIButton *backUpBtn;
///title
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *countryCodeStr;       //国家代码
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger num;
///显示区域代码的label---默认是86
@property (weak, nonatomic) IBOutlet UILabel *countryCode;
///显示区域名字---默认是‘中国大陆’
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseCountry;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backUpBtnConstraint;
///是否同意协议按钮
@property (weak, nonatomic) IBOutlet UIButton *agreeMentBtn;
///密码明文切换
@property (weak, nonatomic) IBOutlet UIButton *visibleBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
///隐私政策的按钮
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyBtn;

@end

@implementation KDSSignupVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.countdown = 59;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //监听网络状态
    [[KDSUserManager sharedManager] monitorNetWork];
    [self setUI];
    if (self.countryName.length)
    {
        self.countryLabel.text = self.countryName;
        self.countryCode.text = self.countryCodeString;
        self.countryCodeStr = [self.countryCodeString stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    else
    {
        NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
        NSString *code = [locale objectForKey:NSLocaleCountryCode];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CRCCODE" ofType:@"plist"];
        NSDictionary *codeDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *telCode = codeDict[code] ?: @"+86";
        self.countryCode.text = telCode;
        NSString *language = [KDSTool getLanguage];
        NSString *sortedName;
        if ([language isEqualToString:JianTiZhongWen])
        {
            sortedName = @"sortedChnames";
        }
        else if ([language isEqualToString:FanTiZhongWen])
        {
            sortedName = @"sortedChFantinames";
        }
        else
        {
            sortedName = @"sortedEnames";
        }
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:sortedName ofType:@"plist"]];
        NSMutableArray *namesAndCodes = [NSMutableArray array];
        for (NSArray *value in dict.allValues)
        {
            [namesAndCodes addObjectsFromArray:value];
        }
        for (NSString *nameAndCode in namesAndCodes)
        {
            if ([nameAndCode hasSuffix:telCode])
            {
                self.countryLabel.text = [[nameAndCode componentsSeparatedByString:@"+"].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                break;
            }
        }
    }
    _num = 60;
    [_pwdTextField addTarget:self action:@selector(pwdtextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_userNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_codeTextField addTarget:self action:@selector(codeTextFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
-(void)setUI {
    
    self.signupBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    self.signupBtn.layer.masksToBounds = YES;
    self.signupBtn.layer.cornerRadius = 22;
    self.getCodeBtn.layer.masksToBounds = YES;
    self.getCodeBtn.layer.cornerRadius = 15;
    self.userNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.codeTextField.keyboardType = UIKeyboardTypeNumberPad;
//    self.pwdTextField.secureTextEntry = YES;
    self.backUpBtnConstraint.constant = kStatusBarHeight + 10;
    self.titleTopConstraint.constant = kStatusBarHeight + 10;
    NSRange strRange = {0,[self.agreeBtn.titleLabel.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.agreeBtn.titleLabel.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.agreeBtn setAttributedTitle:str forState:UIControlStateNormal];
    self.pwdTextField.secureTextEntry = NO;
    self.visibleBtn.selected = YES;
    [self.visibleBtn setImage:[UIImage imageNamed:@"眼睛闭Default"] forState:UIControlStateNormal];
    [self.visibleBtn setImage:[UIImage imageNamed:@"眼睛开Default"] forState:UIControlStateSelected];
    [self.agreeMentBtn setImage:[UIImage imageNamed:@"未选择"] forState:UIControlStateNormal];
    [self.agreeMentBtn setImage:[UIImage imageNamed:@"选择"] forState:UIControlStateSelected];
    
    UITapGestureRecognizer *selectCountryCodeTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountryCodeClick:)];
    UITapGestureRecognizer *selectCountryCodeTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountryCodeClick:)];

    self.countryLabel.userInteractionEnabled = YES;
    self.chooseCountry.userInteractionEnabled = YES;

    [self.countryLabel addGestureRecognizer:selectCountryCodeTap1];
    [self.chooseCountry addGestureRecognizer:selectCountryCodeTap2];
    
    //边框宽度
    [self.getCodeBtn.layer setBorderWidth:1.0];
    self.getCodeBtn.layer.borderColor= KDSRGBColor(220, 221, 222).CGColor;
    self.agreeMentBtn.selected = NO;
    if (self.registerType == RegisteredTypeByTel) {
        _countryCodeStr = @"86";      //默认中国
        self.countryCode.text = @"+86";
        
        
    }else if(self.registerType == RegisteredTypeByEmail){
        _userNameTextField.placeholder = Localized(@"请输入邮箱名");
        _countryCodeStr = @"";
        self.countryCode.text = _countryCodeStr;

        
    }else{
        self.agreeBtn.hidden = YES;
        self.agreeMentBtn.hidden = YES;
        self.agreementLabel.hidden = YES;
        self.privacyPolicyBtn.hidden = YES;
        self.titleLabel.text = Localized(@"forgetPwd");
        _countryCodeStr = @"86";      //默认中国
        self.countryCode.text = @"+86";
        [self.signupBtn setTitle:@"完成" forState:UIControlStateNormal];
        
    }
    
    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:self.privacyPolicyBtn.titleLabel.text];
    [tncString addAttribute:NSUnderlineStyleAttributeName
                        value:@(NSUnderlineStyleSingle)
                      range:(NSRange){1,tncString.length-1}];
    [tncString addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(32, 150, 248) range:NSMakeRange(1,tncString.length-1)];
    [tncString addAttribute:NSUnderlineColorAttributeName value:KDSRGBColor(32, 150, 248) range:(NSRange){1,tncString.length-1}];
    [self.privacyPolicyBtn setAttributedTitle:tncString forState:UIControlStateNormal];
    
    
}
///密码输入框限制条件6～12位
- (void)pwdtextFieldDidChange:(UITextField *)textField{
    textField.text = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    if (textField.text.length > 12) {
        textField.text = [textField.text substringToIndex:12];
        [MBProgressHUD showError:Localized(@"PwdLength6BitsAndNotMoreThan12bits")];
    }
}
///用户名输入框限制条件6～12位
- (void)textFieldDidChange:(UITextField *)textField{
   textField.text = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
}

///验证码输入框限制条件是6位数字
-(void)codeTextFieldDidChange:(UITextField *)sender
{
    sender.text = [[sender.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    if (sender.text.length > 6)
    {
        sender.text = [sender.text substringToIndex:6];
    }
}
#pragma mark - 控件点击事件
///注册
- (IBAction)signupBtn:(id)sender {
    if (self.agreeMentBtn.selected == NO && (self.registerType == RegisteredTypeByTel || self.registerType == RegisteredTypeByEmail)) {
        [MBProgressHUD showError:@"请先同意用户协议"];
        return;
    }
    if ([self.userNameTextField.text isEqualToString:@""]) {
    
        [MBProgressHUD showError:Localized(@"AccountIsEmpty")];
        return;
    
    }else if ([self.codeTextField.text isEqualToString:@""]){
        
        [MBProgressHUD showError:Localized(@"enterValidationCode")];
        return;
    
    }else if ([self.pwdTextField.text isEqualToString:@""]) {
        
        [MBProgressHUD showError:Localized(@"PwdcannotBeEmpty")];
        return;
    }
    
    if (![KDSTool isValidPassword:self.pwdTextField.text])
    {
        [MBProgressHUD showError:Localized(@"requireValidPwd")];
        return;
    }
    
    if (self.registerType == RegisteredTypeByTel || self.registerType == RegisteredTypeByEmail) {
        NSString *username = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *crcCode = @"86";
        int source = 1;
        ///用户名是否是邮箱，source=2代表邮箱，source=1代表手机号码
        if ([KDSTool isValidateEmail:username])
        {
            source = 2;
        }
        ///手机号码是否是中国区的号码
        else if (crcCode.intValue != 86 || [KDSTool isValidatePhoneNumber:self.userNameTextField.text])
        {
            username = [crcCode stringByAppendingString:username];
        }
        else
        {
            [MBProgressHUD showError:Localized(@"inputValidEmailOrPhoneNumber")];
            return;
        }
        if (!self.agreeMentBtn.selected) {
            [MBProgressHUD showError:Localized(@"agreeing agreement can register Cadillac APP")];
            return;
        }
        NSString *msg = Localized(@"signingup");
        MBProgressHUD *hud = [MBProgressHUD showMessage:msg toView:self.view];
        
        [[KDSHttpManager sharedManager] signup:source username:username captcha:self.codeTextField.text password:self.pwdTextField.text success:^{
            [hud hideAnimated:YES];
            [MBProgressHUD showSuccess:Localized(@"signupSuccess")];
            [self dismissViewControllerAnimated:YES completion:^{
                !self.registeredSucessBlock ?: self.registeredSucessBlock(source==2 ? username : [username substringFromIndex:crcCode.length], crcCode, self.pwdTextField.text);
            }];
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
    }else{
        //忘记密码
        [self forgetPwd];
    }
    
}
///获取验证码
- (IBAction)getCodeBtn:(UIButton *)sender
{
    //if (self.registerType != RegisteredTypeForgetPwd && self.agreementStateBtn.selected) return;
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        [MBProgressHUD showError:Localized(@"networkNotAvailable")];
        return;
    }
    if (self.userNameTextField.text.length == 0)
    {
        [MBProgressHUD showError:Localized(@"usernameCan'tBeNull")];
        return;
    }
    NSString *crcCode = [self.countryCode.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
//    NSString *username = self.userNameTextField.text;
    NSString *username = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([KDSTool isValidateEmail:username])
    {
        [[KDSHttpManager sharedManager] getCaptchaWithEmail:username success:^{
            [MBProgressHUD showSuccess:Localized(@"captchaSendSuccess")];
            sender.enabled = NO;
            __weak typeof(self) weakSelf = self;
            NSTimer *timer = [NSTimer kdsScheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (weakSelf.countdown < 0 || !weakSelf)
                {
                    [timer invalidate];
                    weakSelf.countdown = 59;
                    sender.enabled = YES;
                    return;
                }
                [sender setTitle:[NSString stringWithFormat:@"%lds", (long)weakSelf.countdown] forState:UIControlStateDisabled];
                weakSelf.countdown--;
                //        NSLog(@"--{Kaadas}--countdown=%ld",(long)weakSelf.countdown);
            }];
            [timer fire];
        } error:^(NSError * _Nonnull error) {
            if (error.code == 704)
            {
                [MBProgressHUD showError:@"getCaptchaTooOfter"];
            }
            else
            {
                [MBProgressHUD showError:[NSString stringWithFormat:@"error: %ld", (long)error.code]];
            }
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }
    else if (crcCode.intValue != 86 || [KDSTool isValidatePhoneNumber:username])
    {
        [[KDSHttpManager sharedManager] getCaptchaWithTel:username crc:crcCode success:^{
            [MBProgressHUD showSuccess:Localized(@"captchaSendSuccess")];
            sender.enabled = NO;
            __weak typeof(self) weakSelf = self;
            NSTimer *timer = [NSTimer kdsScheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (weakSelf.countdown < 0 || !weakSelf)
                {
                    [timer invalidate];
                    weakSelf.countdown = 59;
                    sender.enabled = YES;
                    return;
                }
                [sender setTitle:[NSString stringWithFormat:@"%lds", (long)weakSelf.countdown] forState:UIControlStateDisabled];
                weakSelf.countdown--;
                //        NSLog(@"--{Kaadas}--countdown=%ld",(long)weakSelf.countdown);
            }];
            [timer fire];
        } error:^(NSError * _Nonnull error) {
            //服务器返回的说明
            [MBProgressHUD showError:[NSString stringWithFormat:@"error: %@", error.localizedDescription]];
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }
    else
    {
        [MBProgressHUD showError:Localized(@"inputValidEmailOrPhoneNumber")];
        return;
    }
    
    
}
- (IBAction)backUpBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)UserAgreementBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
}
///用户协议
- (IBAction)agreeMentBtn:(id)sender {
    
    KDSUserAgreementVC * userAgreeMentVC = [[KDSUserAgreementVC alloc] init];
    
    [self.navigationController pushViewController:userAgreeMentVC animated:YES];
    
}


///密码明文切换
- (IBAction)visiblebtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.pwdTextField.secureTextEntry = NO;
    }else{
        self.pwdTextField.secureTextEntry = YES;
    }
    [self.pwdTextField becomeFirstResponder];
    
}
///选中国家区域代码
-(void)selectCountryCodeClick:(UITapGestureRecognizer *)tap
{
    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryCodeStr) {
        NSArray<NSString *> *comps = [countryCodeStr componentsSeparatedByString:@"+"];
        self.countryCode.text = [@"+" stringByAppendingString:comps.lastObject];
        self.countryLabel.text = comps.firstObject;
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:countryCodeVC];
    [self presentViewController:navi animated:YES completion:nil];
}

//60s倒计时
- (void)updataTimer:(NSTimer *)timer
{
    _num--;
    [_getCodeBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_num] forState:UIControlStateNormal];
    _getCodeBtn.enabled = NO;
    if (_num == 1) {
        _num = 60;
        [_getCodeBtn setTitle:Localized(@"GetAuthenticationCode") forState:UIControlStateNormal];
        _getCodeBtn.enabled = YES;
        [timer invalidate];
    }
}

- (void)forgetPwd{
    
    NSString *name = _userNameTextField.text;
    int source = 1;
    NSString *crcCode = [self.countryCode.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    ///用户名是否是邮箱，source=2代表邮箱，source=1代表手机号码
    if ([KDSTool isValidateEmail:name])
    {
        source = 2;
    }
    ///手机号码是否是中国区的号码
    else if (crcCode.intValue != 86 || [KDSTool isValidatePhoneNumber:self.userNameTextField.text])
    {
        name = [crcCode stringByAppendingString:name];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"requestingResetPwd") toView:self.view];
    [[KDSHttpManager sharedManager] forgotPwd:source name:name captcha:self.codeTextField.text newPwd:self.pwdTextField.text success:^{
        [MBProgressHUD showSuccess:Localized(@"resetPwdSuccess")];
        if ([self.markSecuritySetting isEqualToString:@"KDSGesturePwdVC"]) {
            //退出登录
            int source = 1;
            NSString *userName = [KDSTool getDefaultLoginAccount];
            if ([KDSTool isValidateEmail:userName])
            {
                source = 2;
            }
            [[KDSHttpManager sharedManager] logout:source username:[KDSTool getDefaultLoginAccount] uid:[KDSUserManager sharedManager].user.uid success:^{
               [hud hideAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLogoutNotification object:nil userInfo:nil];
            } error:^(NSError * _Nonnull error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:error.localizedDescription];
            } failure:^(NSError * _Nonnull error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:error.localizedDescription];
            }];
        }else{
            [hud hideAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
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
    
}
///隐私政策点击事件
- (IBAction)privacyPolicyBtn:(id)sender {
    
    KDSPrivacyPolicyVC * vc = [KDSPrivacyPolicyVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end

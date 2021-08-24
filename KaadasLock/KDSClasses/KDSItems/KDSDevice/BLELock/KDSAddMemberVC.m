//
//  KDSAddMemberVC.m
//  xiaokaizhineng
//
//  Created by wzr on 2019/2/18.
//  Copyright © 2019 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAddMemberVC.h"
#import "XWCountryCodeController.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager+User.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSDBManager.h"


@interface KDSAddMemberVC ()
@property (weak, nonatomic) IBOutlet UIView *numberView;
///国家/区域电话代码按钮。
@property (weak, nonatomic) IBOutlet UIButton *crcBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *tipsIV;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation KDSAddMemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addShareUser");
    self.textField.placeholder = Localized(@"inputOne'sPhoneNumberOrEmailAccount");
    ///手机号码输入框键盘类型
    self.textField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.okBtn setTitle:Localized(@"ok") forState:UIControlStateNormal];

    NSString *title = KDSTool.crc;
    if (!title)
    {
        NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
        NSString *code = [locale objectForKey:NSLocaleCountryCode];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CRCCODE" ofType:@"plist"];
        NSDictionary *codeDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        title = codeDict[code] ?: @"+86";
    }
    else
    {
        title = [@"+" stringByAppendingString:title];
    }
    [self.crcBtn setTitle:title forState:UIControlStateNormal];
    
    self.tipsLabel.text = Localized(@"memberAuthTips");
}

#pragma mark - 控件等事件方法。
- (IBAction)saveClick:(id)sender {
    
    NSString *username = self.textField.text;
    NSArray<NSString *> *comps = [self.crcBtn.currentTitle componentsSeparatedByString:@"+"];
    ///如果用户名是邮箱地址
    if ([KDSTool isValidateEmail:username])
    {
        
    }
    ///如果用户名是中国区手机号码
    else if (comps.lastObject.intValue != 86 || [KDSTool isValidatePhoneNumber:self.textField.text])
    {
        username = [comps.lastObject stringByAppendingString:username];
    }
    else///不是邮箱且不是手机号码
    {
        [MBProgressHUD showError:Localized(@"inputValidEmailOrPhoneNumber")];
        return;
    }
    ///如果输入的手机号码或者邮箱是本人的则提示不能添加自己
    if ([username isEqualToString:[KDSUserManager sharedManager].user.name])
    {
        [MBProgressHUD showError:Localized(@"can'tAddSelf")];
        return;
    }
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    userMgr.userNickname = [[KDSDBManager sharedManager] queryUserNickname];
    KDSAuthMember *member = [KDSAuthMember new];
    member.jurisdiction = @"3";
    member.beginDate = @"2000-01-01 00:00:00";
    member.endDate = @"2099-01-01 00:00:00";
    member.uname = username;
    member.unickname = username;
    member.adminname = userMgr.userNickname ?: userMgr.user.name;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    if (self.lock.device) {
        [[KDSHttpManager sharedManager] addAuthorizedUser:member withUid:[KDSUserManager sharedManager].user.uid device:self.lock.device success:^{
            [hud hideAnimated:NO];
            [MBProgressHUD showSuccess:Localized(@"addSuccess")];
            !self.memberDidAddBlock ?: self.memberDidAddBlock(member);
            if (self.navigationController.topViewController == self)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } error:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:error.localizedDescription];
        } failure:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }else if (self.lock.wifiDevice){
        [[KDSHttpManager sharedManager] addWifiLockAuthorizedUser:member withUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^{
            [hud hideAnimated:NO];
            [MBProgressHUD showSuccess:Localized(@"addSuccess")];
            !self.memberDidAddBlock ?: self.memberDidAddBlock(member);
            if (self.navigationController.topViewController == self)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } error:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:error.localizedDescription];
        } failure:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }else{
        [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.catEye.gw.model ?: self.lock.gw.model device:self.catEye.gatewayDeviceModel ?: self.lock.gwDevice userAccount:username userNickName:@"" shareFlag:1 type:2 completion:^(NSError * _Nullable error, BOOL success) {
            [hud hideAnimated:NO];
            if (success) {
                [MBProgressHUD showSuccess:Localized(@"addSuccess")];
                if (self.navigationController.topViewController == self)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else if (error.code == 402){
                
                [MBProgressHUD showError:@"提示账户不存在"];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if (error.code == 738){
                
                [MBProgressHUD showError:@"分享设备失败"];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [MBProgressHUD showError:@"分享设备失败"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

///点击国家/区域码按钮选择国家/区域码。
- (IBAction)crcBtnClickSelectCode:(UIButton *)sender
{
    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryCodeStr) {
        NSArray<NSString *> *comps = [countryCodeStr componentsSeparatedByString:@"+"];
        [self.crcBtn setTitle:[@"+" stringByAppendingString:comps.lastObject] forState:UIControlStateNormal];
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:countryCodeVC];
    [self presentViewController:navi animated:YES completion:nil];
}

///被授权的账号限制输入长度
- (IBAction)textFieldTextDidChange:(UITextField *)sender
{
    if (sender.text.length > 25)
    {
        sender.text = [sender.text substringToIndex:25];
    }
}

@end

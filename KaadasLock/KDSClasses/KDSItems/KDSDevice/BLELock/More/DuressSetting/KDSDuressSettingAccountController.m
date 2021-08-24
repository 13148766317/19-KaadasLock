//
//  KDSDuressSettingAccountController.m
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSDuressSettingAccountController.h"
#import "KDSHttpManager+WifiLock.h"

@interface KDSDuressSettingAccountController ()<UITextFieldDelegate>

//修改密码名称输入框
@property (nonatomic, strong) UITextField *accountTextField;

//确认Button
@property (nonatomic, strong) UIButton *confirmBurron;

@end

@implementation KDSDuressSettingAccountController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化主视图
    [self setupMainView];
}

#pragma mark - 初始化主视图
- (void) setupMainView{
    
    self.navigationTitleLabel.text = @"接受账号";
    self.view.backgroundColor = KDSRGBColor(248, 248, 248);
    
    //初始化修改密码输入框背景View
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 50)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    //添加密码名称修改输入框
    [backView addSubview:self.accountTextField];
    
    //添加确认Button
    self.confirmBurron.userInteractionEnabled = NO;
    [self.view addSubview:self.confirmBurron];
    
    //监听键盘弹出状态
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //UIKeyboardWillShowNotification  监听键盘弹出
    [center addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    //UIKeyboardWillHideNotification  监听键盘收回
    [center addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 修改胁迫报警属性接口--设置胁迫报警账户
-(void) loadNewData{
    
    //正则判断是否为手机号
    BOOL isPhoneNumber = [KDSTool isValidatePhoneNumber:self.accountTextField.text];
    
    //正则判断是否为邮箱
    BOOL isEmail = [KDSTool isValidateEmail:self.accountTextField.text];
    
    NSString *accountStr = nil;
    
    //判断输入账户类型  1：电话号码  2：邮箱
    int accountType = 0;
    if (isPhoneNumber) {
        accountType = 1;//电话号码
        accountStr = [NSString stringWithFormat:@"86%@",self.accountTextField.text];
    }
    
    if (isEmail) {
        accountType = 2;//邮箱
        accountStr = self.accountTextField.text;
    }
    
    //添加判断条件
    if (isPhoneNumber == NO && isEmail == NO) {
        [MBProgressHUD showError:Localized(@"inputValidEmailOrPhoneNumber")];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSHttpManager sharedManager] setDuressAlarmSinglePwdAccountWithUid:[KDSUserManager sharedManager].user.uid WifiSN:self.lock.wifiDevice.wifiSN PwdType:self.model.pwdType Num:self.model.num.intValue AccountType:accountType DuressAlarmAccount:accountStr success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.userInfo[@"msg"]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark 确认修改昵称点击事件
-(void) confirmButtonClick{
    
    //收回键盘
    [self.accountTextField resignFirstResponder];
    
    //提交数据
    [self loadNewData];
}

#pragma mark - 键盘处理
/**
 *  键盘即将弹出
 */
- (void)keyBoardDidShow:(NSNotification *)notice
{
    NSValue * obj = notice.userInfo[@"UIKeyboardFrameEndUserInfoKey"];
    
    // 转换成CGRect
    CGRect keyboardRect = [obj CGRectValue];
    
    //获取self.confirmBurron偏移后的 y
    CGFloat distance = keyboardRect.size.height - _confirmBurron.frame.size.height - 20;
    self.confirmBurron.frame = CGRectMake(20,  distance , kScreenWidth-40,40);
}

/**
 *  键盘即将隐藏
 */
- (void)keyBoardDidHide:(NSNotification *)notice
{
    // 让self.confirmBurron回归原位
    self.confirmBurron.frame = CGRectMake(20, kScreenHeight-200, kScreenWidth-40, 40);
}

#pragma mark - 触摸屏幕可视区域，收回键盘
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.accountTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString *nameStr = textField.text;

    // 限制输入字符长度
    if (textField == self.accountTextField) {

        if (![string isEqualToString:@""]) {
            nameStr = [self.accountTextField.text stringByAppendingString:string];
        }else{
            nameStr = [nameStr substringWithRange:NSMakeRange(0, self.accountTextField.text.length-1)];
        }

        if (nameStr.length > 0) {
            _confirmBurron.userInteractionEnabled = YES;
            [_confirmBurron setBackgroundColor:KDSRGBColor(45, 100, 156)];
        }else{
            _confirmBurron.userInteractionEnabled = NO;
            [_confirmBurron setBackgroundColor:KDSRGBColor(183, 200, 228)];
        }

        if (string.length == 0){

            return YES;
        }
    }

    return YES;
}

#pragma mark - 重写析构函数
-(void) dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - 懒加载

-(UITextField *)accountTextField{
    if (!_accountTextField) {
        _accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth-40, 50)];
        _accountTextField.delegate = self;
        _accountTextField.backgroundColor = [UIColor whiteColor];
        _accountTextField.textColor = [UIColor blackColor];
        //_accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountTextField.textAlignment = NSTextAlignmentLeft;
        _accountTextField.placeholder = @"输入手机号/邮箱号";
    }
    
    return _accountTextField;
}

-(UIButton *) confirmBurron{
    if (!_confirmBurron) {
        _confirmBurron = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBurron setFrame:CGRectMake(20, kScreenHeight-200, kScreenWidth-40, 40)];
        [_confirmBurron setBackgroundColor:KDSRGBColor(183, 200, 228)];
        [_confirmBurron setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmBurron setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBurron addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confirmBurron;
}


@end

//
//  KDSMediaLockInPutAdminPwdVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaLockInPutAdminPwdVC.h"
#import "KDSXMMediaLockHelpVC.h"
#import "KDSAddWiFiLockFailVC.h"
#import "KDSBleAndWiFiUpDataAdminiPwdVC.h"
#import "KDSBleAssistant.h"
#import "NSData+JKEncrypt.h"
#import "NSString+extension.h"
#import "KDSBleAndWiFiForgetAdminPwdVC.h"
#import "NSTimer+KDSBlock.h"
#import "KDSAddWiFiLockSuccessVC.h"
#import "KDSAddVideoWifiLockStep1VC.h"
#import "KDSHttpManager+VideoWifiLock.h"
#import "KDSHomeViewController.h"


@interface KDSMediaLockInPutAdminPwdVC ()

///密码输入框
@property (nonatomic, strong) UITextField * pwdTf;
@property (nonatomic, strong) UIButton * nextBtn;
@property (nonatomic, strong) UIView * supView;

@property (nonatomic, assign) int inputPwdCount;
///是否已经push过（只能执行一次）
@property (nonatomic, assign) BOOL ispushing;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation KDSMediaLockInPutAdminPwdVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inputPwdCount = 0;
    self.ispushing = YES;
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaLockBindStatus:) name:KDSMQTTEventNotification object:nil];
}

-(void)setUI
{
    self.supView = [UIView new];
    self.supView.backgroundColor = UIColor.whiteColor;
    self.supView.layer.masksToBounds = YES;
    self.supView.layer.cornerRadius = 10;
    [self.view addSubview:self.supView];
    [self.supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第六步：输入管理密码，激活临时密码 ";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(36);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.supView.mas_left).offset(KDSScreenHeight <= 667 ? 10:30);
        make.right.equalTo(self.supView.mas_right).offset(KDSScreenHeight <= 667 ? -10:-30);
    }];
    
    UILabel * tipMsgLabe2 = [UILabel new];
    tipMsgLabe2.text = @"① 使用临时密码，请先输入管理密码激活 ";
    tipMsgLabe2.font = [UIFont systemFontOfSize:15];
    tipMsgLabe2.textColor = KDSRGBColor(126, 126, 126);
    tipMsgLabe2.textAlignment = NSTextAlignmentLeft;
    [self.supView addSubview:tipMsgLabe2];
    [tipMsgLabe2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(15);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.supView.mas_left).offset(KDSScreenHeight <= 667 ? 10:30);
        make.right.equalTo(self.supView.mas_right).offset(KDSScreenHeight <= 667 ? -10:-30);
    }];
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(220, 220, 220);
    [_supView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipMsgLabe2.mas_bottom).offset(50);
        make.left.equalTo(_supView.mas_left).offset(KDSScreenHeight <= 667 ? 10:30);
        make.right.equalTo(_supView.mas_right).offset(KDSScreenHeight <= 667 ? -10:-30);
        make.height.equalTo(@1);
    }];
    UIImageView * pwdIconImg = [UIImageView new];
    pwdIconImg.image = [UIImage imageNamed:@"wifi-Lock-pwdIcon"];
    [_supView addSubview:pwdIconImg];
    [pwdIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.left.equalTo(_supView.mas_left).offset(KDSScreenHeight <= 667 ? 10:30);
        make.bottom.equalTo(line.mas_top).offset(-5);
    }];
    
    _pwdTf= [UITextField new];
    _pwdTf.placeholder=Localized(@"input6~12NumericPwd");
    _pwdTf.secureTextEntry = YES;
    _pwdTf.borderStyle=UITextBorderStyleNone;
    _pwdTf.textAlignment = NSTextAlignmentLeft;
    _pwdTf.keyboardType = UIKeyboardTypeNumberPad;
    _pwdTf.font = [UIFont systemFontOfSize:13];
    _pwdTf.textColor = UIColor.blackColor;
    [_pwdTf addTarget:self action:@selector(pwdtextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_supView addSubview:_pwdTf];
    [_pwdTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pwdIconImg.mas_right).offset(7);
        make.right.mas_equalTo(_supView.mas_right).offset(-10);
        make.bottom.equalTo(line.mas_top).offset(0);
        make.height.equalTo(@30);
    }];
    
    _nextBtn = [UIButton new];
    [_nextBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [_nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.nextBtn.userInteractionEnabled = NO;
    _nextBtn.backgroundColor = KDSRGBColor(191, 191, 191);
    _nextBtn.layer.masksToBounds = YES;
    _nextBtn.layer.cornerRadius = 22;
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.supView.mas_bottom).offset(-73);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDSMQTTEventNotification object:nil];
}

#pragma mark 控件点击事件
//- (void)navBackClick{
//     // 返回到首页
//    NSLog(@"zhushiqi返回到首页 ");
//    KDSHomeViewController  * home = [KDSHomeViewController new];
//    [self.navigationController pushViewController:home animated:YES];
//
//}

-(void)navRightClick
{
    KDSXMMediaLockHelpVC * vc = [KDSXMMediaLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)nextClick:(UIButton *)sender
{
    ///校验管理员密码是否正确
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:sender];
    [self performSelector:@selector(todoSomething:) withObject:sender afterDelay:0.5f];
}
- (void)todoSomething:(UIButton *)sender
{
    NSLog(@"是否点击验证管理员密码");
    self.hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [self getRandomCodeWidthAdminPwd:self.pwdTf.text resultData:self.crcData];
}

-(void)getRandomCodeWidthAdminPwd:(NSString *)pwd resultData:(NSString *)data
{
    NSLog(@"收到讯美发过来的密码因子16进制字符串：%@",data);
    ///56字符长度的随机数A+8字符长度的CRC32+13字符长度字符串的eSN（WF开头）+ 2字符长度功能集共79个字符长度
    if (data.length >= 79) {
        
        //32个字节的（28字节随机数+4字节CRC）
        NSData * currentData = [KDSBleAssistant convertHexStrToData:[data substringToIndex:64]];
        NSLog(@"收到讯美发过来的密码因子配网过程将要开始pwd:%@,密码因子data:%@",pwd,currentData);
        if ([self.pwdTf.text isEqualToString:@"12345678"]) {
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"门锁初始密码不能验证，\n 请修改门锁管理密码或重新输入" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * againInPutAction = [UIAlertAction actionWithTitle:@"重新输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            UIAlertAction * changePasswordAction = [UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                KDSBleAndWiFiUpDataAdminiPwdVC * vc = [KDSBleAndWiFiUpDataAdminiPwdVC new];
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [changePasswordAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
            [alerVC addAction:changePasswordAction];
            [alerVC addAction:againInPutAction];
            [self presentViewController:alerVC animated:YES completion:nil];
            return;
        }
        NSString * wifiSN = [data substringWithRange:NSMakeRange(64, 13)];
        NSString * string = @"";
        for (int i = 0; i<pwd.length; i ++) {
            NSString * temstring = [NSString ToHex:[pwd substringWithRange:NSMakeRange(i, 1)].integerValue];
            string  = [string stringByAppendingFormat:@"%02ld",(long)temstring.integerValue];
        }
        NSData * datastring = [KDSBleAssistant convertHexStrToData:string];
        NSString *aString = [[NSString alloc] initWithData:datastring encoding:NSUTF8StringEncoding];
        //key AES256后的值
        NSString * Haxi = [NSString sha256HashFor:aString];
        NSData *resultData = [currentData aesWifiLock256_decryptData:[KDSBleAssistant convertHexStrToData:Haxi]];
        int crc = [NSString data2Int:[resultData subdataWithRange:NSMakeRange(28, 4)]];
        //测试数据：随机数A
        int32_t randomCode = [[resultData subdataWithRange:NSMakeRange(0, 28)] crc32];
        ///添加到服务器用到的随机数A
        NSString * randomCodeData = [KDSBleAssistant convertDataToHexStr:[resultData subdataWithRange:NSMakeRange(0, 28)]];
        u_int8_t tt;///wifi的功能集
        NSData * functionSetData = [KDSBleAssistant convertHexStrToData:[data substringWithRange:NSMakeRange(77, 2)]];
        [functionSetData getBytes:&tt length:sizeof(tt)];
        long long int value = randomCode;
        Byte byte[4] = {};
        byte[3] =(Byte) ((value>>24) & 0xFF);
        byte[2] =(Byte) ((value>>16) & 0xFF);
        byte[1] =(Byte) ((value>>8) & 0xFF);
        byte[0] =(Byte) (value & 0xFF);
        if (randomCode != crc) {
            self.inputPwdCount ++;
             NSLog(@"随机数生成的CRC：%d原始CRC：%d",randomCode,crc);
            NSString * messageStr = @"门锁管理员密码验证失败，\n请重新输入";
            NSString *forgetPwdStr = @"忘记密码";
            NSString * inputAgainStr = @"重新输入";
            if (self.inputPwdCount == 3) {
                messageStr = @"门锁管理密码验证已失败3次，超过5次门锁将退出配网";
            }else if (self.inputPwdCount == 4){
                messageStr = @"门锁管理密码验证已失败4次，超过5次门锁将退出配网";
            }else if (self.inputPwdCount >= 5) {
                messageStr = @"门锁管理密码验证已失败5次 请修改管理密码，重新配网";
                forgetPwdStr = @"确定";
                inputAgainStr = @"";
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:messageStr preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * forgetPwdAction = [UIAlertAction actionWithTitle:forgetPwdStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (self.inputPwdCount >= 5) {
                        ///5次密码错误配网失败
                        [self addDeviceFail];
                    }else{
                        ///忘记密码
                        KDSBleAndWiFiForgetAdminPwdVC * vc = [KDSBleAndWiFiForgetAdminPwdVC new];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }];
                UIAlertAction * inputAgainAction = [UIAlertAction actionWithTitle:inputAgainStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    ///重新输入密码
                    [self.hud   hideAnimated:YES];
                    
                }];
                [inputAgainAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
                if (inputAgainStr.length > 0) {
                    [alerVC addAction:inputAgainAction];
                }
                if (forgetPwdStr.length > 0) {
                    [alerVC addAction:forgetPwdAction];
                }
                [self presentViewController:alerVC animated:YES completion:nil];
            });
            
        }else{
            ///拿到随机码、wifiSN、绑定设备
            // 视屏绑定成功 收到mqtt的响应后  已经将 P2P的密码保存起来了
            self.model.wifiSN = wifiSN;
            self.model.lockNickname = wifiSN;
            self.model.isAdmin = @"1";
            self.model.randomCode = randomCodeData;
            self.model.functionSet = @(tt).stringValue;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self bindWifiLockWithWifiSN:self.model randomCode:self.model.randomCode];
            });
        }
    }else{
        ///锁下发的密码因子（32+13SN+1功能集）数据错误
        [self addDeviceFail];
    }
}

-(void)bindWifiLockWithWifiSN:(KDSWifiLockModel *)wifiLockModel randomCode:(NSString *)randomCode
{
    NSMutableArray * hasBeensn = [NSMutableArray array];
    for (KDSLock * lock in [KDSUserManager sharedManager].locks) {
        if (lock.wifiDevice && lock.wifiDevice.isAdmin.intValue == 1) {
            [hasBeensn addObject:lock.wifiDevice.wifiSN];
        }
    }
    BOOL isContentWifiSN = [hasBeensn containsObject:wifiLockModel.wifiSN];
    ///XMMediawifi配网
    wifiLockModel.distributionNetwork = 3;
    if (isContentWifiSN) {
        ///主用户绑定的是相同的一个锁，更新锁信息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KDSHttpManager sharedManager] updateMediaBindWifiDevice:wifiLockModel uid:[KDSUserManager sharedManager].user.uid success:^{
                //处理请求 返回数据
                [self addSuccessWithModel:wifiLockModel];
            } error:^(NSError * _Nonnull error) {
                if (error.code != 202) {
                    //202    已绑定
                    [self addDeviceFail];
                }
            } failure:^(NSError * _Nonnull error) {
                [self addDeviceFail];
            }];
        });
        
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KDSHttpManager sharedManager] bindMediaWifiDevice:wifiLockModel uid:[KDSUserManager sharedManager].user.uid success:^{
                //处理请求 返回数据
                [self addSuccessWithModel:wifiLockModel];
            } error:^(NSError * _Nonnull error) {
                if (error.code != 202) {
                    //202    已绑定
                    [self addDeviceFail];
                }
            } failure:^(NSError * _Nonnull error) {
                [self addDeviceFail];
                
            }];
        });
    }
}
-(void)addDeviceFail
{
    [self.hud hideAnimated:YES];
    if (self.ispushing) {
        self.ispushing = NO;
        [[KDSHttpManager sharedManager] XMMediaBindFailWifiDevice:self.model uid:[KDSUserManager sharedManager].user.uid result:0 success:nil error:nil failure:nil];
        KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
   
}

- (void)addSuccessWithModel:(KDSWifiLockModel *)wifiLockModel
{
    [self.hud hideAnimated:YES];
    if (self.ispushing) {
        self.ispushing = NO;
        KDSAddWiFiLockSuccessVC * vc = [KDSAddWiFiLockSuccessVC new];
        vc.model = wifiLockModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)navBackClick
{
  
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddVideoWifiLockStep1VC class]]) {
                KDSAddVideoWifiLockStep1VC *A =(KDSAddVideoWifiLockStep1VC *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
    
    
}

-(void)pwdtextFieldDidChange:(UITextField *)textField
{
      if (textField.text.length >= 6) {
        _nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
        self.nextBtn.userInteractionEnabled = YES;
       }
       if (textField.text .length < 6) {
           _nextBtn.backgroundColor = KDSRGBColor(191, 191, 191);
           self.nextBtn.userInteractionEnabled = NO;
       }
       if (textField.text.length > 12) {
           textField.text = [textField.text substringToIndex:12];
           [MBProgressHUD showError:Localized(@"PwdLength6BitsAndNotMoreThan12bits")];
       }
}

#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    //取出键盘动画的时间
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //取得键盘最后的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.nextBtn.frame.size.height;
    NSLog(@"键盘上移的高度：%f-----取出键盘动画时间：%f",transformY,duration);
    [UIView animateWithDuration:duration animations:^{
        [self.nextBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.supView.mas_top).offset(170);
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        }];
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [self.nextBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.supView.mas_bottom).offset(-73);
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        }];
    }];
}

#pragma mark -- 视频锁绑定结果的通知（超时）
- (void)mediaLockBindStatus:(NSNotification *)noti
{
    MQTTSubEvent  subevent = noti.userInfo[MQTTEventKey];
    if ([subevent isEqualToString:MQTTSubEventMdeiaLockBindErrorNotity]){
        //不管超时还是其他错误，都结束配网且失败
        [self addDeviceFail];
    }
}

@end

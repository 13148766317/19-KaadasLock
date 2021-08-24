//
//  KDSGWAddPINPermanentVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/30.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSGWAddPINPermanentVC.h"
#import "KDSMQTT.h"
#import "MBProgressHUD+MJ.h"
#import "KDSTimelinessView.h"
#import "KDSPINShareVC.h"
#import "KDSHttpManager+Ble.h"
#import "KDSDBManager+GW.h"

@interface KDSGWAddPINPermanentVC ()

///文本密码输入框
@property(nonatomic,readwrite,strong)UITextField * pwdTextfield;
///确定生成
@property(nonatomic,readwrite,strong)UIButton * sureBtn;
///设置密码时返回的凭证。
@property (nonatomic, strong) KDSMQTTTaskReceipt *receipt;
///时效密码的开始时间视图，周期密码的起止时间视图。
@property (nonatomic, strong) KDSTimelinessView *beginTimelinessView;
///时间密码的结束时间视图，周期密码的规则视图。
@property (nonatomic, strong) KDSTimelinessView *endTimelinessView;

@end

@implementation KDSGWAddPINPermanentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized((self.type==2 ? @"addTempPIN" : @"addPIN"));
    [self setUI];
}

-(void)setUI{
    UIView * contentView = [UIView new];
    contentView.userInteractionEnabled = YES;
    contentView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.top.mas_equalTo(self.view.mas_top).offset(31);
    }];
    UIImageView * pwdiconImg = [UIImageView new];
    pwdiconImg.image = [UIImage imageNamed:@"密码Hight"];
    [contentView addSubview:pwdiconImg];
    [pwdiconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(19);
        make.width.mas_equalTo(16);
        make.left.mas_equalTo(contentView.mas_left).offset(16);
        make.centerY.mas_equalTo(contentView.mas_centerY).offset(0);
    }];
    
    UIButton * randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [randomBtn setTitle:Localized(@"randomOccur") forState:UIControlStateNormal];
    randomBtn.backgroundColor = KDSRGBColor(205, 225, 247);
    [randomBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    randomBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [randomBtn addTarget:self action:@selector(clickRandomOccurBtnOccurRandomPassword:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:randomBtn];
    [randomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(contentView.mas_right).offset(0);
        make.width.mas_equalTo(100);
        make.top.mas_equalTo(contentView.mas_top).offset(0);
        make.height.mas_equalTo(50);
        
    }];
    
    self.pwdTextfield = [UITextField new];
    self.pwdTextfield.placeholder = Localized(@"input6~12NumericPwd");
    self.pwdTextfield.font = [UIFont systemFontOfSize:kScreenWidth<375 ? 13 : 15];
    self.pwdTextfield.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:self.pwdTextfield];
    [self.pwdTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView.mas_top).offset(0);
        make.bottom.mas_equalTo(contentView.mas_bottom).offset(0);
        make.left.mas_equalTo(pwdiconImg.mas_right).offset(10);
        make.right.mas_equalTo(randomBtn.mas_left).offset(-10);
    }];
    

    UILabel * savePwdTipsLabel = [UILabel new];
    savePwdTipsLabel.text =  Localized(@"saveBlePwdTipsWithoutName");
    savePwdTipsLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    savePwdTipsLabel.font = [UIFont systemFontOfSize:12];
    savePwdTipsLabel.numberOfLines = 0;
    savePwdTipsLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:savePwdTipsLabel];
    [savePwdTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.top.mas_equalTo(contentView.mas_bottom).offset(20);
        make.height.mas_equalTo(15);
    }];
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sureBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [self.sureBtn setTitle:Localized(@"ensureOccur") forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:KDSRGBColor(255, 255, 255) forState:UIControlStateNormal];
    self.sureBtn.layer.cornerRadius = 22;
    [self.sureBtn addTarget:self action:@selector(clickOccurBtnOccurPwd:) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [self.view addSubview:self.sureBtn];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-240);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
}

#pragma mark - 控件等事件方法。
///点击随机生成按钮生成随机密码。
- (void)clickRandomOccurBtnOccurRandomPassword:(UIButton *)sender
{
    NSInteger count = arc4random() % 7 + 6;
    NSMutableString *ms = [NSMutableString stringWithCapacity:count];
    for (int i = 0; i < count; ++i)
    {
        [ms appendString:@(arc4random() % 10).stringValue];
    }
    self.pwdTextfield.text = ms.copy;
}

///点击生成密码按钮发送命令在锁中添加密码。
- (void)clickOccurBtnOccurPwd:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (self.receipt) return;
    
    if ([KDSTool isSimplePasswordInLock:self.pwdTextfield.text])
    {
        [MBProgressHUD showError:Localized(@"pleaseInputAtLeast6NumericsPwd")];
        return;
    }
    if (!self.pwdTextfield.text.length)
    {
        [MBProgressHUD showError:Localized(@"pleaseInputPwdName")];
        return;
    }
    //先获取已存在的密码，然后判断是否已满，最后再到添加密码，
    //方案一：每次添加密码前要递归查询已经存在的密码(比较慢，但确保证数据一致)
    [self getExistedPasswords];
    
    //方案二：每次添加密码前从本地数据库查已经存在的密码（本地数据库可能不准确，不准确的情况下，先同步再添加），再添加
//    [self addPasswordToDb];
}

#pragma mark - 网络请求相关方法。
/**
 *@brief 将密码信息上传到服务器。@note 原为蓝牙使用，网关锁先不使用此接口。
 *@param m 根据相关信息生成的密码模型，此参数只需设置密码编号，剩下的参数在方法内会设置。
 */
- (void)addPasswordToServer:(KDSPwdListModel *)m
{
    m.nickName = self.pwdTextfield.text;
    if (self.type == 0)
    {
        m.pwdType = KDSServerKeyTpyePIN;
        m.type = KDSServerCycleTpyeForever;
    }
    else if (self.type == 2)
    {
        m.pwdType = KDSServerKeyTpyeTempPIN;
    }
    [[KDSHttpManager sharedManager] addBlePwds:@[m] withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.gwDevice.deviceId success:nil error:nil failure:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) return YES;
    if (string.length != strlen(string.UTF8String)) return NO;
    if (string.length + textField.text.length > 12) return NO;
    for (int i = 0; i < string.length; ++i)
    {
        if (string.UTF8String[i]<'0' || string.UTF8String[i]>'9') return NO;
    }
    return YES;
}

#pragma mark - MQTT接口相关方法。
///获取已存在的密码。
- (void)getExistedPasswords
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"settingPwd") toView:self.view.superview.superview];
    [[KDSMQTTManager sharedManager] dlGetKeyInfo:self.lock.gwDevice completion:^(NSError * _Nullable error, KDSGWLockKeyInfo * _Nullable info) {
        if (!info || info.maxpwdusernum==0)
        {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
        }
        else
        {
            unsigned from, to, max;
            if (self.type == 2)
            {
                //目前所有的锁临时密码只有4组：05、06、07、08
                from = 5; to = 9; max = 4/*(unsigned)info.maxpwdusernum - 6*/;
            }
            else if (self.type == 3)
            {
                from = 9; to = 10; max = 1;
            }
            else
            {
                from = 0; to = (unsigned)info.maxpwdusernum; max = (unsigned)info.maxpwdusernum - 5;//(4个临时1个胁迫)
            }
            //暂时只使用密码。
            NSMutableArray<KDSBleUserType *> *container = [NSMutableArray arrayWithCapacity:to - from];
            [self recursiveGetKeys:self.keyType from:from to:to recursiveCount:0 container:container completion:^{
                
                [hud hideAnimated:NO];
                //胁迫密码编号是9
                if (container.lastObject.userId == to)
                {
                    [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
                    return;
                }
                
                if (container.count == max && self.type == 3)
                {
                    [MBProgressHUD showError:Localized(@"passwordUpperLimit")];
                    return;
                }
                int schedule = 0, temp = 0;
                for (KDSBleUserType *user in container)
                {
                    if (!(user.userId > 4 && user.userId < 9))
                    {
                        schedule ++;
                    }
                    else if (user.userId != 9)
                    {
                        temp++;
                    }
                }
                if (container.count == max)
                {
                    NSString *warning = Localized((self.type==0 ? @"permanentPwdUpperLimit" : (self.type==2 ? @"temporaryPwdUpperLimit" : @"passwordUpperLimit")));
                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:warning message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
                    [ac addAction:okAction];
                    [self presentViewController:ac animated:YES completion:nil];
                }
                else
                {
                    int num = self.type==0 ? 0 : 5;
                    for (KDSBleUserType *user in container)
                    {
                        if (self.type == 1 && user.userId < 5) continue;
                        if (user.userId != num) break;
                        num++;
                    }
                    num = self.type==3 ? 9 : num;//胁迫密码的编号固定为9
                    self.receipt = [self setPwdInLock:self.pwdTextfield.text PwdNumber:num];
                }
            }];
        }
    }];
}

-(void)addPasswordToDb
{
    ///目前app只可以添加临时密码，所以查寻本地数据库的已有的临时密码
     NSArray *passwords = [[KDSDBManager sharedManager] queryPasswordsWithLock:self.lock.gwDevice type:2];
    NSMutableArray * pwdNum = [NSMutableArray array];
    for (KDSPwdListModel * pwdModel in passwords) {
        if (passwords) {
            [pwdNum addObject:@(pwdModel.num.intValue)];
        }
    }
        
    int  num = [self setTempNumWitchUserId:pwdNum];
    NSLog(@"pwdNum:%d",num);
    self.receipt = [self setPwdInLock:self.pwdTextfield.text PwdNumber:num];
    
}
-(int)setTempNumWitchUserId:(NSArray *)userIds
{
    int userNum = 5;
    for (int i = 0; i < 10; i ++) {
        if ((4 < i && i < 9)) {
            if (![userIds containsObject:@(i)]) {
                userNum = i;
                return userNum;
            }
        }
    }
    return userNum;
}

/**
 *@brief 递归获取[index1, index2)编号的密匙信息。不包含index2的编号，如果index1=index2，则递归结束。
 *@param type 密匙类型。
 *@param index1 起始密匙编号。
 *@param index2 结束密匙编号，应该比最大编号大。
 *@param count 当某个编号获取失败时，继续获取该编号的最大递归次数。如果此值>=3，则不再继续获取。除首次外其它的递归次数最大都为3.
 *@param container 由使用者负责初始化的可变数组，每个编号递归结束后，结果(当成功时，编号小于index2，当失败时，编号等于index2)会存入此数组中。暂时使用蓝牙的用户类型，只用到编号。
 *@param completion 递归结束执行的回调。如果有一个编号获取失败或者全部编号获取完毕后执行。
 */
- (void)recursiveGetKeys:(KDSGWKeyType)type from:(unsigned)index1 to:(unsigned)index2 recursiveCount:(int)count container:(NSMutableArray<KDSBleUserType *> *)container completion:(void(^)(void))completion
{
    if (index1 == 9 && self.type != 3) index1++;
    if (index1 >= index2)
    {
        !completion ?: completion();
        return;
    }
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:index1 type:(int)type completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
        BOOL finished = success;
        if (success)
        {
            KDSBleUserType *user = [KDSBleUserType new];
            user.userId = index1;
            [container addObject:user];
        }
        else if (error && error.code == 0)
        {
            finished = YES;
        }
        else if (count >= 3)
        {
            KDSBleUserType *user = [KDSBleUserType new];
            user.userId = index2;
            [container addObject:user];
            !completion ?: completion();
            return;
        }
        [self recursiveGetKeys:type from:(count>=3 || finished) ? index1 + 1 : index1 to:index2 recursiveCount:count>=3 ? 0 : count + 1 container:container completion:completion];
    }];
}

///根据密码和密码编号设置密码。
- (KDSMQTTTaskReceipt *)setPwdInLock:(NSString *)pwd PwdNumber:(int)number
{
    __weak typeof(self) weakSelf = self;
     MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view.superview.superview];
    return [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:0 withPwd:pwd number:number type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
        [MBProgressHUD hideHUDForView:weakSelf.view.superview.superview];
        [hud hideAnimated:YES];
        if (success)
        {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            KDSPwdListModel *m = [KDSPwdListModel new];
            m.num = [NSString stringWithFormat:@"%02d", number];
            //[weakSelf addPasswordToServer:m];
            if (weakSelf.type == 2)
            {
                m.pwdType = KDSServerKeyTpyeTempPIN;
            }
            else
            {
                m.type = KDSServerCycleTpyeForever;
                m.pwdType = KDSServerKeyTpyePIN;
            }
            m.pwd = weakSelf.pwdTextfield.text;
            [[KDSDBManager sharedManager] insertPasswords:@[m] withLock:self.lock.gwDevice];
            KDSPINShareVC *vc = [KDSPINShareVC new];
            vc.model = m;
            vc.lock = weakSelf.lock;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
        weakSelf.receipt = nil;
    }];
}

@end

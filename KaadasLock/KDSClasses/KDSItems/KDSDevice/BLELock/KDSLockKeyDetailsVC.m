//
//  KDSLockKeyDetailsVC.m
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSLockKeyDetailsVC.h"
#import "Masonry.h"
#import "KDSHttpManager+User.h"
#import "KDSHttpManager+Ble.h"
#import "KDSAlertController.h"
#import "KDSDBManager.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"

@interface KDSLockKeyDetailsVC ()

///不可编辑的昵称标签。
@property (nonatomic, weak) UILabel *nicknameLabel;
///编辑按钮旁边的可编辑的昵称标签。
@property (nonatomic, weak) UILabel *editNicknameLabel;

@end

@implementation KDSLockKeyDetailsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    switch (self.keyType)
    {
        case KDSBleKeyTypeReserved:
            self.navigationTitleLabel.text = Localized(@"userDetails");
            break;
            
        case KDSBleKeyTypePIN:
            self.navigationTitleLabel.text = Localized(@"passwordDetails");
            break;
            
        case KDSBleKeyTypeFingerprint:
            self.navigationTitleLabel.text = Localized(@"fingerprintDetails");
            break;
            
        case KDSBleKeyTypeRFID:
            self.navigationTitleLabel.text = Localized(@"cardDetails");
            break;
            
        default:
            break;
    }
    [self setupUI];
}

- (void)setupUI
{
    UIView *view = nil;
    if (self.keyType == KDSBleKeyTypePIN)
    {
        UILabel *label = [self createLabelWithText:@"text" color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
        KDSPwdListModel *m = self.model;
        if (m.pwdType == KDSServerKeyTpyeTempPIN)
        {
            label.text = Localized(@"tempPwd,onlyOnce");
        }
        else if (m.type == KDSServerCycleTpyeForever)
        {
            label.text = Localized(@"permanentValidation");
        }
        else if (m.type == KDSServerCycleTpyeCycle)
        {
            NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
            fmt.dateFormat = @"HH:mm";
            NSString *begin = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]];
            NSString *end = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]];
            NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
            NSString *separator = @" ";
            NSMutableString *ms = [NSMutableString string];
            int t = 0;
            for (int i = 0; i < m.items.count; ++i)
            {
                if (m.items[i].boolValue)
                {
                    t++;
                    [ms appendFormat:@"%@%@", days[i<days.count ? i : days.count-1], separator];
                }
            }
            label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), t==m.items.count ? Localized(@"everyday") : ms, begin, end];
        }
        else
        {
            NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            if (m.startTime.doubleValue > FutureTime && m.endTime.doubleValue > FutureTime) {
                //毫秒
                label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"),@"", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue/1000]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue/1000]]];
            }else{//秒
                label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"),@"", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]]];
            }
//            label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), @"", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]]];
        }
        
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(52);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
        }];
        view = label;
    }
    else
    {
        UIImageView *iv = [UIImageView new];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(52);
            make.centerX.equalTo(self.view);
            make.width.height.equalTo(@40);
        }];
        view = iv;
    }
    NSString *nm = nil;
    if (self.keyType == KDSBleKeyTypeReserved)
    {
        nm = ((KDSAuthMember *)self.model).unickname;
    }
    else
    {
        nm = ((KDSPwdListModel *)self.model).nickName;
        nm = nm.length ? nm : [NSString stringWithFormat:@"%02d", [self.model num].intValue];
    }
    UILabel *nicknameLabel = [self createLabelWithText:self.keyType==KDSBleKeyTypePIN ? @"* * * * * * * *" : nm color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    nicknameLabel.textAlignment = NSTextAlignmentCenter;
    self.nicknameLabel = nicknameLabel;
    [self.view addSubview:nicknameLabel];
    [nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.keyType==KDSBleKeyTypePIN ? view : view.mas_bottom).offset(self.keyType==KDSBleKeyTypePIN ? 73 : 22);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.layer.cornerRadius = 22;
    deleteBtn.backgroundColor = KDSRGBColor(0xff, 0x3b, 0x30);
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    switch (self.keyType)
    {
        case KDSBleKeyTypeReserved:
            [deleteBtn setTitle:Localized(@"deleteUser") forState:UIControlStateNormal];
            ((UIImageView*)view).image = [UIImage imageNamed:@"member"];
            break;
            
        case KDSBleKeyTypePIN:
            [deleteBtn setTitle:Localized(@"deletePassword") forState:UIControlStateNormal];
            break;
            
        case KDSBleKeyTypeFingerprint:
            [deleteBtn setTitle:Localized(@"deleteFingerprint") forState:UIControlStateNormal];
            ((UIImageView*)view).image = [UIImage imageNamed:@"bigFingerprint"];
            break;
            
        case KDSBleKeyTypeRFID:
            [deleteBtn setTitle:Localized(@"deleteCard") forState:UIControlStateNormal];
            ((UIImageView*)view).image = [UIImage imageNamed:@"bigCard"];
            break;
            
        default:
            break;
    }
    [deleteBtn addTarget:self action:@selector(clickDeleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nicknameLabel.mas_bottom).offset(60);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.clipsToBounds = YES;
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deleteBtn.mas_bottom).offset(42);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@101);
    }];
    
    UILabel *nLabel = [self createLabelWithText:Localized(@"name") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:15]];
    [cornerView addSubview:nLabel];
    [nLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView);
        make.left.equalTo(cornerView).offset(26);
        make.width.equalTo(@(nLabel.bounds.size.width));
        make.height.equalTo(@50);
    }];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    editBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [editBtn addTarget:self action:@selector(clickEditBtnEditNickname:) forControlEvents:UIControlEventTouchUpInside];
    [cornerView addSubview:editBtn];
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(cornerView);
        make.width.height.equalTo(@50);
    }];
    
    UILabel *eLabel = [self createLabelWithText:nm color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:17]];
    eLabel.textAlignment = NSTextAlignmentCenter;
    self.editNicknameLabel = eLabel;
    [cornerView addSubview:eLabel];
    [eLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView);
        make.left.equalTo(nLabel.mas_right).offset(kScreenWidth<375 ? 26 : 37);
        make.right.equalTo(editBtn.mas_left).offset(kScreenWidth<375 ? -11 : -20);
        make.height.equalTo(@50);
    }];
    
    UIView *separatorView = [UIView new];
    separatorView.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [cornerView addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eLabel.mas_bottom);
        make.left.right.equalTo(cornerView);
        make.height.equalTo(@1);
    }];
    
    UILabel *tLabel = [self createLabelWithText:Localized(@"authTime") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:15]];
    [cornerView addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separatorView.mas_bottom);
        make.left.equalTo(cornerView).offset(26);
        make.width.equalTo(@(tLabel.bounds.size.width));
        make.height.equalTo(@50);
    }];
    
    NSTimeInterval createTime = 0;
    if (self.keyType == KDSBleKeyTypeReserved)
    {
        createTime = ((KDSAuthMember *)self.model).createTime;
    }
    else
    {
        createTime = ((KDSPwdListModel *)self.model).createTime;
    }
    self.lock.bleTool.dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    UILabel *timeLabel = [self createLabelWithText:[self.lock.bleTool.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]] color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    [cornerView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separatorView.mas_bottom);
        make.left.equalTo(tLabel.mas_right).offset(kScreenWidth<375 ? 26 : 37);
        make.right.equalTo(cornerView).offset(kScreenWidth<375 ? 26 : 37);
        make.height.equalTo(@50);
    }];
}

- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}

#pragma mark - 控件等事件方法。
///点击删除按钮，删除密码、指纹、卡片、用户
- (void)clickDeleteBtnAction:(UIButton *)sender
{
    NSString *title = nil;
    switch (self.keyType)
    {
        case KDSBleKeyTypeReserved:
            title = Localized(@"ensureDeleteUser?");
            break;
            
        case KDSBleKeyTypePIN:
            title = Localized(@"ensureDeletePassword?");
            break;
            
        case KDSBleKeyTypeFingerprint:
            title = Localized(@"ensureDeleteFingerprint?");
            break;
            
        case KDSBleKeyTypeRFID:
            title = Localized(@"ensureDeleteCard?");
            break;
            
        default:
            break;
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.keyType == KDSBleKeyTypeReserved)
        {
            [weakSelf deleteAuthMember:nil];
        }
        else
        {
            KDSAlertController *alert = [KDSAlertController alertControllerWithTitle:Localized(@"deleting") message:Localized(@"openBleAndStandByDoorLock")];
            [weakSelf presentViewController:alert animated:YES completion:nil];
            KDSPwdListModel *m = weakSelf.model;
            [weakSelf.lock.bleTool manageKeyWithPwd:@"" userId:m.num action:KDSBleKeyManageActionDelete keyType:weakSelf.keyType completion:^(KDSBleError error) {
                if (error == KDSBleErrorSuccess)
                {
                    alert.title = Localized(@"deleteSuccess");
                    [weakSelf deletePassword:m];
                }
                else
                {
                    alert.title = Localized(@"deleteFailed");
                    alert.titleColor = KDSRGBColor(0xff, 0x3b, 0x30);
                }
                alert.message = nil;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }];
                });
            }];
        }
    }];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
}

///点击编辑按钮编辑昵称。
- (void)clickEditBtnEditNickname:(UIButton *)sender
{
    NSString *title = nil;
    switch (self.keyType)
    {
        case KDSBleKeyTypeReserved:
            title = Localized(@"pleaseInputUserName");
            break;
            
        case KDSBleKeyTypePIN:
            title = Localized(@"pleaseInputPasswordName");
            break;
            
        case KDSBleKeyTypeFingerprint:
            title = Localized(@"pleaseInputFingerprintName");
            break;
            
        case KDSBleKeyTypeRFID:
            title = Localized(@"pleaseInputCardName");
            break;
            
        default:
            break;
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    NSString *placeholder = self.editNicknameLabel.text;
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:12];
        textField.placeholder = placeholder;
        [textField addTarget:weakSelf action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf updateNickname:ac.textFields.firstObject.text];
    }];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
}

///编辑昵称时输入框文字改变。
- (void)textFieldTextChanged:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

#pragma mark - 网络请求方法。
///更新昵称。
- (void)updateNickname:(NSString *)nickname
{
    if (nickname.length == 0) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    if (self.keyType == KDSBleKeyTypeReserved)
    {
        KDSAuthMember *member = self.model;
        NSString *name = member.unickname;
        member.unickname = nickname;
        [[KDSHttpManager sharedManager] updateAuthorizedUserNickname:member success:^{
            [hud hideAnimated:NO];
            self.editNicknameLabel.text = self.nicknameLabel.text = nickname;
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
        } error:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:Localized(@"setFailed")];
            member.unickname = name;
        } failure:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:error.localizedDescription];
            member.unickname = name;
        }];
    }
    else
    {
        KDSPwdListModel *m = self.model;
        NSString *name = m.nickName;
        m.nickName = nickname;
        [[KDSHttpManager sharedManager] setBlePwd:m withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:^{
            [hud hideAnimated:NO];
            self.editNicknameLabel.text = nickname;
            if (self.keyType != KDSBleKeyTypePIN)
            {
                self.nicknameLabel.text = nickname;
            }
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
        } error:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:Localized(@"setFailed")];
            m.nickName = name;
        } failure:^(NSError * _Nonnull error) {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:error.localizedDescription];
            m.nickName = name;
        }];
    }
}

///删除授权用户。参数如果为空则取model属性值
- (void)deleteAuthMember:(nullable KDSAuthMember *)member
{
    KDSAlertController *ac = [KDSAlertController alertControllerWithTitle:Localized(@"deleting") message:nil];
    [self presentViewController:ac animated:YES completion:^{
        
    }];
    void(^completion)(BOOL) = ^(BOOL success){
        
        ac.title = Localized(success ? @"deleteSuccess" : @"deleteFailed");
        ac.message = nil;
        !success ? ac.titleColor = KDSRGBColor(0xff, 0x3b, 0x30) : nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ac dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
    };
    if (!member) member = self.model;
    [[KDSHttpManager sharedManager] deleteAuthorizedUser:member withUid:[KDSUserManager sharedManager].user.uid device:self.lock.device success:^{
        completion(YES);
    } error:^(NSError * _Nonnull error) {
        completion(NO);
    } failure:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

///删除密码、卡片、指纹。
- (void)deletePassword:(KDSPwdListModel *)m
{
    [[KDSHttpManager sharedManager] deleteBlePwd:@[m] withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:nil error:nil failure:nil];
}

@end

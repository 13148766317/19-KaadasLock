//
//  KDSGWLockKeyDetailsVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWLockKeyDetailsVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSAlertController.h"
#import "UIView+Extension.h"
#import "KDSDBManager+GW.h"

@interface KDSGWLockKeyDetailsVC ()

///不可编辑的昵称标签。
@property (nonatomic, weak) UILabel *nicknameLabel;
///编辑按钮旁边的可编辑的昵称标签。
@property (nonatomic, weak) UILabel *editNicknameLabel;
@property (nonatomic,strong)UIButton * editBtn;
///周期密码时，位域标记选中日期的变量，从低到高分别表示周日 ~ 周六，最高位保留0，1选中。
@property (nonatomic, assign) char mask;

@end

@implementation KDSGWLockKeyDetailsVC

- (void)setMask:(char)mask
{
    _mask = mask;NSString * stringStr;
    NSArray<NSString *> *comps = [@"12~22" componentsSeparatedByString:@"~"];
    NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (mask == 0x7f)
    {
        stringStr = [NSString stringWithFormat:Localized(@"pwdRuleTips"), Localized(@"everyday"), begin, end];
    }
    else
    {
        NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
        NSMutableString *ms = [NSMutableString string];
        NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
        for (int i = 0; i < 7; ++i)
        {
            !((mask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
        }
        [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
        stringStr = [NSString stringWithFormat:Localized(@"pwdRuleTips"), ms, begin, end];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    switch (self.keyType)
    {
        case KDSGWKeyTypeReserved:
            self.navigationTitleLabel.text = Localized(@"userDetails");
            break;
            
        case KDSGWKeyTypePIN:
            self.navigationTitleLabel.text = Localized(@"passwordDetails");
            break;
            
        case KDSGWKeyTypeFingerprint:
            self.navigationTitleLabel.text = Localized(@"fingerprintDetails");
            break;
            
        case KDSGWKeyTypeRFID:
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
    if (self.keyType == KDSGWKeyTypePIN)
    {
        UILabel *label = [self createLabelWithText:@"text" color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
       NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
        KDSPwdListModel *m = self.model;
        if (m.pwdType == KDSServerKeyTpyeTempPIN)
        {
            label.text = Localized(@"tempPwd,onlyOnce");
            
        }
        else if (m.type == KDSServerCycleTpyeForever)
        {
            if ([m.num isEqualToString:@"09"]) {
                label.text = Localized(@"menacePassword");
            }else{
                label.text = Localized(@"permanentValidation");
            }
        }
        else if (m.type == KDSServerCycleTpyeCycle)
        {
            NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"HH:mm";
            if (m.startHour || m.endHour || m.startMinutes || m.endMinutes) {
                NSString * begin = [NSString stringWithFormat:@"%02d:%02d",m.startHour,m.startMinutes];
                NSString * end = [NSString stringWithFormat:@"%02d:%02d",m.endHour,m.endMinutes];
                if (m.daysMask == 127)
                {
                    label.text = [NSString stringWithFormat:@"%@ %@-%@", Localized(@"everyday"), begin, end];
                }
                else
                {
                    NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
                    NSMutableString *ms = [NSMutableString string];
                    NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
                    for (int i = 0; i < 7; ++i)
                    {
                        !((m.daysMask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
                    }
                    [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
                    label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), ms, begin, end];
                }
            }else{
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
            
        }
        else
        {
            NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), @"", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue + MQTTFixedTime - secondsFromGMT]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue + MQTTFixedTime - secondsFromGMT]]];
            
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
    NSTimeInterval createTime = 0;
    if (self.keyType == KDSGWKeyTypeReserved)
    {
        KDSAuthCatEyeMember *member = self.model;
        nm = member.userNickname;
    }
    else
    {
        KDSPwdListModel *model = self.model;
        nm = model.nickName.length ? model.nickName : [NSString stringWithFormat:@"%02d", model.num.intValue];
        createTime = model.createTime;
    }
    UILabel *nicknameLabel = [self createLabelWithText:self.keyType==KDSGWKeyTypePIN ? @"* * * * * * * *" : nm color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    nicknameLabel.textAlignment = NSTextAlignmentCenter;
    self.nicknameLabel = nicknameLabel;
    [self.view addSubview:nicknameLabel];
    [nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.keyType==KDSGWKeyTypePIN ? view : view.mas_bottom).offset(self.keyType==KDSGWKeyTypePIN ? 73 : 22);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.layer.cornerRadius = 22;
    deleteBtn.backgroundColor = KDSRGBColor(0xff, 0x3b, 0x30);
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    switch (self.keyType)
    {
        case KDSGWKeyTypeReserved:
            [deleteBtn setTitle:Localized(@"deleteUser") forState:UIControlStateNormal];
            ((UIImageView*)view).image = [UIImage imageNamed:@"member"];
            break;
            
        case KDSGWKeyTypePIN:
            [deleteBtn setTitle:Localized(@"deletePassword") forState:UIControlStateNormal];
            break;
            
        case KDSGWKeyTypeFingerprint:
            [deleteBtn setTitle:Localized(@"deleteFingerprint") forState:UIControlStateNormal];
            ((UIImageView*)view).image = [UIImage imageNamed:@"bigFingerprint"];
            break;
            
        case KDSGWKeyTypeRFID:
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
    cornerView.hidden = self.keyType != KDSGWKeyTypeReserved;
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
    
    self.lock.bleTool.dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    UILabel *timeLabel = [self createLabelWithText:[self.lock.bleTool.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:createTime]] color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    if (self.keyType == KDSGWKeyTypeReserved)
    {
        KDSAuthCatEyeMember *member = self.model;
        timeLabel.text = [member.time componentsSeparatedByString:@"."].firstObject ?: member.time;
    }
    [cornerView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separatorView.mas_bottom);
        make.left.equalTo(tLabel.mas_right).offset(kScreenWidth<375 ? 26 : 37);
        make.right.equalTo(cornerView).offset(kScreenWidth<375 ? 26 : 37);
        make.height.equalTo(@50);
    }];
    
    self.editBtn = [UIButton new];
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.editBtn addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
    self.editBtn.hidden = YES;
    self.editBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [self.view addSubview:self.editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
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
        case KDSGWKeyTypeReserved:
            title = Localized(@"ensureDeleteUser?");
            break;
            
        case KDSGWKeyTypePIN:
            title = Localized(@"ensureDeletePassword?");
            break;
            
        case KDSGWKeyTypeFingerprint:
            title = Localized(@"ensureDeleteFingerprint?");
            break;
            
        case KDSGWKeyTypeRFID:
            title = Localized(@"ensureDeleteCard?");
            break;
            
        default:
            break;
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.keyType == KDSGWKeyTypeReserved)
        {
            [weakSelf deleteAuthMember:weakSelf.model];
        }
        else
        {
            [weakSelf deleteGWLock];
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
        case KDSGWKeyTypeReserved:
            title = Localized(@"pleaseInputUserName");
            break;
            
        case KDSGWKeyTypePIN:
            title = Localized(@"pleaseInputPasswordName");
            break;
            
        case KDSGWKeyTypeFingerprint:
            title = Localized(@"pleaseInputFingerprintName");
            break;
            
        case KDSGWKeyTypeRFID:
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
    KDSAuthCatEyeMember *m = self.model;
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.lock.gw.model device:self.lock.gwDevice userAccount:m.username userNickName:nickname shareFlag:1 type:2 completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            self.editNicknameLabel.text = nickname;
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
        }else{
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
}

///删除授权用户。
- (void)deleteAuthMember:(id)member
{
    KDSAlertController *ac = [KDSAlertController alertControllerWithTitle:Localized(@"deleting") message:nil];
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
    KDSAuthCatEyeMember *m = member ?: self.model;
    [self presentViewController:ac animated:YES completion:^{
        [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.lock.gw.model device:self.lock.gwDevice userAccount:m.username userNickName:m.userNickname shareFlag:0 type:2 completion:^(NSError * _Nullable error, BOOL success) {
            completion(success);
        }];
    }];
}

///删除密码、卡片、指纹。 deleting
- (void)deletePassword:(KDSPwdListModel *)m
{
    
}
///删除网关锁密码
-(void)deleteGWLock
{
    
    KDSPwdListModel *m = self.model;
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    if (m.num == nil) {
        m.num = [NSString stringWithFormat:@"%d",m.userId];
    }
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:2 withPwd:nil number:m.num.intValue type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
        [hud hideAnimated:YES];
        if (success) {
            
            [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
            [[KDSDBManager sharedManager] deletePasswords:@[m] withLock:self.lock.gwDevice];
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            
            [MBProgressHUD showSuccess:Localized(@"deleteFailed")];
        }
      
    }];
}

-(void)editClick:(UIButton *)sender
{
    KDSPwdListModel * pwdModel = [KDSPwdListModel new];
    pwdModel = self.model;
    [self scheduleWithNumber:pwdModel.num.intValue completion:^(NSError * _Nullable error, BOOL success) {
        if (success) {
            [MBProgressHUD showSuccess:@"编辑成功"];
        }else{
            [MBProgressHUD showError:@"编辑失败"];
        }
    }];
    
}

///根据密码编号设置年月日、周计划，完毕执行completion回调。先设置计划->再设置用户类型->最后获取一下是否存在计划(最后一步可选)。
- (void)scheduleWithNumber:(int)number completion:(void(^)(NSError * _Nullable error, BOOL success))completion
{
    KDSGWLockSchedule *schedule = [KDSGWLockSchedule new];
    schedule.scheduleId = schedule.userId = number;
    KDSPwdListModel * pwdModel = [KDSPwdListModel new];
    pwdModel = self.model;
    if (pwdModel.type == KDSServerCycleTpyePeriod) {//时间段
        NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
        schedule.yearAndWeek = @"year";
        schedule.beginTime = @(MQTTTextStarTime - MQTTFixedTime + secondsFromGMT).stringValue;
        schedule.endTime = @(MQTTTextEndTime - MQTTFixedTime + secondsFromGMT).stringValue;

    }else if (pwdModel.type == KDSServerCycleTpyeCycle){//周期
        NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
        fmt.dateFormat = @"HH:mm";
        NSArray<NSString *> *comps = [@"11~22" componentsSeparatedByString:@"~"];
        NSArray<NSString *> *begins = [comps.firstObject componentsSeparatedByString:@":"];
        NSArray<NSString *> *ends = [comps.lastObject componentsSeparatedByString:@":"];
//        schedule.mask = self.mask;
        schedule.yearAndWeek = @"week";
        schedule.beginH = begins.firstObject.intValue;
        schedule.beginMin = begins.lastObject.intValue;
        schedule.endH = ends.firstObject.intValue;
        schedule.endMin = ends.lastObject.intValue;

    }else if (pwdModel.type == KDSServerCycleTpyeTwentyfourHours){//24小时

        NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
        schedule.yearAndWeek = @"year";
        NSInteger interval = NSDate.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT;
        schedule.beginTime = @(interval).stringValue;
        schedule.endTime = @(interval + 24 * 3600).stringValue;
    }

    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:0 withSchedule:schedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
        if (success)
        {
            !completion ?: completion(error, success);
        }
        else
        {
            !completion ?: completion(error, NO);
        }
    }];
}

@end

//
//  KDSPINShareVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/4.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSPINShareVC.h"
#import "KDSHttpManager+Ble.h"
#import "KDSAlertController.h"
#import "MBProgressHUD+MJ.h"
//#import <WechatOpenSDK/WXApi.h>
#import <MessageUI/MessageUI.h>
#import "UIView+Extension.h"
#import "KDSMQTT.h"
#import "KDSDBManager+GW.h"


@interface KDSPINShareVC () <MFMessageComposeViewControllerDelegate>

///label for displaying pin name.
@property (nonatomic, strong) UILabel *editNicknameLabel;
///当前密码标签（胁迫密码的时候会用到）
@property (nonatomic ,strong) NSString * numStr;

@end

@implementation KDSPINShareVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"passwordDetails");
    if (self.model.num.intValue == 9) {
        self.numStr = Localized(@"menacePIN");
    }else{
        self.numStr = @"";
    }
    [self setupUI];
    
}

- (void)setupUI
{
    UILabel *label = [self createLabelWithText:@"" color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];//validation description
    NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
    NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
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
        fmt.dateFormat = @"yyyy/MM/dd HH:mm";
        if (self.lock.gwDevice) {
            label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), @"", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue + MQTTFixedTime -secondsFromGMT]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue + MQTTFixedTime -secondsFromGMT]]];
        }else{
            label.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), @"", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]]];
        }
        
        
    }
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    self.model.schedule = label.text;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 25 : 52);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    NSMutableString *ms = [NSMutableString stringWithCapacity:m.pwd.length * 2 - 2];
    for (int i = 0; i < m.pwd.length; ++i)
    {
        [ms appendFormat:@"%c%@", m.pwd.UTF8String[i], i==m.pwd.length-1 ? @"" : @" "];
    }
    UILabel *pwdLabel = [self createLabelWithText:ms color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:19]];
    pwdLabel.textAlignment = NSTextAlignmentCenter;
    if (pwdLabel.bounds.size.width > kScreenWidth - 40)
    {
        pwdLabel.font = [UIFont systemFontOfSize:19 * (kScreenWidth - 40) / pwdLabel.bounds.size.width];
    }
    [self.view addSubview:pwdLabel];
    [pwdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 76 : 126);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@(pwdLabel.bounds.size.height));
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.layer.cornerRadius = 22;
    deleteBtn.backgroundColor = KDSRGBColor(0xff, 0x3b, 0x30);
    [deleteBtn setTitle:Localized(@"deletePassword") forState:UIControlStateNormal];
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [deleteBtn addTarget:self action:@selector(clickDeleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pwdLabel.mas_bottom).offset(KDSScreenHeight<667 ? 45 : 58);
        make.centerX.equalTo(@0);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
    }];
    
    UIView *cornerView = [UIView new];
    if (self.lock.gwDevice)
    {
        cornerView.hidden = YES;
    }
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
    
    UILabel *nLabel = [self createLabelWithText:Localized(@"name") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:15]];//显示”名称“
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
    
    UILabel *eLabel = [self createLabelWithText:m.nickName color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:17]];//显示密码名称
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
    
    UILabel *tLabel = [self createLabelWithText:Localized(@"authTime") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:15]];//显示”授权时间“
    [cornerView addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separatorView.mas_bottom);
        make.left.equalTo(cornerView).offset(26);
        make.width.equalTo(@(tLabel.bounds.size.width));
        make.height.equalTo(@50);
    }];
    
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    NSTimeInterval serverTimer = [KDSHttpManager sharedManager].serverTime;
    NSDate *date = serverTimer>0 ? [NSDate dateWithTimeIntervalSince1970:serverTimer] : NSDate.date;
    UILabel *timeLabel = [self createLabelWithText:[fmt stringFromDate:date] color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    [cornerView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separatorView.mas_bottom);
        make.left.equalTo(tLabel.mas_right).offset(kScreenWidth<375 ? 26 : 37);
        make.right.equalTo(cornerView).offset(kScreenWidth<375 ? 26 : 37);
        make.height.equalTo(@50);
    }];
    
    UILabel *tipsLabel = [self createLabelWithText:Localized(@"forSecurity,pinOnlyDisplayName") color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0;
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView.mas_bottom).offset(kScreenHeight<667 ? 15 : 33);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    NSArray<UIButton *> *btns = [self createShareButtonsWithTitles:@[Localized(@"shortMessage"), Localized(@"weixin"), Localized(@"copy")] images:@[@"shortMessage", @"weixin", @"pasteboard"]];
    UIButton *weixinBtn = btns[1];
    CGFloat space = (kScreenWidth - weixinBtn.bounds.size.width*3) / 4;
    [weixinBtn addTarget:self action:@selector(clickWeixinBtnShareToWeixin:) forControlEvents:UIControlEventTouchUpInside];
    [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView.mas_bottom).offset(kScreenHeight<667 ? 78 : 96);
        make.centerX.equalTo(@0);
        make.size.mas_equalTo(weixinBtn.bounds.size);
    }];
    
    UIButton *msgBtn = btns.firstObject;
    [msgBtn addTarget:self action:@selector(clickShortMessageBtnSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weixinBtn);
        make.right.equalTo(weixinBtn.mas_left).offset(-space);
        make.size.mas_equalTo(msgBtn.bounds.size);
    }];
    
    UIButton *cpyBtn = btns.lastObject;
    [cpyBtn addTarget:self action:@selector(clickCopyBtnCopyToPasteboard:) forControlEvents:UIControlEventTouchUpInside];
    [cpyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weixinBtn);
        make.left.equalTo(weixinBtn.mas_right).offset(space);
        make.size.mas_equalTo(cpyBtn.bounds.size);
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

- (NSArray<UIButton *> *)createShareButtonsWithTitles:(NSArray<NSString *> *)titles images:(NSArray<NSString *> *)imgNames
{
    CGFloat tWidth = 0;
    UIFont *font = [UIFont systemFontOfSize:12];
    for (NSString *title in titles)
    {
        tWidth = MAX(tWidth, ceil([title sizeWithAttributes:@{NSFontAttributeName : font}].width));
    }
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:titles.count];
    for (int i = 0; i < titles.count; ++i)
    {
        NSString *title = titles[i];
        NSString *imgName = i<imgNames.count ? imgNames[i] : nil;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateHighlighted];
        [btn setTitleColor:KDSRGBColor(0x99, 0x99, 0x99) forState:UIControlStateNormal];
        
        btn.titleLabel.font = font;
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : font}];
        CGFloat iWidth = btn.currentImage.size.width;
        CGFloat width = MAX(iWidth, tWidth);
        btn.bounds = CGRectMake(0, 0, width, iWidth + 7 + ceil(size.height));
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, (width - iWidth) * 0.5, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(iWidth + 7, -iWidth + (width - ceil(size.width)) * 0.5, 0, 0);
        [btns addObject:btn];
        [self.view addSubview:btn];
    }
    
    return btns.copy;
}

#pragma mark - 控件等事件方法。
///点击删除按钮，删除密码、指纹、卡片。
- (void)clickDeleteBtnAction:(UIButton *)sender
{
    NSString *title = Localized(@"ensureDeletePassword?");
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        KDSAlertController *alert = [KDSAlertController alertControllerWithTitle:Localized(@"deleting") message:weakSelf.lock.bleTool ? Localized(@"openBleAndStandByDoorLock") : nil];
        [weakSelf presentViewController:alert animated:YES completion:nil];
        
        KDSPwdListModel *m = weakSelf.model;
        if (weakSelf.lock.gwDevice)
        {
            [[KDSMQTTManager sharedManager] dl:weakSelf.lock.gwDevice manageKey:2 withPwd:m.pwd number:m.num.intValue type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
                if (success)
                {
                    alert.title = Localized(@"deleteSuccess");
                    [[KDSDBManager sharedManager] deletePasswords:@[m] withLock:self.lock.gwDevice];
                }
                else
                {
                    alert.title = Localized(@"deleteFailed");
                    alert.titleColor = KDSRGBColor(0xff, 0x3b, 0x30);
                }
                alert.message = nil;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:^{
                        if (error == KDSBleErrorSuccess)
                        {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                });
            }];
            return;
        }
        
        [weakSelf.lock.bleTool manageKeyWithPwd:@"" userId:m.num action:KDSBleKeyManageActionDelete keyType:KDSBleKeyTypePIN completion:^(KDSBleError error) {
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
                    if (error == KDSBleErrorSuccess)
                    {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }];
            });
        }];
        
    }];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
}

///点击编辑按钮编辑昵称。
- (void)clickEditBtnEditNickname:(UIButton *)sender
{
    NSString *title = Localized(@"pleaseInputPasswordName");
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    NSString *placeholder = self.model.nickName;
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

///点击短信按钮，短信发送。
- (void)clickShortMessageBtnSendMessage:(UIButton *)sender
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc]init];
        NSString *string = [NSString stringWithFormat:@"【凯迪仕智能】密码: %@。此密码只能用于凯迪仕智能锁验证开门,%@%@。",self.model.pwd,self.numStr,self.model.schedule];
        controller.body = string;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"notSupportShortMessage") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }

}

///点击微信按钮分享。
- (void)clickWeixinBtnShareToWeixin:(UIButton *)sender
{
    if (![WXApi isWXAppInstalled])
    {
        [MBProgressHUD showError:Localized(@"wechatIsNotInstalled")];
        return;
    }
    NSString *string = [NSString stringWithFormat:@"【凯迪仕智能】密码: %@。此密码只能用于凯迪仕智能锁验证开门,%@%@。",self.model.pwd,self.numStr,self.model.schedule];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = string;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
   
}

///点击复制按钮复制密码到剪贴板。
- (void)clickCopyBtnCopyToPasteboard:(UIButton *)sender
{
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    NSString *string = [NSString stringWithFormat:@"【凯迪仕智能】密码: %@。此密码只能用于凯迪仕智能锁验证开门,%@%@。",self.model.pwd,self.numStr,self.model.schedule];
    [pab setString:string];
    if (pab == nil) {
        [MBProgressHUD showSuccess:Localized(@"copySuccess")];
    }else
    {
        [MBProgressHUD showSuccess:Localized(@"hasCopy")];
    }

}

#pragma mark - 网络请求方法。
///更新昵称。
- (void)updateNickname:(NSString *)nickname
{
    if (nickname.length == 0) return;
    
    if (self.lock.device)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        KDSPwdListModel *m = self.model;
        NSString *name = m.nickName;
        [[KDSHttpManager sharedManager] setBlePwd:m withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:^{
            [hud hideAnimated:NO];
            self.editNicknameLabel.text = nickname;
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
    else
    {
        
    }
}

///删除密码。
- (void)deletePassword:(KDSPwdListModel *)m
{
    if (self.lock.device)
    {
        [[KDSHttpManager sharedManager] deleteBlePwd:@[m] withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:nil error:nil failure:nil];
    }
    else
    {
        
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

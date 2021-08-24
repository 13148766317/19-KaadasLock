//
//  KDSWifiLockKeyDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockKeyDetailsVC.h"
#import "KDSAuthMember.h"
#import "UIView+Extension.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSDBManager.h"

@interface KDSWifiLockKeyDetailsVC ()

///编辑按钮旁边的可编辑的昵称标签。
@property (nonatomic, weak) UILabel *editNicknameLabel;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;

@end

@implementation KDSWifiLockKeyDetailsVC

- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy/MM/dd HH:mm";
    }
    return _dateFmt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

     self.navigationTitleLabel.text = Localized(@"userDetails");
     [self setupUI];
}

- (void)setupUI
{
    KDSAuthMember * model = self.model;
    UIImageView *iv = [UIImageView new];
    iv.image = [UIImage imageNamed:@"member"];
    [self.view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(KDSSSALE_HEIGHT(61));
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@37);
    }];
    UILabel * nameLb = [UILabel new];
    nameLb.textColor = KDSRGBColor(153, 153, 153);
    nameLb.textAlignment = NSTextAlignmentCenter;
    nameLb.text = model.uname;
    nameLb.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:nameLb];
    [nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iv.mas_bottom).offset(KDSSSALE_HEIGHT(26));
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
        
    }];
    
    UIButton * deleteBtn = [UIButton new];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [deleteBtn setTitle:@"删除用户" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleClick:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.backgroundColor = KDSRGBColor(259, 59, 48);
    deleteBtn.layer.masksToBounds = YES;
    deleteBtn.layer.cornerRadius = 22;
    [self.view addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLb.mas_bottom).offset(KDSSSALE_HEIGHT(75));
        make.centerX.equalTo(self.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        
    }];
    
    UIView * tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.masksToBounds = YES;
    tipsView.layer.cornerRadius = 4;
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deleteBtn.mas_bottom).offset(KDSSSALE_HEIGHT(42));
        make.height.equalTo(@100);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
    }];
    UILabel * nickNameTipsLb = [UILabel new];
    nickNameTipsLb.font = [UIFont systemFontOfSize:15];
    nickNameTipsLb.textColor = UIColor.blackColor;
    nickNameTipsLb.text = @"名称";
    nickNameTipsLb.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:nickNameTipsLb];
    [nickNameTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsView.mas_top).offset(0);
        make.left.mas_equalTo(tipsView.mas_left).offset(25);
        make.height.equalTo(@50);
        make.width.equalTo(@50);
    }];
    UIButton * eitBtn = [UIButton new];
    [eitBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [eitBtn addTarget:self action:@selector(clickEditBtnEditNickname:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:eitBtn];
    [eitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsView.mas_top).offset(14);
        make.width.equalTo(@15);
        make.height.equalTo(@19);
        make.right.mas_equalTo(tipsView.mas_right).offset(-15);
    }];
    UILabel * nickNameLb = [UILabel new];
    nickNameLb.font = [UIFont systemFontOfSize:17];
    nickNameLb.textColor = KDSRGBColor(153, 153, 153);
    nickNameLb.textAlignment = NSTextAlignmentCenter;
    nickNameLb.text = model.userNickname;
    self.editNicknameLabel = nickNameLb;
    ///用户的昵称
    [tipsView addSubview:nickNameLb];
    [nickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsView.mas_top).offset(0);
        make.left.mas_equalTo(nickNameTipsLb.mas_right).offset(10);
        make.right.mas_equalTo(eitBtn.mas_left).offset(-10);
        make.height.equalTo(@50);
    }];
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(234, 233, 233);
    [tipsView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(0);
        make.right.mas_equalTo(tipsView.mas_right).offset(0);
        make.top.mas_equalTo(tipsView.mas_top).offset(49.5);
        make.height.equalTo(@0.5);
    }];
    
    UILabel * authorizedTimeTipsLb = [UILabel new];
    authorizedTimeTipsLb.font = [UIFont systemFontOfSize:15];
    authorizedTimeTipsLb.textColor = UIColor.blackColor;
    authorizedTimeTipsLb.textAlignment = NSTextAlignmentLeft;
    authorizedTimeTipsLb.text = @"授权时间";
    [tipsView addSubview:authorizedTimeTipsLb];
    [authorizedTimeTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tipsView.mas_bottom).offset(0);
        make.left.mas_equalTo(tipsView.mas_left).offset(25);
        make.height.equalTo(@50);
        make.width.equalTo(@100);
    }];
    UILabel * authorizedTimeLb = [UILabel new];
    authorizedTimeLb.font = [UIFont systemFontOfSize:17];
    authorizedTimeLb.textColor = KDSRGBColor(153, 153, 153);
    authorizedTimeLb.textAlignment = NSTextAlignmentCenter;
    authorizedTimeLb.text = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.createTime]];
    [tipsView addSubview:authorizedTimeLb];
    [authorizedTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tipsView.mas_bottom).offset(0);
        make.left.mas_equalTo(nickNameTipsLb.mas_right).offset(10);
        make.right.mas_equalTo(eitBtn.mas_left).offset(-10);
        make.height.equalTo(@50);
    }];
    
}

#pragma 点击事件

-(void)deleClick:(UIButton *)sender
{
    NSLog(@"点击了删除用户按钮");
    KDSAuthMember *member = self.model;
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    userMgr.userNickname = [[KDSDBManager sharedManager] queryUserNickname];
    member.adminname = userMgr.userNickname ?: userMgr.user.name;
    NSString *title = Localized(@"Are you sure delete user's rights");
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
        [[KDSHttpManager sharedManager] deleteWifiLockAuthorizedUser:member withUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^{
            [hud hideAnimated:YES];
            [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:Localized(@"deleteFailed")];
        } failure:^(NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:Localized(@"deleteFailed")];
        }];
    }];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
}
-(void)clickEditBtnEditNickname:(UIButton *)sender
{
    NSString *title = Localized(@"pleaseInputUserName");
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

///更新昵称。
- (void)updateNickname:(NSString *)nickname
{
    if (nickname.length == 0) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    KDSAuthMember *member = self.model;
    NSString *name = member.unickname;
    member.unickname = nickname;
    [[KDSHttpManager sharedManager] updateWifiLockAuthorizedUserNickname:member wifiSN:self.lock.wifiDevice.wifiSN success:^{
         [hud hideAnimated:NO];
         self.editNicknameLabel.text = nickname;
         [MBProgressHUD showSuccess:Localized(@"setSuccess")];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:error.localizedDescription];
        member.unickname = name;
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:error.localizedDescription];
        member.unickname = name;
    }];
           
       
    
}



@end

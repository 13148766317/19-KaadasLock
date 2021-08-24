//
//  KDSWifiLockFPDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/28.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockFPDetailsVC.h"
#import "KDSAuthMember.h"
#import "UIView+Extension.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSDBManager.h"

@interface KDSWifiLockFPDetailsVC ()

///编辑按钮旁边的可编辑的昵称标签。
@property (nonatomic, weak) UILabel *editNicknameLabel;
///图片下面的的昵称标签。
@property (nonatomic, weak) UILabel *nicknameLabel;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;

@end

@implementation KDSWifiLockFPDetailsVC

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

    if (self.keyType == KDSBleKeyTypeRFID) {
        self.navigationTitleLabel.text = Localized(@"cardDetails");
    }else if (self.keyType == KDSBleKeyTypeFace){
        self.navigationTitleLabel.text = Localized(@"faceRecognition");
    }else{
        self.navigationTitleLabel.text = Localized(@"fingerprintDetails");
    }
     [self setupUI];
}

- (void)setupUI
{
    KDSPwdListModel * model = self.model;
    UIImageView * iconImg = [UIImageView new];
    switch (model.pwdType) {
        case KDSServerKeyTpyeFingerprint:
            iconImg.image = [UIImage imageNamed:@"bigFingerprint"];
            break;
        case KDSServerKeyTpyeCard:
            iconImg.image = [UIImage imageNamed:@"bigCard"];
            break;
        case KDSServerKeyTpyeFace:
            iconImg.image = [UIImage imageNamed:@"faceRecognition"];
            break;
        default:
            break;
    }
    [self.view addSubview:iconImg];
    [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(61));
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(iconImg.image.size));
    }];
    
    NSString * nickNameStr = [NSString stringWithFormat:@"%02d  %@",model.num.intValue,model.nickName ?: [NSString stringWithFormat:@"%02d",model.num.intValue]];
    UILabel *nicknameLabel = [self createLabelWithText:nickNameStr color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    nicknameLabel.textAlignment = NSTextAlignmentCenter;
    self.nicknameLabel = nicknameLabel;
    [self.view addSubview:nicknameLabel];
    [nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.top.mas_equalTo(iconImg.mas_bottom).offset(KDSSSALE_HEIGHT(31.5));
    }];
    
    UIView * tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.masksToBounds = YES;
    tipsView.layer.cornerRadius = 4;
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nicknameLabel.mas_bottom).offset(KDSSSALE_HEIGHT(90));
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
    nickNameLb.text = model.nickName ?: [NSString stringWithFormat:@"%02d",model.num.intValue];
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


-(void)clickEditBtnEditNickname:(UIButton *)sender
{
    NSString *title;
    if (self.keyType == KDSBleKeyTypeRFID) {
       title = Localized(@"pleaseInputCardName");
    }else{
        title = Localized(@"pleaseInputFingerprintName");
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

///更新昵称。
- (void)updateNickname:(NSString *)nickname
{
    if (nickname.length == 0) return;
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    userMgr.userNickname = [[KDSDBManager sharedManager] queryUserNickname];
    
    KDSPwdListModel * model = self.model;
    NSString * name = model.nickName ?: [NSString stringWithFormat:@"%02d",model.num.intValue];
    model.nickName = nickname;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    [[KDSHttpManager sharedManager] setWifiLockPwd:model withUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN userNickname:userMgr.userNickname ?: userMgr.user.name success:^{
         [hud hideAnimated:NO];
         self.editNicknameLabel.text = nickname;
        self.nicknameLabel.text =  [NSString stringWithFormat:@"%02d  %@",model.num.intValue,nickname];
        [MBProgressHUD showSuccess:Localized(@"setSuccess")];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:error.localizedDescription];
        model.nickName = name;
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:error.localizedDescription];
        model.nickName = name;
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


@end

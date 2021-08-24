//
//  KDSModifyNicknameVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSModifyNicknameVC.h"
#import "KDSDBManager.h"
#import "KDSHttpManager+User.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"

@interface KDSModifyNicknameVC ()

///输入新昵称的文本框。
@property (nonatomic, readwrite, strong) UITextField *nicknameTF;

@property (nonatomic, readwrite, strong) UIView *cornerView;
///取消按钮
@property (nonatomic, readwrite, strong) UIButton *cancleBtn;
///提示：昵称
@property (nonatomic, readwrite, strong) UILabel *nickNameLabe;
@end

@implementation KDSModifyNicknameVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    self.navigationTitleLabel.text = Localized(@"modifyNickname");

    [self.view addSubview:self.cornerView];
    [self.cornerView addSubview:self.nickNameLabe];
    [self.cornerView addSubview:self.nicknameTF];
    [self.cornerView addSubview:self.cancleBtn];

    [self makeMyConstraints];

    UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithTitle:Localized(@"save") style:UIBarButtonItemStyleBordered target:self action:@selector(clickEvent:)];
    myButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = myButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

- (void)makeMyConstraints {
    [self.cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(75);
    }];

    [self.nickNameLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cornerView.mas_left).offset(16);
        make.centerY.mas_equalTo(self.cornerView.mas_centerY).offset(0);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(16);
    }];
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.cornerView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.cornerView.mas_centerY).offset(0);
        make.width.height.mas_equalTo(17);
    }];
    [self.nicknameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nickNameLabe.mas_right).offset(10);
        make.top.mas_equalTo(self.cornerView.mas_top).offset(0);
        make.bottom.mas_equalTo(self.cornerView.mas_bottom).offset(0);
        make.right.mas_equalTo(self.cancleBtn.mas_left).offset(-10);
    }];
}

#pragma mark -- 控件点击事件
///个人信息昵称文本框文字改变后，限制长度不超过16。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

- (void)cancleBtnClick:(UIButton *)sender
{
    self.nicknameTF.text = @"";
}

///保存修改昵称
- (void)clickEvent:(UIBarButtonItem *)sender
{
    if (self.nicknameTF.text.length == 0) {
        [MBProgressHUD showError:Localized(@"Nicknames are not empty")];
        return;
    }
    if ([self.nicknameTF.text isEqualToString:[KDSUserManager sharedManager].userNickname]) {
        [MBProgressHUD showSuccess:Localized(@"No modification nickname")];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    [[KDSHttpManager sharedManager] setUserNickname:self.nicknameTF.text withUid:[KDSUserManager sharedManager].user.uid success:^{
        [self  selectNiceNameFromDBManager];
        [hud hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"modifyNicknameSuccess")];
    } error:^(NSError *_Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"modifyNicknameFailed") stringByAppendingFormat:@": %ld", (long)error.localizedDescription]];
    } failure:^(NSError *_Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"modifyNicknameFailed") stringByAppendingFormat:@"，%@", error.localizedDescription]];
    }];
}

// 从服务器查询修改后的昵称  然后在进行保存
- (void)selectNiceNameFromDBManager {
    [[KDSHttpManager  sharedManager] getUserNicknameWithUid:[KDSUserManager sharedManager].user.uid success:^(NSString *_Nullable nickname) {
        NSLog(@"zhu == nickname ==%@", nickname);
        if (nickname) {
            [[KDSDBManager sharedManager] updateUserNickname:nickname];
            [KDSUserManager sharedManager].userNickname = nickname;
        } 
    } error:^(NSError *_Nonnull error) {
    } failure:^(NSError *_Nonnull error) {
    }];
}

#pragma mark -- Lazy load
- (UIView *)cornerView
{
    if (!_cornerView) {
        _cornerView = ({
            UIView *cornerV = [UIView new];
            cornerV.backgroundColor = UIColor.whiteColor;
            cornerV;
        });
    }
    return _cornerView;
}

- (UITextField *)nicknameTF
{
    if (!_nicknameTF) {
        _nicknameTF = ({
            UITextField *tf = [UITextField new];
            tf.font = [UIFont systemFontOfSize:15];
            tf.placeholder = Localized(@"inputNewNickname");
            [tf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
            tf.backgroundColor = [UIColor clearColor];
            tf.textColor = KDSRGBColor(142, 142, 147);
            tf.textAlignment = NSTextAlignmentLeft;
            tf;
        });
    }

    return _nicknameTF;
}

- (UIButton *)cancleBtn
{
    if (!_cancleBtn) {
        _cancleBtn = ({
            UIButton *cBtn = [UIButton new];
            [cBtn setImage:[UIImage imageNamed:@"取消_icon"] forState:UIControlStateNormal];
            [cBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cBtn.backgroundColor = UIColor.clearColor;
            cBtn;
        });
    }
    return _cancleBtn;
}

- (UILabel *)nickNameLabe
{
    if (!_nickNameLabe) {
        _nickNameLabe = ({
            UILabel *nLb = [UILabel new];
            nLb.text = Localized(@"nickname");
            nLb.font = [UIFont systemFontOfSize:15];
            nLb.textAlignment = NSTextAlignmentLeft;
            nLb.textColor = KDSRGBColor(51, 51, 51);
            nLb;
        });
    }
    return _nickNameLabe;
}

@end

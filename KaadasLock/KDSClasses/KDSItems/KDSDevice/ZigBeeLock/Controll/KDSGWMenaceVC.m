//
//  KDSGWMenaceVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWMenaceVC.h"
#import "KDSGWMenaceCell.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager+User.h"
#import "KDSGWAddPINPermanentVC.h"
#import "KDSGWLockKeyDetailsVC.h"
#import "KDSDBManager+GW.h"



@interface KDSGWMenaceVC () <UITableViewDataSource, UITableViewDelegate>

///密码表头视图。
@property (nonatomic, strong) UIView *pwdHeaderView;
///胁迫密码数组，数组元素是胁迫密码的编号。
@property (nonatomic, strong, nullable) NSArray<KDSPwdListModel *> *menacePwds;
@property (nonatomic, strong)UISwitch *swi;

@end

@implementation KDSGWMenaceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"menaceAlarm");
    UIView *footer = [self footerView];
    footer.hidden = YES;
    [self.view addSubview:footer];
    UIView *cornerView = [UIView new];
    cornerView.clipsToBounds = YES;
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(18);
        make.centerX.equalTo(@0);
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@44);
    }];
    
    UILabel *syncLabel = [UILabel new];
    syncLabel.font = [UIFont systemFontOfSize:12];
    syncLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    syncLabel.text = Localized(@"pwdSync");
    [cornerView addSubview:syncLabel];
    [syncLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cornerView).offset(15);
        make.centerY.equalTo(@0);
    }];
    
    UIButton *syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    syncBtn.layer.cornerRadius = 9.5;
    syncBtn.backgroundColor = UIColor.whiteColor;
    syncBtn.layer.borderWidth = 1;
    syncBtn.layer.borderColor = KDSRGBColor(0x1f, 0x96, 0xf7).CGColor;
    [syncBtn setTitle:Localized(@"synchronize") forState:UIControlStateNormal];
    [syncBtn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
    syncBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    CGSize size = [syncBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : syncBtn.titleLabel.font}];
    [syncBtn addTarget:self action:@selector(clickSyncBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cornerView addSubview:syncBtn];
    [syncBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cornerView).offset(-15);
        make.centerY.equalTo(@0);
        make.width.equalTo(@(MAX(45, size.width + 19)));
        make.height.equalTo(@19);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
//        make.bottom.equalTo(footer.mas_top);
        make.height.mas_equalTo(200);
    }];
    [footer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(self.view);
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(60);
        make.height.equalTo(@155);
    }];
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 75;
    self.tableView.sectionHeaderHeight = 110;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.pwdHeaderView = [self createSectionHeaderWithTitle:Localized(@"menacePIN") action:Localized(@"addPIN") image:@"bigPassword"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    ///先查询推送开关的状态
//     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [[KDSHttpManager sharedManager] getUserGWLockUnlockNotificationWithUid:[KDSUserManager sharedManager].user.uid completion:^(BOOL open) {
//        [hud hideAnimated:YES];
//        self.swi.on = open;
//    } error:^(NSError * _Nonnull error) {
//        [hud hideAnimated:YES];
//        [MBProgressHUD showError:Localized(@"getappNotificationFail")];
//    } failure:nil];
    
    ///先从数据库读取
    NSArray *passwords = [[KDSDBManager sharedManager] queryPasswordsWithLock:self.lock.gwDevice type:99];
    NSMutableArray *pins = [NSMutableArray array];
    for (KDSPwdListModel *m in passwords)
    {
        if (m.pwdType == KDSServerKeyTpyePIN && [m.num isEqualToString:@"09"])
        {
            [pins addObject:m];
        }
    }
    self.menacePwds = pins;
    [self.tableView reloadData];
    if (pins.count == 0) {
        ////数据库没有去请求服务器
        [self getGWMenacePin];
    }
    
}

-(void)getGWMenacePin
{
    //先查密码，指纹卡片等以后再递归查。
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:9 type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status,NSString * _Nullable userType) {
        [hud hideAnimated:YES];
        
        KDSPwdListModel *m = [KDSPwdListModel new];
        m.num = @"09";
        m.pwdType = KDSServerKeyTpyePIN;
        m.type = KDSServerCycleTpyeForever;
        if (success)
        {
            self.menacePwds = @[m];
            [[KDSDBManager sharedManager] insertPasswords:@[m] withLock:self.lock.gwDevice];
        }
        else
        {
            self.menacePwds = nil;
            [[KDSDBManager sharedManager] deletePasswords:@[m] withLock:self.lock.gwDevice];
        }
        [self.tableView reloadData];
    }];
}
///根据功能名称、动作名称和图片名称创建表头视图。
- (UIView *)createSectionHeaderWithTitle:(NSString *)title action:(NSString *)action image:(NSString *)imgName
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 110)];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@40);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    [view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iv.mas_right).offset(15);
        make.centerY.equalTo(@0);
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 22;
    [view addSubview:cornerView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateHighlighted];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn addTarget:self action:@selector(clickAddButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-36);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@44);
    }];
    
    UILabel *actionLabel = [UILabel new];
    actionLabel.text = action;
    actionLabel.font = [UIFont systemFontOfSize:15];
    actionLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    [view addSubview:actionLabel];
    [actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btn.mas_left).offset(-19);
        make.centerY.equalTo(@0);
    }];
    
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(actionLabel).offset(-30);
        make.right.equalTo(btn).offset(20);
        make.centerY.equalTo(@0);
        make.height.equalTo(@44);
    }];
    
    return view;
}

- (UIView *)footerView
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 75 + 80)];
    UIView *whiteBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 75)];
    whiteBgView.backgroundColor = UIColor.whiteColor;
    [footer addSubview:whiteBgView];
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = Localized(@"appNotification");
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    [footer addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(whiteBgView);
        make.left.equalTo(whiteBgView).offset(15);
    }];
    
    self.swi= [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 26, 15)];
    self.swi.onTintColor = KDSRGBColor(69, 150, 240);
    CGFloat width = self.swi.bounds.size.width;
    self.swi.transform = CGAffineTransformMakeScale(sqrt(0.5), sqrt(0.5));
    [self.swi addTarget:self action:@selector(switchOpenOrCloseAppNotification:) forControlEvents:UIControlEventValueChanged];
    [whiteBgView addSubview:self.swi];
    [self.swi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.right.equalTo(whiteBgView).offset(-(15 - (width * (1 - sqrt(0.5))) / 2));
    }];
    
    return footer;
}

#pragma mark - 控件等事件方法。
///点击添加按钮添加胁迫密码等。
- (void)clickAddButtonAction:(UIButton *)sender
{
    //无网络的时候不让添加密码
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        [MBProgressHUD showError:Localized(@"networkNotAvailable")];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:9 type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
        [hud hideAnimated:NO];
        if (success)
        {
            [MBProgressHUD showError:Localized(@"menacePasswordAlreadyExisted")];
        }
        else if (error && error.code == 0)
        {
            KDSGWAddPINPermanentVC *vc = [KDSGWAddPINPermanentVC new];
            vc.lock = self.lock;
            vc.type = 3;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
        }
    }];
}

-(void)clickSyncBtnAction:(UIButton *)sender
{
    //无网络的时候不让添加密码
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        [MBProgressHUD showError:Localized(@"networkNotAvailable")];
        return;
    }
    ////数据库没有去请求服务器
    [self getGWMenacePin];
}

///点击选择控件开启或关闭APP胁迫通知。
- (void)switchOpenOrCloseAppNotification:(UISwitch *)switchBtn
{
     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KDSHttpManager sharedManager] setUserGWLockUnlockNotification:!switchBtn.on withUid:[KDSUserManager sharedManager].user.uid completion:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"setSuccess")];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:Localized(@"setFailed")];
        [switchBtn setOn:!switchBtn.on animated:YES];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:Localized(@"setFailed")];
        [switchBtn setOn:!switchBtn.on animated:YES];
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0 ? self.menacePwds.count : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return section==0 ? self.pwdHeaderView : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSGWMenaceCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSGWMenaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.name = [NSString stringWithFormat:@"%@%@", Localized(@"menacePassword"), @"09"];
    cell.hideSeparator = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL oldFlag = NO;
    if (!oldFlag)
    {
        ///网关锁胁迫密码详情
        KDSGWLockKeyDetailsVC *vc = [KDSGWLockKeyDetailsVC new];
        vc.lock = self.lock;
        vc.keyType = KDSGWKeyTypePIN;
        vc.model = self.menacePwds[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -- Lazy load

- (NSArray<KDSPwdListModel *> *)menacePwds
{
    if (!_menacePwds) {
        _menacePwds = [NSArray array];
    }
    return _menacePwds;
}
@end

//
//  KDSWIfiLockMoreSettingVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/20.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWIfiLockMoreSettingVC.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSHttpManager+WifiLock.h"
#import "UIView+Extension.h"
#import "KDSWifiLockParamVC.h"
#import "KDSConnectedReconnectVC.h"
#import "KDSLockSecurityModeVC.h"
#import "KDSLockLanguageAlterVC.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSAlertController.h"
#import "KDSWFAMModeSpecificationVC.h"
#import "KDSFaceEnergyModeVC.h"
#import "KDSFaceAMModelVC.h"

#import "KDSChangeWifiLockWifiViewController.h"
// 电机外置新增
#import "KDSSetDoorDirectionViewController.h"
#import "KDSSetDoorStrengthViewController.h"
#import "KDSLockedWayViewController.h"
@interface KDSWIfiLockMoreSettingVC ()<UITableViewDataSource, UITableViewDelegate>

///表视图。
@property (nonatomic, strong) UITableView *tableView;
///删除按钮。
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) NSMutableArray *titles;

@end

@implementation KDSWIfiLockMoreSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //26人脸管理，46节能模式
    [self.titles addObjectsFromArray:@[@"设备名称", @"Wi-Fi", @"消息免打扰", @"安全模式"]];
    //门锁方向显示
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@60]) [self.titles addObject:@"开门方向"];
    // 开门力量显示
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@61]) [self.titles addObject:@"开门力量"];
    //上锁方式的显示
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@62]) [self.titles addObject:@"上锁方式"];

    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@11]) [self.titles addObject:@"A-M自动/手动模式"];
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@46]) [self.titles addObject:@"节能模式"];
    [self.titles addObjectsFromArray:@[@"门锁语言", @"静音模式", @"设备信息"]];

    self.navigationTitleLabel.text = Localized(@"systemSetting");
    CGFloat offset = 0;
    if (kStatusBarHeight + kNavBarHeight + 9 * 60 + 84 > kScreenHeight) {
        offset = -44;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;

    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat height = 44;
    CGFloat width = 200;
    self.deleteBtn.layer.cornerRadius = height / 2.0;
    self.deleteBtn.backgroundColor = KDSRGBColor(0xff, 0x3b, 0x30);
    [self.deleteBtn setTitle:Localized(@"deleteDevice") forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.deleteBtn addTarget:self action:@selector(clickDeleteBtnDeleteBindedLock:) forControlEvents:UIControlEventTouchUpInside];
    if (offset > 0) {
        [self.view addSubview:self.deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.centerX.equalTo(self.view);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 132)];
        view.backgroundColor = self.view.backgroundColor;
        self.deleteBtn.frame = (CGRect) { (kScreenWidth - width) / 2, 40, width, height };
        [view addSubview:self.deleteBtn];
        self.tableView.tableFooterView = view;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.title = self.titles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    if ([cell.title isEqualToString:@"设备名称"]) {
        cell.subtitle = self.lock.wifiDevice.lockNickname ? : self.lock.wifiDevice.wifiSN;

        cell.hideSwitch = YES;
    } else if ([cell.title isEqualToString:@"Wi-Fi"]) {
        cell.subtitle = self.lock.wifiDevice.wifiName;
        cell.hideSwitch = YES;
    } else if ([cell.title isEqualToString:@"消息免打扰"]) {
        cell.subtitle = nil;
        cell.hideSwitch = NO;
        cell.switchEnable = YES;
        if (self.lock.wifiDevice.pushSwitch.intValue == 2) {
            ///关闭推送（消息免打扰开启）
            cell.switchOn = YES;
        } else {
            ///开启推送（消息免打扰关闭:1/0）
            cell.switchOn = NO;
        }
        __weak typeof(self) weakSelf = self;
        cell.switchStateDidChangeBlock = ^(UISwitch *_Nonnull sender) {
            [weakSelf switchClickSetNotificationMode:sender];
        };
    } else if ([cell.title isEqualToString:@"安全模式"]) {
        cell.subtitle = nil;
        cell.hideSwitch = YES;
    } else if ([cell.title isEqualToString:@"A-M自动/手动模式"]) {
        cell.subtitle = self.lock.wifiDevice.amMode.intValue == 0 ? @"自动" : @"手动";
        cell.hideSwitch = YES;
    } else if ([cell.title isEqualToString:@"节能模式"]) {
        cell.subtitle = self.lock.wifiDevice.powerSave.intValue == 1 ? @"开启" : @"关闭";
        cell.hideSwitch = YES;
    } else if ([cell.title isEqualToString:@"门锁语言"]) {
        cell.subtitle = [self.lock.wifiDevice.language isEqualToString:@"en"] ? Localized(@"languageEnglish") : Localized(@"languageChinese");
        cell.hideSwitch = YES;
        cell.hideArrow = YES;
    } else if ([cell.title isEqualToString:@"静音模式"]) {
        __weak typeof(self) weakSelf = self;
        cell.subtitle = nil;
        cell.hideSwitch = NO;
        cell.switchEnable = YES;
        if (self.lock.wifiDevice.volume.intValue == 1) {
            ///静音模式开启
            cell.switchOn = YES;
        } else {
            ///静音模式关闭(语音)
            cell.switchOn = NO;
        }
        cell.switchStateDidChangeBlock = ^(UISwitch *_Nonnull sender) {
            [weakSelf switchClickSetLockVolume:sender];
        };
    } else if ([cell.title isEqualToString:@"设备信息"]) {
        cell.subtitle = nil;
        cell.hideSwitch = YES;
    } else if ([cell.title isEqualToString:@"开门方向"]) {
        //   cell.subtitle = @"左开门";
        NSInteger opendir = self.lock.wifiDevice.openDirection;
        NSString *openDirStr = (opendir == 1 ? @"左开门" : @"右开门");
        if (opendir == 1) {
            openDirStr = @"左开门";
        }else if(opendir == 2){
            openDirStr = @"右开门";
        }
        cell.subtitle = openDirStr;
        cell.hideSwitch = YES;
        cell.hideArrow = YES; // 目前只是显示  将箭头去掉
    } else if ([cell.title isEqualToString:@"开门力量"]) {
        NSInteger openforce = self.lock.wifiDevice.openForce;
        NSString *openforceStr = @"";
        if (openforce == 1) {
            openforceStr  = @"低扭力";
        }else if(openforce == 2){
            openforceStr  = @"高扭力";
        }
        cell.subtitle = openforceStr;
        cell.hideSwitch = YES;
        cell.hideArrow = YES;// 目前只是显示  将箭头去掉
    } else if ([cell.title isEqualToString:@"上锁方式"]) {
        NSInteger lockingway = self.lock.wifiDevice.lockingMethod;
        NSString *openwayStr;
        switch (lockingway) {
            case 1:
                openwayStr = @"自动上锁";
                break;
            case 2:
                openwayStr = @"定时5秒";
                break;
            case 3:
                openwayStr = @"定时10秒";
                break;
            case 4:
                openwayStr = @"定时15秒";
                break;
            case 5:
                openwayStr = @"关闭自动上锁";
                break;
            default:
                break;
        }

        cell.subtitle = openwayStr;
        cell.hideSwitch = YES;
        cell.hideArrow = YES;// 目前只是显示  将箭头去掉
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSLockMoreSettingCell *cell = (KDSLockMoreSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.title isEqualToString:@"设备名称"]) {
        [self alterDeviceNickname];
    } else if ([cell.title isEqualToString:@"Wi-Fi"]) {
        KDSChangeWifiLockWifiViewController *change = [KDSChangeWifiLockWifiViewController new];
        change.lock = self.lock;
        [self.navigationController pushViewController:change animated:YES];
    } else if ([cell.title isEqualToString:@"安全模式"]) {
        KDSLockSecurityModeVC *vc = [KDSLockSecurityModeVC new];
        KDSLockMoreSettingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        vc.title = cell.title;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([cell.title isEqualToString:@"A-M自动/手动模式"]) {
        if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@26]) {
            KDSFaceAMModelVC *vc = [KDSFaceAMModelVC new];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            KDSWFAMModeSpecificationVC *vc = [KDSWFAMModeSpecificationVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if ([cell.title isEqualToString:@"节能模式"]) {
        KDSFaceEnergyModeVC *vc = [KDSFaceEnergyModeVC new];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([cell.title isEqualToString:@"门锁语言"]) {
        if (self.lock.wifiDevice) {
            return;
        }
        KDSLockLanguageAlterVC *vc = [KDSLockLanguageAlterVC new];
        vc.language = self.lock.wifiDevice.language;
        vc.lockLanguageDidAlterBlock = ^(NSString *_Nonnull newLanguage) {
            //self.infoModel.language = newLanguage;
        };
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([cell.title isEqualToString:@"设备信息"]) {
        if (self.lock.wifiDevice.productModel == nil) {
            [MBProgressHUD showError:@"暂无设备信息"];
            return;
        }
        KDSWifiLockParamVC *vc = [KDSWifiLockParamVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    } 
}

#pragma mark - 控件等事件方法。
//MARK:点击删除按钮删除绑定的设备。
- (void)clickDeleteBtnDeleteBindedLock:(UIButton *)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"beSureDeleteDevice?") message:Localized(@"deviceWillBeUnbindAfterDelete") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self deleteBindedDevice];
    }];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}

///修改锁昵称。
- (void)alterDeviceNickname
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"inputDeviceName") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
        textField.font = [UIFont systemFontOfSize:13];
        [textField addTarget:weakSelf action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        NSString *newNickname = ac.textFields.firstObject.text;
        if (newNickname.length && ![newNickname isEqualToString:weakSelf.lock.name]) {
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"alteringLockNickname") toView:weakSelf.view];
            [[KDSHttpManager sharedManager] alterWifiBindedDeviceNickname:newNickname withUid:[KDSUserManager sharedManager].user.uid wifiModel:self.lock.wifiDevice success:^{
                [hud hideAnimated:NO];
                [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
                weakSelf.lock.wifiDevice.lockNickname = newNickname;
                [weakSelf.tableView reloadData];
            } error:^(NSError *_Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
            } failure:^(NSError *_Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
            }];
        }
    }];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}

///锁昵称修改文本框文字改变后，限制长度不超过16个字节。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

///点击免打扰cell中的开关时设置锁报警信息本地通知功能或设置wifi锁开锁通知功能
- (void)switchClickSetNotificationMode:(UISwitch *)sender
{
    int switchNumber;
    if (sender.on) {
        switchNumber = 2;
    } else {
        switchNumber = 1;
    }
    NSLog(@"消息免打扰的值：%d", switchNumber);
    [[KDSHttpManager sharedManager] setUserWifiLockUnlockNotification:switchNumber withUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN completion:^{
        [MBProgressHUD showSuccess:Localized(@"setSuccess")];
        self.lock.wifiDevice.pushSwitch = [NSString stringWithFormat:@"%d", switchNumber];
    } error:^(NSError *_Nonnull error) {
        [MBProgressHUD showError:Localized(@"setFailed")];
        [sender setOn:!sender.on animated:YES];
    } failure:^(NSError *_Nonnull error) {
        [MBProgressHUD showError:Localized(@"setFailed")];
        [sender setOn:!sender.on animated:YES];
    }];
}

///点击静音cell中的开关时设置锁的音量，开->锁设置静音，关->锁设置低音。
- (void)switchClickSetLockVolume:(UISwitch *)sender
{
    KDSAlertController *alert = [KDSAlertController alertControllerWithTitle:@"App不可设置，请在锁端设置" message:nil];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
            [sender setOn:!sender.isOn animated:YES];
        }];
    });
    return;
}

///删除绑定的设备
- (void)deleteBindedDevice
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    [[KDSHttpManager sharedManager] unbindWifiDeviceWithWifiSN:self.lock.wifiDevice.wifiSN uid:[KDSUserManager sharedManager].user.uid success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{ @"lock": self.lock }];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError *_Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@", %@", error.localizedDescription]];
    } failure:^(NSError *_Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@", %@", error.localizedDescription]];
    }];
}

#pragma mark 通知

///mqtt上报事件通知。
- (void)wifimqttEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if ([event isEqualToString:MQTTSubEventWifiLockStateChanged]) {
        if ([param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) {
            self.lock.wifiDevice.volume = param[@"volume"];
            self.lock.wifiDevice.language = param[@"language"];
            self.lock.wifiDevice.amMode = param[@"amMode"];
            [self.tableView reloadData];
        }
    }
}

#pragma Lazy --load

- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

@end

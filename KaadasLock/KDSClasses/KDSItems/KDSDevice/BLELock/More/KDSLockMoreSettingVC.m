//
//  KDSLockMoreSettingVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLockMoreSettingVC.h"
#import "Masonry.h"
#import "KDSHttpManager+Ble.h"
#import "KDSLockMoreSettingCell.h"
#import "MBProgressHUD+MJ.h"
#import "KDSLockParamVC.h"
#import "KDSAMModeSpecificationVC.h"
#import "KDSLockLanguageAlterVC.h"
#import "KDSLockSecurityModeVC.h"
#import "KDSHttpManager+User.h"
#import "UIView+Extension.h"
#import "KDSOADVC.h"
#import "KDSDFUVC.h"
#import "KDSBleAssistant.h"
#import "KDSHttpManager+WifiLock.h"


@interface KDSLockMoreSettingVC () <UITableViewDataSource, UITableViewDelegate>

///表视图。
@property (nonatomic, strong) UITableView *tableView;
///删除按钮。
@property (nonatomic, strong) UIButton *deleteBtn;
///门锁信息模型，如果请求成功从蓝牙工具中获取。蓝牙锁初始化时从已提取的属性中赋值音量、手自动模式和语言3个属性。网关锁时暂时也沿用。
@property (nonatomic, strong) KDSBleLockInfoModel *infoModel;
///网关锁是否支持自动上锁模式
@property (nonatomic, assign) BOOL isAutoRelock;
///锁的功能集
@property (nonatomic,strong)NSString *function;

@end

@implementation KDSLockMoreSettingVC

#pragma mark - 生命周期、界面设置相关方法。
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.lock.bleTool.connectedPeripheral)
    {
        self.infoModel = [[KDSBleLockInfoModel alloc] init];
        self.infoModel.language = self.lock.bleTool.connectedPeripheral.language;
        self.infoModel.volume = self.lock.bleTool.connectedPeripheral.volume;
        self.infoModel.lockState = 0 | (self.lock.bleTool.connectedPeripheral.isAutoMode ? 128 : 0);
    }
    
    self.navigationTitleLabel.text = Localized(@"more");
    ///锁的功能集
    self.function = self.lock.lockFunctionSet;

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    CGFloat offset = 0;
    if (kStatusBarHeight + kNavBarHeight + 9*60 + 84 > kScreenHeight)
    {
        offset = -44;
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);//.offset(offset);
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
    if (offset > 0)
    {
        [self.view addSubview:self.deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.centerX.equalTo(self.view);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 132)];
        view.backgroundColor = self.view.backgroundColor;
        self.deleteBtn.frame = (CGRect){(kScreenWidth - width) / 2, 40, width, height};
        [view addSubview:self.deleteBtn];
        self.tableView.tableFooterView = view;
    }
    if (self.lock.bleTool)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleLockDidReport:) name:KDSLockDidReportNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mqttEventNotification:) name:KDSMQTTEventNotification object:nil];
    }
    [self getZigBeeLockInformation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.lock.device) {
        //蓝牙锁
        if (!self.lock.bleTool.connectedPeripheral)
        {
            [MBProgressHUD showError:Localized(@"bleNotConnect")];
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self.lock.bleTool getLockInfo:^(KDSBleError error, KDSBleLockInfoModel * _Nullable infoModel) {
            if (infoModel)
            {
                weakSelf.infoModel = infoModel;
                char defenceMode = ((weakSelf.infoModel.lockState >> 7) & 1);
                weakSelf.lock.bleTool.connectedPeripheral.isAutoMode = defenceMode;
                [weakSelf.tableView reloadData];
            }
        }];
    }
}

///获取zigbee锁的信息：音量、AM、消息免打扰等
-(void)getZigBeeLockInformation
{
    if (self.lock.gwDevice)
    {   //网关锁
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"SynchronizingLockInformationWaiting") toView:self.view];
        if (!self.infoModel) self.infoModel = [[KDSBleLockInfoModel alloc] init];
        [[KDSMQTTManager sharedManager] dlGetVolume:self.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success, int volume) {
            [hud hideAnimated:YES];
            if (success)
            {
                self.infoModel.volume = volume;
                [self.tableView reloadData];
            }else{
                [MBProgressHUD showError:Localized(@"Volume acquisition failure")];
            }
        }];
        [[KDSMQTTManager sharedManager] dlGetAMStatus:self.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success, BOOL automatic) {
            if (success) {
                self.isAutoRelock = YES;
                if (automatic) {
                    self.lock.gwDevice.AMAutoRelockTime = 10;
                }
            }if (error.code == 405) {
                self.isAutoRelock = NO;
            }
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lock.gwDevice)
    {
        return (indexPath.row == 2 || indexPath.row == 3 || indexPath.row==4 || indexPath.row == 8) ? 0.001 : 60;//网关锁不支持安全模式、A-M 自動上鎖,
    }

    if (indexPath.row == 1) {
        return 0.001;//蓝牙锁不支持消息免打扰。
    }
    if (indexPath.row == 3)
    {
        //功能集
        BOOL func = [KDSLockFunctionSet[self.function] containsObject:@11];
        return func ? 60 : 0.001 ;
    }
    return indexPath.row==4 ? 0.001 : 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSArray *titles = @[Localized(@"deviceName"), Localized(@"doNotDisturb"), Localized(@"moreSettingSecurityMode"), Localized(@"Auto/ManualMode"), Localized(@"autoUnlock"), Localized(@"switchLockLanguage"), Localized(@"lockVolume"), Localized(@"deviceInfo"), Localized(@"checkFirmwareUpdate")];
    cell.title = titles[indexPath.row];
    cell.hideSeparator = indexPath.row == titles.count - 1;
    switch (indexPath.row)
    {
        case 0://修改锁昵称
            cell.subtitle = self.lock.device.lockNickName ?: self.lock.gwDevice.nickName;
            cell.hideSwitch = YES;
            break;
            
        case 1://消息免打扰
        {
            NSString *deviceId = self.lock.device.lockName ?: self.lock.gwDevice.deviceId;
            cell.subtitle = nil;
            cell.hideSwitch = NO;
            cell.switchEnable = YES;
            if (self.lock.device) {
                cell.switchOn = ![KDSTool getNotificationOnForDevice:deviceId];
            }if (self.lock.gwDevice) {
                if (self.lock.gwDevice.pushSwitch.intValue == 2) {
                    ///关闭推送（消息免打扰开启）
                    cell.switchOn = YES;
                }else{
                    ///开启推送（消息免打扰关闭:1/0）
                    cell.switchOn = NO;
                }
            }
            __weak typeof(self) weakSelf = self;
            cell.switchStateDidChangeBlock = ^(UISwitch * _Nonnull sender) {
                [weakSelf switchClickSetNotificationMode:sender];
            };
        }
            break;
            
        case 3://自动/手动模式
        {
            __weak typeof(self) weakSelf = self;
            cell.subtitle = nil;
            cell.hideSwitch = NO;
            if (self.lock.gwDevice) {
                if (self.lock.gwDevice.AMAutoRelockTime == 10) {
                    cell.switchOn = YES;
                }else{
                    cell.switchOn = NO;
                }
                
            }else{
                 cell.switchOn = self.lock.bleTool.connectedPeripheral.isAutoMode;
                
                cell.switchEnable = NO;
                
               
            }
           
            cell.switchStateDidChangeBlock = ^(UISwitch * _Nonnull sender) {
                [weakSelf switchClickSetLockAutoMode:sender];
            };
        }
            break;
            
        case 6://音量设置
        {
            __weak typeof(self) weakSelf = self;
            cell.subtitle = nil;
            cell.hideSwitch = NO;
            cell.switchEnable = YES;
            cell.switchOn = self.infoModel.volume == 0;
            cell.switchStateDidChangeBlock = ^(UISwitch * _Nonnull sender) {
                [weakSelf switchClickSetLockVolume:sender];
            };
        }
            break;
            
        default:
            cell.subtitle = nil;
            cell.hideSwitch = YES;
            break;
    }
    cell.clipsToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.lock.device && !self.lock.device.is_admin.boolValue)
    {
        [MBProgressHUD showError:Localized(@"noAuthorization")];
        return;
    }
    if (self.lock.bleTool && !self.lock.bleTool.connectedPeripheral && indexPath.row != 3 && indexPath.row != 0)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    if (![self.lock.gwDevice.device_type isEqualToString:@"kdszblock"]) {
        //蓝牙锁
     if(!self.lock.bleTool.connectedPeripheral.serialNumber)
     {
         [MBProgressHUD showError:Localized(@"bleNotConnect")];
         return;
     }
    }
    
    switch (indexPath.row)
    {
        case 0://修改锁昵称
            [self alterDeviceNickname];
            break;
            
        case 1://消息免打扰
        {
            
        }
            break;
            
        case 2://安全模式
        {
            KDSLockSecurityModeVC *vc = [KDSLockSecurityModeVC new];
            KDSLockMoreSettingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            vc.title = cell.title;
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 3://自动/手动
        {
            
        }
            break;
            
        case 4://自动开锁
        {
            
        }
            break;
            
        case 5://语言切换
        {
            KDSLockLanguageAlterVC *vc = [KDSLockLanguageAlterVC new];
            vc.language = self.infoModel.language;
            vc.lockLanguageDidAlterBlock = ^(NSString * _Nonnull newLanguage) {
                self.infoModel.language = newLanguage;
            };
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
            
        case 6://设置音量
            break;
            
        case 7://锁参数信息
        {
            KDSLockParamVC *vc = [[KDSLockParamVC alloc] init];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 8://固件升级
        {
            ///bleversion==3并且为主用户然后根据蓝牙服务和特征判断支持TI还是P6平台的OTA
            if (self.lock.bleTool.isBinding) {

                 if(self.lock.power < 20){
                    [MBProgressHUD showError:Localized(@"low power cannot OTA")];
                     return;
                }
                //蓝牙本地固件版本号
                NSString *softwareRev = [self parseBluetoothVersion];
        
                if ([self.lock.device.peripheralId isEqualToString:self.lock.bleTool.connectedPeripheral.identifier.UUIDString]
                    &&[self.lock.device.deviceSN isEqualToString:self.lock.bleTool.connectedPeripheral.serialNumber]
                    &&[self.lock.device.softwareVersion isEqualToString:softwareRev]) {
                    //蓝牙连接上才检查固件
                    [self checkBleOTA];
                }else{
                    //服务器无蓝牙UUID，需要更新服务器上蓝牙的UUID
                    [self updateSoftwareVersion];
                }
              
            }
            else{
                 [MBProgressHUD showError:Localized(@"bleNotConnect")];
            }
           
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - KDSBluetoothToolDelegate
- (void)didReceiveDeviceElctInfo:(int)elct
{
    __weak typeof(self) weakSelf = self;
    [self.lock.bleTool getLockInfo:^(KDSBleError error, KDSBleLockInfoModel * _Nullable infoModel) {
        if (infoModel)
        {
            weakSelf.infoModel = infoModel;
            [weakSelf.tableView reloadData];
        }
    }];
}
-(void)hasInBootload{
    KDSLog(@"--{Kaadas}--锁蓝牙已进入bootloadm模式22222");
    [self checkBleOTA];
    
}
#pragma mark - 通知相关方法。
///mqtt上报事件通知。
- (void)mqttEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if ([event isEqualToString:MQTTSubEventDevDel])

    {
        [MBProgressHUD hideHUDForView:self.view];
        NSString *gwSn = param[@"gwId"], *deviceId = param[@"deviceId"];
        if (![gwSn isEqualToString:self.lock.gw.model.deviceSN] || ![deviceId isEqualToString:self.lock.gwDevice.deviceId]) return;
        [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : self.lock}];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

///蓝牙锁操作上报。
- (void)bleLockDidReport:(NSNotification *)noti
{
    CBPeripheral *peripheral = noti.userInfo[@"peripheral"];
    if (peripheral != self.lock.bleTool.connectedPeripheral) return;
    NSData *data = noti.userInfo[@"data"];
    const Byte *bytes = data.bytes;
    if (bytes[5] == 9)
    {
        peripheral.isAutoMode = (bytes[6]>>4) & 0x1;
        [self.tableView reloadData];
    }
}

#pragma mark - 控件等事件方法。
//MARK:点击删除按钮删除绑定的设备。
- (void)clickDeleteBtnDeleteBindedLock:(UIButton *)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"beSureDeleteDevice?") message:Localized(@"deviceWillBeUnbindAfterDelete") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self deleteBindedDevice];
        
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

///点击静音cell中的开关时设置锁的音量，开->锁设置静音，关->锁设置低音。
- (void)switchClickSetLockVolume:(UISwitch *)sender
{
    if (self.lock.bleTool && !self.lock.bleTool.connectedPeripheral)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sender setOn:NO animated:YES];
        });
    }
    else if (self.lock.bleTool && !self.lock.device.is_admin.boolValue)
    {
        [MBProgressHUD showError:Localized(@"noAuthorization")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sender setOn:!sender.on animated:YES];
        });
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"settingLockVolume") toView:self.view];
        if (self.lock.gw)
        {
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice setVolume:sender.on ? 0:1 completion:^(NSError * _Nullable error, BOOL success) {
                [hud hideAnimated:YES];
                if (success)
                {
                    [MBProgressHUD showSuccess:Localized(@"setSuccess")];
                    weakSelf.infoModel.volume = sender.on ? 0 : 1;
                }
                else
                {
                    [MBProgressHUD showError:Localized(@"setFailed")];
                    [sender setOn:!sender.on animated:YES];
                }
            }];
            return;
        }
        [self.lock.bleTool setLockVolume:sender.on ? 0 : 1 completion:^(KDSBleError error) {
            [hud hideAnimated:YES];
            if (error == KDSBleErrorSuccess)
            {
                weakSelf.infoModel.volume = sender.on ? 0 : 1;
                weakSelf.lock.bleTool.connectedPeripheral.volume = sender.on ? 0 : 1;
                [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            }
            else
            {
                [MBProgressHUD showError:[Localized(@"setFailed") stringByAppendingFormat:@": %ld", (long)error]];
                [sender setOn:!sender.on animated:YES];
            }
        }];
    }
}

///点击免打扰cell中的开关时设置锁报警信息本地通知功能或设置网关锁开锁通知功能，开->开启锁报警信息通知，关->关闭锁报警信息通知。
- (void)switchClickSetNotificationMode:(UISwitch *)sender
{
    if (self.lock.gwDevice)
    {
        int switchNumber;
        if (sender.on) {
            switchNumber = 2;
        }else{
            switchNumber = 1;
        }
        [[KDSMQTTManager sharedManager] updateDevPushSwitchWithGw:self.lock.gw.model device:self.lock.gwDevice pushSwitch:switchNumber completion:^(NSError * _Nullable error, BOOL success) {
            if (success) {
                self.lock.gwDevice.pushSwitch = [NSString stringWithFormat:@"%d",switchNumber];
                [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            }else{
                [MBProgressHUD showError:Localized(@"setFailed")];
                [sender setOn:!sender.on animated:YES];
                
            }
        }];
    }
    else
    {
        [KDSTool setNotificationOn:!sender.on forDevice:self.lock.device ? self.lock.device.lockName : self.lock.gwDevice.deviceId];
    }
}

///点击A-M自动上锁cell中的开关时设置锁AM模式，开->自动模式，关->手动模式。
- (void)switchClickSetLockAutoMode:(UISwitch *)sender
{
    
    if (self.lock.gwDevice)
    {
        if (!self.isAutoRelock) {
            [MBProgressHUD showError:Localized(@"AutomaticLocking")];
            [sender setOn:!sender.on animated:YES];
        }else{
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(sender.on ? @"settingLockAutoMode" : @"settingLockManualMode") toView:self.view];
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice setAutoMode:sender.on completion:^(NSError * _Nullable error, BOOL success) {
                [hud hideAnimated:YES];
                if (success) {
                    
                    [MBProgressHUD showSuccess:Localized(@"setSuccess")];
                    self.lock.gwDevice.AMAutoRelockTime = sender.on ? 10 : 0;
                    
                }else{
                    
                    [MBProgressHUD showError:Localized(@"setFailed")];
                    [sender setOn:!sender.on animated:YES];
                }
            }];
        }
        
    }else{
        __weak typeof(self) weakSelf = self;
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(sender.on ? @"settingLockAutoMode" : @"settingLockManualMode") toView:self.view];
        [self.lock.bleTool setLockAutoLockStatus:sender.on ? 0 : 1 completion:^(KDSBleError error) {
            [hud hideAnimated:NO];
            if (error == KDSBleErrorSuccess)
            {
                [MBProgressHUD showSuccess:Localized(@"setSuccess")];
                weakSelf.lock.bleTool.connectedPeripheral.isAutoMode = sender.on;
            }
            else
            {
                [MBProgressHUD showError:Localized(@"setFailed")];
                [sender setOn:!sender.on animated:YES];
            }
        }];
    }
  
    [self.tableView reloadData];
}

#pragma mark - http、mqtt请求相关
///删除绑定的设备
- (void)deleteBindedDevice
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    if (self.lock.gwDevice)
    {
        [[KDSMQTTManager sharedManager] gw:self.lock.gw.model deleteDevice:self.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success) {
            if (error)//成功以上报事件为准
            {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:Localized(@"deleteFailed")];
            }
        }];
        return;
    }
    [[KDSHttpManager sharedManager] deleteBindedDeviceWithUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : self.lock}];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@":%ld", (long)error.code]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@", %@", error.localizedDescription]];
    }];
}

///修改锁昵称。
- (void)alterDeviceNickname
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"inputDeviceName") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
        textField.font = [UIFont systemFontOfSize:13];
        [textField addTarget:weakSelf action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *newNickname = ac.textFields.firstObject.text;
        if (newNickname.length && ![newNickname isEqualToString:weakSelf.lock.name])
        {
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"alteringLockNickname") toView:weakSelf.view];
            if (weakSelf.lock.gwDevice)
            {
                NSString *nn = weakSelf.lock.gwDevice.nickName;
                weakSelf.lock.gwDevice.nickName = newNickname;
                [[KDSMQTTManager sharedManager] updateDeviceNickname:weakSelf.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success) {
                    [hud hideAnimated:YES];
                    if (success)
                    {
                        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
                        weakSelf.lock.gwDevice.nickName = newNickname;
                        [weakSelf.tableView reloadData];
                    }
                    else
                    {
                        [MBProgressHUD showError:Localized(@"saveFailed")];
                        weakSelf.lock.gwDevice.nickName = nn;
                    }
                }];
                return;
            }
            [[KDSHttpManager sharedManager] alterBindedDeviceNickname:newNickname withUid:[KDSUserManager sharedManager].user.uid bleName:weakSelf.lock.device.lockName success:^{
                [hud hideAnimated:YES];
                [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
                weakSelf.lock.device.lockNickName = newNickname;
                [weakSelf.tableView reloadData];
            } error:^(NSError * _Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingFormat:@"%ld", (long)error.localizedDescription]];
            } failure:^(NSError * _Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
            }];
        }
        
    }];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}
/**
 解析蓝牙版本为存数字的字符串以便比较大小
 @return 蓝牙版本
 */
-(NSString *)parseBluetoothVersion{
    
    //截取出字符串后带了\u0000
    //NSString *bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].lastObject;
    NSString *bleVesion ;

    if (!self.lock.bleTool.connectedPeripheral.softwareVer.length) {
        bleVesion = [self.lock.device.softwareVersion componentsSeparatedByString:@"-"].firstObject;
    }else{
        bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].firstObject;
    }

    //去掉NSString中的\u0000
    if (bleVesion.length > 9) {
        //挽救K9S第一版本的字符串带\u0000错误
        bleVesion = [bleVesion substringToIndex:9];
    }
    //去掉NSString中的V
    bleVesion = [bleVesion stringByReplacingOccurrencesOfString:@"V" withString:@""];
    //带T为测试固件
    bleVesion = [bleVesion stringByReplacingOccurrencesOfString:@"T" withString:@""];
    
    return bleVesion;
}
//Unicode 转字符串
- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}
///检查蓝牙固件是否需要升级
- (void)checkBleOTA{
    
    //蓝牙本地固件版本号
    NSString *softwareRev = [self parseBluetoothVersion];
    NSString *deviceSN ;
    if (!self.lock.device.deviceSN.length) {
        deviceSN = self.lock.bleTool.connectedPeripheral.serialNumber ;
    }else{
        deviceSN = self.lock.device.deviceSN ;
    }
        NSLog(@"--{Kaadas}--检查OTA的softwareRev:%@",softwareRev);
        NSLog(@"--{Kaadas}--检查OTA的deviceSN:%@",deviceSN);

    [[KDSHttpManager sharedManager] checkBleOTAWithSerialNumber:deviceSN withCustomer:1 withVersion:softwareRev withDevNum:1 success:^(NSString *URL) {
        NSLog(@"--{Kaadas}--OTA--URL=%@",URL);

        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"newImage") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSLog(@"--{Kaadas}--URL==%@",URL);
            [self chooseOTASolution:URL];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [ac addAction:cancelAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Lock OTA upgrade") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Lock OTA upgrade") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }];

}
//修改设备固件版本
-(void)updateSoftwareVersion{
    
    NSString *softwareVer = self.lock.bleTool.connectedPeripheral.softwareVer;
    if (softwareVer.length > 9) {
        softwareVer = [self.lock.bleTool.connectedPeripheral.softwareVer substringWithRange:NSMakeRange(1,8)];
    }
    if (softwareVer
        && self.lock.device.lockName
        && [KDSUserManager sharedManager].user.uid
        && self.lock.bleTool.connectedPeripheral.serialNumber
        && self.lock.bleTool.connectedPeripheralWithIdentifier.UUIDString) {
        
        [[KDSHttpManager sharedManager] updateSoftwareVersion:softwareVer withDevname:self.lock.device.lockName withUser_id:[KDSUserManager sharedManager].user.uid withDeviceSN:self.lock.bleTool.connectedPeripheral.serialNumber withPeripheralId:self.lock.bleTool.connectedPeripheralWithIdentifier.UUIDString success:^{
            //蓝牙连接上才检查固件
            [self checkBleOTA];

        } error:^(NSError * _Nonnull error) {

            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"NetworkCauseConnectionFailure") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:nil];

        } failure:^(NSError * _Nonnull error) {
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"NetworkCauseConnectionFailure") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:nil];
        }];
    }
    else{
        
        NSLog(@"--{Kaadas}--有数据为空--异常");
    }
    
}
#pragma mark - 选择OTA升级方案
///根据OTA启动服务FFD0和1802，来选择TI、Psco6升级方案
-(void)chooseOTASolution:(NSString *)url{
    
    BOOL hasResetOTAServer = NO;
    for (CBService *service in self.lock.bleTool.connectedPeripheral.services) {
        //检测到OAD启动服务:FFD0 ---> TI方案
        KDSLog(@"--{Kaadas}--service.UUID==%@",service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString: OADResetServiceUUID]) {
            KDSLog(@"--{Kaadas}--检测到OAD启动服务:FFD0->TI方案");
            KDSOADVC *otaVC = [[KDSOADVC alloc]init];
            otaVC.url = url;
            otaVC.lock = self.lock;
            hasResetOTAServer = YES;
            otaVC.isBootLoadModel = YES;
//            [self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
            [self.navigationController pushViewController:otaVC animated:YES];
        }
        else if ([service.UUID.UUIDString isEqualToString: DFUResetServiceUUID]) {
            KDSLog(@"--{Kaadas}--检测到DFU启动服务:1802->P6方案");
            //检测到DFU启动服务:1802->P6方案
            KDSDFUVC *dfuVC = [[KDSDFUVC alloc]init];
            dfuVC.url = url;
            dfuVC.isBootLoadModel = YES;
            dfuVC.lock = self.lock;
            hasResetOTAServer = YES;
//            [self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
            [self.navigationController pushViewController:dfuVC animated:YES];
        }
    }
    //蓝牙升级服务未读取到
    hasResetOTAServer?:[MBProgressHUD showSuccess:@"蓝牙信息获取不完整，请稍后再试"];
}
@end

//
//  KDSMediaLockMoreSettingVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaLockMoreSettingVC.h"
#import "KDSLockMoreSettingCell.h"
#import "UIView+Extension.h"
#import "KDSXMMediaLockLanguageVC.h"
#import "KDSWanderingAlarmVC.h"
#import "KDSFaceWanderingAlarmVC.h"
#import "KDSMediaMessagePushVC.h"
#import "KDSMediaLockParamVC.h"
#import "KDSRealTimeVideoSettingsVC.h"
#import "KDSHttpManager+VideoWifiLock.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSMQTTManager+SmartHome.h"
#import "KDSXMMediaUnlockModeVC.h"
#import "KDSMediaSettingCell.h"
#import "KDSAddVideoWifiLockStep3VC.h"
#import "KDSAutolockPeriodSetingVC.h"
#import "XMP2PManager.h"
#import "XMUtil.h"
// 电机外置新增
#import "KDSSetDoorDirectionViewController.h"
#import "KDSSetDoorStrengthViewController.h"
#import "KDSLockedWayViewController.h"
#import "KDSDisplayScreenBrightnessVC.h"
#import "KDSDisplayScreenBrightnessTimeVC.h"
#import "KDSVoiceLevelVC.h"
#import "KDSDuressPasswordViewController.h"
#import "KDSFaceEnergyModeVC.h"


@interface KDSMediaLockMoreSettingVC ()<UITableViewDataSource, UITableViewDelegate>

///表视图。
@property (nonatomic, strong) UITableView *tableView;
///删除按钮。
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) NSMutableArray * titles;

@property(nonatomic, assign) BOOL isFaceRecognition;

@end

@implementation KDSMediaLockMoreSettingVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.titles addObjectsFromArray:@[@"设备名称",@"WiFi设置",@"开锁验证模式"]];
    
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@32]) [self.titles addObject:@"自动上锁"];
    //上锁方式的显示
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@62]) [self.titles addObject:@"上锁方式"];
   
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@11]) [self.titles addObject:@"A-M自动/手动模式"];

    [self.titles addObjectsFromArray:@[@"门锁语言"]];

    //门锁方向显示
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@60]) [self.titles addObject:@"开门方向"];
    // 开门力量显示
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@61]) [self.titles addObject:@"开门力量"];
    //感应门把手
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@91]) [self.titles addObject:@"感应门把手"];
    //显示屏亮度
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@71]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@72]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@73]) [self.titles addObject:@"显示屏亮度"];
    //显示屏时间
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@74]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@75]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@76]) [self.titles addObject:@"显示屏时间"];
    //人脸识别
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@92]) [self.titles addObject:@"人脸识别"];
    
    self.isFaceRecognition = [KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@26];
    //人脸徘徊报警或者徘徊报警
    self.isFaceRecognition?[self.titles addObject:@"人脸徘徊报警"]:[self.titles addObject:@"徘徊报警"];
    //红外传感器，80～82：AMS传感器，83～85:TDK传感器
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@80]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@81]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@82]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@83]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@84]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@85]
        ) [self.titles addObject:@"红外传感器"];
    //视频模式
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@93]) [self.titles addObject:@"视频模式"];
    //节能模式
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@46]) [self.titles addObject:@"节能模式"];
    
    //胁迫报警
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@90]) [self.titles addObject:@"胁迫报警"];
    //语音设置
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@88]
        ||[KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@94]) [self.titles addObject:@"语音设置"];

    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@17]) [self.titles addObject:@"静音模式"];
    
    //实时视频设置
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@54]) [self.titles addObject:@"实时视频设置"];
    
    
    [self.titles addObjectsFromArray:@[@"设备信息",@"消息推送"]];

    self.navigationTitleLabel.text = Localized(@"systemSetting");
    CGFloat offset = 0;
    if (kStatusBarHeight + kNavBarHeight + 9*60 + 84 > kScreenHeight)
    {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 6) {
//        if(self.isFaceRecognition) {
//            NSString *reuseIdOne = @"人脸徘徊报警";
//            KDSMediaSettingCell *cellOne = [tableView dequeueReusableCellWithIdentifier:reuseIdOne];
//            if (!cellOne) {
//                cellOne = [[KDSMediaSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdOne];
//            }
//            cellOne.title = self.titles[indexPath.row];
//            cellOne.hideSeparator = indexPath.row == self.titles.count - 1;
//            cellOne.clipsToBounds = YES;
//            cellOne.subtitle = self.lock.wifiDevice.hoverAlarm == 1 ? @"开启": @"已关闭";
//            cellOne.explain = NSLocalizedString(@"对逗留人员进行人脸识别，识别失败后抓拍视频并发送报警信息", nil);
//            cellOne.hideSwitch = YES;
//            return cellOne;
//        }else {
//            NSString *reuseIdOne = NSStringFromClass([self class]);
//            KDSMediaSettingCell *cellOne = [tableView dequeueReusableCellWithIdentifier:reuseIdOne];
//            if (!cellOne) {
//                cellOne = [[KDSMediaSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdOne];
//            }
//            cellOne.title = self.titles[indexPath.row];
//            cellOne.hideSeparator = indexPath.row == self.titles.count - 1;
//            cellOne.clipsToBounds = YES;
//            cellOne.subtitle = self.lock.wifiDevice.stay_status == 1 ? @"开启": @"已关闭";
//            cellOne.explain = @"开启后，可摄像头会侦测门外徘徊人员，比较耗电";
//            cellOne.hideSwitch = YES;
//            return cellOne;
//        }
//
//    }else{
        NSString *reuseId = NSStringFromClass([self class]);
        KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        if (!cell)
        {
            cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        }
        cell.title = self.titles[indexPath.row];
        cell.hideSeparator = indexPath.row == self.titles.count - 1;
        cell.clipsToBounds = YES;
        if ([cell.title isEqualToString:@"设备名称"]) {
            cell.subtitle = self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"WiFi设置"]){
            cell.subtitle = self.lock.wifiDevice.wifiName;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"开锁验证模式"]){
            cell.subtitle = self.lock.wifiDevice.safeMode.intValue == 0 ? @"普通模式" : @"安全模式";
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"自动上锁"]){
            cell.subtitle = self.lock.wifiDevice.amMode.intValue == 0 ? @"自动上锁" : @"手动上锁";
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"门锁语言"]){
            cell.subtitle = [self.lock.wifiDevice.language isEqualToString:@"en"] ? Localized(@"languageEnglish") : Localized(@"languageChinese");
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"静音模式"]){
            __weak typeof(self) weakSelf = self;
            cell.subtitle = nil;
            cell.hideSwitch = NO;
            cell.switchEnable = YES;
            cell.hideArrow = NO;
            if (self.lock.wifiDevice.volume.intValue == 1) {
                ///静音模式开启
                cell.switchOn = YES;
            }else{
                ///静音模式关闭(语音)
                cell.switchOn = NO;
            }
            cell.switchStateDidChangeBlock = ^(UISwitch * _Nonnull sender) {
                [weakSelf switchClickSetLockVolume:sender];
            };
        }else if ([cell.title isEqualToString:@"设备信息"]
                  || [cell.title isEqualToString:@"消息推送"]
                  || [cell.title isEqualToString:@"实时视频设置"]
                  || [cell.title isEqualToString:@"胁迫报警"]){
            cell.subtitle = nil;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"人脸徘徊报警"]){
            KDSMediaSettingCell *cellOne = [tableView dequeueReusableCellWithIdentifier:cell.title];
            if (!cellOne) {
                cellOne = [[KDSMediaSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell.title];
            }
            cellOne.title = self.titles[indexPath.row];
            cellOne.hideSeparator = indexPath.row == self.titles.count - 1;
            cellOne.clipsToBounds = YES;
            cellOne.subtitle = self.lock.wifiDevice.hoverAlarm == 1 ? @"开启": @"已关闭";
            cellOne.explain = NSLocalizedString(@"对逗留人员进行人脸识别，识别失败后抓拍视频并发送报警信息", nil);
            cellOne.hideSwitch = YES;
            cell.hideArrow = NO;
            return cellOne;
        }else if ([cell.title isEqualToString:@"徘徊报警"]){
            KDSMediaSettingCell *cellOne = [tableView dequeueReusableCellWithIdentifier:cell.title];
            if (!cellOne) {
                cellOne = [[KDSMediaSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell.title];
            }
            cellOne.title = self.titles[indexPath.row];
            cellOne.hideSeparator = indexPath.row == self.titles.count - 1;
            cellOne.clipsToBounds = YES;
            cellOne.subtitle = self.lock.wifiDevice.stay_status == 1 ? @"开启": @"已关闭";
            cellOne.explain = @"开启后，可摄像头会侦测门外徘徊人员，比较耗电";
            cellOne.hideSwitch = YES;
            cell.hideArrow = NO;
            return cellOne;
        }else if ([cell.title isEqualToString:@"上锁方式"]) {
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
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"开门方向"]) {
            NSInteger opendir = self.lock.wifiDevice.openDirection;
            NSString *openDirStr = @"";
            if (opendir == 1) {
                openDirStr = @"左开门";
            }else if(opendir == 2){
                openDirStr = @"右开门";
            }
            cell.subtitle = openDirStr;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"开门力量"]) {
            NSInteger openforce = self.lock.wifiDevice.openForce;
            NSString *openforceStr = @"";
            if (openforce == 1) {
                openforceStr  = @"低扭力";
            }else if(openforce == 2){
                openforceStr  = @"高扭力";
            }
            cell.subtitle = openforceStr;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"感应门把手"]){
            NSInteger opendir = self.lock.wifiDevice.touchHandleStatus;
            NSString *openDirStr = @"";
            if (opendir == 1) {
                openDirStr  = @"开";
            }else if(opendir == 0){
                openDirStr  = @"关";
            }
            cell.subtitle = openDirStr;
            cell.hideSwitch = YES;
            cell.hideArrow = YES;
        }else if ([cell.title isEqualToString:@"显示屏亮度"]){
            NSInteger opendir = self.lock.wifiDevice.screenLightLevel;
            NSString *openDirStr = opendir == 80 ? @"高" : (opendir == 50 ? @"中" : (opendir == 30 ? @"低" : @"")) ;
            cell.subtitle = openDirStr;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
        }else if ([cell.title isEqualToString:@"显示屏时间"]){
            cell.subtitle = [NSString stringWithFormat:@"%d s",self.lock.wifiDevice.screenLightTime];
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
            
        }else if ([cell.title isEqualToString:@"人脸识别"]){
            NSInteger opendir = self.lock.wifiDevice.faceStatus.intValue;
            NSString *openDirStr = @"";
            if (opendir == 1) {
                openDirStr  = @"开";
            }else if(opendir == 0){
                openDirStr  = @"关";
            }
            cell.subtitle = openDirStr;
            cell.hideSwitch = YES;
            cell.hideArrow = YES;
        }else if ([cell.title isEqualToString:@"红外传感器"]){
            NSInteger opendir = self.lock.wifiDevice.bodySensor;
            NSString *openDirStr = (opendir == 1 ? @"高灵敏" : (opendir == 2 ? @"中灵敏" : (opendir == 3 ? @"低灵敏" : (opendir == 4 ? @"关" : @"")))) ;
            cell.subtitle = openDirStr;
            cell.hideSwitch = YES;
            cell.hideArrow = YES;
        }else if ([cell.title isEqualToString:@"视频模式"]){
            cell.subtitle = self.lock.wifiDevice.powerSave.intValue == 1 ? @"开" : @"关";
            cell.hideSwitch = YES;
            cell.hideArrow = YES;

        }else if ([cell.title isEqualToString:@"胁迫报警"]){
            cell.subtitle = self.lock.wifiDevice.powerSave.intValue == 1 ? @"开" : @"关";
            cell.hideSwitch = YES;
            cell.hideArrow = YES;

        }else if ([cell.title isEqualToString:@"语音设置"]){
            NSInteger opendir = self.lock.wifiDevice.volLevel;
            NSString *openDirStr = (opendir == 0 ?  @"静音" : (opendir == 1 ? @"中音量" : @"高音量")) ;
            cell.subtitle = openDirStr;
            cell.hideSwitch = YES;
            cell.hideArrow = NO;

        }else if ([cell.title isEqualToString:@"节能模式"]) {
            cell.subtitle = self.lock.wifiDevice.powerSave.intValue == 1 ? @"开启" : @"关闭";
            cell.hideSwitch = YES;
        }

        return cell;
//    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 6) {
//        ///徘徊报警
//        if(self.isFaceRecognition) {
//            [self canContinueWithTile:@"人脸徘徊报警"];
//        }else {
//            [self canContinueWithTile:@"徘徊报警"];
//        }
//
//    }else{
        
        KDSLockMoreSettingCell * cell = (KDSLockMoreSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.title isEqualToString:@"设备名称"]) {
            [self alterDeviceNickname];
        }else if ([cell.title isEqualToString:@"WiFi设置"]){
            [self changeWiFiName];
        }else if ([cell.title isEqualToString:@"开锁验证模式"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"自动上锁"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"门锁语言"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"设备信息"]){
            if (self.lock.wifiDevice.productModel == nil) {
                [MBProgressHUD showError:@"暂无设备信息"];
                return;
            }
            KDSMediaLockParamVC * vc = [KDSMediaLockParamVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([cell.title isEqualToString:@"消息推送"]){
            KDSMediaMessagePushVC * vc = [KDSMediaMessagePushVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([cell.title isEqualToString:@"实时视频设置"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"人脸徘徊报警"]){
            [self canContinueWithTile:@"人脸徘徊报警"];
        }else if ([cell.title isEqualToString:@"徘徊报警"]){
            [self canContinueWithTile:@"徘徊报警"];
        }else if ([cell.title isEqualToString:@"上锁方式"]) {
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"开门方向"]) {
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"开门力量"]) {
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"显示屏亮度"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"显示屏时间"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"胁迫报警"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"语音设置"]){
            [self canContinueWithTile:cell.title];
        }else if ([cell.title isEqualToString:@"节能模式"]) {
            KDSFaceEnergyModeVC *vc = [KDSFaceEnergyModeVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
//    }
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
            [[KDSHttpManager sharedManager] alterWifiBindedDeviceNickname:newNickname withUid:[KDSUserManager sharedManager].user.uid wifiModel:self.lock.wifiDevice success:^{
                [hud hideAnimated:NO];
                [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
                weakSelf.lock.wifiDevice.lockNickname = newNickname;
                [weakSelf.tableView reloadData];
            } error:^(NSError * _Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
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

///锁昵称修改文本框文字改变后，限制长度不超过16个字节。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

///点击静音cell中的开关时设置锁的音量，开->锁设置静音，关->锁设置低音。
- (void)switchClickSetLockVolume:(UISwitch *)sender
{
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = [NSString stringWithFormat:@"手机未开启网络，请打开网络再试"];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //                [self.navigationController popViewControllerAnimated:true];
            }];
            [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
        [sender setOn:!sender.on animated:YES];
        return;
    }
    if (self.lock.wifiDevice.powerSave.intValue == 1) {
        
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"锁已开启节能模式，无法设置" message:@"请更换电池或进入管理员模式进行关闭" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        }];
        
        //修改title
        NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"锁已开启节能模式，无法设置"];
        [alertTitleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, alertTitleStr.length)];
        [alerVC setValue:alertTitleStr forKey:@"attributedTitle"];
        
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:@"请更换电池或进入管理员模式进行关闭"];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, alertControllerMessageStr.length)];
        
        [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        
        [alerVC addAction:retryAction];
        [self presentViewController:alerVC animated:YES completion:nil];
        [sender setOn:!sender.on animated:YES];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
    [[XMP2PManager sharedXMP2PManager] connectDevice];
    [XMP2PManager sharedXMP2PManager].XMP2PConnectDevStateBlock = ^(NSInteger resultCode) {
        if (resultCode > 0) {
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                NSString *message = [NSString stringWithFormat:@"无法连接到设备，原因是：%@", [XMUtil checkPPCSErrorStringWithRet:resultCode]];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:true];
                }];
                UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
                    [[XMP2PManager sharedXMP2PManager] connectDevice];
                    [hud showAnimated:YES];
                }];
                [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
                [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
                [controller addAction:cancelAction];
                [controller addAction:retryAction];
                [self presentViewController:controller animated:true completion:nil];
                return;
                
            });
        }
    };
    [XMP2PManager sharedXMP2PManager].XMMQTTConnectDevOutTimeBlock = ^{
        ///超时
        [hud hideAnimated:YES];
        NSString *message = [NSString stringWithFormat:@"连接服务器超时，稍后再试"];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
            [[XMP2PManager sharedXMP2PManager] connectDevice];
            [hud showAnimated:YES];
        }];
        [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        [controller addAction:cancelAction];
        [controller addAction:retryAction];
        [self presentViewController:controller animated:true completion:nil];
        return;
        
    };
    
    [XMP2PManager sharedXMP2PManager].XMMQTTConnectDevStateBlock = ^(BOOL isCanBeDistributed) {
        if (isCanBeDistributed == YES) {
            ///讯美登录MQTT成功
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"MQTT 登录成功");
                int switchNumber;
                if (sender.on) {
                    switchNumber = 1;
                }else{
                    switchNumber = 0;
                }
                [[KDSMQTTManager sharedManager] setLockVolumeWithWf:self.lock.wifiDevice volume:switchNumber completion:^(NSError * _Nullable error, BOOL success) {
                    [hud hideAnimated:YES];
                    if (success) {
                        self.lock.wifiDevice.volume = [NSString stringWithFormat:@"%d",switchNumber];
                        [MBProgressHUD showSuccess:Localized(@"setSuccess")];
                    }else{
                        [MBProgressHUD showError:Localized(@"setFailed")];
                        [sender setOn:!sender.on animated:YES];
                    }
                    [[XMP2PManager sharedXMP2PManager] releaseLive];
                }];
            });
        }else{
            [hud hideAnimated:YES];
            [[XMP2PManager sharedXMP2PManager] releaseLive];
            [MBProgressHUD showError:Localized(@"setFailed")];
            [sender setOn:!sender.on animated:YES];
        }
    };
}

///删除绑定的设备
- (void)deleteBindedDevice
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    [[KDSHttpManager sharedManager] unbindXMMediaWifiDeviceWithWifiSN:self.lock.wifiDevice.wifiSN uid:[KDSUserManager sharedManager].user.uid success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : self.lock}];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@", %@", error.localizedDescription]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@", %@", error.localizedDescription]];
    }];
}

///更换wifi

- (void)changeWiFiName
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:@"跟换WiFi需重新进入添加门锁步骤" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        KDSAddVideoWifiLockStep3VC * vc = [KDSAddVideoWifiLockStep3VC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
    [okAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}

/*自动上锁、门锁语言、开锁验证模式、静音模式等进入这些设置页面需先验证，然后讯美P2P服务是保活状态才可以才发设置*/

- (void)canContinueWithTile:(NSString *)title
{
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = [NSString stringWithFormat:@"手机未开启网络，请打开网络再试"];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
        return;
    }
    if (self.lock.wifiDevice.powerSave.intValue == 1) {
        
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"锁已开启节能模式，无法设置" message:@"请更换电池或进入管理员模式进行关闭" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        //修改title
        NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"锁已开启节能模式，无法设置"];
        [alertTitleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, alertTitleStr.length)];
        [alerVC setValue:alertTitleStr forKey:@"attributedTitle"];
        
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:@"请更换电池或进入管理员模式进行关闭"];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, alertControllerMessageStr.length)];
        
        [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        
        [alerVC addAction:retryAction];
        [self presentViewController:alerVC animated:YES completion:nil];
        return;
    }
    
    if ([title isEqualToString:@"开锁验证模式"]) {
        KDSXMMediaUnlockModeVC *vc = [KDSXMMediaUnlockModeVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"自动上锁"]){
        KDSAutolockPeriodSetingVC *vc = [KDSAutolockPeriodSetingVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"门锁语言"]){
        KDSXMMediaLockLanguageVC *vc = [KDSXMMediaLockLanguageVC new];
        vc.lock = self.lock;
        vc.language = self.lock.wifiDevice.language;
        vc.lockLanguageDidAlterBlock = ^(NSString * _Nonnull newLanguage) {
            self.lock.wifiDevice.language = newLanguage;
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"实时视频设置"]){
        KDSRealTimeVideoSettingsVC * vc = [KDSRealTimeVideoSettingsVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"徘徊报警"]){
        KDSWanderingAlarmVC * vc = [KDSWanderingAlarmVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"人脸徘徊报警"]){
        KDSFaceWanderingAlarmVC * vc = [KDSFaceWanderingAlarmVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"上锁方式"]) {
        KDSLockedWayViewController *lockedMode = [KDSLockedWayViewController new];
        lockedMode.lock = self.lock;
        lockedMode.lockedModeChangeBlock = ^(int newLockedMode){
             self.lock.wifiDevice.lockingMethod = newLockedMode;
           };
        [self.navigationController pushViewController:lockedMode animated:YES];
    }else if ([title isEqualToString:@"开门方向"]) {
        KDSSetDoorDirectionViewController *openDirection = [KDSSetDoorDirectionViewController new];
        openDirection.lock = self.lock;
        openDirection.openDirectionChangeBlock = ^(int newOpenDirection){
            self.lock.wifiDevice.openDirection = newOpenDirection;
            };
        [self.navigationController pushViewController:openDirection animated:YES];
    }else if ([title isEqualToString:@"开门力量"]) {
        KDSSetDoorStrengthViewController *DoorStrength = [KDSSetDoorStrengthViewController new];
        DoorStrength.lock = self.lock;
        DoorStrength.doorStrengthChangeBlock = ^(int newDoorStrength){
            self.lock.wifiDevice.openForce = newDoorStrength;
            };
        [self.navigationController pushViewController:DoorStrength animated:YES];
    }else if ([title isEqualToString:@"显示屏亮度"]){
        KDSDisplayScreenBrightnessVC *screenBrightness = [KDSDisplayScreenBrightnessVC new];
        screenBrightness.lock = self.lock;
        screenBrightness.screenBrightnessChangeBlock = ^(int newScreenBrightness){
            self.lock.wifiDevice.screenLightLevel = newScreenBrightness;
            };
        [self.navigationController pushViewController:screenBrightness animated:YES];

    }else if ([title isEqualToString:@"显示屏时间"]){

        KDSDisplayScreenBrightnessTimeVC *screenBrightnessTime = [KDSDisplayScreenBrightnessTimeVC new];
        screenBrightnessTime.lock = self.lock;
        screenBrightnessTime.screenBrightnessTimeChangeBlock = ^(int newScreenBrightnessSwitch,int newScreenBrightnessTime){
            self.lock.wifiDevice.screenLightSwitch = newScreenBrightnessSwitch;
            self.lock.wifiDevice.screenLightTime = newScreenBrightnessTime;
            };
        [self.navigationController pushViewController:screenBrightnessTime animated:YES];
        
    }else if ([title isEqualToString:@"胁迫报警"]){
        KDSDuressPasswordViewController *duressPasswordVC = [KDSDuressPasswordViewController new];
        duressPasswordVC.lock = self.lock;
        [self.navigationController pushViewController:duressPasswordVC animated:YES];
    }else if ([title isEqualToString:@"语音设置"]){
        KDSVoiceLevelVC *voiceLevelVC = [KDSVoiceLevelVC new];
        voiceLevelVC.lock = self.lock;
        voiceLevelVC.voiceLevelChangeBlock = ^(int newVoiceLevel){
            self.lock.wifiDevice.volLevel = newVoiceLevel;
            };
        [self.navigationController pushViewController:voiceLevelVC animated:YES];
    }
}
#pragma mark 通知

///mqtt上报事件通知。
- (void)wifimqttEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if ([event isEqualToString:MQTTSubEventWifiLockStateChanged]){
        if ([param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]){
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

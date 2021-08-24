//
//  KDSSettingSwithVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/21.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSettingSwithVC.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSAddSwitchVC.h"
#import "KDSSwitchLinkageDetailVC.h"

@interface KDSSettingSwithVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *titles;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;

@end

@implementation KDSSettingSwithVC

- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy/MM/dd";
    }
    return _dateFmt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"设置";
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
    [self.titles addObject:@"设备型号"];
    NSArray * switchArray = self.lock.wifiDevice.switchDev[@"switchArray"];
    for (int i = 0; i < switchArray.count; i ++) {
        NSString * tempName = switchArray[i][@"nickname"];
        [self.titles addObject:tempName.length >0 ? tempName : [NSString stringWithFormat:@"键位%d",i+1]];
    }
    [self.titles addObject:@"MAC地址"];
    //    [self.titles addObject:@"绑定时间"];
    [self.titles addObject:@"更换智能开关"];
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.title = self.titles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    cell.hideSwitch = YES;
    cell.hideArrow = NO;
    NSString *ttt = self.lock.wifiDevice.switchDev[@"createTime"];
    if ([cell.title isEqualToString:@"绑定时间"]) {
        cell.subtitle = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:ttt.intValue]] ?:@"";
        cell.hideArrow = YES;
    }if ([cell.title isEqualToString:@"设备型号"]) {
        cell.subtitle = @"智能开关";
        cell.hideArrow = YES;
    }if ([cell.title isEqualToString:@"MAC地址"]) {
        cell.subtitle = self.lock.wifiDevice.switchDev[@"mac"] ?:@"";
        cell.hideArrow = YES;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.titles.count -1) {
        ///
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"确认更换智能开关？" message:@"新的智能开关需要手动配置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            KDSAddSwitchVC * vc = [KDSAddSwitchVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancel setValue:UIColor.blackColor forKey:@"titleTextColor"];
        [alerVC addAction:cancel];
        [alerVC addAction:ok];
        [self presentViewController:alerVC animated:YES completion:nil];
    }
    NSArray * switchArray = self.lock.wifiDevice.switchDev[@"switchArray"];
    if (indexPath.row !=0 && indexPath.row  <= switchArray.count) {
        [self setUpDateSwitchNickName:switchArray[indexPath.row -1][@"nickname"] ?: [NSString stringWithFormat:@"键位%ld",indexPath.row +1] type:(int)indexPath.row];
    }
}

///type键位，nickName原昵称
-(void)setUpDateSwitchNickName:(NSString *)nickName type:(int)type
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"请输入键位%d名称",type] message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    NSString *placeholder = nickName;
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:12];
        textField.placeholder = placeholder;
        [textField addTarget:weakSelf action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
        NSMutableArray * switchNicknameArr = [[NSMutableArray alloc] init];
        NSDictionary * dict =@{@"type":@(type),@"nickname":ac.textFields.firstObject.text};
        [switchNicknameArr addObject:dict];
        [[KDSHttpManager sharedManager] updateSwitchNickname:switchNicknameArr withUid:[KDSUserManager sharedManager].user.uid wifiModel:weakSelf.lock.wifiDevice success:^{
            [hud hideAnimated:NO];
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [weakSelf.titles replaceObjectAtIndex:type withObject:ac.textFields.firstObject.text];
            [weakSelf.tableView reloadData];
            NSMutableDictionary * tempDict = [NSMutableDictionary dictionaryWithDictionary:weakSelf.lock.wifiDevice.switchDev[@"switchArray"][type-1]];
            tempDict[@"nickname"] = ac.textFields.firstObject.text;
            NSMutableArray * switchArray = [NSMutableArray array];
            [switchArray addObjectsFromArray:weakSelf.lock.wifiDevice.switchDev[@"switchArray"]];
            [switchArray replaceObjectAtIndex:type -1 withObject:tempDict];
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"switchEn":self.lock.wifiDevice.switchDev[@"switchEn"],@"switchArray":switchArray,@"mac":self.lock.wifiDevice.switchDev[@"mac"],@"updateTime":self.lock.wifiDevice.switchDev[@"updateTime"],@"total":self.lock.wifiDevice.switchDev[@"total"]}];
            weakSelf.lock.wifiDevice.switchDev = dict;
        } error:^(NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:[Localized(@"setFailed") stringByAppendingString:error.localizedDescription]];
        } failure:^(NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:[Localized(@"setFailed") stringByAppendingString:error.localizedDescription]];
        }];
    }];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
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
            [self.tableView reloadData];
        }
    }
}

- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

///编辑昵称时输入框文字改变。
- (void)textFieldTextChanged:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

-(void)navBackClick{
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSSwitchLinkageDetailVC class]]) {
            KDSSwitchLinkageDetailVC * vc = (KDSSwitchLinkageDetailVC *)controller;
            vc.isRefreshPage = YES;
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

@end

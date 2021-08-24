//
//  KDSWanderingAlarmVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSWanderingAlarmVC.h"
#import "KDSMediaLockPIRSensitivityVC.h"
#import "KDSMediaSettingCell.h"
#import "KDSMediaWanderingTimeVC.h"
#import "XMP2PManager.h"
#import "XMUtil.h"
#import "KDSMQTTManager+SmartHome.h"

@interface KDSWanderingAlarmVC ()<UITableViewDataSource, UITableViewDelegate>
///表视图。
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * titles;
/// 菊花loading
//@property (nonatomic, strong)UIActivityIndicatorView *indicatorView;
///PIR徘徊判定的时间：10~60秒
@property (nonatomic,assign)int WanderingTimeNum;
///PIR灵敏度：0~100
@property (nonatomic,assign)int PIRSensitivityNum;
///徘徊检测开关状态(0/1)
@property (nonatomic,assign)int stay_status;
///服务器原始PIR数据
@property (nonatomic,strong)NSDictionary * setPir;

@end

@implementation KDSWanderingAlarmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"徘徊报警";
    [self.titles addObjectsFromArray:@[@"徘徊报警",@"探测距离选择",@"判定时间选择"]];
    [self setUI];
}
- (void)setUI
{
    NSDictionary * dic = self.lock.wifiDevice.setPir;
    NSString * pirNum = [NSString stringWithFormat:@"%@",dic[@"pir_sen"]];
    NSString * stay_time = [NSString stringWithFormat:@"%@",dic[@"stay_time"]];
    self.PIRSensitivityNum = pirNum.intValue;
    self.WanderingTimeNum = stay_time.intValue;
    self.stay_status = self.lock.wifiDevice.stay_status;
    self.setPir = dic;
    
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
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSMediaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSMediaSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.title = self.titles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    if ([cell.title isEqualToString:@"徘徊报警"]){
        cell.subtitle = nil;
        cell.hideSwitch = NO;
        cell.switchEnable = YES;
        cell.switchOn = self.stay_status == 1 ? YES : NO;
        cell.explain = @"开启后，可摄像头会侦测门外徘徊人员，比较耗电";
        __weak typeof(self) weakSelf = self;
        cell.switchXMStateDidChangeBlock = ^(UISwitch * _Nonnull sender) {
            
            [weakSelf setWanderingAlarmStatus:sender];
        };
        
    }else if ([cell.title isEqualToString:@"探测距离选择"]) {
        NSString * pir;
        if (self.PIRSensitivityNum == 90) {
            pir = @"高";
        }else if (self.PIRSensitivityNum == 70){
            pir = @"中";
        }else{
            pir = @"低";
        }
        cell.subtitle = pir;
        cell.hideSwitch = YES;
        cell.explain = @"远距离会增加频繁检测距离，导致耗电";
    }else if ([cell.title isEqualToString:@"判定时间选择"]){
        cell.subtitle = [NSString stringWithFormat:@"%d秒",self.WanderingTimeNum];
        cell.explain = @"判定时间不宜太短，防止误报";
        cell.hideSwitch = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSMediaSettingCell * cell = (KDSMediaSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.title isEqualToString:@"探测距离选择"]) {
        KDSMediaLockPIRSensitivityVC * vc = [KDSMediaLockPIRSensitivityVC new];
        vc.lock = self.lock;
        vc.didSelectPIRSensitivityBlock = ^(int PIRSensitivityNum) {
            self.PIRSensitivityNum = PIRSensitivityNum;
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.title isEqualToString:@"判定时间选择"]){
        KDSMediaWanderingTimeVC * vc = [KDSMediaWanderingTimeVC new];
        vc.lock = self.lock;
        vc.didSelectWanderingTimeBlock = ^(int WanderingTimeNum) {
            self.WanderingTimeNum = WanderingTimeNum;
            [self.tableView reloadData];
        };
    
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)setWanderingAlarmStatus:(UISwitch *)sender
{
    if (sender.on) {
        self.stay_status = 1;
    }else{
        self.stay_status = 0;
    }
}

- (void)navBackClick
{
    NSDictionary * setPirDic = self.lock.wifiDevice.setPir;
    NSString * stay_time = setPirDic[@"stay_time"];
    NSString * pir_sen = setPirDic[@"pir_sen"];
    if (stay_time.intValue == self.WanderingTimeNum && pir_sen.intValue == self.PIRSensitivityNum && self.stay_status == self.lock.wifiDevice.stay_status) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"正在设置徘徊报警，请稍等。。。" toView:self.view];
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
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                dic[@"stay_time"] = @(self.WanderingTimeNum);
                dic[@"pir_sen"] = @(self.PIRSensitivityNum);
                [[KDSMQTTManager sharedManager] setCameraPIRSensitivitySettingsWithWf:self.lock.wifiDevice setPir:dic stay_status:self.stay_status completion:^(NSError * _Nullable error, BOOL success) {
                    if (success) {
                        [MBProgressHUD showSuccess:@"设置成功"];
                        self.lock.wifiDevice.setPir = dic;
                        self.lock.wifiDevice.stay_status = self.stay_status;
                    }else{
                        [MBProgressHUD showError:@"设置失败"];
                    }
                    [hud hideAnimated:YES];
                    [[XMP2PManager sharedXMP2PManager] releaseLive];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            });
        }else{
            
            [MBProgressHUD showError:@"设置失败"];
            [hud hideAnimated:YES];
            [[XMP2PManager sharedXMP2PManager] releaseLive];
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
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

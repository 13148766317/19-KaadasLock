//
//  KDSFaceWanderingAlarmVC.m
//  KaadasLock
//
//  Created by Apple on 2021/5/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSFaceWanderingAlarmVC.h"
#import "KDSMediaLockPIRSensitivityVC.h"
#import "KDSMediaSettingCell.h"
#import "KDSCateyeMoreCell.h"
#import "KDSMediaWanderingTimeVC.h"
#import "XMP2PManager.h"
#import "XMUtil.h"
#import "KDSMQTTManager+SmartHome.h"
@interface KDSFaceWanderingAlarmVC ()<UITableViewDataSource, UITableViewDelegate>
///表视图。
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * titles;

//开启报警
@property (nonatomic,assign) BOOL hoverAlarm;
//识别失败报警次数
@property (nonatomic,assign) NSUInteger hoverAlarmLevel;
@property (nonatomic,strong) NSArray *hoverAlarmLevels;

@end

@implementation KDSFaceWanderingAlarmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"人脸徘徊报警";
    [self.titles addObjectsFromArray:@[@"人脸识别失败1次报警",@"人脸识别失败2次报警",@"人脸识别失败3次报警"]];
    
    self.hoverAlarm = self.lock.wifiDevice.hoverAlarm;
    
    if (self.hoverAlarm) {
        self.hoverAlarmLevel = self.lock.wifiDevice.hoverAlarmLevel;
        
    }else {
        self.hoverAlarmLevel = 1;
    }
    [self setUI];
    
    self.hoverAlarmLevels = @[@(2),@(1),@(0)];
}

- (void)setUI
{
    
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hoverAlarm) {
        return 2;
    }else {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else {
        return self.titles.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        NSString *reuseId = @"人脸徘徊报警";
        KDSMediaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        if (!cell)
        {
            cell = [[KDSMediaSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        }
        cell.title = reuseId;
        cell.hideSeparator = YES;
        cell.clipsToBounds = YES;
        
        cell.subtitle = nil;
        cell.hideSwitch = NO;
        cell.switchEnable = YES;
        cell.switchOn = self.hoverAlarm ? YES : NO;
        cell.explain = @"对逗留人员进行人脸识别，识别失败后抓拍视频并发送报警信息";
        __weak typeof(self) weakSelf = self;
        cell.switchXMStateDidChangeBlock = ^(UISwitch * _Nonnull sender) {
            
            [weakSelf setWanderingAlarmStatus:sender];
        };
            
        
        return cell;
    }else {
        KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
        
        if (!cell)
        {
            cell = [[KDSCateyeMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KDSCateyeMoreCell.ID];
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        cell.titleNameLb.text = self.titles[indexPath.row];
        cell.selectBtn.tag = [self.hoverAlarmLevels[indexPath.row] integerValue];
        [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (indexPath.row == [self titleIndexFromHoverAlarmLevel:self.hoverAlarmLevel]) {
            cell.selectBtn.selected = YES;
        }
        else{
            cell.selectBtn.selected = NO;
        }
        
        if (indexPath.row == (self.titles.count -1)) {
            cell.hideSeparator = YES;
        }else {
            cell.hideSeparator = NO;
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 10;
    }else {
        return 0;
    }
    
}

- (void)setWanderingAlarmStatus:(UISwitch *)sender
{
    
    self.hoverAlarm = sender.on;

    
    [self.tableView reloadData];
}

- (void)navBackClick
{
    
    if (self.hoverAlarm == self.lock.wifiDevice.hoverAlarm && self.hoverAlarmLevel == self.lock.wifiDevice.hoverAlarmLevel) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"正在设置人脸徘徊报警，请稍等。。。" toView:self.view];
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
                    [weakSelf.navigationController popViewControllerAnimated:true];
                }];
                UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [XMP2PManager sharedXMP2PManager].model = weakSelf.lock.wifiDevice;
                    [[XMP2PManager sharedXMP2PManager] connectDevice];
                    [hud showAnimated:YES];
                }];
                [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
                [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
                [controller addAction:cancelAction];
                [controller addAction:retryAction];
                [weakSelf presentViewController:controller animated:true completion:nil];
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
            [weakSelf.navigationController popViewControllerAnimated:true];
        }];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [XMP2PManager sharedXMP2PManager].model = weakSelf.lock.wifiDevice;
            [[XMP2PManager sharedXMP2PManager] connectDevice];
            [hud showAnimated:YES];
        }];
        [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        [controller addAction:cancelAction];
        [controller addAction:retryAction];
        [weakSelf presentViewController:controller animated:true completion:nil];
        return;
        
    };
    [XMP2PManager sharedXMP2PManager].XMMQTTConnectDevStateBlock = ^(BOOL isCanBeDistributed) {
        if (isCanBeDistributed == YES) {
            ///讯美登录MQTT成功
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"MQTT 登录成功");
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                dic[@"hoverAlarm"] = @(weakSelf.hoverAlarm ? 1 : 0 );
                dic[@"hoverAlarmLevel"] = @(weakSelf.hoverAlarmLevel);
                
                [[KDSMQTTManager sharedManager] setLockWithWf:weakSelf.lock.wifiDevice hoverAlarm:weakSelf.hoverAlarm hoverAlarmLevel:weakSelf.hoverAlarmLevel completion:^(NSError * _Nullable error, BOOL success) {
                    if (success) {
                        [MBProgressHUD showSuccess:@"设置成功"];
                        weakSelf.lock.wifiDevice.hoverAlarm = weakSelf.hoverAlarm;
                        weakSelf.lock.wifiDevice.hoverAlarmLevel = weakSelf.hoverAlarmLevel;
                    }else{
                        [MBProgressHUD showError:@"设置失败"];
                    }
                    //[hud hideAnimated:YES];
                    [[XMP2PManager sharedXMP2PManager] releaseLive];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];

                
                
            });
        }else{

            [MBProgressHUD showError:@"设置失败"];
            [hud hideAnimated:YES];
            [[XMP2PManager sharedXMP2PManager] releaseLive];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    };
}

-(void)selectBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
//    [KDSUserDefaults setObject:[NSString stringWithFormat:@"%ld",sender.tag] forKey:@"lastSelectResolution"];
    self.hoverAlarmLevel = sender.tag;
    [self.tableView reloadData];
   
   
}

#pragma Lazy --load

- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

//获取人脸徘徊报警对应标题序号
-(NSInteger) titleIndexFromHoverAlarmLevel:(NSUInteger) hoverAlarmLevel {
    
    __block NSUInteger result = NSNotFound;
    
    [self.hoverAlarmLevels enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj unsignedIntegerValue] == hoverAlarmLevel) {
            result = idx;
            *stop = YES;
        }
        
    }];
    return result;
}

@end

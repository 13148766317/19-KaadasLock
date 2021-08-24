//
//  KDSBleSearchTableVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBleSearchTableVC.h"
#import "Masonry.h"
#import "KDSHttpManager+Ble.h"
#import "KDSBleInfoCell.h"
#import "MBProgressHUD+MJ.h"
#import "KDSBleBindVC.h"
#import "KDSBLEBindHelpVC.h"
#import "KDSDBManager.h"

@interface KDSBleSearchTableVC () <KDSBluetoothToolDelegate, UITableViewDataSource, UITableViewDelegate>
{
    KDSBluetoothTool *_bleTool;
}

///搜索动画视图。
@property (nonatomic, strong) UIImageView *animationIV;
///搜索提示标签。
@property (nonatomic, strong) UILabel *label;
///重新搜索按钮。
@property (nonatomic, strong) UIButton *searchBtn;
///已绑定的蓝牙，从服务器获取，重新请求时清除。
@property (nonatomic, strong) NSArray<MyDevice *> *devices;
///搜索到的蓝牙，重新搜索时清除数据。
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralsArr;
///动画定时器。
@property (nonatomic, strong) NSTimer *animationTimer;
///仿射变换偏转角弧度，默认0.
@property (nonatomic, assign) CGFloat deflectionRadian;
///仿射变换偏半径，默认20.
@property (nonatomic, assign) CGFloat deflectionRadius;

@end

@implementation KDSBleSearchTableVC

#pragma mark - getter setter
- (KDSBluetoothTool *)bleTool
{
    if (!_bleTool)
    {
        _bleTool = [[KDSBluetoothTool alloc] initWithVC:self];
    }
    return _bleTool;
}

- (NSMutableArray<CBPeripheral *> *)peripheralsArr
{
    if (!_peripheralsArr)
    {
        _peripheralsArr = [NSMutableArray array];
    }
    return _peripheralsArr;
}

- (NSTimer *)animationTimer
{
    if (!_animationTimer)
    {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30 target:self selector:@selector(animationTimerActionChangeAnimationIVTransform:) userInfo:nil repeats:YES];
    }
    return _animationTimer;
}

#pragma mark - 生命周期、界面设置方法
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.deflectionRadian = 0;
    self.deflectionRadius = 20;
    self.navigationTitleLabel.text = Localized(@"addBLEDoorLock");
    self.animationIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bluetoothSearch"]];
    [self.view addSubview:self.animationIV];
    [self.animationIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight < 667 ? 49 : 89);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(self.animationIV.image.size);
    }];
    
    self.label = [[UILabel alloc] init];
    self.label.text = Localized(@"searchingNearbyBle");
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.animationIV.mas_bottom).offset(kScreenHeight < 667 ? 20 : 35);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName : self.label.font}].height));
    }];
    
    self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchBtn.layer.cornerRadius = 22;
    self.searchBtn.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    [self.searchBtn setTitle:Localized(@"searchAgain") forState:UIControlStateNormal];
    [self.searchBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.searchBtn.titleLabel.font = [UIFont systemFontOfSize:15    ];
    [self.searchBtn addTarget:self action:@selector(searchNearbyBleAgain:) forControlEvents:UIControlEventTouchUpInside];
    //self.searchBtn.hidden = YES;
    [self.view addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-KDSSSALE_HEIGHT(50));
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).offset(kScreenHeight < 667 ? 25 : 51);
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.searchBtn.mas_top).offset(kScreenHeight < 667 ? -50 : -86);
        make.right.equalTo(self.view).offset(-15);
    }];
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 4;
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //导航栏帮助按钮。
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showDeviceBleSearchHelp:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    self.devices = [[KDSDBManager sharedManager] queryBindedDevices];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.bleTool.connectedPeripheral)
    {
        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    }
    self.bleTool.delegate = self;
    [self startSearchingAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if (index == NSNotFound)
    {
        [self stopSearchingAnimation];
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

///开始搜索动画。
- (void)startSearchingAnimation
{
    self.deflectionRadian = M_PI_4 * 3;
    //self.animationIV.transform = CGAffineTransformMake(1, 0, 0, 1, -self.deflectionRadius * sin(self.deflectionRadian), self.deflectionRadius * cos(self.deflectionRadian));
    //self.animationTimer.fireDate = [NSDate date];
    [self getBindedDeviceList];
    [self.bleTool beginScanForPeripherals];
    self.label.text = Localized(@"searchingNearbyBle");
}

///结束搜索动画。
- (void)stopSearchingAnimation
{
    //self.animationTimer.fireDate = [NSDate distantFuture];
    //self.animationIV.transform = CGAffineTransformIdentity;
    [self.bleTool stopScanPeripherals];
    self.searchBtn.hidden = NO;
    self.label.text = nil;
}

#pragma mark - 控件等事件方法。
///重新搜索蓝牙
- (void)searchNearbyBleAgain:(UIButton *)sender
{
    [self.peripheralsArr removeAllObjects];
    [self.tableView reloadData];
    [self startSearchingAnimation];
}

///显示设备蓝牙搜索帮助界面。
- (void)showDeviceBleSearchHelp:(UIButton *)sender
{
    KDSBLEBindHelpVC *vc = [[KDSBLEBindHelpVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

///启动定时器时改变动画视图的转置矩阵。
- (void)animationTimerActionChangeAnimationIVTransform:(NSTimer *)timer
{
    self.deflectionRadian += M_PI / 25;
    self.animationIV.transform = CGAffineTransformMake(1, 0, 0, 1, -self.deflectionRadius * sin(self.deflectionRadian), self.deflectionRadius * cos(self.deflectionRadian));
}

#pragma mark - 网络请求相关方法
///从服务器获取账号下绑定的设备列表。
- (void)getBindedDeviceList
{
    self.devices = nil;
    [[KDSHttpManager sharedManager] getBindedDeviceListWithUid:[KDSUserManager sharedManager].user.uid success:^(NSArray<MyDevice *> * _Nonnull devices) {
        self.devices = devices;
    } error:^(NSError * _Nonnull error) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
/**
 *@abstract 检查设备是否已被其它账号绑定，并重置或绑定。
 *@param peripheral 外设。
 */
//MARK:检查设备是否已被其它账号绑定，并重置或绑定
- (void)checkBleDeviceBindingStatus:(CBPeripheral *)peripheral
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"checkingBleBindingStatus") toView:self.view];
    [[KDSHttpManager sharedManager] checkBleDeviceBindingStatusWithBleName:peripheral.advDataLocalName uid:[KDSUserManager sharedManager].user.uid success:^(int status, NSString * _Nullable account) {
        [hud hideAnimated:YES];
        if (status == 201)
        {
            KDSBleBindVC *vc = [[KDSBleBindVC alloc] init];
            vc.bleTool = self.bleTool;
            vc.bleTool.delegate = vc;
            vc.destPeripheral = peripheral;
            vc.model = self.model;
            vc.step = 1;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            NSRange range = [account rangeOfString:@"@" options:NSBackwardsSearch];
            if (range.length > 0)
            {
                account = [NSString stringWithFormat:@"%@***%@", [account substringToIndex:range.location>2 ? 3 : range.location], [account substringFromIndex:range.location]];
            }
            else
            {
                if (account.length > 6)
                {
                    account = [NSString stringWithFormat:@"%@***%@", [account substringToIndex:3], [account substringFromIndex:account.length - 3]];
                }
            }
            NSString *message = [NSString stringWithFormat:Localized(@"thisDeviceHasBeenBindedBy%@Tips"), account];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                KDSBleBindVC *vc = [[KDSBleBindVC alloc] init];
                vc.bleTool = self.bleTool;
                vc.bleTool.delegate = vc;
                vc.destPeripheral = peripheral;
                vc.hasBinded = YES;
                vc.model = self.model;
                vc.step = 1;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [ac addAction:cancelAction];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:^{
                
            }];
        }
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"error:%ld", (long)error.code]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark - KDSBluetoothToolDelegate
- (void)discoverManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:Localized(@"pleaseOpenBle") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:action];
        [self presentViewController:ac animated:YES completion:^{
            [self stopSearchingAnimation];
        }];
    }
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    if ([self.peripheralsArr containsObject:peripheral]) return;
    [self.peripheralsArr addObject:peripheral];
    [self.tableView reloadData];
}

- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    [self stopSearchingAnimation];
    if (self.peripheralsArr.count == 0)
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"notDiscoverDevices") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"searchAgain") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startSearchingAnimation];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [okAction setValue:KDSRGBColor(0x1f, 0x96, 0xf7) forKey:@"_titleTextColor"];
        [cancelAction setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"_titleTextColor"];
        [ac addAction:cancelAction];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:^{
            
        }];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripheralsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSBleInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSBleInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSString *bleName = self.peripheralsArr[indexPath.row].advDataLocalName;
    cell.bleName = bleName;
    BOOL hasBinded = NO;
    for (MyDevice *device in self.devices)
    {
        if (![device.lockName isEqualToString:cell.bleName]) continue;
        hasBinded = YES;
    }
    cell.hasBinded = hasBinded;
    cell.underlineHidden = indexPath.row == self.peripheralsArr.count - 1;
    __weak typeof(self) weakSelf = self;
    cell.bindBtnDidClickBlock = ^(UIButton * _Nonnull sender) {
        [weakSelf checkBleDeviceBindingStatus:weakSelf.peripheralsArr[indexPath.row]];
    };
    
    return cell;
}

@end

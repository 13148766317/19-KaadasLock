//
//  KDSBleAndWiFiSearchBluToothVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAndWiFiSearchBluToothVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSBleInfoCell.h"
#import "KDSBleAndWiFiDeviceConnectionStep1VC.h"
#import "KDSBleAndWiFiConnectedReconnectVC.h"
#import "KDSHttpManager+Ble.h"
#import "KDSBleBindVC.h"
#import "KDSSearchBleFailVC.h"

@interface KDSBleAndWiFiSearchBluToothVC ()<KDSBluetoothToolDelegate, UITableViewDataSource, UITableViewDelegate>
{
    KDSBluetoothTool *_bleTool;
}

@property (nonatomic,strong)CABasicAnimation * rotateAnimation;
@property (nonatomic,strong)UIImageView * img;
///已绑定的蓝牙，从服务器获取，重新请求时清除。
@property (nonatomic, strong) NSArray<MyDevice *> *devices;
///搜索到的蓝牙，重新搜索时清除数据。
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralsArr;
@property (nonatomic, strong) UIButton * searchBtn;

@end

@implementation KDSBleAndWiFiSearchBluToothVC

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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     
    if (self.bleTool.connectedPeripheral)
    {
        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    }
    [self.peripheralsArr removeAllObjects];
    [self startAnimatingWidthImg:self.img];
    [self.bleTool beginScanForPeripherals];
    self.bleTool.delegate = self;
    self.searchBtn.hidden = YES;
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if (index == NSNotFound)
    {
        [self stopAnimatingWidthImg:self.img];
    }
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 10;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(@400);
    }];
    
    self.img = [UIImageView new];
    self.img.image = [UIImage imageNamed:@"searchBluToothImg"];
    [supView addSubview:self.img];
    [self.img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@260);
        make.centerX.equalTo(supView);
        make.centerY.equalTo(supView);
    }];
    self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.backgroundColor = KDSRGBColor(242, 242, 242);
    [_searchBtn setTitle:@"重新扫描" forState:UIControlStateNormal];
    [_searchBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    _searchBtn.titleLabel.font = [UIFont systemFontOfSize:15    ];
    [_searchBtn addTarget:self action:@selector(searchNearbyBleAgain:) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn.hidden = YES;
    [supView addSubview:_searchBtn];
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(supView.mas_top).offset(10);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(35);
    }];
    
    UIButton * manualAdditionBtn = [UIButton new];
    [manualAdditionBtn setTitle:@"搜索不到该设备，请尝试手动添加" forState:UIControlStateNormal];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:manualAdditionBtn.titleLabel.text];
    NSRange titleRange = {title.length-4,4};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
    [manualAdditionBtn setAttributedTitle:title forState:UIControlStateNormal];
    NSRange btnRange=NSMakeRange(0,11);
    NSRange btnR=NSMakeRange(11,4);
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]range:btnRange];
    [title addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(31, 150, 247) range:btnR];
    [manualAdditionBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [manualAdditionBtn addTarget:self action:@selector(manualAdditionClick:) forControlEvents:UIControlEventTouchUpInside];
    manualAdditionBtn.hidden = YES;
    [supView addSubview:manualAdditionBtn];
    [manualAdditionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(supView.mas_bottom).offset(-20);
        make.centerX.equalTo(supView);
        make.height.equalTo(@20);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(supView.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.right.equalTo(self.view).offset(-15);
    }];
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 20;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 4;
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(void)startAnimatingWidthImg:(UIImageView *)imgView
{
    if([imgView.layer animationForKey:@"rotatianAnimKey"]){
        if (imgView.layer.speed == 1) {
            return;
        }
        imgView.layer.speed = 1;
        imgView.layer.beginTime = 0;
        CFTimeInterval pauseTime = imgView.layer.timeOffset;
        imgView.layer.timeOffset = 0;
        imgView.layer.beginTime = [imgView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
    }else{
        [self addAnimationWidthImg:imgView];
    }
}
-(void)addAnimationWidthImg:(UIImageView *)imgView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue =   [NSNumber numberWithFloat: M_PI *2];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 1.0f;
    animation.autoreverses = NO;
    animation.cumulative = NO;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = FLT_MAX;
    [imgView.layer addAnimation:animation forKey:@"rotatianAnimKey"];
    [self startAnimatingWidthImg:imgView];
}

-(void)stopAnimatingWidthImg:(UIImageView *)imgView
{
    if (imgView.layer.speed == 0) {
        return;
    }
    CFTimeInterval pausedTime = [imgView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    imgView.layer.speed = 0;
    imgView.layer.timeOffset = pausedTime;
}

#pragma mark 控件点击事件

///帮助按钮
-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

///手动添加
-(void)manualAdditionClick:(UIButton *)btn
{
    KDSBleAndWiFiConnectedReconnectVC * vc = [KDSBleAndWiFiConnectedReconnectVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
///重新搜索蓝牙
- (void)searchNearbyBleAgain:(UIButton *)sender
{
    [self.peripheralsArr removeAllObjects];
    [self.tableView reloadData];
    [self startAnimatingWidthImg:self.img];
    [self.bleTool beginScanForPeripherals];
}

#pragma mark - KDSBluetoothToolDelegate
- (void)discoverManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    { //用户的蓝牙未打开
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:Localized(@"pleaseOpenBle") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:action];
        [self presentViewController:ac animated:YES completion:^{
            [self stopAnimatingWidthImg:self.img];
            self.searchBtn.hidden = YES;
        }];
    }
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    if ([self.peripheralsArr containsObject:peripheral]) return;
     self.searchBtn.hidden = YES;
     // 发现蓝牙进行连接
    if (peripheral.lockModelType && peripheral.isBleAndWifi) {
        [self.peripheralsArr addObject:peripheral];
    }
    [self.tableView reloadData];
}

// 停止蓝牙扫描
- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    [self stopAnimatingWidthImg:self.img];
    self.searchBtn.hidden = self.peripheralsArr.count==0 ? YES : NO;
    if (self.peripheralsArr.count == 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.mode =MBProgressHUDModeText;
        hud.detailsLabel.text = @"未搜索到门锁，请重新扫描\n或返回添加设备扫码添加";
        hud.bezelView.backgroundColor = [UIColor blackColor];
        hud.detailsLabel.textColor = [UIColor whiteColor];
        hud.detailsLabel.font = [UIFont systemFontOfSize:15];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            KDSSearchBleFailVC * vc = [KDSSearchBleFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        });
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
//    NSString *bleName = self.peripheralsArr[indexPath.row].advDataLocalName;
//    NSString * bleSerialNumber = self.peripheralsArr[indexPath.row].lockModelType;
    CBPeripheral *p = self.peripheralsArr[indexPath.row];
    cell.bleName = [NSString stringWithFormat:@"%@   %@",p.lockModelType ?: p.advDataLocalName,p.serialNumber.length>0 ? p.serialNumber :@""];
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
            KDSBleAndWiFiDeviceConnectionStep1VC * vc = [KDSBleAndWiFiDeviceConnectionStep1VC new];
            vc.destPeripheral = peripheral;
            vc.bleTool = self.bleTool;
            vc.bleTool.delegate = vc;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            NSString *message = [NSString stringWithFormat:Localized(@"Thedoorlockhasbeenpaired"), account];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:^{
                
            }];
            return;
            
        }
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"error:%ld", (long)error.code]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

@end

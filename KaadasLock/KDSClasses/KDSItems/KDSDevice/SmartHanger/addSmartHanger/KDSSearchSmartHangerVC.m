//
//  KDSSearchSmartHangerVC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/6.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSearchSmartHangerVC.h"
#import "KDSAddSmartHangerFailVC.h"

@interface KDSSearchSmartHangerVC ()<KDSBluetoothToolDelegate, UITableViewDataSource, UITableViewDelegate>
{
    KDSBluetoothTool *_bleTool;
}

@end

@implementation KDSSearchSmartHangerVC

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
    
    self.navigationTitleLabel.text = Localized(@"addDevice");
//    [self setRightButton];
//    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    [self startAnimationWithSearchBle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     
    if (self.bleTool.connectedPeripheral)
    {
        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    }
    [self.peripheralsArr removeAllObjects];
//    [self startAnimationWithSearchBle];
    [self.bleTool beginScanForPeripherals];
    self.bleTool.delegate = self;

    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if (index == NSNotFound)
    {
        [self stopAnimationWithSearchBle];
    }
}
-(void)setUI
{
    UIView *supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 10;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    ///添加晾衣机的logo
    self.addSmartHangerlogoImg = [UIImageView new];
    self.addSmartHangerlogoImg.image = [UIImage imageNamed:@"bleSearchSmartHanger1.png"];
//    self.addSmartHangerlogoImg.backgroundColor = UIColor.yellowColor;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.addSmartHangerlogoImg addGestureRecognizer:tapGesture];
    self.addSmartHangerlogoImg.userInteractionEnabled = NO;
    [supView addSubview:self.addSmartHangerlogoImg];
    [self.addSmartHangerlogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(32);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@177);
        make.width.equalTo(@177);
    }];

    
    self.label = [[UILabel alloc] init];
    self.label.text = Localized(@"searchingNearbySmartHanger");
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    self.label.numberOfLines = 0;
    [supView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addSmartHangerlogoImg.mas_bottom).offset(kScreenHeight < 667 ? 20 : 35);
        make.left.right.equalTo(self.view);
        //make.height.mas_equalTo(ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName : self.label.font}].height));
    }];
    
    [supView addSubview:self.tableView];

    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).offset(20);
        make.left.equalTo(supView).offset(15);
        make.bottom.equalTo(supView.mas_bottom).offset(-20);
        make.right.equalTo(supView).offset(-15);
    }];
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 20;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 4;
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}
//几张图片按顺序切换
- (void)startAnimationWithSearchBle {
    self.addSmartHangerlogoImg.userInteractionEnabled = NO;

    //创建数组
        NSMutableArray *imagesArray = [NSMutableArray new];
        for (int count = 1; count <= 3; count++) {
            NSString *imageName = [NSString stringWithFormat:@"bleSearchSmartHanger%d.png", count];
            UIImage  *image     = [UIImage imageNamed:imageName];
            [imagesArray addObject:image];
        }
    [self.addSmartHangerlogoImg setAnimationImages:imagesArray];
    [self.addSmartHangerlogoImg setAnimationRepeatCount:0];
    [self.addSmartHangerlogoImg setAnimationDuration:2.0f];
    [self.addSmartHangerlogoImg startAnimating];
    
}
- (void)stopAnimationWithSearchBle {
    [self.addSmartHangerlogoImg stopAnimating];
    self.addSmartHangerlogoImg.userInteractionEnabled = YES;

}
-(void) updateUISearching {
    self.label.text = NSLocalizedString(@"searchingNearbySmartHanger", nil);
}
-(void) updateUINoFind {
    ESWeakSelf
 
    dispatch_main_async_safe(^(){
        __weakSelf.label.text = NSLocalizedString(@"未搜索到晾衣机，请重新扫描\n或返回添加设备扫码添加", nil);
    });
}
#pragma mark - 控件等事件方法。
///重新搜索蓝牙
- (void)clickImage
{
    [self.peripheralsArr removeAllObjects];
    [self.tableView reloadData];
    [self startAnimationWithSearchBle];
    [self.bleTool beginScanForPeripherals];
    [self updateUISearching];

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
            [self stopAnimationWithSearchBle];

        }];
    }
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    if ([self.peripheralsArr containsObject:peripheral]) return;

    if (peripheral.lockModelType && peripheral.isBleAndWifi) {
        [self.peripheralsArr addObject:peripheral];
    }
    [self.tableView reloadData];
}

- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    [self stopAnimationWithSearchBle];

    if (self.peripheralsArr.count == 0)
    {
//        [self updateUINoFind];
        [self bindFail];
        
    }
    else{
        
        [NSTimer scheduledTimerWithTimeInterval:180.0f target:self selector:@selector(bindFail) userInfo:nil repeats:NO];
        
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
    KDSSearchSmartHangerCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSSearchSmartHangerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }

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
            KDSSmartHangerConnectedVC * vc = [KDSSmartHangerConnectedVC new];
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

#pragma mark - 绑定失败
-(void)bindFail{
    KDSAddSmartHangerFailVC * AddSmartHangerFailVC = [[KDSAddSmartHangerFailVC alloc] init];

    [self.navigationController pushViewController:AddSmartHangerFailVC animated:YES];
}
@end

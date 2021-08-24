//
//  KDSBindingGatewayVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBindingGatewayVC.h"
#import "KDSBindingGatewayCell.h"
#import "KDSAddZigBeeLockVC.h"
#import "KDSAddCatEyeVC.h"
#import "KDSAddGWVCOne.h"
#import "KDSFTIndicator.h"
#import "KDSMQTT.h"
#import "MBProgressHUD+MJ.h"
#import "NetworkManagerByReachability.h"
#import "hisi_util.h"
#import "GatewayModel.h"
#import "KDSSwitchWifiVC.h"
#import "KDSAddCatEyeVCStep1.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <CoreLocation/CoreLocation.h>


@interface KDSBindingGatewayVC ()<UITableViewDelegate,UITableViewDataSource,AMapLocationManagerDelegate,CLLocationManagerDelegate>

//@property (nonatomic, strong) AMapLocationManager *locationManager;  //定位管理者
@property (nonatomic, strong) CLLocationManager *locationManager;  //定位管理者

///下一步
@property (nonatomic,readwrite,strong)UIButton * nextStepBtn;
///生成二维码
@property (nonatomic,readwrite,strong)UIButton * generateQRCodeBtn;
///标记选择的网关
@property (nonatomic,readwrite,strong)NSMutableArray *  selectIndexArr;
///声明一个UIButton类型的变量
@property (nonatomic , strong) UIButton *lastButton;
///网关所在网段密码
@property (nonatomic,strong)NSString * gwConfigPwd;
///网关所在wifi名称
@property (nonatomic,strong)NSString * gwConfigWifiSsid;
///wifi的dssid
@property (nonatomic,strong)NSString *connectedSSID;
///wifi的iP
@property (nonatomic,strong) NSString *connectedWifiIP;


@end

@implementation KDSBindingGatewayVC

#pragma mark 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"BindingGateway");
    [self setRightButton];
    
    self.gateways = [KDSUserManager sharedManager].gateways;
    
    [self.rightButton setImage:[UIImage imageNamed:@"添加设备"] forState:UIControlStateNormal];
    [self setUI];
    self.generateQRCodeBtn.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicantionDidBecomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkLocationPermissions];
    
    if (self.gateways.count == 0 ) {
        self.nextStepBtn.hidden = YES;
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        self.nextStepBtn.hidden = NO;
    }
}

#pragma private methods

-(void)setUI
{
    
    [self.view addSubview:self.nextStepBtn];
    [self.view addSubview:self.generateQRCodeBtn];
    [self.generateQRCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-150);
    }];
    [self.nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.nextStepBtn.mas_top).offset(-10);
    }];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}
- (void)checkLocationPermissions{
    if (self.fromStrValue == 2) {//猫眼
        //2.创建定位管理者
        [self initWithLocationManager];
        //3.接受定位开启和关闭的通知
        [KDSNotificationCenter addObserver:self selector:@selector(didOpenAutoLock) name:@"didOpenAutoLock" object:nil];
        [KDSNotificationCenter addObserver:self selector:@selector(didCloseAutoLock) name:@"didCloseAutoLock" object:nil];
        
    }
}
- (void)initWithLocationManager{
    
    CGFloat version = [[UIDevice currentDevice].systemVersion doubleValue];//float
    
    if(!_locationManager){
        
        // 初始化定位管理器
        _locationManager = [[CLLocationManager alloc] init];
        // 设置代理
        _locationManager.delegate = self;
        // 设置定位精确度到米
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置过滤器为无
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        
        if(version > 8.0f){
            // 请求定位服务
            // 取得定位权限,有两个方法,取决于你的定位使用情况
            // 一个是requestAlwaysAuthorization,一个是requestWhenInUseAuthorization
            
            // iOS8对定位进行了一些修改，其中包括定位授权的方法,CLLocationManager增加了下面的两个方法
            // 在Info.plist文件中添加如下配置：
            // NSLocationAlwaysUsageDescription Always
            // NSLocationWhenInUseUsageDescription InUse
            [_locationManager requestWhenInUseAuthorization];//这句话ios8以上版本使用。
        }
        
        [_locationManager startUpdatingLocation];
        
    }
    
    [self checkPermissions];
    
    
}
-(void)checkPermissions{
    if (![KDSTool determineWhetherTheAPPOpensTheLocation]){
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请到设置->隐私->定位服务中开启【凯迪仕智能】定位服务，否则无法添加猫眼" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        // 创建action，这里action1只是方便编写，以后再编程的过程中还是以命名规范为主
        UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alerVC addAction:cancleAction];
        [alerVC addAction:action];
        [self presentViewController:alerVC animated:YES completion:nil];
    }
    else{
        BOOL isWIFI =[GLobalNetworkManagerByReachability isWiFiEnabled];
        if (!isWIFI) {//如果WiFi没有打开，作出弹窗提示
            [self wifiNetworkUnreachalertController:@"Wi-Fi未打开，继续操作需要打开Wi-Fi，是否前往？"];
            return;
        }
        self.connectedSSID = [GLobalNetworkManagerByReachability getWifiSSID];
        self.connectedWifiIP = [GLobalNetworkManagerByReachability getLocalIPAddress:@"en0"];
    }
}

#pragma mark DataManagerDelegate
-(void)refreshGWTableview{
    [self.tableView.mj_header endRefreshing];
    
    [self.tableView reloadData];
}

#pragma mark 控件点击事件
///添加网关--UIBarButtonItem--right
-(void)navRightClick
{
    KDSAddGWVCOne *vc = [[KDSAddGWVCOne alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)nextStepBtnClick:(UIButton *)sender
{
    
    ///点击下一步的时候如果一个网关都没有选择，不能进行下一步，提示需要先选择网关
    if (self.selectIndexArr.count ==0) {
        [MBProgressHUD showError:@"请先选择一个可用网关"];
        return;
    }
    
    if (self.fromStrValue == 3)
    {///添加锁
        KDSAddZigBeeLockVC * zigbeeLockVC = [KDSAddZigBeeLockVC new];
        zigbeeLockVC.gwConfigWifiSsid = self.gwConfigWifiSsid;
        zigbeeLockVC.gwConfigPwd = self.gwConfigPwd;
        zigbeeLockVC.gw = self.gateways[[self.selectIndexArr.firstObject intValue]];
        [self.navigationController pushViewController:zigbeeLockVC animated:YES];
        return;
    }
    ///先鉴权下网关的wifi、pwd，如果手机等设备连接的是当前wifi允许进行下一步，否则提示切换wifi
    [self checkWifiNetwork];
    
}

-(void)checkWifiNetwork {
    
    [self checkPermissions];
    
    NSString *connectedSSID = [GLobalNetworkManagerByReachability getWifiSSID];
    NSString *connectedWifiIP = [GLobalNetworkManagerByReachability getLocalIPAddress:@"en0"];
    if(connectedSSID == nil || connectedWifiIP == nil)
    {
        return;
    }else{
        if (self.fromStrValue == 2) {//猫眼
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"requestingResetPwd") toView:self.view];
            [[KDSMQTTManager sharedManager] gwGetWifiSetting:self.gateways[[self.selectIndexArr.firstObject intValue]].model completion:^(NSError * _Nullable error, NSString * _Nullable ssid, NSString * _Nullable pwd, NSString * _Nullable encryption) {
                [hud hideAnimated:YES];
                self.gwConfigPwd = pwd;
                self.gwConfigWifiSsid = ssid;
                
                if (![self.gwConfigWifiSsid isEqualToString:connectedSSID]) {
                    KDSSwitchWifiVC * vc = [KDSSwitchWifiVC new];
                    vc.block = ^(id _Nonnull param) {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    return ;
                }else{
                    
                    ///添加猫眼
                    KDSAddCatEyeVCStep1 * catEyeVC = [KDSAddCatEyeVCStep1 new];
                    catEyeVC.gwConfigPwd = self.gwConfigPwd;
                    catEyeVC.gwConfigWifiSsid = self.gwConfigWifiSsid;
                    catEyeVC.gateway = self.gateways[[self.selectIndexArr.firstObject intValue]];
                    [self.navigationController pushViewController:catEyeVC animated:YES];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
                }
                
            }];
        }
        
    }
}
- (void)wifiNetworkUnreachalertController:(NSString *)alertMessage
{
    // 危险操作:弹框提醒
    // 1.UIAlertView
    // 2.UIActionSheet
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"警告") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:Localized(@"前往") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [KDSTool openSettingsURLString];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:Localized(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        //        [self.navigationController popViewControllerAnimated:YES];
    }]];
    if (alert) {
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}
-(void)rBtnClick:(UIButton *)sender
{
    // 获取'edit按钮'所在的cell
    KDSBindingGatewayCell *cell = (KDSBindingGatewayCell *)[[sender superview] superview];
    // 获取cell的indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KDSGW *model;
    //有绑定网关
    if (self.gateways) {
        model = self.gateways[indexPath.row];
    }
    if ([model.state isEqualToString:@"offline"]) {
        sender.selected = NO;
        [MBProgressHUD showError:@"网关离线不可用"];
        return;
    }
    if (self.fromStrValue == 2 && ([model.model.model isEqualToString:@"6030"] || [model.model.model isEqualToString:@"6032"])) {
        sender.selected = NO;
        [MBProgressHUD showError:@"此网关不支持绑定猫眼"];
        return;
    }
    if (!sender.selected) {
        [self.selectIndexArr removeAllObjects];
        self.lastButton.selected = !self.lastButton.selected;
        sender.selected = YES;
        self.lastButton = sender;
        [self.selectIndexArr insertObject:@(sender.tag) atIndex:0];
        NSLog(@"-------selectIndexArr:%@",self.selectIndexArr);
    }else{
        [self.selectIndexArr removeAllObjects];
        sender.selected = NO;
        
    }
    
}

#pragma mark UITableViewDelegate

///每组多少个cell
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gateways.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 140;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *reuseId = NSStringFromClass([self class]);
    KDSBindingGatewayCell * gatewayCell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!gatewayCell)
    {
        gatewayCell = [[KDSBindingGatewayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        gatewayCell.clipsToBounds = YES;
    }
    gatewayCell.rightIconBtn.tag = indexPath.row;
    [gatewayCell.rightIconBtn addTarget:self action:@selector(rBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    gatewayCell.layer.cornerRadius = 4;
    
    if (self.gateways) {
        //有绑定网关
        KDSGW *gw = self.gateways[indexPath.row];
        //网关ID
        gatewayCell.gateWayID.text = [NSString stringWithFormat:@"ID:%@",gw.model.deviceSN];
        //管理员昵称
        gatewayCell.AdministratorsLabel.text = [NSString stringWithFormat:@"%@：%@",Localized(@"Administrators"),gw.model.adminNickname];
        gatewayCell.titleLabel.text = gw.model.deviceNickName ?: gw.model.deviceSN;
        if (!gw.online) {
            gatewayCell.gateWayStatusLb.text = Localized(@"offline");
            gatewayCell.gateWayStatusLb.textColor = KDSRGBColor(153, 153, 153);
            gatewayCell.gateWayStatusImg.image = [UIImage imageNamed:@"Gateway outline_icon"];
            gatewayCell.gateWayIconImg.image = [UIImage imageNamed:@"Gateway offline"];
        }else {
            gatewayCell.gateWayStatusLb.text = Localized(@"online");
            gatewayCell.gateWayStatusLb.textColor = KDSRGBColor(31, 150, 247);
            gatewayCell.gateWayStatusImg.image = [UIImage imageNamed:@"Gateway online_icon"];
            gatewayCell.gateWayIconImg.image = [UIImage imageNamed:@"GatewayOnLine"];
        }
        if ([gw.model.isAdmin isEqualToString:@"2"]) {
            gatewayCell.authMemGwLb.hidden = NO;
            gatewayCell.rightIconBtn.hidden = YES;
        }else{
            gatewayCell.authMemGwLb.hidden = YES;
            gatewayCell.rightIconBtn.hidden = NO;
        }
    }
    
    return gatewayCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * hearderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 30)];
    
    UIImageView * ico = [UIImageView new];
    ico.image = [UIImage imageNamed:@"提醒"];
    ico.backgroundColor = UIColor.clearColor;
    [hearderView addSubview:ico];
    [ico mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(12);
        make.bottom.mas_equalTo(hearderView.mas_bottom).offset(-4);
        make.left.mas_equalTo(hearderView.mas_left).offset(17);
    }];
    UILabel * remindLabel = [UILabel new];
    remindLabel.backgroundColor = UIColor.clearColor;
    remindLabel.font = [UIFont systemFontOfSize:12];
    remindLabel.textColor = KDSRGBColor(51, 51, 51);
    remindLabel.text = Localized(@"Select gateway which device be bound");
    [hearderView addSubview:remindLabel];
    [remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ico.mas_right).offset(7);
        make.right.mas_equalTo(hearderView.mas_right).offset(-35);
        make.bottom.mas_equalTo(hearderView.mas_bottom).offset(-4);
        make.height.mas_equalTo(12);
    }];
    
    
    return hearderView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(void)applicantionDidBecomActive:(NSNotification *)notification
{
    NSLog(@"applicantionDidBecomActive");
    BOOL isWIFI =[GLobalNetworkManagerByReachability isWiFiEnabled];
    if (!isWIFI) {//如果WiFi没有打开，作出弹窗提示
        [self wifiNetworkUnreachalertController:@"Wi-Fi未打开，继续操作需要打开Wi-Fi，是否前往？"];
    }
    NSString *connectedSSID = [GLobalNetworkManagerByReachability getWifiSSID];
    NSString *connectedWifiIP = [GLobalNetworkManagerByReachability getLocalIPAddress:@"en0"];
    if ([self.connectedSSID isEqualToString:connectedSSID] && [self.connectedWifiIP isEqualToString:connectedWifiIP]) {
        return;
    }else{
        [self checkWifiNetwork];
    }
}

#pragma mark --Lazy load
- (UIButton *)nextStepBtn
{
    if (!_nextStepBtn) {
        _nextStepBtn = ({
            UIButton * nsBtn = [UIButton new];
            nsBtn.backgroundColor = KDSRGBColor(31, 150, 247);
            [nsBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [nsBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
            [nsBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            nsBtn.layer.cornerRadius = 22;
            nsBtn;
        });
    }
    return _nextStepBtn;
}

- (UIButton *)generateQRCodeBtn
{
    if (!_generateQRCodeBtn) {
        _generateQRCodeBtn = ({
            UIButton * nsBtn = [UIButton new];
            nsBtn.backgroundColor = UIColor.whiteColor;
            [nsBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
            [nsBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
            [nsBtn addTarget:self action:@selector(generateQRCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            nsBtn.layer.cornerRadius = 22;
            nsBtn;
        });
    }
    return _generateQRCodeBtn;
}
- (NSMutableArray *)selectIndexArr
{
    if (!_selectIndexArr) {
        _selectIndexArr = ({
            NSMutableArray * arr = [NSMutableArray new];
            arr;
        });
    }
    
    return _selectIndexArr;
}
#pragma mark - 高德地图代理方法
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    //定位错误
    KDSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}
- (void)didOpenAutoLock{
    [self.locationManager startUpdatingLocation];
    
}
- (void)didCloseAutoLock{
    [self.locationManager stopUpdatingLocation];
}
- (void)dealloc{
    [self.locationManager stopUpdatingLocation];
    [KDSNotificationCenter removeObserver:self];
    KDSLog(@"tabbar销毁了")
}
@end

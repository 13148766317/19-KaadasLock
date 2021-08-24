//
//  KDSDeviceViewController.m
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDeviceViewController.h"
#import "KDSBLELockVC.h"
#import "KDSGWDetailVC.h"
#import "KDSCatEyeDetailsVC.h"
#import "KDSGWLockVC.h"
#import "KDSShareUserBLELockVC.h"
#import "KDSDeviceContentView.h"
#import "KDSDeviceCell.h"
#import "KDSMQTT.h"
#import "MBProgressHUD+MJ.h"
#import "KDSFTIndicator.h"
#import "KDSAddDeviceVC.h"
#import "KDSOldBLELockVC.h"
#import "KDSDBManager+GW.h"
#import "KDSCountdown.h"
#import "KDSDBManager+CY.h"
#import "KDSBleAssistant.h"
#import "KDSWifiLockDetailsVC.h"
#import "KDSBleAddWiFiLockDetailsVC.h"
#import "KDSWifiLockIsNotAdminDetailsVC.h"
#import "KDSHangerSettingVC.h"



@interface KDSDeviceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *naviViewHeightConstant;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
///设备列表、智能场景、添加设备的父视图
@property (weak, nonatomic) IBOutlet UIView *supView;
///设备列表选择按钮
@property (weak, nonatomic) IBOutlet UIButton *selectedeviceListBtn;
///默认选择设备列表(显示下划线)
@property (weak, nonatomic) IBOutlet UIView *line1;
///智能场景选择按钮
@property (weak, nonatomic) IBOutlet UIButton *selecteSceneBtn;

///选择场景的下划线（选中显示下划线反之隐藏）
@property (weak, nonatomic) IBOutlet UIView *line2;
///没有设备的时候展示的视图
@property (nonatomic,readwrite,strong)KDSDeviceContentView * deviceContentView;
@property (nonatomic,readwrite,strong)UITableView * tableView;
///场景的列表视图
@property (nonatomic,readwrite,strong)UITableView * sceneTableView;
@property (nonatomic,readwrite,strong)NSMutableArray * dataSourceArr;
///蓝牙锁数组。
@property (nonatomic,strong,readonly)NSArray<KDSLock *> *bleLocks;
///网关锁数组。
@property (nonatomic,strong,readonly)NSArray<KDSLock *> *gwLocks;
///wifi锁数组。
@property (nonatomic,strong,readonly)NSArray<KDSLock *> * wifiLocks;
///猫眼锁数组。
@property (nonatomic,strong,readonly)NSArray<KDSCatEye *> *cateyes;
///网关数组。
@property (nonatomic,strong,readonly)NSArray<KDSGW *> *gateways;
//晾衣架
@property (nonatomic,strong,readonly)NSArray<KDSDeviceHangerModel *> *hangers;
///如果收到网关上线、离线事件时，还没有获取绑定的网关，先将事件记录下来，根据对应的值显示界面后再移除。key是网关sn，值是状态字符串。
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *gatewayEvents;
///如果收到设备上线、离线事件时，还没有获取绑定的设备，先将事件记录下来，根据对应的值显示界面后再移除。key是设备ID，值是状态字符串。
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *deviceEvents;
@property (nonatomic, strong) NSString *FunctionSetKey;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;
@property (nonatomic, strong) NSArray * scenesArray;



@end

@implementation KDSDeviceViewController

- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy/MM/dd HH:mm";
    }
    return _dateFmt;
}

#pragma mark - getter setter
- (NSArray<KDSLock *> *)bleLocks
{
    NSMutableArray *locks = [NSMutableArray array];
    for (KDSLock *lock in [KDSUserManager sharedManager].locks)
    {
        if (lock.device) [locks addObject:lock];
    }
    return locks.copy;
}

- (NSArray<KDSDeviceHangerModel *> *)hangers {
    return [KDSUserManager sharedManager].hangers;
}
- (NSArray<KDSLock *> *)gwLocks
{
    NSMutableArray *locks = [NSMutableArray array];
    for (KDSLock *lock in [KDSUserManager sharedManager].locks)
    {
        if (lock.gwDevice)
        {
            [locks addObject:lock];
            NSString *state = self.deviceEvents[lock.gwDevice.deviceId];
            if (state)
            {
                lock.gwDevice.event_str = state;
                self.deviceEvents[lock.gwDevice.deviceId] = nil;
            }
            if (!lock.powerUpdated)
            {
                lock.powerUpdated = YES;
                [[KDSMQTTManager sharedManager] dlGetDevicePower:lock.gwDevice completion:^(NSError * _Nullable error, BOOL success, int power) {
                    if (success)
                    {
                        [[KDSDBManager sharedManager] updatePower:power withLock:lock.gwDevice];
                        [[KDSDBManager sharedManager] updatePowerTime:NSDate.date withLock:lock.gwDevice];
                        lock.power = power;
                        [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:nil userInfo:nil];
                    }
                }];
            }
        }
    }
    return locks.copy;
}
- (NSArray<KDSLock *> *)wifiLocks
{   // wifi 锁的信息是从单例类中上传的
    NSMutableArray * wifiLocks = [NSMutableArray array];
    for (KDSLock *lock in [KDSUserManager sharedManager].locks)
    {
        if (lock.wifiDevice) [wifiLocks addObject:lock];
    }
    return wifiLocks.copy;
    
}
- (NSArray<KDSCatEye *> *)cateyes
{
    NSMutableArray * cateyes = [NSMutableArray array];
    for (KDSCatEye * cateye in [KDSUserManager sharedManager].cateyes)
    {
        if ([cateye.gatewayDeviceModel.device_type isEqualToString:@"kdscateye"])
        {
            NSString * event_state = self.deviceEvents[cateye.gatewayDeviceModel.deviceId];
            if (event_state) {
                cateye.gatewayDeviceModel.event_str = event_state;
                self.deviceEvents[cateye.gatewayDeviceModel.deviceId] = nil;
            }
           [cateyes addObject:cateye];
            if (!cateye.powerDidrequest) {
                cateye.powerDidrequest = YES;
                [[KDSMQTTManager sharedManager] cyGetDevicePower:cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success, int power) {
                    if (success) {
                        //获取当前时间的时间戳
                        NSString * timSpam = [KDSTool getNowTimeTimestamp];
                        cateye.powerStr = power;
                        cateye.getPowerTime = timSpam;
                        [[KDSDBManager sharedManager] updateCateyePower:power withDeviceId:cateye.gatewayDeviceModel.deviceId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:[NSString stringWithFormat:@"%d",power]];
                    }
                }];
            }
        }
    }
    return cateyes.copy;
}

- (NSArray<KDSGW *> *)gateways
{
    NSMutableArray * arr = [NSMutableArray array];
    for (KDSGW * gateway in [KDSUserManager sharedManager].gateways) {
        NSString *state = self.gatewayEvents[gateway.model.deviceSN];
        if (state)
        {
            self.gatewayEvents[gateway.model.deviceSN] = nil;
            gateway.state = state;
        }
        
        //展示所有的网关（授权非授权，以及授权设备所在的网关）
        
        [arr addObject:gateway];
        
        //如果不展示授权锁、猫眼所在的网关替换下面代码即可
//        if (gateway.model.isAdmin.intValue != 2) {///被分享的设备
//            [arr addObject:gateway];
//        }
    }
    return arr.copy;
}

- (NSMutableDictionary<NSString *,NSString *> *)gatewayEvents
{
    if (!_gatewayEvents)
    {
        _gatewayEvents = [NSMutableDictionary dictionary];
    }
    return _gatewayEvents;
}

- (NSMutableDictionary<NSString *,NSString *> *)deviceEvents
{
    if (!_deviceEvents)
    {
        _deviceEvents = [NSMutableDictionary dictionary];
    }
    return _deviceEvents;
}

#pragma mark - 生命周期、界面设置方法
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        ///监听网关上线
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gatewayState:) name:KDSMQTTEventNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenDeviceDidSync:) name:KDSDeviceSyncNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviViewHeightConstant.constant = kNavBarHeight+kStatusBarHeight;
    self.titleLabel.text = Localized(@"MyDevice");
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [self.selecteSceneBtn addTarget:self action:@selector(selectedBtnChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectedeviceListBtn addTarget:self action:@selector(selectedBtnChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    /*使用智能家居的时候打开
    self.selectedeviceListBtn.selected = YES;
    self.selecteSceneBtn.selected = NO;
    self.line1.hidden = NO;
    self.line2.hidden = YES;
     */
    CGFloat deviceBtnWidth = [self.selectedeviceListBtn.titleLabel.text boundingRectWithSize:CGSizeMake(KDSScreenWidth/3, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size.width;
    [self.selectedeviceListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.supView.mas_left).offset(20);
        make.bottom.mas_equalTo(self.supView.mas_bottom).offset(-2);
        make.width.equalTo(@(deviceBtnWidth));
        make.height.equalTo(@30);
    }];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.supView.mas_left).offset(20);
        make.width.equalTo(@(deviceBtnWidth));
        make.height.equalTo(@1);
        make.bottom.mas_equalTo(self.supView.mas_bottom).offset(0);
        
    }];
    CGFloat sceneBtnWidth = [self.selecteSceneBtn.titleLabel.text boundingRectWithSize:CGSizeMake(KDSScreenWidth/3, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size.width;
    [self.selecteSceneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectedeviceListBtn.mas_right).offset(30);
        make.bottom.mas_equalTo(self.supView.mas_bottom).offset(-2);
        make.width.equalTo(@(sceneBtnWidth));
        make.height.equalTo(@30);
    }];
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.line1.mas_right).offset(30);
        make.width.equalTo(@(sceneBtnWidth));
        make.height.equalTo(@1);
        make.bottom.mas_equalTo(self.supView.mas_bottom).offset(0);
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"--{Kaadas}-KDSDeviceViewController-viewWillAppear");
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (self.cateyes.count == 0 && self.bleLocks.count == 0 && self.gwLocks.count == 0 && self.wifiLocks.count == 0 && self.gateways.count == 0 && self.hangers.count == 0)
    {
        [self.tableView removeFromSuperview];
        [self.view addSubview:self.deviceContentView];
        [self.deviceContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_offset(0);
            make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight);
        }];
    }
    else
    {
        [self.deviceContentView removeFromSuperview];
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(kNavBarHeight+kStatusBarHeight);
        }];
    }
    [self.tableView reloadData];
}

#pragma mark - 控件事件
-(void)addDeviceBtnClick:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:[@"http://" stringByAppendingString:@"www.kaadas.com"]];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)rightBtnClick:(id)sender {
    NSLog(@"点击了添加按钮");
    
    KDSAddDeviceVC *vc = [[KDSAddDeviceVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.gateways = [KDSUserManager sharedManager].gateways;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)selectedBtnChangeClick:(UIButton *)sender
{
    self.selectedeviceListBtn.selected = !self.selectedeviceListBtn.selected;
    self.selecteSceneBtn.selected = !self.selecteSceneBtn.selected;
    if (self.selectedeviceListBtn.selected) {
       /*使用智能家居的时候打开
        self.line1.hidden = NO;
        self.line2.hidden = YES;
        */
        [self.sceneTableView removeFromSuperview];
        if (self.cateyes.count == 0 && self.bleLocks.count == 0 && self.gwLocks.count == 0 && self.wifiLocks.count == 0 && self.gateways.count == 0)
        {
            [self.tableView removeFromSuperview];
            [self.view addSubview:self.deviceContentView];
            [self.deviceContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_offset(0);
                make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight);
            }];
        }
        else
        {
            [self.deviceContentView removeFromSuperview];
            [self.view addSubview:self.tableView];
            [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(kNavBarHeight+kStatusBarHeight);
            }];
        }
        [self.tableView reloadData];
    }else{
        /*使用智能家居的时候打开
        self.line1.hidden = YES;
        self.line2.hidden = NO;
         */
        [self.tableView removeFromSuperview];
        [self.view addSubview:self.sceneTableView];
        [self.sceneTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(kNavBarHeight+kStatusBarHeight);
        }];
        [self.sceneTableView reloadData];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.selecteSceneBtn.selected) {
        return 1;
    }
    return 6;
}
///每组多少个cell
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selecteSceneBtn.selected) {
        return self.scenesArray.count;
    }
    switch (section) {
        case 0:
            ///蓝牙锁
            return self.bleLocks.count;
        case 1:
            ///zigbee锁
            return self.gwLocks.count;
        case 2:///wifi锁
            return self.wifiLocks.count;
        case 3:
            ///猫眼
            return self.cateyes.count;
        case 4:
           ///网关
            return self.gateways.count;
        case 5:
            return self.hangers.count;
            break;
        default:
            break;
    }
    return 0;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selecteSceneBtn.selected) {
        return 100;
    }
    return 130;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId;
    if (indexPath.section == 5) {
        reuseId = @"hanger";
    }else {
        reuseId = NSStringFromClass([self class]);
    }
    
    KDSDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    switch (indexPath.section) {

        case 0:///蓝牙锁
        {
             cell.model = self.bleLocks[indexPath.row];
        }
            break;
            
        case 1:///zigbee锁
        {
            cell.model = self.gwLocks[indexPath.row];
        }
            break;
        
        case 2:///wifi锁
        {
            cell.model = self.wifiLocks[indexPath.row];
        }
            break;

        case 3:///猫眼
        {
            cell.model = self.cateyes[indexPath.row];
        }
            break;
            
        case 4:  ///网关
        {
            cell.model = self.gateways[indexPath.row];
        }
            break;
            //晾衣架
        case 5:{
            cell.model = self.hangers[indexPath.row];
        }
            break;
            
        default:
            break;
    }
    
    
    cell.backgroundColor = self.view.backgroundColor;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        switch (indexPath.section) {
            case 0:///蓝牙锁
            {
                KDSLock *lock = self.bleLocks[indexPath.row];

                NSLog(@"--{Kaadas}--bleVersion==%d",lock.device.bleVersion.intValue);
                ////根据蓝牙锁的功能集判断是开锁记录/操作记录
                self.FunctionSetKey = lock.lockFunctionSet;//?:lock.bleTool.connectedPeripheral.functionSet;
                BOOL oldTag = lock.device.bleVersion.intValue < 3;
                BOOL isoldLock = [self.FunctionSetKey isEqualToString:@"0x00"];
                if (oldTag || isoldLock)
                {
                    KDSOldBLELockVC *vc = [KDSOldBLELockVC new];
                    vc.lock = lock;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                if (lock.device.is_admin.boolValue)
                {
                    ///绑定的蓝牙锁
                    KDSBLELockVC *vc = [KDSBLELockVC new];
                    vc.lock = lock;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    ///授权的蓝牙锁
                    KDSShareUserBLELockVC *vc = [KDSShareUserBLELockVC new];
                    vc.lock = lock;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }
                break;
            case 1: ///zigbee锁
            {
                KDSLock *lock = self.gwLocks[indexPath.row];
                KDSGWLockVC *vc = [KDSGWLockVC new];
                vc.lock = lock;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                
                break;
            case 2: ///wifi锁
            {
                KDSLock * wifiLock = self.wifiLocks[indexPath.row];
                if (wifiLock.wifiDevice.isAdmin.intValue == 1) {
                    //KDSWifiLockDetailsVC * vc = [KDSWifiLockDetailsVC new];
                    KDSBleAddWiFiLockDetailsVC * vc = [KDSBleAddWiFiLockDetailsVC new];
                    vc.lock = wifiLock;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    KDSWifiLockIsNotAdminDetailsVC * vc = [KDSWifiLockIsNotAdminDetailsVC new];
                    vc.lock = wifiLock;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
                break;  
            case 3: ///猫眼
            {
                KDSCatEye * cateye = self.cateyes[indexPath.row];
                KDSCatEyeDetailsVC * catEyeVC = [KDSCatEyeDetailsVC new];
                catEyeVC.cateye = cateye;
                catEyeVC.gatewayModel = cateye.gw.model;
                catEyeVC.gatewayDeviceModel = cateye.gatewayDeviceModel;
                catEyeVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:catEyeVC animated:YES];
            }
                break;
            case 4: ///网关
            {
                KDSGWDetailVC * gwDetailVC = [KDSGWDetailVC new];
                gwDetailVC.gateway = self.gateways[indexPath.row];
                gwDetailVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:gwDetailVC animated:YES];
            }
                break;
            // 晾衣机
            case 5: {
                KDSHangerSettingVC *vc = [[KDSHangerSettingVC alloc] init];
                vc.hanger = self.hangers[indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
   
}
#pragma mark --Lazy load
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView * b = [UITableView new];
            b.backgroundColor = UIColor.clearColor;
            b.showsVerticalScrollIndicator = NO;
            b.showsHorizontalScrollIndicator = NO;
            b.delegate = self;
            b.dataSource = self;
            b.rowHeight = 130;
            b.separatorStyle = UITableViewCellSeparatorStyleNone;
            b;
        });
    }
    return _tableView;
}
- (UITableView *)sceneTableView
{
    if (!_sceneTableView) {
        _sceneTableView = [UITableView new];
        _sceneTableView.backgroundColor = UIColor.clearColor;
        _sceneTableView.showsVerticalScrollIndicator = NO;
        _sceneTableView.showsHorizontalScrollIndicator = NO;
        _sceneTableView.delegate = self;
        _sceneTableView.dataSource = self;
        _sceneTableView.rowHeight = 100;
        _sceneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _sceneTableView;
}

-(KDSDeviceContentView *)deviceContentView
{
    if (!_deviceContentView) {
        _deviceContentView = ({
            KDSDeviceContentView * cV = [KDSDeviceContentView new];
            cV.backgroundColor = UIColor.clearColor;
            cV.userInteractionEnabled = YES;
            [cV.addDeviceBtn addTarget:self action:@selector(addDeviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cV;
        });
    }
    return _deviceContentView;
}

#pragma mark - 通知。

- (void)wifimqttEventNotification:(NSNotification *)noti {
    
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    
    KDSLog(@"%@ %@",event, param);
    if ([event isEqualToString:MQTTSubEventLockInf] || [event isEqualToString:MQTTSubEventLockMultiInfo]) {
        [self.tableView reloadData];
    }
}

///在这儿处理网关的状态和事件。
-(void)gatewayState:(NSNotification *)noti
{
    MQTTSubEvent  subevent = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    NSArray<NSString *> *alarms = @[MQTTSubEventLowPower, MQTTSubEventDLAlarm,MQTTSubEventWIfiLockAlarm, MQTTSubEventPIRAlarm, MQTTSubEventCYHeadLost, MQTTSubEventCYBell, MQTTSubEventCYHostLost,MQTTSubEventDLInfo];
    if ([subevent isEqualToString:MQTTSubEventGWOnline]) {//网关上线
        [self handleMQTTSubEventGWOnline:YES param:param];
    }else if ([subevent isEqualToString:MQTTSubEventGWOffline]){//网关下线
        [self handleMQTTSubEventGWOnline:NO param:param];
    }else if ([subevent isEqualToString:MQTTSubEventGWReset]){//网关重置
        [self handleMQTTSubEventGWReset:param];
    }else if ([alarms containsObject:subevent]){//网关锁报警
        [self handleMQTTSubEventAlarm:subevent param:param];
    }else if ([subevent isEqualToString:MQTTSubEventDeviceOnline]){///设备上线
        [self handleMQTTSubEventDeviceOnline:YES param:param];
    }else if ([subevent isEqualToString:MQTTSubEventDeviceOffline]){///设备离线
        [self handleMQTTSubEventDeviceOnline:NO param:param];
    }else if ([subevent isEqualToString:MQTTSubEventDLKeyChanged]){
        [self handleMQTTSubEventDLKeyChanged:param];
    }else if ([subevent isEqualToString:MQTTSubEventUnlock]){//开锁
        [self handleMQTTSubEventDeviceLocked:NO param:param];
    }else if ([subevent isEqualToString:MQTTSubEventLock]){//关锁
        [self handleMQTTSubEventDeviceLocked:YES param:param];
    }else if ([subevent isEqualToString:MQTTSubEventOTA]){//OTA升级
        [self handleMQTTSubEventOTA:param];
    }else if ([subevent isEqualToString:MQTTSubEventDLInfo]){
        [self handleMQTTSubEventDLInfo:param];//电量
    }else if ([subevent isEqualToString:MQTTSubEventWifiLockStateChanged]){
        [self wifiLockMoreSettingHandleMQTTSubEventWifiLockStateChanged:param];//wifi锁模式更改
    }
}

///当设备的数量或者各种状态等改变时，刷新本页面的设备状态。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
    [self.tableView reloadData];
}

///收到更改了本地语言的通知，刷新表视图。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.titleLabel.text = Localized(@"MyDevice");
    [self.deviceContentView.addDeviceBtn setTitle:Localized(@"buyItNow") forState:UIControlStateNormal];
    self.deviceContentView.promptingLabel.text = Localized(@"youNoDeviceNow");
    [self.tableView reloadData];
}

#pragma mark - 处理MQTT的一些通知子事件。
/**
 *@brief 处理网关上下线子事件
 *@param online 上线(YES)或者下线(NO)。
 *@param param 网关上下线子事件参数，请参考事件说明。
 */
- (void)handleMQTTSubEventGWOnline:(BOOL)online param:(NSDictionary *)param
{
    NSString *state = online ? @"online" : @"offline";
    NSString *uuid = param[@"uuid"];
    [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:@"%@%@",uuid,Localized((online ? @"gwOnline" : @"gwOffline"))] tapHandler:^{
    }];
    ///刷新设备状态
    if (online) [[NSNotificationCenter defaultCenter] postNotificationName:KDSGWOnlineNotification object:nil userInfo:nil];
    self.gatewayEvents[uuid] = state;
    [self.tableView reloadData];
}

///处理网关被重置子事件，参数请参考事件说明。
- (void)handleMQTTSubEventGWReset:(NSDictionary *)param
{
    NSString *uuid = param[@"uuid"];
    [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:@"%@%@",uuid,Localized(@"gwReset")] tapHandler:^{
        
    }];
    KDSGW *gw = [self.gateways filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K like %@", @"model.deviceSN", uuid]].firstObject;
    if (gw)
    {
        KDSLock *lock = [KDSLock new];
        lock.gw = gw;
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : lock}];
    }
}

/**
 *@brief 处理网关设备上下线子事件
 *@param online 上线(YES)或者下线(NO)。
 *@param param 网关设备上下线子事件参数，请参考事件说明。
 */
- (void)handleMQTTSubEventDeviceOnline:(BOOL)online param:(NSDictionary *)param
{
    NSString *event_state = online ? @"online" : @"offline";
    GatewayDeviceModel * gwModel = param[@"device"];
    NSString * cateyeID = gwModel.deviceId;
    if ([gwModel.device_type isEqualToString:@"kdscateye"])
    {
        [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:@"%@%@",param[@"deviceId"],Localized((online ? @"CatEyeOnline" : @"CatEyeOffline"))] tapHandler:^{
            
        }];
    }
    self.deviceEvents[cateyeID] = event_state;
    [self.tableView reloadData];
}

/**
 *@brief 处理网关设备报警子事件。
 *@param subevent 各种报警子事件，参考KDSMQTTOptions.h。
 *@param param 网关设备上下线子事件参数，请参考事件说明。
 */
- (void)handleMQTTSubEventAlarm:(MQTTSubEvent)subevent param:(NSDictionary *)param
{
    CGFloat alarmType = NAN;
    NSString *message;
    if ([subevent isEqualToString:MQTTSubEventLowPower]){
        if ([self.gwLocks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K like %@", @"gwDevice.deviceId", param[@"deviceId"]]].firstObject)
        {
            alarmType = KDSDLAlarmTypeLowPower;
        }
        else if ([self.cateyes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K like %@", @"gatewayDeviceModel.deviceId", param[@"deviceId"]]].firstObject)
        {
            alarmType = KDSCYAlarmTypeLowPower;
        }
    }
    else if ([subevent isEqualToString:MQTTSubEventDLAlarm])
    {
        if ([param[@"clusterID"] intValue] == 257)
        {
            alarmType = 100001 + [param[@"alarmCode"] intValue];
            NSDictionary *map = @{@(100001):@"lockedRotorAlarm", @(100002):@"lockHasBeenResetAlarm", @(100005):@"multiVerifyFailAlarm", @(100006):@"frontEscutcheonRemovedFromLockAlarm", @(100007):@"lockTeardownAlarm", @(100008):@"violenceUnlockAlarm", @(100009):@"temperatureExceptionAlarm", @(100010):@"forceUnlockAlarm", @(100011):@"keyLeftInLockAlarm", };
            if (map[@(alarmType)])
            {
                message = Localized(map[@(alarmType)]);
            }
        }
        else if ([param[@"clusterID"] intValue] == 1 && [param[@"alarmCode"] intValue] == 16)
        {
            alarmType = 16;
            message = Localized(@"lowPowerAlarm");
        }
    }
    else if ([subevent isEqualToString:MQTTSubEventWIfiLockAlarm]){//wifi锁报警推送
        ///目前wifi锁的模式：布防>反锁>安全
        KDSWifiLockModel * wifiLockModel = [self wifiLockDeviceForId:param[@"wfId"]];
//        if ([param[@"clusterID"] intValue])
//        {
            int alarmCode = [param[@"alarmCode"] intValue];
            switch (alarmCode) {
                case 1://锁定报警（输入错误密码或指纹或卡片超过 10 次就报 警系统锁定）
                    message = [NSString stringWithFormat:@"您的'%@'门锁错误验证多次，门锁系统锁定100秒！",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 2:// 劫持报警（输入防劫持密码或防劫持指纹开锁就报警）
                    message = [NSString stringWithFormat:@"您的家人使用劫持密码开启'%@'门锁，赶紧联系或报警",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 3:// 三次错误报警
                    message = [NSString stringWithFormat:@"您'%@'门锁错误验证多次",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 4:// 防撬报警（锁被撬开）
                    message = [NSString stringWithFormat:@"已监测到您的'%@'门锁被撬，请联系家人或小区保安",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 8:// 机械方式报警（使用机械方式开锁）
                    message = [NSString stringWithFormat:@"您的'%@'门锁正在被机械方式开启，请回家或联系保安查看",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 16:// 低电压报警（电池电量不足）0x10
                    message = [NSString stringWithFormat:@"您的'%@'门锁门锁低电量，请及时更换",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 32:// 锁体异常报警（旧:门锁不上报警）0x20
                    message = [NSString stringWithFormat:@"您的'%@'门锁有故障，请注意",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 64:// 门锁布防报警 0x40
                    message = [NSString stringWithFormat:@"您的'%@'门锁处于布防状态，有从门内开锁情况",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                    /*
                case 96:// 门铃报警 0x60
                    message = [NSString stringWithFormat:@"您的'%@'门锁门铃报警",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                case 112:// pir动作 0x70
                    message = [NSString stringWithFormat:@"您的'%@'门锁pir动作",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                     */
                case 128:// 一级低电告警（电量低，进入节能模式）0x80
                    message = [NSString stringWithFormat:@"您的'%@'门锁面容识别已关闭，如需重新开启面容 识别，请更换电池",wifiLockModel.lockNickname ?: wifiLockModel.wifiSN];
                    break;
                default:
                    break;
            }
//        }
    }
    else if ([subevent isEqualToString:MQTTSubEventPIRAlarm]){///快照报警
        message = Localized(@"Snapshot alerted");
        NSArray * AlarmArray = [[NSArray alloc] initWithArray:[KDSUserDefaults objectForKey:[NSString stringWithFormat:@"PhotoAlarmArray%@",[param objectForKey:@"deviceId"]]]];
        NSMutableArray * array = [[NSMutableArray alloc] initWithArray:AlarmArray];
        NSString *pictureStr = [[param objectForKey:@"url"] substringFromIndex:1];
        [array addObject:pictureStr];
        KDSLog(@"pictureStr = %@",pictureStr);
        [KDSUserDefaults setObject:array forKey:[NSString stringWithFormat:@"PhotoAlarmArray%@",[param objectForKey:@"deviceId"]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PirPhotoAlarmUpdate" object:nil userInfo:param];
        alarmType = KDSCYAlarmTypePir;
    }else if ([subevent isEqualToString:MQTTSubEventCYHeadLost]){
        message = Localized(@"Cat's eye cat's head pulled out");
        alarmType = KDSCYAlarmTypeHeadLost;
        
    }else if ([subevent isEqualToString:MQTTSubEventCYBell]){
        message = Localized(@"Cat Eye Door Bell Trigger");
        alarmType = KDSCYAlarmTypeBell;
    }else if ([subevent isEqualToString:MQTTSubEventCYHostLost]){
        message = Localized(@"Cat-eye fuselage pulled out");
        alarmType = KDSCYAlarmTypeHostLost;
    }
    if (message)
    {
        [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:message tapHandler:^{
            
        }];
    }
    if (!isnan(alarmType))
    {
        KDSAlarmModel *model = [KDSAlarmModel new];
        model.gwSn = param[@"gwId"];
        model.devName = param[@"deviceId"];
        model.warningType = (int)alarmType;
        NSDate *date = NSDate.date;
        model.warningTime = date.timeIntervalSince1970 * 1000;
        KDSUserManager *manager = [KDSUserManager sharedManager];
        manager.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        model.date = [manager.dateFormatter stringFromDate:date];
        GatewayDeviceModel *device = [self.gwLocks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K like %@", @"gwDevice.deviceId", param[@"deviceId"]]].firstObject.gwDevice;
        device = device ?: [self.cateyes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K like %@", @"gatewayDeviceModel.deviceId", param[@"deviceId"]]].firstObject.gatewayDeviceModel;
        [[KDSDBManager sharedManager] insertRecords:@[model] inDevice:device];
    }
}

///处理网关锁密匙改变子事件，参数请参考事件说明。
- (void)handleMQTTSubEventDLKeyChanged:(NSDictionary *)param
{
    GatewayDeviceModel *m = [self gwDeviceForId:param[@"deviceId"]];
    KDSPwdListModel *pwd = param[@"pwd"];
    if ([param[@"action"] boolValue])
    {
        [[KDSDBManager sharedManager] insertPasswords:@[pwd] withLock:m];
    }
    else
    {
        [[KDSDBManager sharedManager] deletePasswords:(pwd.num.intValue==255 ? nil : @[pwd]) withLock:m];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSGWLockPwdNotification object:nil];
}

/**
 *@brief 处理网关锁开、关子事件
 *@param locked 开锁(NO)或者关锁(YES)。
 *@param param 网关设备上下线子事件参数，请参考事件说明。
 */
- (void)handleMQTTSubEventDeviceLocked:(BOOL)locked param:(NSDictionary *)param
{
    ///开锁：使用（05～08）一次性密码之后从数据库删除此密码
    GatewayDeviceModel *m = [self gwDeviceForId:param[@"deviceId"]];
    [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:@"%@ %@",m.nickName?:m.deviceId,Localized((locked ? @"LockClose" : @"LockOpen"))] tapHandler:^{
    }];
    NSNumber * userId = param[@"userId"];
    if (!locked && userId.intValue >= 5 && userId.intValue <= 8) {
        KDSPwdListModel * pwdModel = [KDSPwdListModel new];
        pwdModel.num = userId.stringValue;
        pwdModel.pwdType = KDSServerKeyTpyeTempPIN;
        [[KDSDBManager sharedManager] deletePasswords:@[pwdModel] withLock:m];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSGWLockPwdNotification object:nil];
    }
}

///处理网关升级子事件，参数请参考事件说明。
- (void)handleMQTTSubEventOTA:(NSDictionary *)param
{
    NSLog(@"--{Kaadas}--OTA升级-deviceList=%@",param[@"params"][@"deviceList"][0]);
    NSString *mainDevice = param[@"params"][@"deviceList"][0];
    NSString *SW = param[@"params"][@"SW"];
    NSString *device ;
    if ([mainDevice hasPrefix:@"GW"]) {//网关
        device = Localized(@"gateWay:");
        if ([SW hasPrefix:@"znp"]) {//网关znp
            device = Localized(@"Gateway zigbee module:");
        }
    }
    else if ([mainDevice hasPrefix:@"CH"]){//猫眼
        device = Localized(@"cateye:");
    }
    else if ([mainDevice hasPrefix:@"ZG"]){//门锁zigbee模块
        device = Localized(@"Door lock zigbee module:");
    }
   //title
    NSString *title = [NSString stringWithFormat:@"%@%@%@",Localized(@"update"),SW,Localized(@"version")];
    //message
    NSString *str = [NSString stringWithFormat:@"%@%@",device,mainDevice];

    if (device) {

        UIAlertController * otaView = [UIAlertController alertControllerWithTitle:title message:str preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
       
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
            [[KDSMQTTManager sharedManager] otaWithParams:param completion:^(NSError * _Nullable error, BOOL success) {
                [hud hideAnimated:YES];
                if (success) {
                    [MBProgressHUD showSuccess:Localized(@"Gateway Upgrade Successful")];
                }else{
                    [MBProgressHUD showSuccess:Localized(@"Gateway Upgrade Failed")];
                }
            }];
        }];
        [otaView addAction:cancelAction];
        [otaView addAction:okAction];
        //修改title
        NSMutableAttributedString *alertControllerTitleStr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]}];
        [otaView setValue:alertControllerTitleStr forKey:@"attributedTitle"];
        
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];

        [otaView setValue:alertControllerMessageStr forKey:@"attributedMessage"];

        //修改按钮
        [cancelAction setValue:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forKey:@"titleTextColor"];

        [self presentViewController:otaView animated:YES completion:nil];
    }
}

///处理网关锁上报信息子事件，参数请参考事件说明。
- (void)handleMQTTSubEventDLInfo:(NSDictionary *)param
{
    GatewayDeviceModel *device = [self gwDeviceForId:param[@"deviceId"]];
    for (KDSLock *lock in self.gwLocks)
    {
        if (lock.gwDevice == device && [device.gwId isEqualToString:param[@"gwId"]])
        {
            if ([param[@"clusterID"] intValue]==1 && [param[@"attributeID"] intValue]==33 && [param[@"value"] intValue] < 255)//0x002 1,高3位是一个集合，总共有7个集合，最低位表示集合内的属性，每个集合最多包含16个属性。
            {
                lock.power = [param[@"value"] intValue] / 2;
                [[KDSDBManager sharedManager] updatePower:lock.power withLock:lock.gwDevice];
                [[KDSDBManager sharedManager] updatePowerTime:NSDate.date withLock:lock.gwDevice];
                [self.tableView reloadData];
            }
        }
    }
}

-(void)wifiLockMoreSettingHandleMQTTSubEventWifiLockStateChanged:(NSDictionary *)param
{
    for (KDSLock * wifiLock in self.wifiLocks) {
        if ([wifiLock.wifiDevice.wifiSN isEqualToString:param[@"wfId"]]) {
            wifiLock.wifiDevice.volume = param[@"volume"];
            wifiLock.wifiDevice.language = param[@"language"];
            wifiLock.wifiDevice.amMode = param[@"amMode"];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - 其它方法
///通过deviceId搜索对应的网关锁或者猫眼。
- (nullable GatewayDeviceModel *)gwDeviceForId:(NSString *)deviceId
{
    if (!deviceId) return nil;
    for (KDSLock *lock in self.gwLocks)
    {
        if ([lock.gwDevice.deviceId isEqualToString:deviceId])
        {
            return lock.gwDevice;
        }
    }
    for (KDSCatEye *cy in self.cateyes)
    {
        if ([cy.gatewayDeviceModel.deviceId isEqualToString:deviceId])
        {
            return cy.gatewayDeviceModel;
        }
    }
    return nil;
}
///通过wfId搜索对应的wifi锁的信息

-(nullable KDSWifiLockModel *)wifiLockDeviceForId:(NSString *)wifiSN
{
    if (!wifiSN) return nil;
    for (KDSLock * lock in self.wifiLocks) {
        if ([lock.wifiDevice.wifiSN isEqualToString:wifiSN]) {
            return lock.wifiDevice;
        }
    }
    return nil;
}

@end

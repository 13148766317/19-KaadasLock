//
//  KDSLockInFoVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSLockInFoVC.h"
#import "KDSHomePageLockStatusCell.h"
#import "KDSBluetoothTool.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager+Ble.h"
#import "KDSDBManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "KDSRecordDetailsVC.h"
#import "NSTimer+KDSBlock.h"
#import "KDSDFUVC.h"
#import "KDSBleAssistant.h"
#import "LinphoneManager.h"
#import "KDSOADVC.h"

@interface KDSLockInFoVC ()<UITableViewDelegate,UITableViewDataSource,KDSBluetoothToolDelegate>

///最外围的大圆。
@property (weak, nonatomic) IBOutlet UIImageView *bigCircleIV;
///中间的圆。
@property (weak, nonatomic) IBOutlet UIImageView *middleCircleIV;
///内部的小圆
@property (weak, nonatomic) IBOutlet UIImageView *smallCircleIV;
///显示蓝牙图标的视图。
@property (weak, nonatomic) IBOutlet UIImageView *bleLogoIV;
///提示语：关闭状态、布防状态、安全状态、反锁状态、正在开锁、开锁成功、点击，查看门外、设备不在搜索范围。
@property (weak, nonatomic) IBOutlet UILabel *deviceStausPromptLabel;
///提示语<在内环门锁状态视图里>：关闭状态、布防状态、安全状态、反锁状态、正在开锁、开锁成功、点击，查看门外、设备不在搜索范围。
@property (weak, nonatomic) IBOutlet UILabel *deviceStausWithInLockLabel;
///”守护时间“标签，拉出来设置语言本地化。
@property (weak, nonatomic) IBOutlet UILabel *guardianDayLocalizedLabel;
///”守护次数“标签，拉出来设置语言本地化。
@property (weak, nonatomic) IBOutlet UILabel *guardianTimesLocalizedLabel;
///”设备动态“标签，拉出来设置语言本地化。
@property (weak, nonatomic) IBOutlet UILabel *deviceDynamicLocalizedLabel;
///守护时间下的”天“标签，拉出来设置语言本地化。
@property (weak, nonatomic) IBOutlet UILabel *daysLocalizedLabel;
///守护次数下的”次“标签，拉出来设置语言本地化。
@property (weak, nonatomic) IBOutlet UILabel *timesLocalizedLabel;
///展示守护天数：
@property (weak, nonatomic) IBOutlet UILabel *guardianDayLabel;
///守护次数：
@property (weak, nonatomic) IBOutlet UILabel *guardianTimesLabel;
///设备动态：正常
@property (weak, nonatomic) IBOutlet UILabel *deviceDynamicsLabel;
///同步记录按钮
@property (weak, nonatomic) IBOutlet UIButton *synRecordingBtn;
///同步门锁状态标签，拉出来设置语言本地化。
@property (weak, nonatomic) IBOutlet UILabel *bleSyncLabel;
///展示：同步记录、蓝牙同步状态的父视图
@property (weak, nonatomic) IBOutlet UIView *synRecordingView;
///展示：守护时间、守护次数、设备动态的父视图
@property (weak, nonatomic) IBOutlet UIView *deviceDynamicsView;
///蓝牙工具。
@property (nonatomic, strong) KDSBluetoothTool *bleTool;
///锁状态，用于设置状态标签和状态图片。
@property (nonatomic, assign) KDSLockState lockState;
///获取锁信息接口成功返回的锁信息，用于更新锁反锁等状态。
@property (nonatomic, strong) KDSBleLockInfoModel *lockInfo;
///开锁次数。
@property (nonatomic, strong) NSString *lockUnlockTimes;
///浅绿色图片上的长按手势。
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
///显示锁状态以及一些提示语的父视图
@property (weak, nonatomic) IBOutlet UIView *deviceStatusSupView;
///服务器请求回来的开锁记录按日期分组后的数组，同一天的记录分到同一组。只请求第一页最多20条记录。
@property (nonatomic, strong) NSArray<NSArray<News *> *> *unlockRecordArr;
@property (nonatomic, strong) NSMutableArray<News *> * unlockRecordNews;
///服务器请求回来的操作记录数组。
@property (nonatomic, strong) NSMutableArray<KDSOperationalRecord *> * czOperationalArr;
///服务器请求回来操作记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong)NSArray<NSArray<KDSOperationalRecord *> *> *czOPerationalSectionArr;
///密匙列表。
@property (nonatomic, strong) NSArray<KDSPwdListModel *> *keys;
///记录是否正在进行连接成功动画，如果是，设置锁状态时直接返回，等动画完毕再设置锁状态。
@property (nonatomic, assign) BOOL animating;
///标记是否是长时间不操作导致断开蓝牙连接。
@property (nonatomic, assign) BOOL isLongtimeNoOp;
///The receipt which identify the task of query unlock records.
@property (nonatomic, strong) NSString *recReceipt;
///If user touch up sync record button, this variable keeps a ref to the hud shown to user.
@property (nonatomic, strong) MBProgressHUD *recHud;
///是否支持查询操作记录：YES支持，NO不支持
@property (nonatomic, assign) BOOL isOperationalRecords;
@property (nonatomic, strong) NSString *FunctionSetKey;
///锁是否是S8
@property (nonatomic, assign) BOOL s8;
///锁的功能集是否是包含10
@property (nonatomic, assign) BOOL supportPIN;
///蓝牙同步锁端信息的时候会遇到各种情况（模块假死、通信堵塞等）超时同步失败120秒
@property (nonatomic,strong)NSTimer * timeOut;

@end

@implementation KDSLockInFoVC

static NSMutableArray<UIImage *> *connectingBigImages;
static NSMutableArray<UIImage *> *connectingSmallImages;//这2个属性用来缓存蓝牙连接中的动画。
#pragma mark - 生命周期和界面设置方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bleTool = [[KDSBluetoothTool alloc] initWithVC:self];
        _lockState = KDSLockStateInitial;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = UIColor.clearColor;
    self.lock.bleTool = self.bleTool;
    self.lock.bleTool.isAdmin = self.lock.device.is_admin.boolValue;
    __weak typeof(self) weakSelf = self;
    self.bleTool.onAdminModeBlock = ^{
        NSString *tips = [NSString stringWithFormat:Localized(@"lock%@OnAdminModeTips"), weakSelf.lock.device.lockNickName];
        [MBProgressHUD showError:tips];
    };
    self.guardianTimesLabel.text = @"0";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDidOpen:) name:KDSLockDidOpenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDidClose:) name:KDSLockDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockAuthentiateFailed:) name:KDSLockAuthFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDidReport:) name:KDSLockDidReportNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userOperateUnlock:) name:KDSUserUnlockNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLongtimeNoOperation:) name:KDSUserLongtimeNoOperationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userActivateOperationNotification:) name:KDSUserActivateOperationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDidAlarm:) name:KDSLockDidAlarmNotification object:nil];
    ////根据蓝牙锁的功能集判断是开始记录/操作记录
    self.FunctionSetKey = self.lock.lockFunctionSet;
     [self setUI];
    //功能集
    self.isOperationalRecords = [KDSLockFunctionSet[self.FunctionSetKey] containsObject:@23];
    self.s8 = self.lock.device.model.length>=2 ? [[self.lock.device.model substringToIndex:2] isEqualToString:@"S8"] : NO;
    self.supportPIN =  [KDSLockFunctionSet[self.FunctionSetKey] containsObject:@10] ?: NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bleTool.delegate = self;

    if (self.lockState != self.lock.state)
    {
        self.lockState = self.lock.state;
    }
    if (!self.bleTool.connectedPeripheral)
    {
        NSLog(@"1761:%@",self.lock.device.lockNickName);
        [self beginScanForPeripherals];
    }else if (self.lockState != KDSLockStateInitial){
        if (self.lockState == KDSLockStateUnauth)//锁鉴权失败时断开重新连接再次鉴权。
        {
            [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
            return;
        }
        //如果在其它页面连接了蓝牙，设置正确的状态。
        else if ((NSInteger)self.lockState < (NSInteger)KDSLockStateNormal)
        {
            self.lockState = KDSLockStateNormal;
        }
        //有时会获取不到电量或开锁次数。
        if (self.bleTool.connectedPeripheral.power <= 0)
        {
            [self.bleTool getDeviceElectric];
        }
        if (!self.lockUnlockTimes)
        {
            [self getUnlockTimes];
        }
        __weak typeof(self) weakSelf = self;
        [self.bleTool getLockInfo:^(KDSBleError error, KDSBleLockInfoModel * _Nullable infoModel) {
            if (error == KDSBleErrorSuccess)
            {
                weakSelf.lockInfo = infoModel;
                weakSelf.lockState = weakSelf.lockState;
            }
        }];
    }
    [self getUnlockRecord];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.guardianDayLabel.text = @(floor((self.lock.device.currentTime - self.lock.device.createTime) / 24 / 3600)).stringValue;
}

-(void)setUI
{
    CGFloat rate = kScreenHeight / 667;
    rate = rate<1 ? rate : 1;
    [self.bigCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 10 : 26);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@(179 * rate));
    }];
    [self.middleCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bigCircleIV);
        make.width.height.equalTo(@(142 * rate));
    }];
    [self.smallCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.centerY.equalTo(self.bigCircleIV).offset(-6 * rate);
        make.width.height.equalTo(@(30 * rate));
    }];
    [self.bleLogoIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.bottom.equalTo(self.smallCircleIV.mas_top).offset(-14 * rate);
        make.width.height.equalTo(@(18 * rate));
    }];
    [self.deviceStausPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(kScreenHeight<667 ? 15 : 20);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    [self.deviceStausWithInLockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smallCircleIV.mas_bottom).offset(kScreenHeight<667 ? 3 : 10);
        make.centerX.equalTo(self.bigCircleIV);
        make.width.equalTo(@(kScreenWidth - 30));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToConnectBle:)];
    self.bigCircleIV.userInteractionEnabled = YES;
    [self.bigCircleIV addGestureRecognizer:tap];
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageViewUnlock:)];
    [self.bigCircleIV addGestureRecognizer:self.longPressGesture];
    self.bigCircleIV.userInteractionEnabled = YES;
    
    self.synRecordingBtn.layer.masksToBounds = YES;
    [self.synRecordingBtn setTitle:Localized(@"syncRecord") forState:UIControlStateNormal];
    self.synRecordingBtn.layer.cornerRadius = 10;
    self.synRecordingBtn.layer.borderWidth = 1;
    self.synRecordingBtn.layer.borderColor = KDSRGBColor(17, 117, 231).CGColor;
    self.synRecordingView.layer.masksToBounds = YES;
    self.synRecordingView.layer.cornerRadius = 4;
    self.deviceDynamicsView.layer.masksToBounds = YES;
    self.deviceDynamicsView.layer.cornerRadius = 4;
    
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 40;
    _tableView.backgroundColor = self.view.backgroundColor;
    self.automaticallyAdjustsScrollViewInsets = false;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    
    [self.deviceStatusSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat height = kScreenHeight<667 ? 280 : 340;
        make.left.top.right.mas_equalTo(@0);
        make.height.mas_equalTo(@(height));
    }];
    [self.deviceDynamicsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bigCircleIV.mas_bottom).offset(57 * rate);
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.mas_equalTo(@80);
    }];
    [self.view bringSubviewToFront:self.deviceDynamicsView];
    BOOL oldTag = self.lock.device.bleVersion.intValue < 3;
    BOOL isoldLock = [self.FunctionSetKey isEqualToString:@"0x00"];
    if (oldTag || isoldLock)
    {
        self.deviceDynamicsView.hidden = YES;
        [self.synRecordingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0).offset(18);
        }];
    }
    self.guardianDayLabel.text = @(floor((self.lock.device.currentTime - self.lock.device.createTime) / 24 / 3600)).stringValue;
    int times = [[KDSDBManager sharedManager] queryUnlockTimesWithBleName:self.lock.device.lockName];
    if (times > 0) self.lockUnlockTimes = @(times).stringValue;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToViewDeviceDynamicDetails:)];
    [self.deviceDynamicsView addGestureRecognizer:tap];
    self.guardianDayLocalizedLabel.text = Localized(@"guardianTime");
    self.guardianTimesLocalizedLabel.text = Localized(@"guardianTimes");
    self.deviceDynamicLocalizedLabel.text = Localized(@"deviceDynamic");
    self.daysLocalizedLabel.text = Localized(@"days");
    self.timesLocalizedLabel.text = Localized(@"times");
    self.bleSyncLabel.text = Localized(@"bleSyncDoorLockState");
    self.deviceDynamicsLabel.text = Localized(@"normal");
}

#pragma mark - 控件、手势等事件方法
///如果蓝牙未连接，点击中间图片连接蓝牙。
- (void)tapToConnectBle:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded && self.lockState == KDSLockStateBleNotFound)
    {
        [self beginScanForPeripherals];
    }
}

///长按中间的浅绿色视图开锁
- (void)longPressImageViewUnlock:(UILongPressGestureRecognizer *)sender
{
    if (!self.bleTool.connectedPeripheral) return;
    if (sender.state == UIGestureRecognizerStateBegan && (self.lockState == KDSLockStateNormal || self.lockState == KDSLockStateDefence))
    {
        [self checkUnlockAuthThenDealWithResult];
    }
}

///同步记录---刷新设备动态
- (IBAction)synRecordingBtn:(UIButton *)sender {
    self.timeOut = [NSTimer scheduledTimerWithTimeInterval:120.f target:self selector:@selector(timerOutClick:) userInfo:nil repeats:NO];
    [self getUnlockResultThenReport:YES];
}

///点击动态所在父视图进入开锁和报警记录详情页。
- (void)tapToViewDeviceDynamicDetails:(UITapGestureRecognizer *)sender
{
    KDSRecordDetailsVC * vc = [KDSRecordDetailsVC new];
    vc.lock = self.lock;
    vc.didViewDynamic = ^{
        self.deviceDynamicsLabel.text = Localized(@"normal");
        self.deviceDynamicsLabel.textColor = KDSRGBColor(0, 0x7a, 0xff);
        self.deviceDynamicsLabel.tag = 0;
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

///更多事件
-(void)buttonClick:(UIButton *)sender
{
    KDSRecordDetailsVC * vc = [KDSRecordDetailsVC new];
    vc.lock = self.lock;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 网络请求相关方法
///检查授权并处理结果(开锁或者提示没有授权)。
- (void)checkUnlockAuthThenDealWithResult
{
    //如果鉴权失败或者本地没有密码记录，弹框让用户输入密码。如果鉴权失败failed传YES，否则传NO代表本地没有密码记录。
    __weak typeof(self) weakSelf = self;
    void(^authenticateFailedOrNoPwd)(BOOL) = ^(BOOL failed){//是否鉴权失败
        BOOL isRestricted = NO;///是否受限制（系统是否锁定）
        KDSDBManager *manager = [KDSDBManager sharedManager];
        NSString *name = self.lock.device.lockName;
        int times = [manager queryPwdIncorrectTimesWithBleName:name];
        double serverTime = [KDSHttpManager sharedManager].serverTime;
        if (times == 1 && [KDSHttpManager sharedManager].serverTime > 0){
            [manager updatePwdIncorrectFirstTime:serverTime withBleName:name];
        }else if (times > 9){
            double time = [manager queryPwdIncorrectFirstTimeWithBleName:name];
            if (serverTime - time < 300){
                ///系统锁定5分钟
                isRestricted = YES;
                self.lockState = KDSLockStateNormal;;
            }else{
                [manager updatePwdIncorrectFirstTime:serverTime withBleName:name];
                [manager updatePwdIncorrectTimes:1 withBleName:name];
            }
        }
        if (!self.lock.device.is_admin.boolValue && (!self.lock.bleTool.connectedPeripheral.unlockPIN || (self.lock.device.bleVersion.intValue == 1 || self.bleTool.connectedPeripheral.bleVersion == 1)) && ![KDSUserManager sharedManager].netWorkIsAvailable)
        {
            //授权用户无网络状态下，原来不带密码开门策略不让开门（RGBT1761、RGBT1761D、透传模块“bleVersion==1”)
            //带密码策略（其他）则需要重新输入密码（可以开门）
            [MBProgressHUD showError:Localized(@"Authorized users must have a network to unlock!")];
            return ;
        }
        if (self.lock.device.is_admin.boolValue && (!self.lock.bleTool.connectedPeripheral.unlockPIN || (self.lock.device.bleVersion.intValue == 1 || self.bleTool.connectedPeripheral.bleVersion == 1)) && ![KDSUserManager sharedManager].netWorkIsAvailable) {
            //主用户、RGBT1761蓝牙模块、透传蓝牙模块不带密码开门
            [self unlockWithPassword:nil];
            return;
        }
        NSString *title = failed ? Localized(@"checkUnlockAuthrizationFailed") : Localized(@"pleaseInputLockPassword");
        title = isRestricted ? Localized(@"unlockRestricted") : title;
        NSString *message = failed ? Localized(@"changeNetwork") : nil;
        message = isRestricted ? Localized(@"pwdIncorrectTooMany") : message;
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        //取消按钮
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.lockState = KDSLockStateNormal;
        }];
        if (!isRestricted && self.lock.bleTool.connectedPeripheral.unlockPIN)
        {
            //系统没有锁定且有密码策略才添加输入框
            [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.secureTextEntry = YES;
                textField.textAlignment = NSTextAlignmentCenter;
                textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
                textField.font = [UIFont systemFontOfSize:13];
                [textField addTarget:weakSelf action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
            }];
            //只有添加了输入框，才有取消按钮
            [ac addAction:cancel];
        }
        UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isRestricted) return;
            NSString *pwd = [ac.textFields.firstObject.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ((pwd.length > 0 && pwd.length < 6 )|| pwd.length > 12) {
                [MBProgressHUD showError:Localized(@"Please enter the correct 6-12 digit password")];
                [weakSelf setLockState:KDSLockStateNormal];
            }else{
                pwd.length==0 ? (void)(weakSelf.lockState = KDSLockStateNormal) : [weakSelf unlockWithPassword:pwd];
            }
        }];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    };
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"checkingAuthorization")];
    [[KDSHttpManager sharedManager] checkUnlockAuthWithUid:[KDSUserManager sharedManager].user.uid token:[KDSUserManager sharedManager].user.token bleName:self.lock.device.lockName isAdmin:self.lock.device.is_admin.boolValue isNewDevice:self.bleTool.connectedPeripheral.isNewDevice success:^{
        [hud hideAnimated:NO];
        if ((!self.lock.device.is_admin.boolValue && !self.supportPIN) || self.lock.device.bleVersion.intValue == 1 || !self.lock.bleTool.connectedPeripheral.unlockPIN) {
            //非主用户且功能集不包含10、RGBT1761蓝牙模块、透传蓝牙模块不带密码开门
            [self unlockWithPassword:nil];
        }else{
            NSString *pwd = [[KDSDBManager sharedManager] queryUnlockPwdWithBleName:self.lock.device.lockName];
            
            //检查开锁权限成功后：只要没有蓝牙锁密码记录都要输入密码开锁（鉴权成功）
            pwd.length>0 ? [self unlockWithPassword:pwd] : authenticateFailedOrNoPwd(NO);
        }
        
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        //鉴权失败
        authenticateFailedOrNoPwd(YES);
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        //鉴权失败
        authenticateFailedOrNoPwd(YES);
    }];
}

///获取第一页的开锁记录，并刷新表视图。
- (void)getUnlockRecord
{
    void(^failure)(void) = ^{
        if (self.unlockRecordArr.count) return;
        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = Localized(@"noUnlockRecord,pleaseSync");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        self.tableView.tableHeaderView = label;
    };
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    [[KDSHttpManager sharedManager] getBlePwdListWithUid:uid bleName:self.lock.device.lockName pwdType:KDSServerKeyTpyeAll success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
        self.keys = pwdlistArray;
        if (self.isOperationalRecords) {
            ///操作记录
             [self loadOperationalRecords];
        }else{
            ///开锁记录
            [[KDSHttpManager sharedManager] getBindedDeviceUnlockRecordWithUid:uid bleName:self.lock.device.lockName index:1 success:^(NSArray<News *> * _Nonnull news) {
                
                if (news.count == 0)
                {
                    self.unlockRecordArr = @[];
                    failure();
                    return;
                }
                [self getUnlockRecordWithNewsArray:news];
                
            } error:^(NSError * _Nonnull error) {
                failure();
                [self getUnlockRecordWithNewsArray:self.unlockRecordNews];
            } failure:^(NSError * _Nonnull error) {
                failure();
                [self getUnlockRecordWithNewsArray:self.unlockRecordNews];
            }];
        }
    } error:^(NSError * _Nonnull error) {
        failure();
        [self getUnlockRecordWithNewsArray:self.unlockRecordNews];
    } failure:^(NSError * _Nonnull error) {
        failure();
        [self getUnlockRecordWithNewsArray:self.unlockRecordNews];
    }];
}

-(void)getUnlockRecordWithNewsArray:(NSArray *)news
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray<News *> *section = [NSMutableArray array];
    __block NSString *date = nil;
    news = [news sortedArrayUsingComparator:^NSComparisonResult(News *  _Nonnull obj1, News *  _Nonnull obj2) {
        return [obj2.open_time compare:obj1.open_time];
    }];
    [news enumerateObjectsUsingBlock:^(News * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!date)
        {
            if (obj.open_time) {
                date = [obj.open_time componentsSeparatedByString:@" "].firstObject;
                [section addObject:obj];
            }
        }
        else if ([date isEqualToString:[obj.open_time componentsSeparatedByString:@" "].firstObject])
        {
            [section addObject:obj];
        }
        else
        {
            if (section.count >0) {
                [sections addObject:[NSArray arrayWithArray:section]];
            }
            [section removeAllObjects];
            if (obj.open_time) {
                date = [obj.open_time componentsSeparatedByString:@" "].firstObject;
                [section addObject:obj];
            }
        }
    }];
    if (section.count >0) {
        [sections addObject:[NSArray arrayWithArray:section]];
    }
    self.unlockRecordArr = sections.copy;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
    [self.tableView reloadData];
}

////操作记录
-(void)loadOperationalRecords
{
    [[KDSHttpManager sharedManager] getBindedDeviceOperationalRecordsWithBleName:self.lock.device.lockName index:1 success:^(NSArray<KDSOperationalRecord *> * _Nonnull news) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (news.count == 0)
        {
            self.czOperationalArr = nil;
            UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = Localized(@"noUnlockRecord,pleaseSync");
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
            label.font = [UIFont systemFontOfSize:12];
            self.tableView.tableHeaderView = label;
            return;
        }
        NSMutableArray * opArrs = [NSMutableArray array];
        BOOL contain = NO;
        for (KDSOperationalRecord * new in news) {
            if (new.eventType != 3) {///非报警记录
                [opArrs addObject:new];
            }
        }
        for (KDSOperationalRecord *n in opArrs)
        {
            if ([self.czOperationalArr containsObject:n])
            {
                contain = YES;
                break;
            }
            [self.czOperationalArr insertObject:n atIndex:[opArrs indexOfObject:n]];
        }
        [self reloadTableView:self.tableView];
    } error:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


/**
 *@abstract 刷新表视图，调用此方法前请确保开锁或者报警记录的属性数组内容已经更新。方法执行时会自动提取分组记录。
 *@param tableView 要刷新的表视图。
 */
- (void)reloadTableView:(UITableView *)tableView
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray<KDSOperationalRecord *> *section = [NSMutableArray array];
    __block NSString *date = nil;
    [self.czOperationalArr sortUsingComparator:^NSComparisonResult(KDSOperationalRecord *  _Nonnull obj1, KDSOperationalRecord *  _Nonnull obj2) {
        return [obj2.open_time compare:obj1.open_time];
    }];
    [self.czOperationalArr enumerateObjectsUsingBlock:^(KDSOperationalRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!date)
        {
            date = [obj.open_time componentsSeparatedByString:@" "].firstObject;
            [section addObject:obj];
        }
        else if ([date isEqualToString:[obj.open_time componentsSeparatedByString:@" "].firstObject])
        {
            [section addObject:obj];
        }
        else
        {
            [sections addObject:[NSArray arrayWithArray:section]];
            [section removeAllObjects];
            date = [obj.open_time componentsSeparatedByString:@" "].firstObject;
            [section addObject:obj];
        }
    }];
    [sections addObject:[NSArray arrayWithArray:section]];
    self.czOPerationalSectionArr = [NSArray arrayWithArray:sections];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
    [self.tableView reloadData];
    
}

#pragma mark - setter：当蓝牙返回的锁状态发送改变时，刷新界面。
///锁及蓝牙状态改变时设置状态标签和图片，刷新界面。
- (void)setLockState:(KDSLockState)lockState
{
    KDSLockState temp = _lockState;
    _lockState = lockState;
    self.lock.state = lockState;
    if (self.animating) return;
    self.bigCircleIV.image = [UIImage imageNamed:@"bigBlueCircle"];
    self.bleLogoIV.hidden = NO;
    self.deviceStausWithInLockLabel.textColor = UIColor.whiteColor;
    if (lockState==KDSLockStateInitial || lockState==KDSLockStateBleClosed || lockState==KDSLockStateBleNotFound)
    {
        self.middleCircleIV.image = [UIImage imageNamed:@"bleNotConnect"];
        self.smallCircleIV.image = [UIImage imageNamed:@"蓝牙-未连接"];
        self.bleLogoIV.hidden = YES;
        self.deviceStausWithInLockLabel.textColor = KDSRGBColor(0x14, 0xa6, 0xf5);
    }
    switch (lockState)
    {
        case KDSLockStateInitial:
            ///初始状态
            self.deviceStausPromptLabel.text = Localized(@"bleConnecting");
            self.deviceStausWithInLockLabel.text = Localized(@"bleConnecting");
            if (!self.smallCircleIV.animating) [self connectingAnimationEnable:YES];
            break;
            
        case KDSLockStateBleClosed:
            ///蓝牙关闭
            self.deviceStausPromptLabel.text = Localized(@"bleNotOpen");
            self.deviceStausWithInLockLabel.text = Localized(@"bleNotConnect");
            break;
            
        case KDSLockStateBleNotFound:
            ///没有搜索到绑定的蓝牙
            self.deviceStausWithInLockLabel.text = Localized(@"bleNotConnect");
            self.deviceStausPromptLabel.text = Localized(@"lockOutOfScope");
            //锁操作动画阶段tag设置为非0
            if (self.bigCircleIV.tag == 0) [self connectingAnimationEnable:NO];
            break;
            
        case KDSLockStateReset://返回的值不能作为一定被重置的条件
        case KDSLockStateUnauth:
            self.deviceStausWithInLockLabel.text = Localized(@"lockAuthFailed");
            self.deviceStausPromptLabel.text = Localized(@"lockAuthFailed");
            self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
            //锁操作动画阶段tag设置为非0
            if (self.bigCircleIV.tag == 0) [self connectingAnimationEnable:NO];
            break;
            
        case KDSLockStateNormal:
        case KDSLockStateDefence:
        case KDSLockStateLockInside:
        case KDSLockStateSecurityMode:
            //锁操作动画阶段tag设置为非0
            if (self.bigCircleIV.tag == 0) [self connectingAnimationEnable:NO];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.deviceStausWithInLockLabel.text = Localized(@"longPressUnlock");
            self.deviceStausPromptLabel.text = Localized(@"lockDidClose");
            if (self.lockInfo)
            {
                int32_t state = self.lockInfo.lockState;
                int32_t func = self.lockInfo.lockFunc;
                NSString *tips = nil, *imgName = nil;
                char defenceMode = ((state >> 8) & 1) && ((func >> 4) & 0x1);
                char lockInside = !((state >> 2) & 1) && ((func >> 14) & 0x1);
                char securityMode = ((state >> 5) & 1) && ((func >> 13) & 0x1);
                self.bigCircleIV.userInteractionEnabled = !(lockInside || securityMode);
                if (defenceMode)
                {
                    tips = Localized(@"defenceMode"); imgName = @"lockDefence";
                }
                else if (lockInside)
                {
                    tips = Localized(@"lockInside"); imgName = @"lockInside";
                    self.deviceStausWithInLockLabel.text = nil;
                }
                else if (securityMode)
                {
                    self.bigCircleIV.image = [UIImage imageNamed:@"securityModeBigCircle"];
                    tips = Localized(@"securityMode"); imgName = @"securityMode";
                    self.deviceStausWithInLockLabel.text = nil;
                }
                if (tips)
                {
                    self.middleCircleIV.image = [UIImage imageNamed:imgName];
                    self.deviceStausPromptLabel.text = tips;
                    if (temp != lockState)//防止循环递归。
                    {
                        self.lockState = defenceMode ? KDSLockStateDefence : (lockInside ? KDSLockStateLockInside : KDSLockStateSecurityMode);
                    }
                    break;
                }
            }
            self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
            break;
            
        case KDSLockStateUnlocking:
            ///正在开锁
            self.deviceStausPromptLabel.text = Localized(@"unlocking");
            [self stagingLockOperationAnimation:1];
            break;
            
        case KDSLockStateUnlocked:
        {
            ///开锁成功
            self.deviceStausPromptLabel.text = Localized(@"unlocked");
            [self stagingLockOperationAnimation:2];
            //好像并不是所有的锁都会主动发送锁已关闭消息。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.lockState == KDSLockStateUnlocked)
                {
                    [self setLockState:KDSLockStateClosed];
                }
            });
        }
            break;
            
        case KDSLockStateFailed:
            [self stagingLockOperationAnimation:3];
            [self setLockState:KDSLockStateNormal];
            break;
            
        case KDSLockStateClosed:
            [self stagingLockOperationAnimation:4];
            [self setLockState:KDSLockStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)setLockUnlockTimes:(NSString *)lockUnlockTimes
{
    _lockUnlockTimes = lockUnlockTimes;
    self.guardianTimesLabel.text = lockUnlockTimes ?: @"0";
}

#pragma mark - 动画
///蓝牙连接动画。enable参数控制启动或者停止动画。先设置提示内容标签再调用该方法。如果正在展示连接动画，smallCircleIV处于动画状态。
- (void)connectingAnimationEnable:(BOOL)enable
{
    if (enable)
    {
        [self stagingLockOperationAnimation:3];//处于开锁动画阶段进入后台
        int capacity = 58;
        NSMutableArray *bigImages = connectingBigImages ?: [NSMutableArray arrayWithCapacity:capacity];
        NSMutableArray *smallImages = connectingSmallImages ?: [NSMutableArray arrayWithCapacity:capacity];
        if (!connectingSmallImages)
        {
            for (int i = 0; i < capacity; ++i)
            {
                UIImage *bigImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"bigCircle%d.png", i + 1] ofType:nil]];
                [bigImages addObject:bigImg];
                UIImage *smallImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"smallCircle%d.png", i + 1] ofType:nil]];
                [smallImages addObject:smallImg];
            }
            connectingBigImages = bigImages;
            connectingSmallImages = smallImages;
        }
        self.bigCircleIV.animationImages = bigImages;
        self.middleCircleIV.hidden = self.deviceStausWithInLockLabel.hidden = YES;
        self.bigCircleIV.animationDuration = bigImages.count * 0.04;
        self.bigCircleIV.animationRepeatCount = 1;
        [self.bigCircleIV startAnimating];
        self.smallCircleIV.animationImages = smallImages;
        self.smallCircleIV.animationDuration = smallImages.count * 0.04;
        [self.smallCircleIV startAnimating];
        //创建一个临时的视图遮住连接标签，做一个动画。
        UIView *maskView = [[UIView alloc] initWithFrame:self.deviceStausWithInLockLabel.frame];
        maskView.clipsToBounds = YES;
        [self.view addSubview:maskView];
        CGRect frame = maskView.bounds;
        frame.origin.y -= frame.size.height;
        UILabel *connectingLabel = [[UILabel alloc] initWithFrame:frame];
        connectingLabel.text = self.deviceStausWithInLockLabel.text;
        connectingLabel.font = self.deviceStausWithInLockLabel.font;
        connectingLabel.textColor = self.deviceStausWithInLockLabel.textColor;
        connectingLabel.textAlignment = NSTextAlignmentCenter;
        [maskView addSubview:connectingLabel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * 0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            connectingLabel.alpha = 0;
            [UIView animateWithDuration:(bigImages.count - 15 - 20) * 0.04 animations:^{
                connectingLabel.frame = maskView.bounds;
                connectingLabel.alpha = 1;
            }];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((bigImages.count - 4) * 0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.middleCircleIV.hidden = self.deviceStausWithInLockLabel.hidden = NO;
            [maskView removeFromSuperview];
        });
    }
    else
    {
        self.middleCircleIV.hidden = NO;
        if (self.bigCircleIV.animating) [self.bigCircleIV stopAnimating];
        self.bigCircleIV.animationImages = nil;
        if (self.smallCircleIV.animating) [self.smallCircleIV stopAnimating];
        self.smallCircleIV.animationImages = nil;
    }
}

///启动连接成功的动画，完成后会移除相关动画，执行completion回调。
- (void)startConnectedAnimation:(nullable void(^)(void))completion
{
    self.animating = YES;
    int capacity = 44;
    NSMutableArray *bigImages = [NSMutableArray arrayWithCapacity:capacity];
    NSMutableArray *smallImages = [NSMutableArray arrayWithCapacity:capacity];
    for (int i = 0; i < capacity; ++i)
    {
        UIImage *bigImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"connectedBigCircle%d.png", i + 1] ofType:nil]];
        [bigImages addObject:bigImg];
        UIImage *smallImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"connectedSmallCircle%d.png", i + 1] ofType:nil]];
        [smallImages addObject:smallImg];
    }
    self.bigCircleIV.animationImages = bigImages;
    self.bigCircleIV.animationDuration = bigImages.count * 0.04;
    self.bigCircleIV.animationRepeatCount = 1;
    [self.bigCircleIV startAnimating];
    //创建一个临时的视图挡住中间的圆。
    UIImageView *copyMiddleIV = [[UIImageView alloc] initWithFrame:self.middleCircleIV.frame];
    copyMiddleIV.image = [UIImage imageNamed:@"bleConnected"];
    [self.view addSubview:copyMiddleIV];
    //创建一个临时的视图遮住连接标签，做一个动画。
    UIView *maskView = [[UIView alloc] initWithFrame:self.deviceStausWithInLockLabel.frame];
    maskView.clipsToBounds = YES;
    [self.view addSubview:maskView];
    CGRect frame = maskView.bounds;
    UILabel *connectingLabel = [[UILabel alloc] initWithFrame:frame];
    connectingLabel.text = Localized(@"bleConnecting");
    connectingLabel.font = self.deviceStausWithInLockLabel.font;
    connectingLabel.textColor = KDSRGBColor(0x14, 0xa6, 0xf5);
    connectingLabel.textAlignment = NSTextAlignmentCenter;
    [maskView addSubview:connectingLabel];
    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:bigImages.count * 0.02 animations:^{
        //连接标签缩进动画
        connectingLabel.frame = frame;
        connectingLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
        connectingLabel.text = Localized(@"bleConnectSuccess");
        [UIView animateWithDuration:(bigImages.count - 1) * 0.02 animations:^{
            //连接成功展开动画
            connectingLabel.frame = maskView.bounds;
            connectingLabel.alpha = 1;
        } completion:^(BOOL finished) {
            
            UIImage *logoImg = self.bleLogoIV.image;
            UIImageView *copyLogoIV = [[UIImageView alloc] initWithImage:logoImg];
            copyLogoIV.alpha = 0;
            copyLogoIV.bounds = (CGRect){0, 0, logoImg.size.width * 2, logoImg.size.height * 2};
            copyLogoIV.center = self.smallCircleIV.center;
            [self.view addSubview:copyLogoIV];
            UIImageView *copySmallCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closedLock"]];
            copySmallCircleIV.bounds = CGRectZero;
            copySmallCircleIV.center = self.smallCircleIV.center;
            copySmallCircleIV.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:copySmallCircleIV];
            
            [UIView animateWithDuration:0.2 animations:^{
                //logo显示并缩小动画
                copyLogoIV.bounds = (CGRect){0, 0, logoImg.size};
                copyLogoIV.center = (CGPoint){copyLogoIV.center.x, copyLogoIV.center.y - logoImg.size.height / 2};
                copyLogoIV.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.8 animations:^{
                    //logo移动并锁放大动画
                    copyLogoIV.center = self.bleLogoIV.center;
                    copySmallCircleIV.bounds = self.smallCircleIV.bounds;
                } completion:nil];
            }];
            connectingLabel.textColor = UIColor.whiteColor;
            connectingLabel.text = Localized(@"longPressUnlodk");
            connectingLabel.frame = frame;
            [UIView animateWithDuration:1.2 animations:^{
                //长按开锁标签展开动画。和logo显示并缩小+移动的时间一致。
                connectingLabel.frame = maskView.bounds;
            } completion:^(BOOL finished) {
                [maskView removeFromSuperview];
                [copyLogoIV removeFromSuperview];
                [copySmallCircleIV removeFromSuperview];
                [copyMiddleIV removeFromSuperview];
                [self.bigCircleIV stopAnimating];
                self.bigCircleIV.animationImages = nil;
                self.animating = NO;
                //self.lockState = self.lockState;
                !completion ?: completion();
            }];
    
        }];
    }];
}

/**
 *@brief 启动蓝牙开锁/关锁各阶段动画。
 *@param stage 阶段，其中：1表示开锁过程动画，2表示开锁成功动画，3表示开锁失败动画，4表示关锁动画。当开锁失败或者关锁时移除视图。
 */
- (void)stagingLockOperationAnimation:(int)stage
{
    NSInteger gearTag = @"gearIV".hash, cMiddleTag = @"cMiddleIV".hash, cSmallTag = @"cSmallIV".hash;
    UIImageView *gearIV = [self.view viewWithTag:gearTag];//锯齿外圈
    UIImageView *cMiddleIV = [self.view viewWithTag:cMiddleTag];//中间视图的复制
    UIImageView *cSmallIV = [self.view viewWithTag:cSmallTag];//小视图的复制
    self.bigCircleIV.tag = 1;
    if (!gearIV)
    {
        gearIV = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlockGear78.png" ofType:nil]]];
        gearIV.tag = gearTag;
        gearIV.frame = self.middleCircleIV.frame;
        [self.view addSubview:gearIV];
        
        cMiddleIV = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlockMiddleCircle78.png" ofType:nil]]];
        cMiddleIV.tag = cMiddleTag;
        cMiddleIV.frame = self.middleCircleIV.frame;
        [self.view addSubview:cMiddleIV];
        
        cSmallIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closedLock"]];
        cSmallIV.contentMode = UIViewContentModeScaleAspectFit;
        cSmallIV.tag = cSmallTag;
        cSmallIV.frame = self.smallCircleIV.frame;
        [self.view addSubview:cSmallIV];
        
        self.middleCircleIV.hidden = self.smallCircleIV.hidden = YES;
        [self.view bringSubviewToFront:self.bleLogoIV];
        [self.view bringSubviewToFront:self.deviceStausWithInLockLabel];
    }
    if (stage == 1)//开锁过程动画，初始化动画视图。
    {
        int capacity = 78;
        NSMutableArray *bigImages = [NSMutableArray arrayWithCapacity:capacity];
        NSMutableArray *gearImages = [NSMutableArray arrayWithCapacity:capacity];
        NSMutableArray *middleImages = [NSMutableArray arrayWithCapacity:capacity];
        for (int i = 0; i < capacity; ++i)
        {
            UIImage *bigImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockBigCircle%d.png", i + 1] ofType:nil]];
            [bigImages addObject:bigImg];
            UIImage *gearImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockGear%d.png", i + 1] ofType:nil]];
            [gearImages addObject:gearImg];
            UIImage *middleImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockMiddleCircle%d.png", i + 1] ofType:nil]];
            [middleImages addObject:middleImg];
        }
        self.bigCircleIV.animationImages = bigImages;
        self.bigCircleIV.animationDuration = bigImages.count * 0.04;
        self.bigCircleIV.animationRepeatCount = 1;
        [self.bigCircleIV startAnimating];
        gearIV.animationImages = gearImages;
        gearIV.animationRepeatCount = 1;
        gearIV.animationDuration = gearImages.count * 0.04;
        [gearIV startAnimating];
        
        cMiddleIV.animationImages = middleImages;
        cMiddleIV.animationRepeatCount = 1;
        cMiddleIV.animationDuration = middleImages.count * 0.04;
        [cMiddleIV startAnimating];
        
        [UIView animateWithDuration:capacity * 0.01 animations:^{
            self.bleLogoIV.transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.bleLogoIV.alpha = 0.0;
            self.deviceStausWithInLockLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.deviceStausWithInLockLabel.alpha = 0.0;
            cSmallIV.center = self.bigCircleIV.center;
        }];
        
        return;
    }
    
    if (gearIV.animating) [gearIV stopAnimating];
    if (cMiddleIV.animating) [cMiddleIV stopAnimating];
    if (self.bigCircleIV.animating) [self.bigCircleIV stopAnimating];
    gearIV.animationImages = nil;
    cMiddleIV.animationImages = nil;
    self.bigCircleIV.animationImages = nil;
    if (stage == 2)//开锁成功动画
    {
        self.deviceStausWithInLockLabel.alpha = 0.0;
        self.bleLogoIV.alpha = 0.0;
        int capacity = 25;
        NSMutableArray *successImages = [NSMutableArray arrayWithCapacity:capacity];
        for (int i = 54; i < capacity + 54; ++i)
        {
            UIImage *successImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockSuccess%d.png", i] ofType:nil]];
            [successImages addObject:successImg];
        }
        cSmallIV.image = successImages.lastObject;
        cSmallIV.animationImages = successImages;
        cSmallIV.animationDuration = capacity * 0.04;
        cSmallIV.animationRepeatCount = 1;
        [cSmallIV startAnimating];
        return;
    }
    void(^stopAnimationAndRemoveViews)(void) = ^{
        if (cSmallIV.animating) [cSmallIV stopAnimating];
        cSmallIV.animationImages = nil;
        [cSmallIV removeFromSuperview];
        self.middleCircleIV.hidden = self.smallCircleIV.hidden = NO;
        [gearIV removeFromSuperview];
        [cMiddleIV removeFromSuperview];
        self.bleLogoIV.transform = self.deviceStausWithInLockLabel.transform = CGAffineTransformIdentity;
        self.bleLogoIV.alpha = self.deviceStausWithInLockLabel.alpha = 1.0;
        self.bigCircleIV.tag = 0;
    };
    if (stage == 3)//开锁失败动画
    {
        stopAnimationAndRemoveViews();
        return;
    }
    if (stage == 4)//关锁动画
    {
        cSmallIV.center = self.smallCircleIV.center;
        cSmallIV.bounds = CGRectZero;
        cSmallIV.image = [UIImage imageNamed:@"closedLock"];
        [UIView animateWithDuration:27 * 0.04 animations:^{
            cSmallIV.frame = self.smallCircleIV.frame;
        } completion:^(BOOL finished) {
            stopAnimationAndRemoveViews();
        }];
        return;
    }
}
/**
 解析蓝牙版本为存数字的字符串以便比较大小
 @return 蓝牙版本
 */
-(NSString *)parseBluetoothVersion{
    //截取出字符串后带了\u0000
//    NSString *bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].lastObject;
    NSString *bleVesion ;
    if (!self.lock.bleTool.connectedPeripheral.softwareVer.length) {
        bleVesion = [self.lock.device.softwareVersion componentsSeparatedByString:@"-"].firstObject;
    }else{
        bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].firstObject;
    }
    //去掉NSString中的\u0000
    if (bleVesion.length > 9) {
        //挽救K9S、V6、V7第一版本的字符串带\u0000错误
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
- (void)checkBleOTA:(CBPeripheral *)peripheral{
    
    NSString *softwareRev = [self parseBluetoothVersion];
//    NSLog(@"--{Kaadas}--检查OTA的softwareVer111=%@",softwareRev);
//    NSLog(@"--{Kaadas}--检查OTA的deviceSN111:%@",self.lock.device.deviceSN);
    [[KDSHttpManager sharedManager] checkBleOTAWithSerialNumber:self.lock.device.deviceSN withCustomer:1 withVersion:softwareRev withDevNum:1 success:^(NSString *URL) {
        NSLog(@"--{Kaadas}--OTA--URL=%@",URL);
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"newImage") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self chooseOTASolution:URL withPeripheral:peripheral];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [ac addAction:cancelAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Lock OTA upgrade") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Lock OTA upgrade") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }];
    
}
#pragma mark - 蓝牙工具相关方法。
///搜索蓝牙，更新界面。
- (void)beginScanForPeripherals
{
    if (self.bleTool.centralManager.state != CBCentralManagerStatePoweredOn || self.bleTool.connectedPeripheral) return;
    ///据蓝牙开发所说，手机蓝牙断开不一定锁蓝牙状态也是断开，所以这里延迟一秒再重新连接。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bleTool beginScanForPeripherals];
        NSLog(@"首页搜索设备广播名称：%@---昵称：%@",self.lock.bleTool.connectedPeripheral.advDataLocalName,self.lock.device.lockNickName);
    });
    self.lockState = KDSLockStateInitial;
}

/**
 *@abstract 通过蓝牙发送开锁命令。
 *@param password 开锁密码，如果此密码长度不为0，则使用此密码开锁(请确保密码长度为6~12字节)，否则使用不鉴权模式开锁。
 */
- (void)unlockWithPassword:(nullable NSString *)password
{
    __weak typeof(self) weakSelf = self;
    [self setLockState:KDSLockStateUnlocking];
    KDSBleLockControl keytype = password.length>0 ? KDSBleLockControlKeyPIN : KDSBleLockControlKeyAPP;
    [self.lock.bleTool operateLockWithPwd:password actionType:KDSBleLockControlActionUnlock keyType:keytype completion:^(KDSBleError error, CBPeripheral * _Nullable peripheral) {
        if (error == KDSBleErrorSuccess)
        {
            AudioServicesPlaySystemSound(1520);
            /*[weakSelf setLockState:KDSLockStateUnlocked];
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [weakSelf getUnlockResultThenReport:NO];
             });*/
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf.lockState == KDSLockStateUnlocking)
                {
                    weakSelf.lockState = KDSLockStateClosed;
                }
            });
        }
        else
        {
            [weakSelf setLockState:KDSLockStateFailed];
            [MBProgressHUD showError:Localized(@"开锁失败")];
        }
        //管理账号开锁时，无论开锁成功与否，都更新本地记录的开锁密码。
        if (password.length)
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *bleName = weakSelf.lock.device.lockName;
                if (error == KDSBleErrorSuccess)
                {
                    [[KDSDBManager sharedManager] updateUnlockPwd:password withBleName:bleName];
                }
                else if ((int)error <= 0xff)
                {
                    [[KDSDBManager sharedManager] updateUnlockPwd:nil withBleName:bleName];
                }
            });
        }
    }];
}

///获取开锁次数。
- (void)getUnlockTimes
{
    __weak typeof(self) weakSelf = self;
    [self.lock.bleTool getUnlockTimes:^(KDSBleError error, int times) {
        if (error == KDSBleErrorSuccess)
        {
            [weakSelf setLockUnlockTimes:@(times).stringValue];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[KDSDBManager sharedManager] updateUnlockTimes:times withBleName:weakSelf.lock.device.lockName];
            });
        }
    }];
    
}

///获取开锁记录并向服务器上传记录。如果点同步按钮参数传YES显示一个菊花。
- (void)getUnlockResultThenReport:(BOOL)hasTips
{
    if (!self.lock.connected)
    {
        if (hasTips) [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    if (hasTips && !self.recHud)
    {
        self.recHud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        self.recHud.label.text = Localized(@"synchronizingRecord");
        self.recHud.removeFromSuperViewOnHide = YES;
    }
    if (self.recReceipt) return;
    if (self.isOperationalRecords) {
        ///操作记录
        [self updateAllCzRecord];
    }else{
        ///开锁记录
        __weak typeof(self) weakSelf = self;
        KDSDBManager *manager = [KDSDBManager sharedManager];
        NSString *bleName = self.lock.device.lockName;///
        NSString *data = nil;
//        if (![KDSUserManager sharedManager].netWorkIsAvailable) {
//            data = nil;
//        }else{
//            data = [manager queryUploadRecordDataWithBleName:bleName type:0];
//        }
        
        KDSBleUnlockRecord *cachedRec = [[KDSBleUnlockRecord alloc] initWithHexString:data];
        self.recReceipt = [self.lock.bleTool updateRecord:1 afterData:data completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleUnlockRecord *> * _Nullable records) {
            
            if (error != KDSBleErrorSuccess && finished)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                    [weakSelf.recHud hideAnimated:NO];
                    //单独对于开门和报警记录返回错误8B提示
                    error != KDSBleErrorNotFound?[MBProgressHUD showError:[NSString stringWithFormat:@"error: %ld", (long)error]]:[MBProgressHUD showError:Localized(@"noRecord")];
                    weakSelf.recReceipt = nil;
                    weakSelf.recHud = nil;
                });
                return;
            }
            if (finished)
            {
                [self.timeOut invalidate];
                self.timeOut = nil;
                weakSelf.recReceipt = nil;
                [weakSelf.recHud hideAnimated:NO];
                weakSelf.recHud = nil;
                [MBProgressHUD showSuccess:Localized(@"syncComplete")];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSMutableArray<KDSBleUnlockRecord *> *mRecords = [NSMutableArray arrayWithArray:@[]];
                    NSInteger index = -1;
                    for (KDSBleUnlockRecord *record in records)
                    {
                        if ([cachedRec isEqual:record])
                        {
                            index = [records indexOfObject:record];
                            break;
                        }
                        [mRecords containsObject:record] ?: [mRecords addObject:record];
                    }
                    [mRecords sortUsingComparator:^NSComparisonResult(KDSBleUnlockRecord *  _Nonnull obj1, KDSBleUnlockRecord *  _Nonnull obj2) {
                        return [obj2.date compare:obj1.date];
                    }];
                    if (index != -1 || records.firstObject.total == records.count)
                    {
                        [manager updateUploadRecordData:records.firstObject.hexString withBleName:bleName type:0];
                    }
                    //获取完全部数据再在数据库中记录
                    if (records.firstObject.total==records.count || [[records.lastObject.hexString substringFromIndex:12] isEqualToString:[data substringFromIndex:12]])
                    {
                        [manager updateUploadRecordData:mRecords.firstObject.hexString withBleName:bleName type:0];
                    }
                    [self.unlockRecordNews removeAllObjects];
                    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
                        for (KDSBleUnlockRecord *record in mRecords)
                        {
                            News *n = [News new];
                            n.open_time = record.date;
                            n.open_type = record.unlockType;
                            n.user_num = record.userNum;
                            [self.unlockRecordNews addObject:n];
                        }
                        [weakSelf getUnlockRecord];
                        return ;
                            
                    }
                    
                    NSString *uid = [KDSUserManager sharedManager].user.uid;
                    [[KDSHttpManager sharedManager] getBlePwdListWithUid:uid bleName:bleName pwdType:KDSServerKeyTpyeAll success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
                        NSMutableArray *news = [NSMutableArray array];
                        for (KDSBleUnlockRecord *record in mRecords)
                        {
                            News *n = [News new];
                            n.open_time = record.date;
                            n.open_type = record.unlockType;
                            n.user_num = record.userNum;
                            if ([n.open_type isEqualToString:@"密码"])
                            {
                                for (KDSPwdListModel *m in pwdlistArray)
                                {
                                    if ((m.pwdType == KDSServerKeyTpyePIN || m.pwdType == KDSServerKeyTpyeTempPIN) && m.num.intValue == n.user_num.intValue)
                                    {
                                        if (m.nickName) n.nickName = m.nickName;
                                        break;
                                    }
                                }
                            }
                            else if ([n.open_type isEqualToString:@"卡片"])
                            {
                                for (KDSPwdListModel *m in pwdlistArray)
                                {
                                    if (m.pwdType == KDSServerKeyTpyeCard && m.num.intValue == n.user_num.intValue)
                                    {
                                        if (m.nickName) n.nickName = m.nickName;
                                        break;
                                    }
                                }
                            }
                            else if ([n.open_type isEqualToString:@"指纹"])
                            {
                                for (KDSPwdListModel *m in pwdlistArray)
                                {
                                    if (m.pwdType == KDSServerKeyTpyeFingerprint && m.num.intValue == n.user_num.intValue)
                                    {
                                        if (m.nickName) n.nickName = m.nickName;
                                        break;
                                    }
                                }
                            }
                            [news addObject:n];
                        }
                        [[KDSHttpManager sharedManager] uploadBindedDeviceUnlockRecord:news withUid:uid device:weakSelf.lock.device success:^{
                            ///上传成功删除本地缓存的开锁记录
                            [manager deleteRecord:2 bleName:bleName];
                            [weakSelf.recHud hideAnimated:NO];
                            [weakSelf getUnlockRecord];
                            weakSelf.recHud = nil;
                        } error:^(NSError * _Nonnull error) {
                            [manager insertRecord:mRecords type:0 bleName:bleName];
                            [weakSelf.recHud hideAnimated:NO];
                            weakSelf.recHud = nil;
                        } failure:^(NSError * _Nonnull error) {
                            [manager insertRecord:mRecords type:0 bleName:bleName];
                            [weakSelf.recHud hideAnimated:NO];
                            weakSelf.recHud = nil;
                        }];
                    } error:^(NSError * _Nonnull error) {
                        [manager insertRecord:mRecords type:0 bleName:bleName];
                        [weakSelf.recHud hideAnimated:NO];
                        weakSelf.recHud = nil;
                    } failure:^(NSError * _Nonnull error) {
                        [manager insertRecord:mRecords type:0 bleName:bleName];
                        [weakSelf.recHud hideAnimated:NO];
                        weakSelf.recHud = nil;
                    }];
                    
                });
            }
        }];
    }
}


/**
 *@abstract 获取锁中指定数据后的的操作记录，然后更新最后一次更新时间后的操作记录。
 */
-(void)updateAllCzRecord
{
    __weak typeof(self) weakSelf = self;
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSString *bleName = self.lock.device.lockName;
//    NSString *data = [manager queryUploadRecordDataWithBleName:bleName type:0];
    NSString * data = nil;
#if kRecordDebug
    data = nil;
#endif
    NSArray<KDSUnlockAttr *> *attrs = [manager queryUnlockAttrWithBleName:bleName];
    NSMutableArray<KDSBleOpRec *> *total = [NSMutableArray array];
    //提取缓存的昵称词典。
    NSMutableDictionary *nicknameMap = [NSMutableDictionary dictionaryWithCapacity:attrs.count];
    for (KDSUnlockAttr *attr in attrs)
    {
        nicknameMap[[NSString stringWithFormat:@"%02d%@", attr.number, attr.unlockType]] = attr.nickname;
    }
    self.recReceipt = [self.lock.bleTool getOpRecAfterData:data completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleOpRec *> * _Nullable records) {
        if (!records)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [weakSelf.recHud hideAnimated:NO];
                weakSelf.recReceipt = nil;
                weakSelf.recHud = nil;
//                if (weakSelf.recHud) [MBProgressHUD showError:Localized((error==KDSBleErrorNotFound ? @"noRecord" : @"synchronizeFailed"))];
            });
            return ;
        }
        NSInteger index = -1;
        for (KDSBleOpRec *record in records)
        {
            if (data.length > 12 && [[record.hexString substringFromIndex:12] isEqualToString:[data substringFromIndex:12]] && index==-1)
            {
                index = [records indexOfObject:record];
                //                break;
            }
            if ([total containsObject:record]) continue;
            [total addObject:record];
            KDSOperationalRecord * op = [[KDSOperationalRecord alloc] init];
            op.eventSource = record.eventSource;
            op.open_type = [NSString stringWithFormat:@"%d",record.eventCode];
            op.user_num = [NSString stringWithFormat:@"%d",record.userID];
            op.open_time = record.date;
            op.eventType = record.eventType;
            op.cmdType = record.cmdType;
            if (![weakSelf.czOperationalArr containsObject:op] && op.eventType != 3)
            {
                [weakSelf.czOperationalArr addObject:op];
            }
        }
        [weakSelf reloadTableView:weakSelf.tableView];
        
        if (finished) {
            [self.timeOut invalidate];
            self.timeOut = nil;
            [weakSelf.recHud hideAnimated:NO];
            weakSelf.recReceipt = nil;
            weakSelf.recHud = nil;
            [MBProgressHUD showSuccess:Localized(@"syncComplete")];
            NSArray *unuploadRecords = [manager queryRecord:0 bleName:bleName];
            if (unuploadRecords.count)//最后把未上传的记录也显示一下
            {
                for (KDSBleOpRec *record in records)
                {
                    if ([total containsObject:record]) continue;
                    [total addObject:record];
                    KDSOperationalRecord * op = [[KDSOperationalRecord alloc] init];
                    op.eventSource = record.eventSource;
                    op.open_type = [NSString stringWithFormat:@"%d",record.eventCode];
                    op.user_num = [NSString stringWithFormat:@"%d",record.userID];
                    op.open_time = record.date;
                    op.eventType = record.eventType;
                    op.cmdType = record.cmdType;
                    if (![weakSelf.czOperationalArr containsObject:op] && op.eventType != 3)
                    {
                        [weakSelf.czOperationalArr addObject:op];
                    }
                }
                [weakSelf reloadTableView:weakSelf.tableView];
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (index != -1)
                {
                    [weakSelf uploadCzRecord:[records subarrayWithRange:NSMakeRange(0, index)]];
                }
                else if (records.firstObject.niketotal == records.count)
                {
                    [weakSelf uploadCzRecord:records];
                }
                else
                {
                    [weakSelf uploadCzRecord:records];
                }
            });
        }
    }];
    !self.recReceipt ?: [self.recHud hideAnimated:YES];
}


/**
 *@abstract 上传操作记录到服务器。
 *@param records 要上传的开锁记录。
 */
- (void)uploadCzRecord:(nullable NSArray<KDSBleOpRec *> *)records
{
#if kRecordDebug
    return;
#endif
//    KDSDBManager *manager = [KDSDBManager sharedManager];
//    NSString *bleName = self.lock.device.lockName;
    //总的上传记录。
    NSMutableArray *totalArr = [NSMutableArray arrayWithArray:records ?: @[]];
    [totalArr sortUsingComparator:^NSComparisonResult(KDSBleOpRec *  _Nonnull obj1, KDSBleOpRec *  _Nonnull obj2) {
        return [obj2.date compare:obj1.date];
    }];
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    NSMutableArray * news = [NSMutableArray array];
    for (KDSBleOpRec * op in totalArr) {
        KDSOperationalRecord * n = [[KDSOperationalRecord alloc] init];
        n.eventSource = op.eventSource;
        n.open_type = [NSString stringWithFormat:@"%d",op.eventCode];
        n.user_num = [NSString stringWithFormat:@"%d",op.userID];
        n.open_time = op.date;
        n.eventType = op.eventType;
        n.cmdType = op.cmdType;
        if (n.eventType != 3) {
            [news addObject:n];
        }
    }
    [[KDSHttpManager sharedManager] uploadBindedDeviceOperationalRecords:news withUid:uid device:self.lock.device success:^{
//        [manager deleteRecord:0 bleName:bleName];
    } error:^(NSError * _Nonnull error) {
//        [manager insertRecord:totalArr type:0 bleName:bleName];
    } failure:^(NSError * _Nonnull error) {
//        [manager insertRecord:totalArr type:0 bleName:bleName];
    }];
    
}

#pragma mark - KDSBluetoothToolDelegate
- (void)discoverManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        self.bigCircleIV.userInteractionEnabled = YES;
        [self beginScanForPeripherals];
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (![LinphoneManager instance].hasPushkit) {
                self.bigCircleIV.userInteractionEnabled = NO;
                self.lockState = KDSLockStateBleClosed;
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:Localized(@"pleaseOpenBle") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
                [ac addAction:action];
                [self presentViewController:ac animated:YES completion:^{
                    [self.bleTool stopScanPeripherals];
                }];
            }
        });
    }
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    if ([peripheral.advDataLocalName isEqualToString:self.lock.device.lockName]
        ||[peripheral.identifier.UUIDString isEqualToString:self.lock.device.peripheralId])
    {
        NSLog(@"--{Kaadas}--beginConnectPeripheral--LockInFoVC");
        [self.bleTool beginConnectPeripheral:peripheral];
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.bleTool stopScanPeripherals];
    if (self.lock.device.bleVersion.intValue == 1 || self.lock.bleTool.connectedPeripheral.bleVersion == 1){
        if (self.lock.bleTool.connectedPeripheral.bleVersion > self.lock.device.bleVersion.intValue)
        {
            [[KDSHttpManager sharedManager] updateBleVersion:self.lock.bleTool.connectedPeripheral.bleVersion withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:nil error:nil failure:nil];
            ///更新过蓝牙模块版本号之后发出通知，刷新数据源
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockUpdateBleVersionNotification object:nil userInfo:nil];
        }
        self.lock.connected = YES;
        [self startConnectedAnimation:^{
            self.lockState = KDSLockStateNormal;
        }];
    }
}

- (void)didDisConnectPeripheral:(CBPeripheral *)peripheral
{
    self.lock.connected = NO;
    if (self.isLongtimeNoOp)
    {
        self.lockState = KDSLockStateBleNotFound;
        return;
    }
    [MBProgressHUD showError:Localized(@"peripheralDidDisconnect") toView:self.view];
    [self beginScanForPeripherals];
}

- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    if (!self.bleTool.connectedPeripheral)
    {
        self.lockState = KDSLockStateBleNotFound;
    }
}

- (void)didGetSystemID:(CBPeripheral *)peripheral
{
    __weak typeof(self) weakSelf = self;
    [self.bleTool authenticationWithPwd1:self.lock.device.password1 pwd2:self.lock.device.password2 completion:^(KDSBleError error) {
        
        if (error == KDSBleErrorDuplOrAuthenticating) return;
        if (error == KDSBleErrorSuccess)
        {
            weakSelf.lock.connected = YES;
            [weakSelf startConnectedAnimation:^{
                weakSelf.lockState = KDSLockStateNormal;
            }];
          
            if (peripheral.bleVersion > weakSelf.lock.device.bleVersion.intValue)
            {
                [[KDSHttpManager sharedManager] updateBleVersion:peripheral.bleVersion withUid:[KDSUserManager sharedManager].user.uid bleName:weakSelf.lock.device.lockName success:nil error:nil failure:nil];
                ///更新过蓝牙模块版本号之后发出通知，刷新数据源
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockUpdateBleVersionNotification object:nil userInfo:nil];
            }
            return;
        }
        weakSelf.lockState = KDSLockStateUnauth;
    }];
}
- (void)didGetFunctionSet:(CBPeripheral *)peripheral
{
    if (self.lock.device.functionSet.length == 0) {
        //服务器不存在门锁功能集，则更新
        [[KDSHttpManager sharedManager] updateFunctionSet:peripheral.functionSet withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:nil error:nil failure:nil];
    }
}

- (void)didReceiveDeviceElctInfo:(int)elct
{
    self.lock.power = elct;
    [[KDSDBManager sharedManager] updatePower:elct withBleName:self.lock.device.lockName];
    [[KDSDBManager sharedManager] updatePowerTime:NSDate.date withBleName:self.lock.device.lockName];
    //由于要等鉴权成功且动画结束才设置连接为YES，为避免其它页面使用此值时出现未连接却获取了电量的情况，这里设置为YES。
    self.lock.connected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:nil userInfo:nil];
    if (self.lockInfo == nil)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.bleTool getLockInfo:^(KDSBleError error, KDSBleLockInfoModel * _Nullable infoModel) {
                if (error == KDSBleErrorSuccess)
                {
                    weakSelf.lockInfo = infoModel;
                    weakSelf.lockState = weakSelf.lockState;
                }
            }];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.lockInfo ? 3 : 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getUnlockTimes];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristicOfLockModel:(NSString *)model
{

    if (!model.length || [model caseInsensitiveCompare:@"xxxxxVx.x"]==NSOrderedSame) return;
    [[KDSHttpManager sharedManager] getDeviceModelMappingWithDevelopmentModel:@"111"  success:^(KDSDeviceModelMapping * _Nonnull DeviceModelMapping) {
        
       KDSLog(@"--{Kaadas}--锁映射表--DeviceModelMapping==%@",DeviceModelMapping);

    } error:^(NSError * _Nonnull error) {
        KDSLog(@"--{Kaadas}--锁映射表=error=%@",error.localizedDescription);

    } failure:^(NSError * _Nonnull error) {
       KDSLog(@"--{Kaadas}--锁映射表=failure=%@",error.localizedDescription);

    }];
    self.lock.device.model = model;
    
}
-(void)hasInBootload:(CBPeripheral *)peripheral{
    KDSLog(@"--{Kaadas}--锁蓝牙已进入bootloadm模式");
    [self checkBleOTA:peripheral];

}
#pragma mark - 通知事件
///锁已打开
- (void)lockDidOpen:(NSNotification *)noti
{
    CBPeripheral *p = noti.userInfo[@"peripheral"];
    if (p == self.bleTool.connectedPeripheral)
    {
        uint32_t state = self.lockInfo.lockState;
        state |= 0x00000004;
        self.lockInfo.lockState = state;
        [self setLockState:KDSLockStateUnlocked];
        [self getUnlockTimes];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getUnlockResultThenReport:NO];
            
        });
        
    }
}

///锁已关闭
- (void)lockDidClose:(NSNotification *)noti
{
    CBPeripheral *p = noti.userInfo[@"peripheral"];
    if (p == self.bleTool.connectedPeripheral)
    {
        [self setLockState:KDSLockStateClosed];
    }
}

///收到更改了本地语言的通知，更新页面文字。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.lockState = self.lockState;
    self.guardianDayLocalizedLabel.text = Localized(@"guardianTime");
    self.guardianTimesLocalizedLabel.text = Localized(@"guardianTimes");
    self.deviceDynamicLocalizedLabel.text = Localized(@"deviceDynamic");
    self.daysLocalizedLabel.text = Localized(@"days");
    self.timesLocalizedLabel.text = Localized(@"times");
    self.bleSyncLabel.text = Localized(@"bleSyncDoorLockState");
    self.deviceDynamicsLabel.text = Localized((self.deviceDynamicsLabel.tag==0 ? @"normal" : @"exception"));
    [self.synRecordingBtn setTitle:Localized(@"syncRecord") forState:UIControlStateNormal];
    [self.tableView reloadData];
}

///锁鉴权失败，更改状态，保存日志到数据库。
- (void)lockAuthentiateFailed:(NSNotification *)noti
{
    CBPeripheral *peripheral = (CBPeripheral *)noti.userInfo[@"peripheral"];
    NSInteger code = [noti.userInfo[@"code"] integerValue];
    if (peripheral == self.bleTool.connectedPeripheral)
    {
        self.lockState = code==0xc2 ? KDSLockStateReset : KDSLockStateUnauth;
    }
    NSString *bleName = peripheral.advDataLocalName, *nickname = nil;
    for (KDSLock *lock in [KDSUserManager sharedManager].locks)
    {
        if (lock.bleTool.connectedPeripheral == peripheral)
        {
            nickname = lock.device.lockNickName;
            break;
        }
    }
    
    KDSAuthException *exception = [KDSAuthException new];
    exception.bleName = bleName;
    exception.nickname = nickname;
    exception.date = [NSDate date];
    self.lock.bleTool.dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    exception.dateString = [self.lock.bleTool.dateFormatter stringFromDate:exception.date];
    exception.code = (int)code;
    [[KDSDBManager sharedManager] insertAuthExceptions:@[exception]];
}

///锁上报信息。
- (void)lockDidReport:(NSNotification *)noti
{
    CBPeripheral *peripheral = (CBPeripheral *)noti.userInfo[@"peripheral"];
    NSData *data = (NSData *)noti.userInfo[@"data"];
    if (peripheral != self.bleTool.connectedPeripheral || data.length != 20) return;
    Byte *bytes = (Byte *)data.bytes;
    if (bytes[5] == 9)
    {
        int state = self.lockInfo.lockState;
        Byte byte = bytes[6];//1反锁0不反锁
        (byte & 0x1) ? (state &= 0xfffffffb) : (state |= 0x00000004);
        ((byte >> 1) & 0x1) ? (state |= 0x00000100) : (state &= 0xfffffeff);
        ((byte >> 2) & 0x1) ? (state |= 0x00000020) : (state &= 0xffffffdf);
        self.lockInfo.lockState = state;
        if (self.lockState != KDSLockStateUnlocking && self.lockState != KDSLockStateUnlocked)
        {
            [self setLockState:KDSLockStateNormal];
        }
    }
}

///在其它页面操作开锁发出的通知。
- (void)userOperateUnlock:(NSNotification *)noti
{
    if (noti.userInfo[@"lock"] != self.lock || !(self.lock.state == KDSLockStateNormal || self.lock.state == KDSLockStateDefence)) return;
    [self checkUnlockAuthThenDealWithResult];
}

///首页长按开锁密码输入框限制6-12位数字密码
-(void)textFieldTextDidChange:(UITextField *)sender{
    
    char pwd[13] = {0};
    int index = 0;
    NSString *text = sender.text.length > 12 ? [sender.text substringToIndex:12] : sender.text;
    for (NSInteger i = 0; i < text.length; ++i)
    {
        unichar c = [text characterAtIndex:i];
        if (c < '0' || c > '9') continue;
        pwd[index++] = c;
    }
    sender.text = @(pwd);
    
}

///用户长时间没操作，断开蓝牙连接。
- (void)userLongtimeNoOperation:(NSNotification *)noti
{
    if (self.bleTool.connectedPeripheral)
    {
        self.isLongtimeNoOp = YES;
        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    }
}

///用户激活操作，重新连接蓝牙。
- (void)userActivateOperationNotification:(NSNotification *)noti
{
    if (self.isLongtimeNoOp)
    {
        self.isLongtimeNoOp = NO;
        [self beginScanForPeripherals];
    }
}

///锁上报报警通知。
- (void)lockDidAlarm:(NSNotification *)noti
{
    CBPeripheral *p = noti.userInfo[@"peripheral"];
    if (p != self.lock.bleTool.connectedPeripheral) return;
    self.deviceDynamicsLabel.text = Localized(@"exception");
    self.deviceDynamicsLabel.textColor = KDSRGBColor(0xff, 0x3b, 0x30);
    self.deviceDynamicsLabel.tag = 1;
}

#pragma mark UITableViewCell--delegate
///组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isOperationalRecords) {
        return self.czOPerationalSectionArr.count;
    }else{
        return self.unlockRecordArr.count;
    }
}
///每组个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOperationalRecords) {
        
        return self.czOPerationalSectionArr[section].count;

    }else{
        return self.unlockRecordArr[section].count;
    }
}
///cell复用
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KDSHomePageLockStatusCell"];
    cell.alarmRecLabel.hidden = YES;
    cell.topLine.hidden = indexPath.row == 0;
    if (self.isOperationalRecords) {
        ///操作记录
        cell.bottomLine.hidden = indexPath.row == self.czOPerationalSectionArr[indexPath.section].count - 1;
        KDSOperationalRecord *n = self.czOPerationalSectionArr[indexPath.section][indexPath.row];
        cell.timerLabel.text = n.open_time.length > 16 ? [n.open_time substringWithRange:NSMakeRange(11, 5)] : @"未知";
        if (n.eventType == 1) {///开门记录
            cell.unlockModeLabel.text = [n.user_num isEqualToString:@"103"] ? Localized(@"appUnlock") : Localized(n.open_type);
            if (cell.unlockModeLabel.text.intValue == 2) {
                cell.unlockModeLabel.text = [self unlockTypeWithEvent:n.eventSource];
            }
            if (n.user_num.intValue == 103)
            {
                cell.userNameLabel.text = @"APP";
            }
            else if (n.eventSource == 2)
            {
                cell.userNameLabel.text = Localized(@"machineKey");
            }
            else if (n.eventSource == 0)
            {
                NSString *nn = n.nickName;
                for (KDSPwdListModel *m in self.keys)
                {
                    if ((m.pwdType == KDSServerKeyTpyePIN || m.pwdType == KDSServerKeyTpyeTempPIN) && m.num.intValue == n.user_num.intValue)
                    {
                        if (m.nickName && !nn) nn = m.nickName;
                        break;
                    }
                }
                cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
            }
            else if (n.eventSource == 3)
            {
                NSString *nn = n.nickName;
                for (KDSPwdListModel *m in self.keys)
                {
                    if (m.pwdType == KDSServerKeyTpyeCard && m.num.intValue == n.user_num.intValue)
                    {
                        if (m.nickName && !nn) nn = m.nickName;
                        break;
                    }
                }
                cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
            }
            else if (n.eventSource == 4)
            {
                NSString *nn = n.nickName;
                for (KDSPwdListModel *m in self.keys)
                {
                    if (m.pwdType == KDSServerKeyTpyeFingerprint && m.num.intValue == n.user_num.intValue)
                    {
                        if (m.nickName && !nn) nn = m.nickName;
                        break;
                    }
                }
                cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
            }
            else
            {
                cell.userNameLabel.text = [NSString stringWithFormat:@"%02d", n.user_num.intValue];
            }
            
        }else{
            //操作记录
            NSString * recTypeStr = [self recTypeByOpreType:n.open_type.intValue uid:n.user_num.intValue];
            cell.unlockModeLabel.text = recTypeStr;
            NSString * nickName = [self nickNameByOpreVehicle:n.open_type.intValue];
            cell.userNameLabel.text = nickName;
        }
    }else{
        
        ///开门记录
        cell.bottomLine.hidden = indexPath.row == self.unlockRecordArr[indexPath.section].count - 1;
        News *n = self.unlockRecordArr[indexPath.section][indexPath.row];
        if (n.open_time.length > 16) {
            cell.timerLabel.text = [n.open_time substringWithRange:NSMakeRange(11, 5)];
        }else{
            cell.timerLabel.text = @"未知";
        }
        
        if (n.user_num.intValue == 103)
        {
            cell.userNameLabel.text = @"APP";
        }
        else if ([n.open_type isEqualToString:@"手动"])
        {
            NSString *nn = n.nickName;
            for (KDSPwdListModel *m in self.keys)
            {
                if (m.num.intValue == n.user_num.intValue)
                {
                    if (m.nickName && !nn) nn = m.nickName;
                    break;
                }
            }
            cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
            
        }
        else if ([n.open_type isEqualToString:@"密码"])
        {
            NSString *nn = n.nickName;
            for (KDSPwdListModel *m in self.keys)
            {
                if ((m.pwdType == KDSServerKeyTpyePIN || m.pwdType == KDSServerKeyTpyeTempPIN) && m.num.intValue == n.user_num.intValue)
                {
                    if (m.nickName && !nn) nn = m.nickName;
                    break;
                }
            }
            cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
        }
        else if ([n.open_type isEqualToString:@"卡片"])
        {
            NSString *nn = n.nickName;
            for (KDSPwdListModel *m in self.keys)
            {
                if (m.pwdType == KDSServerKeyTpyeCard && m.num.intValue == n.user_num.intValue)
                {
                    if (m.nickName && !nn) nn = m.nickName;
                    break;
                }
            }
            cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
        }
        else if ([n.open_type isEqualToString:@"指纹"])
        {
            NSString *nn = n.nickName;
            for (KDSPwdListModel *m in self.keys)
            {
                if (m.pwdType == KDSServerKeyTpyeFingerprint && m.num.intValue == n.user_num.intValue)
                {
                    if (m.nickName && !nn) nn = m.nickName;
                    break;
                }
            }
            cell.userNameLabel.text = nn ?: [NSString stringWithFormat:@"%02d", n.user_num.intValue];
        }
        else
        {
            cell.userNameLabel.text = [NSString stringWithFormat:@"%02d", n.user_num.intValue];
        }
        cell.unlockModeLabel.text = [n.user_num isEqualToString:@"103"] ? Localized(@"appUnlock") : Localized(n.open_type);
    }
 
    //cell.backgroundColor = indexPath.row % 2 ? UIColor.yellowColor : UIColor.purpleColor;
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(216, 216, 216);
    line.frame = CGRectMake(15, 0, KDSScreenWidth-30, 1);
    line.hidden = section == 0;
    [headerView addSubview:line];
    
    ///显示日期：今天、昨天、///开锁时间:（yyyy-MM-dd ）
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:titleLabel];
    self.bleTool.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *todayStr = [[self.bleTool.dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger today = [todayStr substringToIndex:8].integerValue;
    NSString *dateStr;
    if (self.isOperationalRecords) {
        dateStr = self.czOPerationalSectionArr[section].firstObject.open_time;
    }else{
       dateStr = self.unlockRecordArr[section].firstObject.open_time;
    }
    NSInteger date = [[dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:8].integerValue;
    if (today == date)
    {
        titleLabel.text = Localized(@"today");
    }
    else if (today - date == 1)
    {
        titleLabel.text = Localized(@"yesterday");
    }
    else
    {
        titleLabel.text = [[dateStr componentsSeparatedByString:@" "].firstObject stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    }
    ///更多按钮
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(KDSScreenWidth-80, 10, 40, 20)];
    [btn setTitleColor:KDSRGBColor(17, 117, 231) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.hidden = section != 0;
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:Localized(@"more") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
   
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(NSString *)recTypeByOpreType:(int)type uid:(int)uid
{
    
    __block NSString * str = nil;
    switch (type) {
        case 1:
            str = @"修改管理员密码";
            break;
        case 2:
        {
            if ((uid >= 0 && uid <= 4) || (uid >= 10 && uid <= 19)) {
                str = @"添加永久密码";
            }else if (uid == 9){
                str = @"添加胁迫密码";
            }else{
                str = @"添加临时密码";
            }
        }
            break;
        case 3:
        {
            if ((uid >= 0 && uid <= 4) || (uid >= 10 && uid <= 19)) {
                str = @"删除永久密码";
            }else if (uid == 9){
                str = @"删除胁迫密码";
            }else if (uid >= 5 && uid <= 8){
                str = @"删除临时密码";
            }else{
                str = @"删除全部密码";
            }
        }
            
            break;
        case 4:
            str = @"修改密码";
            break;
        case 5:
            str = @"添加门卡";
            break;
        case 6:
        {
            if ((uid >= 0 && uid <= 99)) {
                 str = @"删除门卡";
            }else{
                str = @"删除全部卡片";
            }
        }
            break;
        case 7:
            str = @"添加指纹";
            break;
        case 8:
        {
            if ((uid >= 0 && uid <= 99)) {
                 str = @"删除指纹";
            }else{
                str = @"删除全部指纹";
            }
        }
            break;
        case 15:
            str = @"恢复出厂设置";
            break;
        default:
            break;
    }
    return str;
}
-(NSString *)unlockTypeWithEvent:(int)eventSource
{
    __block NSString * unlockTypeStr = nil;
    switch (eventSource) {
        case 0:
            unlockTypeStr = @"密码开锁";
            break;
        case 1:
            unlockTypeStr = @"遥控开锁";
            break;
        case 2:
            unlockTypeStr = @"手动开锁";
            break;
        case 3:
            unlockTypeStr = @"门卡开锁";
            break;
        case 4:
            unlockTypeStr = @"指纹开锁";
            break;
        case 5:
            unlockTypeStr = @"语音开锁";
            break;
        case 6:
            unlockTypeStr = @"指静脉开锁";
            break;
        case 7:
            unlockTypeStr = @"人脸识别开锁";
            break;
        case 8:
            unlockTypeStr = @"手机开锁";
            break;
        default:
            break;
    }
    return unlockTypeStr;
}

-(NSString *)nickNameByOpreVehicle:(int)vehicle
{
    __block NSString * nickName = nil;
    switch (vehicle) {
        case 1:
            nickName = @"修改管理员密码";
            break;
        case 2:
            nickName = @"添加密码";
            break;
        case 3:
            nickName = @"删除密码";
            break;
        case 4:
            nickName = @"修改密码";
            break;
        case 5:
            nickName = @"添加门卡";
            break;
        case 6:
            nickName = @"删除门卡";
            break;
        case 7:
            nickName = @"添加指纹";
            break;
        case 8:
            nickName = @"删除指纹";
            break;
        case 15:
            nickName = @"恢复出厂设置";
            break;
        default:
            break;
    }
    return nickName;
}

#pragma mark - 选择OTA升级方案
///根据OTA启动服务FFD0和1802，来选择TI、Psco6升级方案
-(void)chooseOTASolution:(NSString *)url withPeripheral:(CBPeripheral*)peripheral{
    
    BOOL hasResetOTAServer = NO;
    for (CBService *service in peripheral.services) {
        //检测到OAD启动服务:FFD0 ---> TI方案
        KDSLog(@"--{Kaadas}--service.UUID==%@",service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString: KDSOADService]) {
            KDSLog(@"--{Kaadas}--检测到OAD启动服务:FFD0->TI方案");
            ///先检查是否有协议栈
            [self checkIsProtocolStackWthFirmwareUrl:url];
            hasResetOTAServer = YES;
           
        }
        else if ([service.UUID.UUIDString isEqualToString: KDSDFUService]) {
            KDSLog(@"--{Kaadas}--检测到DFU启动服务:1802->P6方案");
            //检测到DFU启动服务:1802->P6方案
            KDSDFUVC *dfuVC = [[KDSDFUVC alloc]init];
            dfuVC.url = url;
            dfuVC.lock = self.lock;
//            dfuVC.lock.bleTool.isBinding = YES;
            hasResetOTAServer = YES;
            dfuVC.isBootLoadModel = YES;
            dfuVC.hidesBottomBarWhenPushed = YES;

            [self.navigationController pushViewController:dfuVC animated:YES];
        }
    }
    //蓝牙升级服务未读取到
    hasResetOTAServer?:[MBProgressHUD showSuccess:@"蓝牙信息获取不完整，请稍后再试"];
}
-(void)checkIsProtocolStackWthFirmwareUrl:(NSString *)firmwareUrl{
    
    //蓝牙本地固件版本号
      NSString *softwareRev = [self parseBluetoothVersion];
      NSString *deviceSN ;
      if (!self.lock.device.deviceSN.length) {
          deviceSN = self.lock.bleTool.connectedPeripheral.serialNumber ;
      }else{
          deviceSN = self.lock.device.deviceSN ;
      }
    KDSOADVC *otaVC = [[KDSOADVC alloc]init];
    [[KDSHttpManager sharedManager] checkBleOTAWithSerialNumber:deviceSN withCustomer:1 withVersion:softwareRev withDevNum:4 success:^(NSString *URL) {
        otaVC.protocolStackUrl = URL;
        otaVC.url = firmwareUrl;
        otaVC.lock = self.lock;
        otaVC.lock.bleTool.isBinding = YES;
        otaVC.isBootLoadModel = YES;
        otaVC.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:otaVC animated:YES];
                    
       } error:^(NSError * _Nonnull error) {
           otaVC.url = firmwareUrl;
           otaVC.lock = self.lock;
           otaVC.lock.bleTool.isBinding = YES;
           otaVC.isBootLoadModel = YES;
           otaVC.hidesBottomBarWhenPushed = YES;

           [self.navigationController pushViewController:otaVC animated:YES];
           
       } failure:^(NSError * _Nonnull error) {
           otaVC.url = firmwareUrl;
           otaVC.lock = self.lock;
           otaVC.isBootLoadModel = YES;
           otaVC.lock.bleTool.isBinding = YES;
           otaVC.hidesBottomBarWhenPushed = YES;

           [self.navigationController pushViewController:otaVC animated:YES];
       }];
    
}

#pragma mark --Lazy load
- (NSMutableArray<KDSOperationalRecord *> *)czOperationalArr
{
    if (!_czOperationalArr) {
        _czOperationalArr = [NSMutableArray array];
    }
    return _czOperationalArr;
}

- (NSMutableArray<News *> *)unlockRecordNews
{
    if (!_unlockRecordNews) {
        _unlockRecordNews = [NSMutableArray array];
    }
    return _unlockRecordNews;
}

#pragma mark 定时器响应

-(void)timerOutClick:(NSTimer *)timer
{
    self.recReceipt = nil;
    [self.recHud hideAnimated:NO];
    self.recHud = nil;
    [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];
  
}

@end

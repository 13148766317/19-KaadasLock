//
//  KDSWifiLockInfoVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockInfoVC.h"
#import "KDSHomePageLockStatusCell.h"
#import "KDSMQTT.h"
#import "KDSDBManager+GW.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager.h"
#import "KDSWFRecordDetailsVC.h"
#import "KDSCountdown.h"
#import "NSDate+KDS.h"
#import "KDSFTIndicator.h"
#import "KDSWifiLockOperation.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSMediaLockRecordDetailsVC.h"
#import "XMPlayController.h"

//修改后
#import "KDSBleAddWiFiLockDetailsVC.h"
#import "KDSWifiLockPwdListVC.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MBProgressHUD+MJ.h"
#import "UIButton+Color.h"
#import "KDSLockKeyVC.h"
#import "KDSWIfiLockMoreSettingVC.h"
#import "KDSWifiLockPwdShareVC.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSAllPhotoShowImgModel.h"
#import "KDSBleAddWiFiFuncListCell.h"
#import "KDSSwitchLinkageDetailVC.h"
#import "UIImageView+ForScrollView.h"

#import "KDSMyAlbumVC.h"
#import "KDSMediaLockRecordDetailsVC.h"
#import "KDSMediaLockMoreSettingVC.h"
#import "XMPlayController.h"

#import "KDSWifiLockParamVC.h"
#import "KDSMediaLockParamVC.h"

static NSString * const deviceListCellId = @"bleAddWiFiFuncListCell";
@interface KDSWifiLockInfoVC ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource> 

///最外围的大圆。
@property (strong, nonatomic) UIImageView *bigCircleIV;
///中间的圆。
@property (strong, nonatomic) UIImageView *middleCircleIV;
///内部的小圆
@property (strong, nonatomic) UIImageView *smallCircleIV;
///显示ZigBee图标的视图。
@property (strong, nonatomic) UIImageView *zbLogoIV;
///锁动作提示标签(开锁、连接等)。
@property (nonatomic, strong) UILabel *actionLabel;
///讯美视频锁：展示锁状态的lb
@property (nonatomic, strong) UILabel * xmMediaStateLabel;
///锁状态提示标签(反锁、布防等)。
@property (nonatomic, strong) UILabel *stateLabel;
///wifi锁信息更新的时间
@property (nonatomic, strong) UILabel *updateTimeLb;
///“守护时间”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *guardianDayLocalizedLabel;
///锁绑定天数标签。
@property (nonatomic, strong) UILabel *dayLabel;
///守护时间“天”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *dayLocalizedLabel;
///“守护次数”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *guardianTimesLocalizedLabel;
///锁开锁次数标签。
@property (nonatomic, strong) UILabel *timesLabel;
///守护次数“次”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *timesLocalizedLabel;
///服务器请求回来的开锁记录数组。
@property (nonatomic, strong) NSMutableArray<KDSWifiLockOperation *> *unlockRecordArr;
///服务器请求回来开锁记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSWifiLockOperation *> *> *unlockRecordSectionArr;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;
///锁状态。
@property (nonatomic, assign) KDSLockState lockState;
@property (nonatomic, strong) UITableView * tableView;
///记录是否正在进行连接成功，如果是，设置锁状态时直接返回，等动画完毕再设置锁状态。
@property (nonatomic, assign) BOOL animating;

/**   修改  **/
///导航栏位置的标题标签。
@property (nonatomic, weak) UILabel *titleLabel;
///锁型号标签。
@property (nonatomic, weak) UILabel *modelLabel;
///显示电量图片、电量和日期的按钮，设置这些属性时使用方法setPowerWithImage:power:date:@see setPowerWithImage:power:date:
@property (nonatomic, weak) UIButton *powerInfoBtn;
///电量内框图片。
@property (nonatomic, strong) UIImageView *powerIV;
///wifi锁的锁型号
@property (nonatomic, strong) UILabel * WifiLockModel;
///临时密码数量标签。
@property (nonatomic, strong) UILabel * tempPwdQuantityLabel;
///密码数量标签。
@property (nonatomic, weak) UILabel *pwdQuantityLabel;
///指纹数量标签。
@property (nonatomic, weak) UILabel *fpQuantityLabel;
///卡片数量标签。
@property (nonatomic, weak) UILabel *cardQuantityLabel;
///共享成员数量标签。
@property (nonatomic, weak) UILabel *memberQuantityLabel;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;
///用来展示设备功能列表
@property (nonatomic,readwrite,strong)UICollectionView * collectionView;
///锁功能的图片
@property (nonatomic,strong)NSMutableArray * funcImgListArray;
///锁功能的名称
@property (nonatomic,strong)NSMutableArray * funcNameListArray;
///锁功能的子视图的个数
@property (nonatomic,strong)NSMutableArray * funcNumListArray;

@end

@implementation KDSWifiLockInfoVC

#pragma mark - getter setter
- (NSMutableArray<KDSWifiLockOperation *> *)unlockRecordArr
{
    if (!_unlockRecordArr)
    {
        _unlockRecordArr = [NSMutableArray array];
    }
    return _unlockRecordArr;
}
- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFmt;
}
#pragma mark --Lazy Load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.layer.masksToBounds = YES;
        _collectionView.layer.shadowColor = [UIColor colorWithRed:121/255.0 green:146/255.0 blue:167/255.0 alpha:0.1].CGColor;
        _collectionView.layer.shadowOffset = CGSizeMake(0,-4);
        _collectionView.layer.shadowOpacity = 1;
        _collectionView.layer.shadowRadius = 12;
        _collectionView.layer.cornerRadius = 5;
        _collectionView.tag = 836914;
        [_collectionView flashScrollIndicators];
    }
    return _collectionView;
}

- (NSMutableArray *)funcImgListArray
{
    if (!_funcImgListArray) {
        _funcImgListArray = [NSMutableArray array];
    }
    return _funcImgListArray;
}
- (NSMutableArray *)funcNameListArray
{
    if (!_funcNameListArray) {
        _funcNameListArray = [NSMutableArray array];
    }
    return _funcNameListArray;
}
- (NSMutableArray *)funcNumListArray
{
    if (!_funcNumListArray) {
        _funcNumListArray = [NSMutableArray array];
    }
    return _funcNumListArray;
}


///目前wifi锁的模式：开锁状态>布防>反锁>安全>面容>节能>锁舌伸出
- (void)setLockState:(KDSLockState)lockState
{
    _lockState = lockState;
    self.lock.state = lockState;
    self.zbLogoIV.hidden = NO;
    self.xmMediaStateLabel.hidden = NO;
    self.actionLabel.textColor = UIColor.whiteColor;
    self.bigCircleIV.image = [UIImage imageNamed:@"bigBlueCircle"];
    self.zbLogoIV.image = [UIImage imageNamed:@"wifiLock-homeIcon"];
    self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
    switch (lockState)
    {
        case KDSLockStateDefence:
            self.middleCircleIV.image = [UIImage imageNamed:@"lockDefence"];
            if (self.lock.wifiDevice.distributionNetwork == 3) {
                self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
                self.actionLabel.text = @"点击查看门外情况";
                self.xmMediaStateLabel.text = @"布防模式";
                self.stateLabel.text = Localized(@"door has been locked");
            }else{
                self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
                self.actionLabel.text = nil;
                self.stateLabel.text = Localized(@"Deployment mode started");
            }
            break;
            
        case KDSLockStateLockInside:
            self.middleCircleIV.image = [UIImage imageNamed:@"lockInside"];
            if (self.lock.wifiDevice.distributionNetwork == 3) {
                self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
                self.actionLabel.text = @"点击查看门外情况";
                self.xmMediaStateLabel.text = @"反锁模式";
                self.stateLabel.text = Localized(@"door has been locked");
                
            }else{
                self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
                self.actionLabel.text = nil;
                self.zbLogoIV.image = [UIImage imageNamed:@"wifi连接失败"];
                self.stateLabel.text = Localized(@"LockInside&unlockInside");
            }
            break;
            
        case KDSLockStateSecurityMode:
            self.bigCircleIV.image = [UIImage imageNamed:@"securityModeBigCircle"];
            self.middleCircleIV.image = [UIImage imageNamed:@"securityMode"];
            if (self.lock.wifiDevice.distributionNetwork == 3) {
                self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
                self.actionLabel.text = @"点击查看门外情况";
                self.xmMediaStateLabel.text = @"安全模式";
                self.stateLabel.text = Localized(@"door has been locked");
            }else{
                self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
                self.actionLabel.text = nil;
                self.stateLabel.text = Localized(@"Security mode started");
            }
            break;
        case KDSLockStateEnergy:
            self.middleCircleIV.image = [UIImage imageNamed:@"EnergyModel"];
            if (self.lock.wifiDevice.distributionNetwork == 3) {
                self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
                self.actionLabel.text = @"节能模式";
                self.xmMediaStateLabel.text = nil;
                self.stateLabel.text = Localized(@"door has been locked");
            }else{
                self.smallCircleIV.image = [UIImage imageNamed:@"energySmallIcon"];
                self.actionLabel.text = nil;
                self.stateLabel.text = Localized(@"Energy saving mode started");
            }
            break;
        case KDSLockStateFaceTurnedOff:
            self.middleCircleIV.image = [UIImage imageNamed:@"FaceTurnedOffModel"];
            self.smallCircleIV.image = [UIImage imageNamed:@"faceTurnedOffModelSmallIcon"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"Face recognition turned off");
            break;
        case KDSLockSpittingState:
               self.middleCircleIV.image = [UIImage imageNamed:@"securityMode"];
               if (self.lock.wifiDevice.distributionNetwork == 3) {
                   self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
                   self.actionLabel.text = @"点击查看门外情况";
               }else{
                   self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
                   self.actionLabel.text = nil;
               }
            self.stateLabel.text = Localized(@"Locked and lifted");
               break;
        case KDSLockStateOnline:
            self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
            if (self.lock.wifiDevice.distributionNetwork == 3) {
                self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
                self.stateLabel.text = Localized(@"door has been locked");
                self.actionLabel.text = @"点击查看门外情况";
                self.xmMediaStateLabel.text = @"正常模式";
            }else{
                self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
                self.actionLabel.text = nil;
            }
            break;
            
        case KDSLockStateUnlocking:
            self.stateLabel.text = Localized(@"unlocking");
            [self stagingLockOperationAnimation:1];
            break;
            
        case KDSLockStateUnlocked:
            self.lock.wifiDevice.openStatus = 2;
            [self stagingLockOperationAnimation:2];
            break;
            
        case KDSLockStateFailed:
            self.stateLabel.text = Localized(@"Closedstate");
            [self stagingLockOperationAnimation:3];
            [self setLockState:KDSLockStateOnline];
            break;
            
        case KDSLockStateClosed:
            self.lock.wifiDevice.openStatus = 1;
            [self stagingLockOperationAnimation:4];
            [self setLockState:KDSLockStateOnline];
            break;
            
        default:
            self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = Localized(@"deviceOffline");
            self.actionLabel.textColor = KDSRGBColor(0x14, 0xa6, 0xf5);
            self.stateLabel.text = nil;
            self.zbLogoIV.hidden = YES;
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    /* 功能列表的参数 */
    NSString *pinUnit = @"组";
    NSString *fpUnit = @"组";
    NSString *cardUnit = @"张";
    NSString *pUnit = @"台";
    NSString *faceUnit = @"组";
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"%@%@",@"", @""] atIndex:0];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"%@%@", @"", @""] atIndex:1];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"%@%@", @"", @""] atIndex:2];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"%@%@", @"", @""] atIndex:3];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"%@%@", @"", @""] atIndex:4];
    
    /*
     **************************功能表的显示顺序***********************************
     1、临时密码，2、实时视频， 3、动态记录， 4、人脸识别，5、密码，6、指纹，7、卡片，
     8、智能开关，9、我的相册，10、设备共享，11、更多
     */
    
    ///临时密码
    if ((self.lock.wifiDevice.isAdmin.intValue ==1)) {
        [self.funcImgListArray addObject:@"password"];
        [self.funcNameListArray addObject:Localized(@"tempPassword")];
    }
    
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@53]  &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///实时视频
        [self.funcImgListArray addObject:@"realTimeVideo"];
        [self.funcNameListArray addObject:Localized(@"realTimeVideo")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@52] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///动态记录
        [self.funcImgListArray addObject:@"dynamicRecording"];
        [self.funcNameListArray addObject:Localized(@"dynamicRecording")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@26] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///支持人脸识别开锁
        [self.funcImgListArray addObject:@"faceRecognition"];
        [self.funcNameListArray addObject:Localized(@"faceRecognition")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@7] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///密码
        [self.funcImgListArray addObject:@"password"];
        [self.funcNameListArray addObject:Localized(@"password")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@8] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///指纹
        [self.funcImgListArray addObject:@"fingerprint"];
        [self.funcNameListArray addObject:Localized(@"fingerprint")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@9] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///卡片
        [self.funcImgListArray addObject:@"card"];
        [self.funcNameListArray addObject:Localized(@"card")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@45] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///智能开关
        [self.funcImgListArray addObject:@"IntelligentSwitchImg"];
        [self.funcNameListArray addObject:Localized(@"IntelligentSwitchImg")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@53] &&(self.lock.wifiDevice.isAdmin.intValue ==1)) {
        ///我的相册
        [self.funcImgListArray addObject:@"myAlbum"];
        [self.funcNameListArray addObject:Localized(@"myAlbum")];
    }
    ///设备共享
    if (self.lock.wifiDevice.isAdmin.intValue ==1) {
        [self.funcImgListArray addObject:@"memberShare"];
        [self.funcNameListArray addObject:Localized(@"deviceShare")];
    }
  
    ///更多
    if (self.lock.wifiDevice.isAdmin.intValue ==1) {
        [self.funcImgListArray addObject:@"more"];
        [self.funcNameListArray addObject:Localized(@"more")];
    }else{
        [self.funcImgListArray addObject:@"blueGear"];
        [self.funcNameListArray addObject:@"设备信息"];
    }
   
    [self setupUI];
    [self getUnlockRecord];
    self.timesLabel.text = @"0";

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(KDSHomePageLockStatusCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass([self class])];
    // 监听语言变化的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    // 接收MQtt上报事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 输出wifi锁的功能集
    NSLog(@"zhu==wifi锁的功能集=>%@",self.lock.wifiLockFunctionSet);
    if ([self.lock.wifiLockFunctionSet isEqualToString:@"0x7a"]) {
        NSLog(@"zhu== 视屏锁的功能集");
    }
    [self getAllKeys];
    [self getUnlockTimes];
    ///网关锁守护天数
    self.dayLabel.text = @(floor(([[NSDate date] timeIntervalSince1970] - self.lock.wifiDevice.createTime) / 24 / 3600)).stringValue;
    if (!self.lock.wifiDevice.updateTime) {
        self.lock.wifiDevice.updateTime = [[NSDate date] timeIntervalSince1970];
    }
    NSString * dateTime= [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.lock.wifiDevice.updateTime]];
    self.updateTimeLb.text =[NSString stringWithFormat:@"更新于 %@",[dateTime stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
     ///目前wifi锁的模式：开锁状态>布防>反锁>安全>面容>节能>锁舌伸出
    self.lock.state = KDSLockStateNormal;
    if (self.lock.wifiDevice.openStatus == 3) {
        self.lock.state = KDSLockSpittingState;
    }if (self.lock.wifiDevice.powerSave.intValue == 1) {
        self.lock.state = KDSLockStateEnergy;
    }if (self.lock.wifiDevice.faceStatus.intValue == 0) {
        self.lock.state = KDSLockStateFaceTurnedOff;
    }if (self.lock.wifiDevice.safeMode.intValue == 1) {
        self.lock.state = KDSLockStateSecurityMode;
    }if (self.lock.wifiDevice.operatingMode.intValue == 1) {
        self.lock.state = KDSLockStateLockInside;
    }if (self.lock.wifiDevice.defences.intValue == 1) {
        self.lock.state = KDSLockStateDefence;
    }if (self.lock.wifiDevice.defences.intValue ==0 && self.lock.wifiDevice.operatingMode.intValue ==0 && self.lock.wifiDevice.safeMode.intValue == 0 && self.lock.wifiDevice.powerSave.intValue ==0 && self.lock.wifiDevice.faceStatus.intValue == 1 && self.lock.wifiDevice.openStatus ==1) {//正常状态（关闭状态）
        self.lock.state = KDSLockStateOnline;
        self.stateLabel.text = Localized(@"door has been locked");
    }if (self.lock.wifiDevice.openStatus == 2 && self.lock.state != KDSLockStateUnlocked) {//门未上锁（开锁状态）
        self.bigCircleIV.image = [UIImage imageNamed:@"openStatusIocnImg"];
        self.middleCircleIV.image = [UIImage imageNamed:@""];
        for(UIImageView *img in [self.view subviews])
        {
            if (img.tag > 10000) {
                [img removeFromSuperview];
            }
        }
        self.smallCircleIV.hidden = NO;
        self.zbLogoIV.hidden = NO;
        self.zbLogoIV.alpha = 1.0;
        
        if (self.lock.wifiDevice.distributionNetwork == 3) {
            self.smallCircleIV.image = [UIImage imageNamed:@"homeVideoLockIcon"];
            self.actionLabel.text = @"点击查看门外情况";
            self.actionLabel.textColor = UIColor.whiteColor;
            self.actionLabel.alpha = 1.0;
            self.xmMediaStateLabel.text = nil;
        }else{
            self.smallCircleIV.image = [UIImage imageNamed:@"Unlocked"];
            self.actionLabel.text = nil;
            self.xmMediaStateLabel.text = nil;
        }
        self.stateLabel.text = Localized(@"door has been unlocked");
        NSString * openStatusTime = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.lock.wifiDevice.updateTime]];
        self.updateTimeLb.text =[NSString stringWithFormat:@"更新于 %@",[openStatusTime stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
        return;
    }
     [self setLockState:self.lock.state];
}

- (void)setupUI
{
    CGFloat rate = kScreenHeight / 667;
    
    rate = rate<1 ? rate : 1;
    self.bigCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigBlueCircle"]];
    [self.view addSubview:self.bigCircleIV];
    [self.bigCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 10 : 26);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@(179 * rate));
    }];
    /*Wi-Fi锁首页不允许点击*/
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureImageViewUnlock:)];
    [self.bigCircleIV addGestureRecognizer:tapGesture];
    self.bigCircleIV.userInteractionEnabled = YES;
    self.middleCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bleConnected"]];
    [self.view addSubview:self.middleCircleIV];
    [self.middleCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bigCircleIV);
        make.width.height.equalTo(@(142 * rate));
    }];
    self.smallCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifiOffline"]];
    self.smallCircleIV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.smallCircleIV];
    [self.smallCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.centerY.equalTo(self.bigCircleIV).offset(-6 * rate);
        make.width.height.equalTo(@(30 * rate));
    }];
    self.zbLogoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifiLock-homeIcon"]];
    self.zbLogoIV.hidden = YES;
    [self.view addSubview:self.zbLogoIV];
    [self.zbLogoIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.bottom.equalTo(self.smallCircleIV.mas_top).offset(-14 * rate);
        make.width.height.equalTo(@(18 * rate));
    }];
    self.actionLabel = [self createLabelWithText:Localized(@"deviceOffline") color:KDSRGBColor(0x14, 0xa6, 0xf5) font:[UIFont systemFontOfSize:12]];
    [self.view addSubview:self.actionLabel];
    [self.actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smallCircleIV.mas_bottom).offset(kScreenHeight<667 ? 5 : 10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    if (self.lock.wifiDevice.distributionNetwork == 3) {
        self.xmMediaStateLabel = [self createLabelWithText:@"正常模式" color:KDSRGBColor(255, 255, 255) font:[UIFont systemFontOfSize:10]];
        [self.view addSubview:self.xmMediaStateLabel];
        [self.xmMediaStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.actionLabel.mas_bottom).offset(kScreenHeight<667 ? 10 : 15);
            make.centerX.equalTo(self.bigCircleIV);
        }];
    }
    self.stateLabel = [self createLabelWithText:Localized(@"") color:KDSRGBColor(0xc6, 0xf5, 0xff) font:[UIFont systemFontOfSize:15]];
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    self.updateTimeLb = [self createLabelWithText:@"2019.12.28 13:05:56" color:UIColor.whiteColor font:[UIFont systemFontOfSize:11]];
    [self.view addSubview:self.updateTimeLb];
    if (self.lock.wifiDevice.distributionNetwork == 3) {
        self.updateTimeLb.hidden = YES;
    }else{
        self.updateTimeLb.hidden = NO;
    }
    [self.updateTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
        
    }];
//    //  这里是根据锁的功能集 进行测
//    if ( ![self.lock.wifiLockFunctionSet  isEqualToString:@"0x7a"]) { // 非主用户界面
//        UIView *grayView = [UIView new];
//        grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
//        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMoreSubfuncViewAction:)];
//        [grayView addGestureRecognizer:tap];
//        [self.view addSubview:grayView];
//        [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.bottom.right.equalTo(self.view);
//            make.height.mas_equalTo(75);
//        }];
//
//        UIImageView * devInfoIcon = [UIImageView new];
//        devInfoIcon.image = [UIImage imageNamed:@"blueGear"];
//        [grayView addSubview:devInfoIcon];
//        [devInfoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.height.equalTo(@23);
//            make.left.mas_equalTo(grayView.mas_left).offset(26);
//            make.centerY.mas_equalTo(grayView.mas_centerY).offset(0);
//        }];
//        UIButton * iocnBtn = [UIButton new];
//        [iocnBtn setImage:[UIImage imageNamed:@"rightBackIcon"] forState:UIControlStateNormal];
//        [grayView addSubview:iocnBtn];
//        [iocnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(grayView.mas_right).offset(-31);
//            make.width.equalTo(@8);
//            make.height.equalTo(@13);
//            make.centerY.mas_equalTo(grayView.mas_centerY).offset(0);
//
//        }];
//        UILabel * lb = [UILabel new];
//        lb.text = Localized(@"deviceInfo");
//        lb.textColor = KDSRGBColor(51, 51, 51);
//        lb.font = [UIFont systemFontOfSize:13];
//        lb.textAlignment = NSTextAlignmentLeft;
//        [grayView addSubview:lb];
//        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(devInfoIcon.mas_right).offset(21.5);
//            make.right.mas_equalTo(iocnBtn.mas_left).offset(-20);
//            make.centerY.mas_equalTo(grayView.mas_centerY).offset(0);
//        }];
//
//    } else
    if ( ![self.lock.wifiLockFunctionSet  isEqualToString:@"0x7a"]  ){
        
        UIView *cornerView = [UIView new];
        cornerView.layer.cornerRadius = 4;
        cornerView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:cornerView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToViewDeviceDynamicDetails:)];
        [cornerView addGestureRecognizer:tap];
        CGFloat   height =0;
        NSLog(@"zhuxx 屏幕的高度==%f",KDSScreenHeight);
        if (KDSScreenHeight == 896) { // 适配xr
            height = 50;
        }else  if(KDSScreenHeight ==0){
            
        }
        [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bigCircleIV.mas_bottom).offset(57 * rate + height);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@50);
        }];
        // 门锁记录
        UILabel   * lockrecord = [UILabel new];
        lockrecord.text = @"门锁记录";
        lockrecord.font = [UIFont systemFontOfSize:15];
        [cornerView addSubview:lockrecord];
        [lockrecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@21);
            make.centerY.equalTo(cornerView.mas_centerY);
            make.left.equalTo(cornerView.mas_left).offset(10);
        }];
        UIImageView *arrowIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头Hight"]];
        [cornerView addSubview:arrowIV];
        [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.right.equalTo(cornerView).offset(-20);
            make.size.mas_equalTo(arrowIV.image.size);
        }];
        // 存放collectionView的控件
        UIView *grayView = [UIView new];
        grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        
        [self.view addSubview:grayView];
        [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.view);
        
           // kScreenHeight == 667 ? 366 : 388;
            make.height.mas_equalTo(KDSScreenHeight - KDSSSALE_HEIGHT(kScreenHeight == 667 ? 435 : 388));
        }];
        NSLog(@"zhushiqi ==输出屏幕的宽度==%f高度==%f",kScreenWidth,kScreenHeight);
        UIView *funcornerView = [UIView new];
        funcornerView.backgroundColor = UIColor.whiteColor;
        funcornerView.layer.cornerRadius = 4;
        funcornerView.clipsToBounds = YES;
        [grayView addSubview:funcornerView];
        if (self.funcImgListArray.count >= 7) {
            [funcornerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(grayView).offset(47);
                make.left.equalTo(grayView).offset(15);
                make.bottom.equalTo(grayView).offset(1);
                make.right.equalTo(grayView).offset(-15);
            }];
        }else{
            [funcornerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(grayView).offset(47);
                make.left.equalTo(grayView).offset(15);
                make.bottom.equalTo(grayView).offset(-17);
                make.right.equalTo(grayView).offset(-15);
            }];
        }
        [funcornerView addSubview:self.collectionView];
        [self.view sendSubviewToBack:grayView];
        // 注册
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSBleAddWiFiFuncListCell class]) bundle:nil] forCellWithReuseIdentifier:deviceListCellId];
        ////添加猫眼、网关父视图
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(funcornerView);
        }];
    } else {
        UIView *cornerView = [UIView new];
        cornerView.layer.cornerRadius = 4;
        cornerView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:cornerView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToViewDeviceDynamicDetails:)];
        [cornerView addGestureRecognizer:tap];
        [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bigCircleIV.mas_bottom).offset(57 * rate);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@80);
        }];
        UIImageView *arrowIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头Hight"]];
        [cornerView addSubview:arrowIV];
        [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.right.equalTo(cornerView).offset(-20);
            make.size.mas_equalTo(arrowIV.image.size);
        }];
        UILabel *timeLabel = [self createLabelWithText:Localized(@"guardianTime") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
        self.guardianDayLocalizedLabel = timeLabel;
        UILabel *timesLabel = [self createLabelWithText:Localized(@"guardianTimes") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
        self.guardianTimesLocalizedLabel = timesLabel;
        [cornerView addSubview:timeLabel];
        [cornerView addSubview:timesLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cornerView).offset(6);
            make.top.equalTo(cornerView).offset(13);
            make.right.equalTo(timesLabel.mas_left).offset(0);
            make.width.equalTo(timesLabel);
        }];
        [timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLabel);
            make.left.equalTo(timeLabel.mas_right).offset(6);
            make.right.equalTo(arrowIV.mas_left).offset(-6);
            make.width.equalTo(timeLabel);
                    
        }];
        UIView * lineView = [UIView new];
        lineView.backgroundColor = KDSRGBColor(220, 220, 220);
        [cornerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@1);
            make.top.mas_equalTo(cornerView.mas_top).offset(10);
            make.bottom.mas_equalTo(cornerView.mas_bottom).offset(-10);
            make.centerX.mas_equalTo(cornerView.mas_centerX).offset(0);
        }];
        self.dayLabel = [self createLabelWithText:nil color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:23]];
        [cornerView addSubview:self.dayLabel];
        [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(cornerView);
            make.left.right.equalTo(timeLabel);
        }];
        ///开锁次数
        self.timesLabel = [self createLabelWithText:self.timesLabel.text color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:23]];
        [cornerView addSubview:self.timesLabel];
        [self.timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(cornerView);
            make.left.right.equalTo(timesLabel);
        }];
        UILabel *dLabel = [self createLabelWithText:Localized(@"days") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
        self.dayLocalizedLabel = dLabel;
        [cornerView addSubview:dLabel];
        [dLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(timeLabel);
            make.bottom.equalTo(cornerView).offset(-12);
        }];
        UILabel *tLabel = [self createLabelWithText:Localized(@"times") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
        self.timesLocalizedLabel = tLabel;
        [cornerView addSubview:tLabel];
        [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(timesLabel);
            make.bottom.equalTo(cornerView).offset(-12);
        }];
        
        UIView * synview = [UIView new];
        synview.backgroundColor = UIColor.whiteColor;
        synview.layer.cornerRadius = 4;
        [self.view addSubview:synview];
        [synview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cornerView.mas_bottom).offset(8);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@40);
        }];
        UILabel * tipsLb = [UILabel new];
        tipsLb.text = Localized(@"Synchronous door lock status");
        tipsLb.textColor = KDSRGBColor(44, 44, 44);
        tipsLb.font = [UIFont systemFontOfSize:12];
        tipsLb.textAlignment = NSTextAlignmentLeft;
        [synview addSubview:tipsLb];
        [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(synview.mas_left).offset(14);
            make.top.bottom.mas_equalTo(0);
            make.width.equalTo(@100);
        }];
        UIButton * synBtn = [UIButton new];
        [synBtn setTitle:Localized(@"syncRecord") forState:UIControlStateNormal];
        [synBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
        synBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        synBtn.layer.cornerRadius = 11;
        synBtn.layer.borderWidth = 1;
        synBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
        [synview addSubview:synBtn];
        [synBtn addTarget:self action:@selector(synBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [synBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@80);
            make.height.equalTo(@25);
            make.right.mas_equalTo(synview.mas_right).offset(-8);
            make.centerY.mas_equalTo(synview.mas_centerY).offset(0);
        }];
        
        UIView *grayView = [UIView new];
        grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [self.view insertSubview:grayView belowSubview:cornerView];
        [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView.mas_centerY);
            make.left.bottom.right.equalTo(self.view);
        }];

        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.view addSubview:self.tableView];
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(synview.mas_bottom).offset(0);
            make.left.mas_equalTo(self.view.mas_left).offset(0);
            make.right.mas_equalTo(self.view.mas_right).offset(0);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        }];
        self.tableView.rowHeight = 40;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.001)];
        self.tableView.sectionFooterHeight = 0.0001;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getUnlockRecord)];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = self.view.backgroundColor;
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
       
         
    }
   
}
//  CollectionView代理 方法的实现
#pragma mark UICollecionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.funcImgListArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSBleAddWiFiFuncListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceListCellId forIndexPath:indexPath];
    
    cell.backgroundColor = UIColor.clearColor;
    cell.funcImgView.image = [UIImage imageNamed:self.funcImgListArray[indexPath.row]];
    cell.funcNameLb.text = self.funcNameListArray[indexPath.row];
    cell.rightLine.hidden = (indexPath.row + 1) % 3 == 0 ? YES : NO;
    //    cell.bottomLine.hidden = self.funcImgListArray.count / 3 >0 ? YES : NO;
    cell.funcNumLb.text = @"";
    if ([cell.funcNameLb.text isEqualToString:Localized(@"faceRecognition")]) {///面容识别
        cell.funcNumLb.text = self.funcNumListArray[0];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"password")]) {///密码
        cell.funcNumLb.text = self.funcNumListArray[1];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"fingerprint")]) {///指纹
        cell.funcNumLb.text = self.funcNumListArray[2];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"card")]) {///卡片
        cell.funcNumLb.text = self.funcNumListArray[3];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"deviceShare")]) {///设备共享
        cell.funcNumLb.text = self.funcNumListArray[4];
    }
    
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake((kScreenWidth - 32) / 3.0, (260 * kScreenWidth / 375.0 - 1) / 2.0);
    return size;
}

// 两个cell之间的最小间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
// 两行之间的最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
//collectionView的点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDSBleAddWiFiFuncListCell * cell = (KDSBleAddWiFiFuncListCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.funcNameLb.text = self.funcNameListArray[indexPath.row];
    if ([cell.funcNameLb.text isEqualToString:Localized(@"tempPassword")]) {
        //临时密码
        KDSWifiLockPwdShareVC * vc = [KDSWifiLockPwdShareVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"realTimeVideo")]){
        //实时视频
        if (self.lock.wifiDevice.powerSave.intValue == 1) {
            ///锁已开启节能模式，无法查看门外情况
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"锁已开启节能模式，无法查看门外情况" message:@"请更换电池或进入管理员模式进行关闭" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            //修改title
            NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"锁已开启节能模式，无法查看门外情况"];
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
        XMPlayController * vc = [XMPlayController new];
        vc.lock = self.lock;
        vc.isActive = YES;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"dynamicRecording")]){
        //动态记录
        KDSMediaLockRecordDetailsVC * vc = [KDSMediaLockRecordDetailsVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"myAlbum")]){
        //我的相册
        KDSMyAlbumVC * vc = [KDSMyAlbumVC new];
        vc.hidesBottomBarWhenPushed = YES;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"faceRecognition")]){
        //面容识别
        
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypeFace;
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"password")]){
        //密码
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypePIN;
        vc.hidesBottomBarWhenPushed = YES;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"fingerprint")]){
        //指纹
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypeFingerprint;
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"card")]){
        //卡片
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypeRFID;
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"IntelligentSwitchImg")]){
        //智能开关
        KDSSwitchLinkageDetailVC * vc = [KDSSwitchLinkageDetailVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"deviceShare")]){
        //设备分享
        KDSLockKeyVC *vc = [KDSLockKeyVC new];
        vc.keyType = KDSBleKeyTypeReserved;
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"more")]){
        if (self.lock.wifiDevice.distributionNetwork == 3) {
            
            KDSMediaLockMoreSettingVC * vc = [KDSMediaLockMoreSettingVC new];
            vc.lock = self.lock;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            //更多
            KDSWIfiLockMoreSettingVC * vc = [KDSWIfiLockMoreSettingVC new];
            vc.lock = self.lock;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else  if([cell.funcNameLb.text isEqualToString:@"设备信息"]){
        [self  tapMoreSubfuncViewAction:nil];
    }
}
- (void)getAllKeys
{
    [[KDSHttpManager sharedManager] getWifiLockAuthorizedUsersWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSAuthMember *> * _Nullable members) {
        
        [[KDSHttpManager sharedManager] getWifiLockPwdListWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdList, NSArray<KDSPwdListModel *> * _Nonnull fingerprintList, NSArray<KDSPwdListModel *> * _Nonnull cardList, NSArray<KDSPwdListModel *> * _Nonnull faceList, NSArray<KDSPwdListModel *> * _Nonnull pwdNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull cardNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull faceNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull pwdDuressArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintDuressArr) {
            int pin = 0, fp = 0, card = 0, membs = 0,face =0;
            for (KDSPwdListModel *m in pwdList)
            {
                if (m.num) {
                    pin++;
                }
            }
            for (KDSPwdListModel *m in fingerprintList)
            {
                if (m.num) {
                    fp++;
                }
            }
            for (KDSPwdListModel *m in cardList)
            {
                if (m.num) {
                    card++;
                }
            }
            for (KDSPwdListModel * m in faceList) {
                if (m.num) {
                    face++;
                }
            }
            for (KDSAuthMember * n in members) {
                if (n.uname) {
                    membs++;
                }
            }
            [self setNumberOfPIN:pin fingerprint:fp card:card face:face member:membs];
        } error:nil failure:nil];
    } error:nil failure:nil];
}
///设置密码、指纹、卡片、共享用户数量。负数不设置。
- (void)setNumberOfPIN:(int)pin fingerprint:(int)fp card:(int)card face:(int)face member:(int)members
{
    NSLog(@"zhushiqi 输出获取到的设置到锁端的数量 密码==%d 手指==%d 卡片==%d 面部==%d 分享===%d ",pin,fp,card,face,members);
    NSString *pinUnit = pin>1 ? @" groups" : @" group";
    NSString *fpUnit = fp>1 ? @" pieces" : @" piece";
    NSString *cardUnit = card>1 ? @" pieces" : @" piece";
    NSString *faceUnit = face>1 ? @" pieces" : @" piece";
    NSString *pUnit = members>1 ? @" persons" : @" person";
    if ([[KDSTool getLanguage] hasPrefix:JianTiZhongWen])
    {
        pinUnit = @"组";
        fpUnit = @"组";
        cardUnit = @"张";
        faceUnit = @"组";
        pUnit = @"台";
    }
    else if ([[KDSTool getLanguage] containsString:FanTiZhongWen])
    {
        pinUnit = @"組";
        fpUnit = @"組";
        cardUnit = @"張";
        faceUnit = @"組";
        pUnit = @"台";
    }
    else if ([[KDSTool getLanguage] containsString:@"th"])
    {
        pinUnit = pin>1 ? @" groups" : @" group";
        fpUnit = fp>1 ? @" pieces" : @" piece";
        cardUnit = card>1 ? @" pieces" : @" piece";
        faceUnit = face>1 ? @" pieces" : @" piece";
        pUnit = members>1 ? @" persons" : @" person";
    }
#pragma mark   修改记录
    // 去掉显示数据列表的数量
    if (face >=0) [self.funcNumListArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@%@", @"", @""]];
    if (pin >= 0)[self.funcNumListArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%@%@", @"", @""]];
    if (fp >= 0) [self.funcNumListArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@%@", @"", @""]];
    if (card >= 0) [self.funcNumListArray replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%@%@", @"", @""]];
    if (members >= 0) [self.funcNumListArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%@%@", @"", @""]];
    
    [self.collectionView reloadData];
}
///根据各属性创建一个label，返回的label已计算好bounds。alignment center.
- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}
/**
 *@brief 启动开锁/关锁各阶段动画。
 *@param stage 阶段，其中：1表示开锁过程动画，2表示开锁成功动画，3表示开锁失败动画，4表示关锁动画。当开锁失败或者关锁时移除视图。
 */
- (void)stagingLockOperationAnimation:(int)stage
{
    self.xmMediaStateLabel.hidden = YES;
    NSInteger gearTag = @"gearIV".hash, cMiddleTag = @"cMiddleIV".hash, cSmallTag = @"cSmallIV".hash;
    UIImageView *gearIV= [self.view viewWithTag:gearTag];//锯齿外圈
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
        [self.view bringSubviewToFront:self.zbLogoIV];
        [self.view bringSubviewToFront:self.actionLabel];
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
        self.middleCircleIV.hidden = self.smallCircleIV.hidden = YES;
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
            self.zbLogoIV.transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.zbLogoIV.alpha = 0.0;
            self.actionLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.actionLabel.alpha = 0.0;
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
        self.stateLabel.text = Localized(@"door has been unlocked");
        self.actionLabel.alpha = 0.0;
        self.zbLogoIV.alpha = 0.0;
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
        self.zbLogoIV.transform = self.actionLabel.transform = CGAffineTransformIdentity;
        self.zbLogoIV.alpha = self.actionLabel.alpha = 1.0;
        self.bigCircleIV.tag = 0;
        self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
        NSLog(@"当前停止动画后中间的圆的显示状态是：%hhd---内部小圆的显示状态：%hhd----小圆的图片%@",self.middleCircleIV.hidden,self.smallCircleIV.hidden, self.middleCircleIV.image);
        
    };
    if (stage == 3)//开锁失败动画
    {
        stopAnimationAndRemoveViews();
        return;
    }
    if (stage == 4)//关锁动画
    {
        self.stateLabel.text = Localized(@"door has been locked");
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


#pragma mark - 控件等事件方法。
///长按中间的浅绿色视图开锁。为方便其它页面发起的通知开锁，sender传nil和手势共用一个方法。
- (void)tapGestureImageViewUnlock:(UITapGestureRecognizer *)sender
{
    if (self.lock.wifiDevice.distributionNetwork == 3) {
        if (self.lock.wifiDevice.powerSave.intValue == 1) {
            ///锁已开启节能模式，无法查看门外情况
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"锁已开启节能模式，无法查看门外情况" message:@"请更换电池或进入管理员模式进行关闭" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            //修改title
            NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"锁已开启节能模式，无法查看门外情况"];
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
        ///跳转到视频连接页面
        XMPlayController *vc = [[XMPlayController alloc] initWithType:XMPlayTypeLive];
        vc.lock = self.lock;
        vc.isActive = YES;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:true];
        
    }else{
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"不可点击" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alerVC animated:YES completion:nil];
        [self performSelector:@selector(dismiss:) withObject:alerVC afterDelay:2.0];
        return;
    }

}

-(void)synBtnClick:(UIButton *)sender
{
    [self getUnlockRecord];
}

///点击动态所在父视图进入开锁和报警记录详情页。
- (void)tapToViewDeviceDynamicDetails:(UITapGestureRecognizer *)sender
{
    if (self.lock.wifiDevice.distributionNetwork == 3) {
        
        KDSMediaLockRecordDetailsVC *  vc = [KDSMediaLockRecordDetailsVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
        KDSWFRecordDetailsVC * vc = [KDSWFRecordDetailsVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

///点击更多按钮查看更多记录。
- (void)moreButtonClick:(UIButton *)sender
{
    if (self.lock.wifiDevice.distributionNetwork == 3) {
        
        KDSMediaLockRecordDetailsVC *  vc = [KDSMediaLockRecordDetailsVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
        KDSWFRecordDetailsVC * vc = [KDSWFRecordDetailsVC new];
        vc.lock = self.lock;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 通知相关方法。

///收到更改了本地语言的通知，更新页面文字。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.lockState = self.lockState;
    self.guardianDayLocalizedLabel.text = Localized(@"guardianTime");
    self.guardianTimesLocalizedLabel.text = Localized(@"guardianTimes");
    self.dayLocalizedLabel.text = Localized(@"days");
    self.timesLocalizedLabel.text = Localized(@"times");
    [self.tableView reloadData];
}
///mqtt上报事件通知。#@#@########
- (void)wifimqttEventNotification:(NSNotification *)noti
{
    
    NSLog(@"zhu -KDSWifiLockInfoVC-  接收到wifi 事件上报通知");
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
   if ([event isEqualToString:MQTTSubEventWifiUnlock]){
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
        [self setLockState:KDSLockStateUnlocked];
        [self getUnlockRecord];
        [self getUnlockTimes];
        int eventType = [param[@"eventType"] intValue]/*, uid = [param[@"userID"] intValue] */, eventSource = [param[@"eventSource"] intValue];
        if (eventType== 2)
        {
            //指纹、卡片开锁不区分是否是胁迫
            [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:Localized(@"theLock%@UnlckWithMenace%@"), self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN, Localized((eventSource==0 ? @"password" : (eventSource==3 ? @"card"/*@"menaceCard"*/ : @"fingerprint"/*@"menaceFingerprint"*/)))] tapHandler:^{
            }];
        }
       return;
    }
    else if ([event isEqualToString:MQTTSubEventWifiLock])
    {
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
        if (self.lockState != KDSLockStateClosed){
           [self setLockState:KDSLockStateClosed];
        }
    }else if ([event isEqualToString:MQTTSubEventWifiLockTongueSticksOut])
    {
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
        [self setLockState:KDSLockSpittingState];
    }else if ([event isEqualToString:MQTTSubEventWifiLockStateChanged]){
        if (self.lock.state == KDSLockStateUnlocked) {
            return;
        }
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
      
        //action事件
        NSString * eventtype = param[@"eventtype"];
        if ([eventtype isEqualToString:@"record"]) {
            ///WIFI锁操作实时上报
            NSNumber *eventCode = param[@"eventCode"];
            if (eventCode.intValue == 1) {
                //自动模式
                self.lock.wifiDevice.amMode = [NSString stringWithFormat:@"%d",0];
            }else if (eventCode.intValue == 2){
                //手动模式
                self.lock.wifiDevice.amMode = [NSString stringWithFormat:@"%d",1];
            }else if (eventCode.intValue == 3){
                //通用模式
                self.lock.wifiDevice.safeMode = [NSString stringWithFormat:@"%d",0];
            }else if (eventCode.intValue == 4){
                //安全模式
                self.lock.wifiDevice.safeMode = [NSString stringWithFormat:@"%d",1];
            }else if (eventCode.intValue == 5){
                //反锁模式
                self.lock.wifiDevice.operatingMode = [NSString stringWithFormat:@"%d",1];
            }else if (eventCode.intValue == 6){
                //布防模式
                self.lock.wifiDevice.defences = [NSString stringWithFormat:@"%d",1];
            }else if (eventCode.intValue == 7){
                //节能模式
                self.lock.wifiDevice.powerSave = [NSString stringWithFormat:@"%d",1];
            }
        }else if ([eventtype isEqualToString:@"action"]){
            ///WIFI锁开关推送
            self.lock.wifiDevice.defences = param[@"defences"];
            self.lock.wifiDevice.operatingMode = param[@"operatingMode"];
            self.lock.wifiDevice.safeMode = param[@"safeMode"];
            self.lock.wifiDevice.defences = param[@"defences"];
            self.lock.wifiDevice.volume = param[@"volume"];
            self.lock.wifiDevice.language = param[@"language"];
            self.lock.wifiDevice.faceStatus = param[@"faceStatus"];
            self.lock.wifiDevice.powerSave = param[@"powerSave"];
        }
        
        ///目前wifi锁的模式：开锁状态>布防>反锁>安全>面容>节能>锁舌伸出
        if (self.lock.wifiDevice.powerSave.intValue == 1) {
            self.lock.state = KDSLockStateEnergy;
        }
        if (self.lock.wifiDevice.faceStatus.intValue == 0) {
            self.lock.state = KDSLockStateFaceTurnedOff;
        }
        if (self.lock.wifiDevice.safeMode.intValue == 1) {
            self.lock.state = KDSLockStateSecurityMode;
        }
        if (self.lock.wifiDevice.operatingMode.intValue == 1) {
            self.lock.state = KDSLockStateLockInside;
        }
        if (self.lock.wifiDevice.defences.intValue == 1) {
            self.lock.state = KDSLockStateDefence;
        }
        if (self.lock.wifiDevice.defences.intValue ==0 && self.lock.wifiDevice.operatingMode.intValue ==0 && self.lock.wifiDevice.safeMode.intValue == 0 && self.lock.wifiDevice.powerSave.intValue == 0 && self.lock.wifiDevice.faceStatus.intValue == 1) {//正常状态
            self.lock.state = KDSLockStateOnline;
            self.stateLabel.text = Localized(@"door has been locked");
        }
        [self setLockState:self.lock.state];
        self.updateTimeLb.text = [NSString stringWithFormat:@"更新于 %@",[KDSTool timeStringFromTimestamp:param[@"timestamp"]]];
        
    }
}


#pragma mark - Http相关方法。

///获取第一页的开锁记录。
- (void)getUnlockRecord
{
    void (^noRecord) (UITableView *) = ^(UITableView *tableView) {
        UILabel *label = [[UILabel alloc] initWithFrame:tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        if (tableView == self.tableView) {
            label.text = Localized(@"noUnlockRecord,pleaseSync");
        }else{
            label.text = Localized(@"NoAlarmRecord");
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"synchronizingRecord") toView:self.view];
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceOperationWithWifiSN:self.lock.wifiDevice.wifiSN index:1 success:^(NSArray<KDSWifiLockOperation *> * _Nonnull operations) {
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.unlockRecordArr removeAllObjects];
           if (operations.count == 0)
           {
               self.tableView.mj_header.state = MJRefreshStateNoMoreData;
                noRecord(self.tableView);
               return;
           }
          [self.tableView.mj_footer resetNoMoreData];
           for (KDSWifiLockOperation * operation in operations)
           {
               operation.date = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:operation.time]];
               [self.unlockRecordArr insertObject:operation atIndex:[operations indexOfObject:operation]];
           }
        [self reloadTableView:self.tableView];
        self.tableView.mj_header.state = MJRefreshStateIdle;
//        [MBProgressHUD showSuccess:Localized(@"syncComplete")];
    } error:^(NSError * _Nonnull error) {
         [hud hideAnimated:YES];
         [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.tableView.mj_header.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [hud hideAnimated:YES];
         [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];
         self.tableView.mj_header.state = MJRefreshStateIdle;
    }];
    
}
/**
 *@abstract 刷新表视图，调用此方法前请确保开锁或者报警记录的属性数组内容已经更新。方法执行时会自动提取分组记录。
 *@param tableView 要刷新的表视图。
 */
- (void)reloadTableView:(UITableView *)tableView
{
    void (^noRecord) (UITableView *) = ^(UITableView *tableView) {
        UILabel *label = [[UILabel alloc] initWithFrame:tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        if (tableView == self.tableView) {
            label.text = Localized(@"noUnlockRecord,pleaseSync");
        }else{
            label.text = Localized(@"NoAlarmRecord");
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    if (tableView == self.tableView)
    {
        [self.unlockRecordArr sortUsingComparator:^NSComparisonResult(KDSWifiLockOperation *  _Nonnull obj1, KDSWifiLockOperation *  _Nonnull obj2) {
            return obj1.time < obj2.time;
        }];
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray *elements = [NSMutableArray array];
        __block NSString *date = nil;
        [self.unlockRecordArr enumerateObjectsUsingBlock:^(KDSWifiLockOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj.date componentsSeparatedByString:@" "].firstObject isEqualToString:date])
            {
                [elements addObject:obj];
            }
            else
            {
                date = [obj.date componentsSeparatedByString:@" "].firstObject;
                if (elements.count > 0) {
                   [sections addObject:elements.copy];
                }
                [elements removeAllObjects];
                [elements addObject:obj];
            }
        }];
        if (elements.count) [sections addObject:elements.copy];
        self.unlockRecordSectionArr = sections;
        if (self.unlockRecordArr.count == 0)
        {
            noRecord(self.tableView);
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
                [self.tableView reloadData];
            });
        }
    }
}

///获取开锁次数，并更新页面。
- (void)getUnlockTimes
{
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceOperationCountWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN index:1 success:^(int count) {
        self.timesLabel.text = @(count).stringValue;
    } error:nil failure:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSourc
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.unlockRecordSectionArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unlockRecordSectionArr[section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
   ///操作记录
       cell.alarmRecLabel.hidden = YES;
       cell.topLine.hidden = indexPath.row == 0;
       cell.bottomLine.hidden = indexPath.row == self.unlockRecordSectionArr[indexPath.section].count - 1;
       KDSWifiLockOperation *record = self.unlockRecordSectionArr[indexPath.section][indexPath.row];
       cell.timerLabel.text = record.date.length > 16 ? [record.date substringWithRange:NSMakeRange(11, 5)] : record.date;
       //type记录类型：1开锁 2关锁 3添加密钥 4删除密钥 5修改管理员密码 6自动模式 7手动模式 8常用模式切换 9安全模式切换 10反锁模式 11布防模式 12修改密码昵称 13添加分享用户 14删除分享用户
       //pwdType密码类型：0密码 3卡片 4指纹 8APP用户 9机械方式 10室内open键开锁 11室内感应把手开锁
    //开锁记录昵称（zigbee、蓝牙，都有昵称，么有昵称显示编号）
     cell.userNameLabel.text = @"";
           if (record.type == 1)
           {
               switch (record.pwdType) {
                   case 0:
                       cell.unlockModeLabel.text = Localized(@"密码");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 3:
                       cell.unlockModeLabel.text = Localized(@"卡片");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 4:
                       cell.unlockModeLabel.text = Localized(@"指纹");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 7:
                       cell.unlockModeLabel.text = Localized(@"面容识别");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 8:
                       cell.unlockModeLabel.text = Localized(@"appUnlock");
                       cell.userNameLabel.text = @"";
                       break;
                   case 9:
                       cell.userNameLabel.text = Localized(@"机械方式");
                       cell.unlockModeLabel.text = @"";
                       break;
                   case 10:
                       cell.userNameLabel.text = Localized(@"室内open键");
                       cell.unlockModeLabel.text = @"";
                       break;
                   case 11:
                       cell.userNameLabel.text = Localized(@"室内感应把手");
                       cell.unlockModeLabel.text = @"";
                       break;
                       
                   default:
                       cell.unlockModeLabel.text = @"开锁";
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
               }
               if (record.pwdNum == 252) {
                   cell.userNameLabel.text = @"临时密码开锁";
                   cell.unlockModeLabel.text = @"";
               }else if (record.pwdNum == 250){
                    cell.userNameLabel.text = @"临时密码开锁";
                    cell.unlockModeLabel.text = @"";
               }else if (record.pwdNum == 253){
                    cell.userNameLabel.text = @"访客密码开锁";
                    cell.unlockModeLabel.text = @"";
               }else if (record.pwdNum == 254){
                    cell.userNameLabel.text = @"管理员密码开锁";
                    cell.unlockModeLabel.text = @"";
               }
               
           }else if (record.type == 2)
           {
               cell.unlockModeLabel.text = @"";
               cell.userNameLabel.text = @"门锁已上锁";
           }else if (record.type == 3){
               switch (record.pwdType) {
                   case 0:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d密码",record.pwdNum];
                       break;
                   case 4:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d指纹",record.pwdNum];
                       break;
                   case 3:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d卡片",record.pwdNum];
                       break;
                    case 7:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d面容识别",record.pwdNum];
                       break;
       
                   default:
                       cell.userNameLabel.text = @"添加密钥";
                       break;
               }
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 4){
               switch (record.pwdType) {
                   case 0:
                   {
                      if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有密码"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d密码",record.pwdNum];
                       }
                   }
                       break;
                   case 4:
                   {
                       if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有指纹"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d指纹",record.pwdNum];
                       }
                   }
                       break;
                   case 3:
                   {
                       if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有卡片"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d卡片",record.pwdNum];
                       }
                   }
                       break;
                    case 7:
                   {
                       if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有面容识别"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d面容识别",record.pwdNum];
                       }
                   }
                       break;
                   default:
                       cell.userNameLabel.text = @"删除密钥";
                       break;
               }
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 5){
               cell.userNameLabel.text = @"门锁修改管理员密码";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 6){
               cell.userNameLabel.text = @"门锁切换自动模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 7){
               cell.userNameLabel.text = @"门锁切换手动模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 8){
               cell.userNameLabel.text = @"门锁切换常用模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 9){
               cell.userNameLabel.text = @"门锁切换安全模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 10){
               cell.userNameLabel.text = @"门锁启动反锁模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 11){
               cell.userNameLabel.text = @"门锁启动布防模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 12){
               ///更改01密码昵称为妈妈
               switch (record.pwdType) {
                   case 0:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d密码昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                   case 3:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d卡片昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                   case 4:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d指纹昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                    case 7:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d面容识别昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                   default:
                       break;
               }
               cell.userNameLabel.text = record.userNickname;
           }else if (record.type == 13){
               ///添加明明为门锁授权使用
               cell.unlockModeLabel.text = [NSString stringWithFormat:@"授权%@使用门锁",record.shareUserNickname ?: record.shareAccount];
               cell.userNameLabel.text = record.userNickname;
           }else if (record.type == 14){
               ///删除明明为门锁授权使用
               cell.unlockModeLabel.text = [NSString stringWithFormat:@"删除%@使用门锁",record.shareUserNickname ?: record.shareAccount];
               cell.userNameLabel.text = record.userNickname;
           }else if (record.type == 15){
               ///修改管理指纹
               cell.userNameLabel.text = @"门锁修改管理员指纹";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 16){
               ///16添加管理员指纹
               cell.userNameLabel.text = @"门锁添加管理员指纹";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 17){
               ///17启动节能模式
               cell.userNameLabel.text = @"门锁启动节能模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 18){
               ///18关闭节能模式
               cell.userNameLabel.text = @"门锁关闭节能模式";
               cell.unlockModeLabel.text = @"";
           }else{
               cell.userNameLabel.text = Localized(@"未知操作");
               cell.unlockModeLabel.text = @"";
           }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = UIColor.clearColor;
    ///线
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
    NSString *todayStr = [[self.dateFmt stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger today = [todayStr substringToIndex:8].integerValue;
    NSString *dateStr = self.unlockRecordSectionArr[section].firstObject.date;
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
    btn.backgroundColor = [UIColor clearColor];
    btn.hidden = section != 0;
    [btn setTitle:Localized(@"more") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  非主用户的点击事件
///点击更多子功能视图。
- (void)tapMoreSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    
    KDSWifiLockParamVC  *medVC = [KDSWifiLockParamVC new];
    medVC.lock = self.lock;
    [self.navigationController pushViewController:medVC animated:YES];
}

@end

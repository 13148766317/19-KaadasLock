//
//  KDSGWLockInfoVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/26.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWLockInfoVC.h"
#import "KDSHomePageLockStatusCell.h"
#import "KDSMQTT.h"
#import "KDSDBManager+GW.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager.h"
#import "KDSGWRecordDetailsVC.h"
#import "KDSCountdown.h"
#import "NSDate+KDS.h"
#import <AudioToolbox/AudioToolbox.h>
#import "KDSFTIndicator.h"

@interface KDSGWLockInfoVC () <UITableViewDelegate, UITableViewDataSource>

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
///锁状态提示标签(反锁、布防等)。
@property (nonatomic, strong) UILabel *stateLabel;
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
///“设备动态”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *deviceDynamicsLocalizedLabel;
///锁动态状态标签。初始化是正常状态，tag为0，报警后设置为异常状态并不再修改，tag为1.
@property (nonatomic, strong) UILabel *deviceDynamicsLabel;
///MQTT服务器请求回来的开锁记录按日期分组后的数组，同一天的记录分到同一组。只请求第一页最多20条记录。
@property (nonatomic, strong) NSArray<NSArray<KDSGWUnlockRecord *> *> *unlockRecordArr;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;
///锁状态。
@property (nonatomic, assign) KDSLockState lockState;
@property (nonatomic, strong) UITableView * tableView;
///记录是否正在进行连接成功，如果是，设置锁状态时直接返回，等动画完毕再设置锁状态。
@property (nonatomic, assign) BOOL animating;

@end

@implementation KDSGWLockInfoVC

#pragma mark - getter setter
- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFmt;
}

- (void)setLockState:(KDSLockState)lockState
{
    _lockState = lockState;
    self.lock.state = lockState;
    self.zbLogoIV.hidden = NO;
    self.actionLabel.textColor = UIColor.whiteColor;
    self.bigCircleIV.image = [UIImage imageNamed:@"bigBlueCircle"];
    if (!self.lock.connected) {
        lockState = KDSLockStateOffline;
    }
    switch (lockState)
    {
        case KDSLockStateDefence:
            self.middleCircleIV.image = [UIImage imageNamed:@"lockDefence"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"defenceMode");
            break;
            
        case KDSLockStateLockInside:
            self.middleCircleIV.image = [UIImage imageNamed:@"lockInside"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"lockInside");
            break;
            
        case KDSLockStateSecurityMode:
            self.bigCircleIV.image = [UIImage imageNamed:@"securityModeBigCircle"];
            self.middleCircleIV.image = [UIImage imageNamed:@"securityMode"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"securityMode");
            break;
            
        case KDSLockStateOnline:
            self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            break;
            
        case KDSLockStateUnlocking:
            self.stateLabel.text = Localized(@"unlocking");
            [self stagingLockOperationAnimation:1];
            break;
            
        case KDSLockStateUnlocked:
            self.stateLabel.text = Localized(@"unlocked");
            [self stagingLockOperationAnimation:2];
            break;
            
        case KDSLockStateFailed:
            self.stateLabel.text = Localized(@"Closedstate");
            [self stagingLockOperationAnimation:3];
            [self setLockState:KDSLockStateOnline];
            break;
            
        case KDSLockStateClosed:
            self.stateLabel.text = Localized(@"Closedstate");
            [self stagingLockOperationAnimation:4];
            [self setLockState:KDSLockStateOnline];
            break;
            
        default:
            self.middleCircleIV.image = [UIImage imageNamed:@"bleNotConnect"];
            self.smallCircleIV.image = [UIImage imageNamed:@"wifiOffline"];
            self.actionLabel.text = Localized(@"deviceOffline");
            self.actionLabel.textColor = KDSRGBColor(0x14, 0xa6, 0xf5);
            self.stateLabel.text = nil;
            self.zbLogoIV.hidden = YES;
            break;
    }
    [self syncGwLockTime];
}

#pragma mark - 生命周期、UI设置相关方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    [self setupUI];
//    [self getLockPower];
    self.timesLabel.text = @"0";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(KDSHomePageLockStatusCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass([self class])];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mqttEventNotification:) name:KDSMQTTEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userOperateUnlock:) name:KDSUserUnlockNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenDeviceDidSync:) name:KDSDeviceSyncNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    [[KDSMQTTManager sharedManager] dlGetMode:self.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success, int mode) {
        if (mode == 0)
        {
            self.stateLabel.text = Localized(@"Closedstate");
            self.lockState = KDSLockStateOnline;
        }
        else if (mode == 1)
        {
            self.lockState = KDSLockStateDefence;
        }
        else if (mode == 2)
        {
            self.lockState = KDSLockStateLockInside;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUnlockRecord];
    ///网关锁守护天数
    NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSDate *joinDate = [fmt dateFromString:self.lock.gwDevice.joinTime];
    NSTimeInterval interval = [joinDate timeIntervalSince1970] /*- [NSTimeZone localTimeZone].secondsFromGMT*/;
    self.dayLabel.text = @(floor((self.lock.gwDevice.currentTime - interval) / 24 / 3600)).stringValue;
    
    self.lockState = (self.lock.connected && [self.lock.gwDevice.event_str isEqualToString:@"online"]) ? KDSLockStateOnline : KDSLockStateOffline;
    if (self.lock.connected) {
         self.deviceDynamicsLabel.text = Localized(@"normal");
    }else{
         self.deviceDynamicsLabel.text = Localized(@"offline");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getUnlockTimes];
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
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageViewUnlock:)];
    [self.bigCircleIV addGestureRecognizer:longPressGesture];
    self.bigCircleIV.userInteractionEnabled = YES;
    self.middleCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bleNotConnect"]];
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
    self.zbLogoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zigbeeLogo"]];
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
    self.stateLabel = [self createLabelWithText:Localized(@"lockDidClose") color:KDSRGBColor(0xc6, 0xf5, 0xff) font:[UIFont systemFontOfSize:10]];
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    
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
    UILabel *dynamicLabel = [self createLabelWithText:Localized(@"deviceDynamic") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    self.deviceDynamicsLocalizedLabel = dynamicLabel;
    [cornerView addSubview:timeLabel];
    [cornerView addSubview:timesLabel];
    [cornerView addSubview:dynamicLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cornerView).offset(6);
        make.top.equalTo(cornerView).offset(13);
        make.width.equalTo(timesLabel);
    }];
    [timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel);
        make.left.equalTo(timeLabel.mas_right).offset(6);
        make.width.equalTo(dynamicLabel);
    }];
    [dynamicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel);
        make.left.equalTo(timesLabel.mas_right).offset(6);
        make.right.equalTo(arrowIV.mas_left).offset(-6);
    }];
    self.dayLabel = [self createLabelWithText:nil color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:23]];
    [cornerView addSubview:self.dayLabel];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.right.equalTo(timeLabel);
    }];
    int times = [[KDSDBManager sharedManager] queryUnlockTimesWithLock:self.lock.gwDevice];
    self.timesLabel = [self createLabelWithText:times>=0 ? @(times).stringValue : @"" color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:23]];
    [cornerView addSubview:self.timesLabel];
    [self.timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.right.equalTo(timesLabel);
    }];
    self.deviceDynamicsLabel = [self createLabelWithText:Localized(@"normal") color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:19]];
    [cornerView addSubview:self.deviceDynamicsLabel];
    [self.deviceDynamicsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.right.equalTo(dynamicLabel);
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
        make.top.equalTo(cornerView.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
    }];
    self.tableView.rowHeight = 40;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.001)];
    self.tableView.sectionFooterHeight = 0.0001;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
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


#pragma mark - 控件等事件方法。
///长按中间的浅绿色视图开锁。为方便其它页面发起的通知开锁，sender传nil和手势共用一个方法。
- (void)longPressImageViewUnlock:(UILongPressGestureRecognizer *)sender
{
    if (!([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
                   || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion)
    {
        if (sender && sender.state == UIGestureRecognizerStateBegan && (self.lockState == KDSLockStateOnline || self.lockState == KDSLockStateDefence))
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"unlockByThisOperationNotSupported") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
            [ok setValue:KDSRGBColor(0x1f, 0x96, 0xf7) forKey:@"titleTextColor"];
            [ac addAction:ok];
            [self presentViewController:ac animated:YES completion:nil];
            return;
        }
    }
    
    if ((!sender || sender.state == UIGestureRecognizerStateBegan) && (self.lockState == KDSLockStateOnline || self.lockState == KDSLockStateDefence))
    {
        NSString *password = [[KDSDBManager sharedManager] queryUnlockPwdWithLock:self.lock.gwDevice];
        if (password.length)
        {
            [self unlockWithPassword:password];
            return;
        }
        //如果本地没有密码记录，弹框让用户输入密码。
        __weak typeof(self) weakSelf = self;
        BOOL isRestricted = NO;
        KDSDBManager *manager = [KDSDBManager sharedManager];
        int times = [manager queryPwdIncorrectTimesWithLock:self.lock.gwDevice];
        double serverTime = [KDSMQTTManager sharedManager].serverTime;
        if (times == 1 && serverTime > 0)
        {
            [manager updatePwdIncorrectFirstTime:serverTime withLock:self.lock.gwDevice];
        }
        else if (times >= 10)
        {
            double time = [manager queryPwdIncorrectFirstTimeWithLock:self.lock.gwDevice];
            if (serverTime - time < 300)
            {
                isRestricted = YES;
                self.lockState = KDSLockStateNormal;;
            }
            else
            {
                [manager updatePwdIncorrectFirstTime:serverTime withLock:self.lock.gwDevice];
                [manager updatePwdIncorrectTimes:0 withLock:self.lock.gwDevice];
            }
        }
        NSString *title = Localized(@"pleaseInputLockPassword");
        title = isRestricted ? Localized(@"unlockRestricted") : title;
        NSString *message = nil;
        message = isRestricted ? Localized(@"pwdIncorrectTooMany") : message;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (!isRestricted)
        {
            [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.secureTextEntry = YES;
                textField.textAlignment = NSTextAlignmentCenter;
                textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
                textField.font = [UIFont systemFontOfSize:13];
                [textField addTarget:weakSelf action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
            }];
        }
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.lockState = KDSLockStateNormal;
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isRestricted) return;
            NSString *pwd = [ac.textFields.firstObject.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (pwd.length < 6 || pwd.length > 12) {
                
                [MBProgressHUD showError:Localized(@"Please enter the correct 6-12 digit password")];
                [weakSelf setLockState:KDSLockStateNormal];
            }else{
                [weakSelf unlockWithPassword:pwd];
            }
            
        }];
        if (!isRestricted) [ac addAction:cancel];
        [ac addAction:ok];
        
        [self presentViewController:ac animated:YES completion:nil];
    }
}

///点击动态所在父视图进入开锁和报警记录详情页。
- (void)tapToViewDeviceDynamicDetails:(UITapGestureRecognizer *)sender
{
    KDSGWRecordDetailsVC * vc = [KDSGWRecordDetailsVC new];
    vc.lock = self.lock;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击更多按钮查看更多记录。
- (void)moreButtonClick:(UIButton *)sender
{
    KDSGWRecordDetailsVC * vc = [KDSGWRecordDetailsVC new];
    vc.lock = self.lock;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

///首页长按开锁密码输入框限制6-12位数字密码
- (void)textFieldTextDidChange:(UITextField *)sender
{
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

#pragma mark - 通知相关方法。
///mqtt上报事件通知。
- (void)mqttEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if ([event isEqualToString:MQTTSubEventGWOnline])
    {
        if (![param[@"uuid"] isEqual:self.lock.gw.model.deviceSN]) return;
        self.lockState = [self.lock.gwDevice.event_str isEqual:@"online"] ? KDSLockStateOnline : KDSLockStateOffline;
    }
    else if ([event isEqualToString:MQTTSubEventGWOffline])
    {
        if (![param[@"uuid"] isEqual:self.lock.gw.model.deviceSN]) return;
        self.lockState = KDSLockStateOffline;
    }
    else if ([event isEqualToString:MQTTSubEventUnlock])
    {
        if (![param[@"deviceId"] isEqualToString:self.lock.gwDevice.deviceId]) return;
        self.lockState = KDSLockStateUnlocked;
        [self getUnlockTimes];
        int source = [param[@"eventSource"] intValue], uid = [param[@"userId"] intValue];
        if ((source==0 && uid==9) || ((source==3 || source==4) && uid>=95))
        {
            //指纹、卡片开锁不区分是否是胁迫
            [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:Localized(@"theLock%@UnlckWithMenace%@"), self.lock.gwDevice.nickName ?: self.lock.gwDevice.deviceId, Localized((source==0 ? @"menacePassword" : (source==3 ? @"card"/*@"menaceCard"*/ : @"fingerprint"/*@"menaceFingerprint"*/)))] tapHandler:^{
            }];
        }
        //有些网关不会发通知
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.lockState == KDSLockStateUnlocked || self.lockState == KDSLockStateNormal) self.lockState = KDSLockStateClosed;

        });
    }
    else if ([event isEqualToString:MQTTSubEventLock])
    {
        if (![param[@"deviceId"] isEqualToString:self.lock.gwDevice.deviceId]) return;
        if (self.lockState != KDSLockStateClosed && self.lockState != KDSLockStateNormal)self.lockState = KDSLockStateClosed;

    }
    else if ([event isEqualToString:MQTTSubEventDeviceOnline])
    {
        if (![param[@"deviceId"] isEqualToString:self.lock.gwDevice.deviceId]) return;
        self.lock.gwDevice.event_str = @"online";
        self.lockState = KDSLockStateOnline;
        self.deviceDynamicsLabel.text = Localized(@"normal");
    }
    else if ([event isEqualToString:MQTTSubEventDeviceOffline])
    {
        if (![param[@"deviceId"] isEqualToString:self.lock.gwDevice.deviceId]) return;
        self.lock.gwDevice.event_str = @"offline";
        self.lockState = KDSLockStateOffline;
        self.deviceDynamicsLabel.text = Localized(@"offline");
    }
    //这里网关锁上报异常事件时不需要将锁状态设置为异常状态，锁只有正常和离线两种状态
//    else if ([event isEqualToString:MQTTSubEventDLAlarm])
//    {
//        if (![param[@"deviceId"] isEqualToString:self.lock.gwDevice.deviceId]) return;
//        self.deviceDynamicsLabel.text = Localized(@"exception");
//        self.deviceDynamicsLabel.tag = 1;
//        self.deviceDynamicsLabel.textColor = KDSRGBColor(0xff, 0x3b, 0x30);
//    }
}

///在其它页面操作开锁发出的通知。
- (void)userOperateUnlock:(NSNotification *)noti
{
    if (noti.userInfo[@"lock"] != self.lock || !(self.lock.state == KDSLockStateNormal || self.lock.state == KDSLockStateDefence)) return;
    [self longPressImageViewUnlock:nil];
}

///当设备的数量或者各种状态等改变时，刷新本页面的设备状态。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
    self.lockState = (self.lock.connected && [self.lock.gwDevice.event_str isEqualToString:@"online"]) ? KDSLockStateOnline : KDSLockStateOffline;
}

///收到更改了本地语言的通知，更新页面文字。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.lockState = self.lockState;
    self.guardianDayLocalizedLabel.text = Localized(@"guardianTime");
    self.guardianTimesLocalizedLabel.text = Localized(@"guardianTimes");
    self.deviceDynamicsLocalizedLabel.text = Localized(@"deviceDynamic");
    self.dayLocalizedLabel.text = Localized(@"days");
    self.timesLocalizedLabel.text = Localized(@"times");
    self.deviceDynamicsLabel.text = Localized((self.deviceDynamicsLabel.tag==0 ? @"normal" : @"exception"));
    [self.tableView reloadData];
}

#pragma mark - MQTT相关方法。
///从MQTT服务器获取开锁记录并刷新界面。
- (void)getUnlockRecord
{
    [[KDSMQTTManager sharedManager] getDeviceUnlockRecords:self.lock.gwDevice atPage:1 completion:^(NSError * _Nullable error, NSArray<KDSGWUnlockRecord *> * _Nullable records) {
        
        if (error) return;
        if (records.count)
        {
            NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            for (KDSGWUnlockRecord *record in records)
            {
                record.date = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:record.open_time / 1000]];
            }
            NSMutableArray *sections = [NSMutableArray array];
            NSMutableArray<KDSGWUnlockRecord *> *section = [NSMutableArray array];
            __block NSString *date = nil;
            records = [records sortedArrayUsingComparator:^NSComparisonResult(KDSGWUnlockRecord *  _Nonnull obj1, KDSGWUnlockRecord *  _Nonnull obj2) {
                return obj1.open_time < obj2.open_time;
            }];
            [records enumerateObjectsUsingBlock:^(KDSGWUnlockRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!date)
                {
                    date = [obj.date componentsSeparatedByString:@" "].firstObject;
                    [section addObject:obj];
                }
                else if ([date isEqualToString:[obj.date componentsSeparatedByString:@" "].firstObject])
                {
                    [section addObject:obj];
                }
                else
                {
                    [sections addObject:[NSArray arrayWithArray:section]];
                    [section removeAllObjects];
                    date = [obj.date componentsSeparatedByString:@" "].firstObject;
                    [section addObject:obj];
                }
            }];
            [sections addObject:[NSArray arrayWithArray:section]];
            self.unlockRecordArr = sections.copy;
            self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.001)];
            [self.tableView reloadData];
        }
        else
        {
            UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = Localized(@"noUnlockRecord");
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
            label.font = [UIFont systemFontOfSize:12];
            self.tableView.tableHeaderView = label;
        }
    }];
}

///获取开锁次数，并更新页面。
- (void)getUnlockTimes
{
    [[KDSMQTTManager sharedManager] getUnlockTimesInLock:self.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success, NSInteger times) {
        
        if (success)
        {
            self.timesLabel.text = @(times).stringValue;
            [[KDSDBManager sharedManager] updateUnlockTimes:(int)times withLock:self.lock.gwDevice];
        }
    }];
}

///获取锁电量。
- (void)getLockPower
{
    [[KDSMQTTManager sharedManager] dlGetDevicePower:self.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success, int power) {
        if (success)
        {
            [[KDSDBManager sharedManager] updatePower:power withLock:self.lock.gwDevice];
            [[KDSDBManager sharedManager] updatePowerTime:NSDate.date withLock:self.lock.gwDevice];
            self.lock.power = power;
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:nil userInfo:nil];
        }
    }];
}

/**
 *@abstract 发送开锁命令。
 *@param password 开锁密码，如果此密码长度不为0，则使用此密码开锁(请确保密码长度为6~12字节)，否则使用不鉴权模式开锁(保留参数)。
 */
- (void)unlockWithPassword:(nullable NSString *)password
{
    if (!password.length) return;
    AudioServicesPlaySystemSound(1520);
    [self setLockState:KDSLockStateUnlocking];
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice operateLock:YES withPwd:password completion:^(NSError * _Nullable error, BOOL success) {
        if (error)
        {
            self.lockState = KDSLockStateFailed;
            [MBProgressHUD showError:Localized(@"error try again later")];
            if (error.code != (NSInteger)KDSGatewayErrorRequestTimeout)
            {
                [[KDSDBManager sharedManager] updateUnlockPwd:nil withLock:self.lock.gwDevice];
            }
        }
        else
        {
            //有些网关不会发通知
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self getLockPower];  //这里好像不需要开锁成功就去获取电量
                if (self.lockState == KDSLockStateUnlocking) self.lockState = KDSLockStateClosed;
                
            });
            [[KDSDBManager sharedManager] updateUnlockPwd:password withLock:self.lock.gwDevice];
        }
    }];
}

///同步锁时间。
- (void)syncGwLockTime
{
    NSTimeInterval time = [KDSMQTTManager sharedManager].serverTime;
    if ([self.lock.gwDevice.event_str isEqualToString:@"online"] && time > 0 && self.lock.gwDevice.isAdmin)
    {
        NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
        fmt.dateFormat = @"yyyyMMdd";
        NSDate *pre = [[KDSDBManager sharedManager] querySyncTimeWithLock:self.lock.gwDevice] ?: NSDate.date;
        NSDate *cur = [NSDate dateWithTimeIntervalSince1970:time];
        if (![[fmt stringFromDate:pre] isEqualToString:[fmt stringFromDate:cur]])
        {
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice setTime:NSDate.date.timeIntervalSince1970 + [NSTimeZone localTimeZone].secondsFromGMT completion:^(NSError * _Nullable error, BOOL success) {
                if (success)
                {
                    [[KDSDBManager sharedManager] updateSyncTime:cur withLock:self.lock.gwDevice];
                }
            }];
        }
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSourc
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.unlockRecordArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unlockRecordArr[section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    cell.alarmRecLabel.hidden = YES;
    cell.topLine.hidden = indexPath.row == 0;
    cell.bottomLine.hidden = indexPath.row == self.unlockRecordArr[indexPath.section].count - 1;
    KDSGWUnlockRecord *record = self.unlockRecordArr[indexPath.section][indexPath.row];
    cell.timerLabel.text = record.date.length > 16 ? [record.date substringWithRange:NSMakeRange(11, 5)] : @"未知";
    if ([record.open_type isEqualToString:@"0"])
    {
        cell.unlockModeLabel.text = Localized(@"pwdOpenDoor");
    }
    else if ([record.open_type isEqualToString:@"1"])
    {
        cell.unlockModeLabel.text = Localized(@"appUnlock");
    }
    else if ([record.open_type isEqualToString:@"2"]){
        cell.unlockModeLabel.text = Localized(@"Machine key or door unlock");
    }else if ([record.open_type isEqualToString:@"3"]){
        cell.unlockModeLabel.text = Localized(@"卡片");
    }else if ([record.open_type isEqualToString:@"4"]){
        cell.unlockModeLabel.text = Localized(@"指纹");
    }else if ([record.open_type isEqualToString:@"255"]){
        cell.unlockModeLabel.text = Localized(@"Other ways to unlock");
    }else{
        cell.unlockModeLabel.text = Localized(@"Other ways to unlock");
    }
    cell.userNameLabel.text = Localized(record.open_type);
    cell.userNameLabel.hidden = YES;
    
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
    NSString *dateStr = self.unlockRecordArr[section].firstObject.date;
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

@end

//
//  KDSCatEyeInForVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/22.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeInForVC.h"
#import "KDSHomePageLockStatusCell.h"
#import "KDSCateyeDynamicVC.h"
#import "KDSCateyeCallVC.h"
#import "KDSAlarmModel.h"
#import "KDSDBManager+GW.h"
#import "NSDate+KDS.h"
#import "KDSCountdown.h"
#import "MBProgressHUD+MJ.h"



@interface KDSCatEyeInForVC ()<UITableViewDelegate,UITableViewDataSource>


///最外围的大圆
@property (weak, nonatomic) IBOutlet UIImageView *bigCircleIV;
///中间的圆
@property (weak, nonatomic) IBOutlet UIImageView *middleCircleIV;
///小圆：展示蓝牙连接信息
@property (weak, nonatomic) IBOutlet UIImageView *smallCircleIV;

///提示语：关闭状态、布防状态、安全状态、反锁状态、正在开锁、开锁成功、点击，查看门外、设备不在搜索范围。
@property (weak, nonatomic) IBOutlet UILabel *deviceStausPromptLabel;
///提示语<在内环门锁状态视图里>：关闭状态、布防状态、安全状态、反锁状态、正在开锁、开锁成功、点击，查看门外、设备不在搜索范围。
@property (weak, nonatomic) IBOutlet UILabel *deviceStausWithInLockLabel;
///展示守护天数：100天
@property (weak, nonatomic) IBOutlet UILabel *guardianDayLabel;
///’守护时间‘
@property (weak, nonatomic) IBOutlet UILabel *guardianDayTispLb;
///'守护次数'
@property (weak, nonatomic) IBOutlet UILabel *guardianTimesTipsLb;
///天
@property (weak, nonatomic) IBOutlet UILabel *dayLb;
///次
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
///'设备动态'
@property (weak, nonatomic) IBOutlet UILabel *deviceDynamicsTipsLb;
///守护次数：200次
@property (weak, nonatomic) IBOutlet UILabel *guardianTimesLabel;
///设备动态：正常
@property (weak, nonatomic) IBOutlet UILabel *deviceDynamicsLabel;
///展示：守护时间、守护次数、设备动态的父视图
@property (weak, nonatomic) IBOutlet UIView *deviceDynamicsView;
///锁电量，初始化-1。
@property (nonatomic, assign) int lockEnergy;

///显示锁状态以及一些提示语的父视图
@property (weak, nonatomic) IBOutlet UIView *deviceStatusSupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

///服务器请求回来的开锁记录数组。
@property (nonatomic, strong) NSMutableArray<KDSGWUnlockRecord *> *unlockRecordArr;
///服务器请求回来开锁记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSGWUnlockRecord *> *> *unlockRecordSectionArr;
///本地存储的报警记录数组。
@property (nonatomic, strong) NSMutableArray<KDSAlarmModel *> *alarmRecordArr;
///本地存储报警记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSAlarmModel *> *> *alarmRecordSectionArr;
///开锁记录页数，初始化1.
@property (nonatomic, assign) int unlockIndex;
///报警记录映射。
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *alarmMaps;

@end

@implementation KDSCatEyeInForVC

#pragma mark - getter setter
- (NSMutableArray<KDSGWUnlockRecord *> *)unlockRecordArr
{
    if (!_unlockRecordArr)
    {
        _unlockRecordArr = [NSMutableArray array];
    }
    return _unlockRecordArr;
}
- (NSMutableArray<KDSAlarmModel *> *)alarmRecordArr
{
    if (!_alarmRecordArr)
    {
        _alarmRecordArr = [NSMutableArray array];
    }
    return _alarmRecordArr;
}

- (NSDictionary<NSNumber *,NSString *> *)alarmMaps
{
    if (!_alarmMaps)
    {
        _alarmMaps = @{@1:Localized(@"num1Alarm"), @2:Localized(@"num2Alarm"), @3:Localized(@"num3Alarm"), @4:Localized(@"num4Alarm"), @8:Localized(@"num8Alarm"), @16:Localized(@"num16Alarm"), @32:Localized(@"num32Alarm"), @64:Localized(@"num64Alarm"),@200001:Localized(@"Snapshot alerted"),@200002:Localized(@"Cat's eye cat's head pulled out"),@200003:Localized(@"Cat Eye Door Bell Trigger"),@200004:Localized(@"cateyeLowPower"),@200005:Localized(@"Cat-eye fuselage pulled out")};
    }
    return _alarmMaps;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = UIColor.clearColor;
    [self setUI];
    //猫眼上下线 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cateyeEventNotification:) name:KDSMQTTEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.alarmRecordArr removeAllObjects];
    [self.unlockRecordArr removeAllObjects];
    [self refreshUI];
    ///猫眼守护天数
    NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSDate *joinDate = [fmt dateFromString:self.cateye.gatewayDeviceModel.joinTime];
    NSTimeInterval interval = [joinDate timeIntervalSince1970]; //- [NSTimeZone localTimeZone].secondsFromGMT;
    self.guardianDayLabel.text = @(floor((self.cateye.gatewayDeviceModel.currentTime - interval) / 24 / 3600)).stringValue;
    [self queryCateyeAlarm];
}

-(void)setUI
{
    CGFloat rate = kScreenHeight / 667;
    rate = rate<1 ? rate : 1;
    [self.bigCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 10 : 26);
        make.centerX.equalTo(@0);
        make.width.equalTo(@(178 * rate));
        make.height.equalTo(@(169 * rate));
    }];
    [self.middleCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bigCircleIV);
        make.width.height.equalTo(@(142 * rate));
    }];
    [self.smallCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.centerY.equalTo(self.bigCircleIV).offset(-20 * rate);
        make.size.mas_equalTo(self.smallCircleIV.image.size);
    }];
    [self.deviceStausPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smallCircleIV.mas_bottom).offset(kScreenHeight<667 ? 10 : 20);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    [self.deviceStausWithInLockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(kScreenHeight<667 ? 15 : 20);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    self.bigCircleIV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToConnectCateyeCall:)];
    [self.bigCircleIV addGestureRecognizer:tap];
    self.deviceDynamicsView.layer.masksToBounds = YES;
    self.deviceDynamicsView.layer.cornerRadius = 4;
    
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 30;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 1, 0.001}];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = self.view.backgroundColor;
    self.automaticallyAdjustsScrollViewInsets = false;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
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
    self.guardianDayTispLb.text = Localized(@"guardianTime");
    self.guardianTimesTipsLb.text = Localized(@"guardianTimes");
    self.deviceDynamicsTipsLb.text = Localized(@"deviceDynamic");
    self.dayLb.text = Localized(@"days");
    self.timeLb.text = Localized(@"times");
    self.deviceDynamicsLabel.text = Localized(@"normal");
    UITapGestureRecognizer *cateyeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToViewDeviceDynamicDetails:)];
    [self.deviceDynamicsView addGestureRecognizer:cateyeTap];
}

-(void)queryCateyeAlarm{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *alarms = [[KDSDBManager sharedManager] queryRecordsInDevice:self.cateye.gatewayDeviceModel type:4];
        if (alarms){
            [self.alarmRecordArr addObjectsFromArray:alarms];
        }
        NSArray *unlocks = [[KDSDBManager sharedManager] queryRecordsInDevice:self.cateye.gatewayDeviceModel type:3];
        if (unlocks) {
            [self.unlockRecordArr addObjectsFromArray:unlocks];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableView:self.tableView];
        });
    });
    
}

/**
 *@abstract 刷新表视图，调用此方法前请确保开锁或者报警记录的属性数组内容已经更新。方法执行时会自动提取分组记录。
 *@param tableView 要刷新的表视图。
 */
- (void)reloadTableView:(UITableView *)tableView
{
    [self.alarmRecordArr sortUsingComparator:^NSComparisonResult(KDSAlarmModel *  _Nonnull obj1, KDSAlarmModel *  _Nonnull obj2) {
        return obj1.warningTime < obj2.warningTime;
    }];
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *elements = [NSMutableArray array];
    __block NSString *date = [self.alarmRecordArr.firstObject.date componentsSeparatedByString:@" "].firstObject;
    [self.alarmRecordArr enumerateObjectsUsingBlock:^(KDSAlarmModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj.date componentsSeparatedByString:@" "].firstObject isEqualToString:date])
        {
            [elements addObject:obj];
        }
        else
        {
            date = [obj.date componentsSeparatedByString:@" "].firstObject;
            [sections addObject:elements.copy];
            [elements removeAllObjects];
            [elements addObject:obj];
        }
    }];
    if (elements.count) [sections addObject:elements.copy];
    self.alarmRecordSectionArr = sections;
    [self.tableView reloadData];
    if (self.alarmRecordSectionArr.count == 0) {
        
        UIView *header = [[UIView alloc] initWithFrame:self.tableView.bounds];
        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = Localized(@"noCateyeRecord,pleaseSync");
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        [header addSubview:label];
        self.tableView.tableHeaderView = header;
        
    }else{
        
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 1, 0.001}];
        [self.tableView reloadData];
    }
    
}

-(void)refreshUI
{
    if (!self.cateye.online) {
        self.deviceStausWithInLockLabel.text = Localized(@"CatEyeOffline");
        self.deviceDynamicsLabel.text = Localized(@"offline");
        self.deviceStausPromptLabel.text = Localized(@"CateyeDeviceOffline");
        self.deviceStausPromptLabel.textColor = KDSRGBColor(20, 166, 245);
        self.bigCircleIV.image = [UIImage imageNamed:@"cateyeOfflineBgImg"];
        self.smallCircleIV.image = [UIImage imageNamed:@"catEyeOffline"];
        
    }else{
        self.deviceStausWithInLockLabel.text = Localized(@"CatEyeOnline");
        self.deviceDynamicsLabel.text = Localized(@"online");
        self.deviceStausPromptLabel.text = Localized(@"ClickOutside");
        self.deviceStausPromptLabel.textColor = UIColor.whiteColor;
        self.bigCircleIV.image = [UIImage imageNamed:@"cateyeOnlineBgImg"];
        self.smallCircleIV.image = [UIImage imageNamed:@"cateyeOnline"];
        
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
   return self.alarmRecordSectionArr.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alarmRecordSectionArr[section].count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KDSHomePageLockStatusCell"];
    cell.topLine.hidden = indexPath.row == 0;
    cell.bottomLine.hidden = indexPath.row == self.alarmRecordSectionArr[indexPath.section].count - 1;
    cell.alarmRecLabel.hidden = NO;
    cell.userNameLabel.hidden = YES;
    cell.unlockModeLabel.hidden = YES;
    cell.dynamicImageView.image = [UIImage imageNamed:@"Alert message_icon 拷贝"];
    KDSAlarmModel *m = self.alarmRecordSectionArr[indexPath.section][indexPath.row];
    //        cell.timerLabel.text = m.date;
    cell.timerLabel.text =m.date.length > 16 ? [m.date substringWithRange:NSMakeRange(11, 5)] :@"未知";
    cell.alarmRecLabel.text = self.alarmMaps[@(m.warningType)];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = UIColor.clearColor;
    
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
    
    ///更多
    UIButton * moreBtn = [UIButton new];
    moreBtn.frame = CGRectMake(KDSScreenWidth-50, 10, 30, 20);
    moreBtn.hidden = section != 0;
    [moreBtn setTitle:Localized(@"more") forState:UIControlStateNormal];
    [moreBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [headerView addSubview:moreBtn];

    NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *todayStr = [[fmt stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger today = [todayStr substringToIndex:8].integerValue;
    NSString *dateStr = nil;
    dateStr = self.alarmRecordSectionArr[section].firstObject.date;
    
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
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark 手势事件

///更多事件
-(void)buttonClick:(UIButton *)sender
{
    KDSCateyeDynamicVC * vc = [KDSCateyeDynamicVC new];
    [self presentViewController:vc animated:YES completion:nil];
    
}
///点击查看门外
-(void)tapToConnectCateyeCall:(UITapGestureRecognizer *)tap
{
    NSLog(@"点击了查看门外");
    if ([self.cateye.gatewayDeviceModel.event_str isEqualToString:@"online"]){
        KDSCateyeCallVC *vc = [[KDSCateyeCallVC alloc] init];
        vc.gatewayDeviceModel = self.cateye.gatewayDeviceModel;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
         [MBProgressHUD showError:Localized(@"CatEyeOffline")];
    }
}
///点击动态所在父视图进入开锁和报警记录详情页。
- (void)tapToViewDeviceDynamicDetails:(UITapGestureRecognizer *)sender
{
    KDSCateyeDynamicVC * vc = [KDSCateyeDynamicVC new];
    vc.cateye = self.cateye;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
///更多
-(void)moreClick:(UIButton *)sender
{
    KDSCateyeDynamicVC * vc = [KDSCateyeDynamicVC new];
    vc.cateye = self.cateye;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 通知相关方法。
///mqtt上报事件通知。
- (void)cateyeEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if (![param[@"uuid"] isEqual:self.cateye.gw.model.deviceSN]) return;
    if ([event isEqualToString:MQTTSubEventGWOnline])
    {
        [self refreshUI];
    }
    else if ([event isEqualToString:MQTTSubEventGWOffline])
    {
        [self refreshUI];
    }
}

///收到更改了本地语言的通知，更新页面文字。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.guardianDayTispLb.text = Localized(@"guardianTime");
    self.guardianTimesTipsLb.text = Localized(@"guardianTimes");
    self.deviceDynamicsTipsLb.text = Localized(@"deviceDynamic");
    self.dayLb.text = Localized(@"days");
    self.timeLb.text = Localized(@"times");
    self.deviceDynamicsLabel.text = Localized(@"normal");
    [self.tableView reloadData];
}

@end

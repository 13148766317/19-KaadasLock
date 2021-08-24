//
//  KDSCateyeDynamicVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCateyeDynamicVC.h"
#import "KDSAlarmModel.h"
#import "KDSDBManager+GW.h"
#import "KDSHomePageLockStatusCell.h"

@interface KDSCateyeDynamicVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;

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

@implementation KDSCateyeDynamicVC

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
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"猫眼动态";
    [self setUI];
    [self.alarmRecordArr removeAllObjects];
    [self.unlockRecordArr removeAllObjects];
    [self queryCateyeAlarm];
}

-(void)setUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, KDSScreenHeight-kStatusBarHeight-kNavBarHeight) style:UITableViewStyleGrouped];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.rowHeight = 30;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    [self.view addSubview:self.tableView];
   
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
    cell.timerLabel.text = m.date.length > 16 ?[m.date substringWithRange:NSMakeRange(11, 5)] : m.date;
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
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:titleLabel];
    
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

@end

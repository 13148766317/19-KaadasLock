//
//  KDSGWRecordDetailsVC.m
//  KaadasLock
//
//  Created by orange on 2019/5/10.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWRecordDetailsVC.h"
#import "KDSMQTT.h"
#import "KDSDBManager+GW.h"
#import "UIButton+Color.h"
#import "MJRefresh.h"
#import "KDSHomePageLockStatusCell.h"

@interface KDSGWRecordDetailsVC () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

///开锁记录按钮。
@property (nonatomic, strong) UIButton *unlockRecBtn;
///报警记录按钮。
@property (nonatomic, strong) UIButton *alarmRecBtn;
///横向滚动的滚动视图，装着开锁记录和报警记录的表视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///显示开锁记录的表视图。
@property (nonatomic, strong) UITableView *unlockTableView;
///显示报警记录的表视图。
@property (nonatomic, strong) UITableView *alarmTableView;
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
///预警信息页数，初始化1.
@property (nonatomic, assign) int alarmIndex;
///获取报警记录时转的菊花。
@property (nonatomic, strong) UIActivityIndicatorView *alarmActivity;
///报警记录映射。
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *alarmMaps;

@end

@implementation KDSGWRecordDetailsVC

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

- (UIActivityIndicatorView *)alarmActivity
{
    if (!_alarmActivity)
    {
        _alarmActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint center = CGPointMake(kScreenWidth * 1.5, self.scrollView.bounds.size.height / 2.0);;
        _alarmActivity.center = center;
        [self.scrollView addSubview:_alarmActivity];
    }
    return _alarmActivity;
}

- (NSDictionary<NSNumber *,NSString *> *)alarmMaps
{
    if (!_alarmMaps)
    {
        _alarmMaps = @{@100001:Localized(@"lockedRotorAlarm"), @100002:Localized(@"lockHasBeenResetAlarm"), @100005:Localized(@"multiVerifyFailAlarm"), @100006:Localized(@"frontEscutcheonRemovedFromLock"), @100007:Localized(@"violenceUnlockAlarm"), @16:Localized(@"num16Alarm"), @100008:Localized(@"lockTeardownAlarm"), @100009:Localized(@"temperatureExceptionAlarm"), @100010:Localized(@"forceUnlockAlarm"), @100011:Localized(@"keyLeftInLock"),};
    }
    return _alarmMaps;
}

#pragma mark - 生命周期、界面设置相关方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.unlockIndex = 1;
    self.alarmIndex = 1;
    [self setupUI];
    [self loadNewUnlockRecord];
   
    if ([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
    || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) {
        //8100预警信息从服务器获取
         [self loadNewAlarmList];
    }else{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //预警信息本地缓存获取
            NSArray *alarms = [[KDSDBManager sharedManager] queryRecordsInDevice:self.lock.gwDevice type:2];
            if (alarms) [self.alarmRecordArr addObjectsFromArray:alarms];
            NSArray *unlocks = [[KDSDBManager sharedManager] queryRecordsInDevice:self.lock.gwDevice type:1];
            if (unlocks) [self.unlockRecordArr addObjectsFromArray:unlocks];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableView:self.unlockTableView];
                [self reloadTableView:self.alarmTableView];
            });
        });
    }
    
}

- (void)viewDidLayoutSubviews
{
    if (CGRectIsEmpty(self.unlockTableView.frame))
    {
        self.scrollView.contentSize = CGSizeMake(kScreenWidth * 2, self.scrollView.bounds.size.height);
        CGRect frame = self.scrollView.bounds;
        frame.origin.x += 10;
        frame.size.width -= 20;
        self.unlockTableView.frame = frame;
        frame.origin.x += kScreenWidth;
        self.alarmTableView.frame = frame;
    }
}

- (void)setupUI
{
    //导航栏位置的标题和关闭按钮。
    UIView *bgView = nil;
    if (self.navigationController)
    {
        self.navigationTitleLabel.text = Localized(@"deviceStatus");
    }
    else
    {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarHeight + kNavBarHeight)];
        bgView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:bgView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavBarHeight)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = Localized(@"deviceStatus");
        [self.view addSubview:titleLabel];
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeImg = [UIImage imageNamed:@"返回"];
        [closeBtn setImage:closeImg forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
        [closeBtn addTarget:self action:@selector(clickCloseBtnDismissController:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeBtn];
    }
    
    //顶部功能选择按钮
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(bgView.frame) + 10, kScreenWidth-30, 44)];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 22;
    [self.view addSubview:view];
    self.unlockRecBtn = [UIButton new];
    [self.unlockRecBtn setTitle:Localized(@"OpRecord") forState:UIControlStateNormal];
    self.unlockRecBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.unlockRecBtn.adjustsImageWhenHighlighted = NO;
    [self.unlockRecBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    self.unlockRecBtn.selected = YES;
    self.unlockRecBtn.layer.masksToBounds = YES;
    self.unlockRecBtn.layer.cornerRadius = 22;
    [view addSubview:self.unlockRecBtn];
    self.alarmRecBtn = [UIButton new];
    [self.alarmRecBtn setTitle:Localized(@"alarmRecord") forState:UIControlStateNormal];
    self.alarmRecBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.alarmRecBtn.adjustsImageWhenHighlighted = NO;
    [self.alarmRecBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    [self.unlockRecBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.unlockRecBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.unlockRecBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.unlockRecBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [self.alarmRecBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.alarmRecBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.alarmRecBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.alarmRecBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    self.alarmRecBtn.layer.masksToBounds = YES;
    self.alarmRecBtn.layer.cornerRadius = 22;
    [view addSubview:self.alarmRecBtn];
    CGFloat width = (KDSScreenWidth-30)/2;
    [self.unlockRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    [self.alarmRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    self.unlockTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.unlockTableView.showsVerticalScrollIndicator = NO;
    self.unlockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.unlockTableView.dataSource = self;
    self.unlockTableView.delegate = self;
    self.unlockTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewUnlockRecord)];
    self.unlockTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreUnlockRecord)];
    [self.unlockTableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    [self.scrollView addSubview:self.unlockTableView];
    self.alarmTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.alarmTableView.showsVerticalScrollIndicator = NO;
    self.alarmTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.alarmTableView.dataSource = self;
    self.alarmTableView.delegate = self;
    if ([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
        || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) {
        self.alarmTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewAlarmList)];
        self.alarmTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreAlarmList)];
    }
   
    [self.alarmTableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    [self.scrollView addSubview:self.alarmTableView];
    self.unlockTableView.rowHeight = self.alarmTableView.rowHeight = 40;
    self.unlockTableView.backgroundColor = self.alarmTableView.backgroundColor = UIColor.clearColor;
    
    if (@available(iOS 11.0, *)) {
        self.unlockTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.alarmTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
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
        if (tableView == self.unlockTableView) {
            label.text = Localized(@"noUnlockRecord");
        }else{
            label.text = Localized(@"NoAlarmRecord");
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    if (tableView == self.unlockTableView)
    {
        [self.unlockRecordArr sortUsingComparator:^NSComparisonResult(KDSGWUnlockRecord *  _Nonnull obj1, KDSGWUnlockRecord *  _Nonnull obj2) {
            return obj1.open_time < obj2.open_time;
        }];
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray *elements = [NSMutableArray array];
        __block NSString *date = [self.unlockRecordArr.firstObject.date componentsSeparatedByString:@" "].firstObject;
        [self.unlockRecordArr enumerateObjectsUsingBlock:^(KDSGWUnlockRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        self.unlockRecordSectionArr = sections;
        if (self.unlockRecordArr.count == 0)
        {
            noRecord(self.unlockTableView);
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.unlockTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
                [self.unlockTableView reloadData];
            });
        }
    }
    else
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
        if (self.alarmRecordArr.count == 0)
        {
            noRecord(self.alarmTableView);
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.alarmTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
                [self.alarmTableView reloadData];
            });
        }
    }
}

#pragma mark - 控件等事件方法。
///点击开锁记录、预警信息按钮调整滚动视图的偏移，切换页面。
- (void)clickRecordBtnAdjustScrollViewContentOffset:(UIButton *)sender
{
    if (sender.selected) return;
    self.unlockRecBtn.selected = self.alarmRecBtn.selected = NO;
    sender.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = CGPointMake(sender == self.unlockRecBtn ? 0 : kScreenWidth, 0);
    }];
}

///dismiss控制器。
- (void)clickCloseBtnDismissController:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MQTT网络请求相关方法。
///获取第一页的开锁记录。
- (void)loadNewUnlockRecord
{
    [[KDSMQTTManager sharedManager] getDeviceUnlockRecords:self.lock.gwDevice atPage:1 completion:^(NSError * _Nullable error, NSArray<KDSGWUnlockRecord *> * _Nullable records) {
        if (records)
        {
            NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            for (KDSGWUnlockRecord *record in records)
            {
                if (![self.unlockRecordArr containsObject:record])
                {
                    record.date = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:record.open_time / 1000]];
                    [self.unlockRecordArr addObject:record];
                }
            }
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
            [self reloadTableView:self.unlockTableView];
            //不要直接使用服务器返回的records，服务器请求回来的数据没有处理过时date属性是nil
            records = self.unlockRecordArr.copy;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[KDSDBManager sharedManager] insertRecords:records inDevice:self.lock.gwDevice];
            });
        }
        self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    }];
}

///获取更多开锁记录。
- (void)loadMoreUnlockRecord
{
    int page = self.unlockIndex + 1;
    [[KDSMQTTManager sharedManager] getDeviceUnlockRecords:self.lock.gwDevice atPage:page completion:^(NSError * _Nullable error, NSArray<KDSGWUnlockRecord *> * _Nullable records) {
        
        if (error)
        {
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
            return;
        }
        
        NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        for (KDSGWUnlockRecord *record in records)
        {
            if (![self.unlockRecordArr containsObject:record])
            {
                record.date = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:record.open_time / 1000]];
                [self.unlockRecordArr addObject:record];
            }
        }
        
        self.unlockIndex = records.count ? page : page - 1;
        self.unlockTableView.mj_footer.state = records.count ? MJRefreshStateIdle : MJRefreshStateNoMoreData;
        //不要直接使用服务器返回的records，服务器请求回来的数据没有处理过时date属性是nil
        [self reloadTableView:self.unlockTableView];
        records = self.unlockRecordArr.copy;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[KDSDBManager sharedManager] insertRecords:records inDevice:self.lock.gwDevice];
        });
    }];
}

///获取第一页的预警信息
-(void)loadNewAlarmList
{
    [[KDSMQTTManager sharedManager] getDeviceAlarmList:self.lock.gwDevice atPage:1 completion:^(NSError * _Nullable error, NSArray<KDSAlarmModel *> * _Nullable records) {
        if (records) {
            NSDateFormatter * fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            for (KDSAlarmModel * alarm in records) {
                if (![self.alarmRecordArr containsObject:alarm]) {
                    alarm.date = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:alarm.warningTime / 1000]];
                    [self.alarmRecordArr addObject:alarm];
                }
            }
            self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
            [self reloadTableView:self.alarmTableView];
            records = self.alarmRecordArr.copy;
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//               ///
//                [[KDSDBManager sharedManager] insertRecords:records inDevice:self.lock.gwDevice];
//            });
        }
        
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
    }];
}

///获取更多预警信息
-(void)loadMoreAlarmList
{
    int page = self.alarmIndex + 1;
    [[KDSMQTTManager sharedManager] getDeviceAlarmList:self.lock.gwDevice atPage:page completion:^(NSError * _Nullable error, NSArray<KDSAlarmModel *> * _Nullable records) {
        if (error)
        {
            self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
            return;
        }
        NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        for (KDSAlarmModel *alarm in records)
        {
           if (![self.alarmRecordArr containsObject:alarm])
            {
                alarm.date = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:alarm.warningTime / 1000]];
                [self.alarmRecordArr addObject:alarm];
            }
        }
        self.alarmIndex = records.count ? page : page - 1;
        self.alarmTableView.mj_footer.state = records.count ? MJRefreshStateIdle : MJRefreshStateNoMoreData;
        //不要直接使用服务器返回的records，服务器请求回来的数据没有处理过时date属性是nil
        [self reloadTableView:self.alarmTableView];
        records = self.alarmRecordArr.copy;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [[KDSDBManager sharedManager] insertRecords:records inDevice:self.lock.gwDevice];
//        });
    
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView)
    {
        self.unlockRecBtn.selected = scrollView.contentOffset.x == 0;
        self.alarmRecBtn.selected = !self.unlockRecBtn.selected;
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.unlockTableView)
    {
        return self.unlockRecordSectionArr.count;
    }
    else
    {
        return self.alarmRecordSectionArr.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.unlockTableView)
    {
        
        return self.unlockRecordSectionArr[section].count;
    }
    else
    {
        return self.alarmRecordSectionArr[section].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KDSHomePageLockStatusCell"];
    if (tableView == self.unlockTableView)
    {
        cell.alarmRecLabel.hidden = YES;
        cell.topLine.hidden = indexPath.row == 0;
        cell.bottomLine.hidden = indexPath.row == self.unlockRecordSectionArr[indexPath.section].count - 1;
        KDSGWUnlockRecord *record = self.unlockRecordSectionArr[indexPath.section][indexPath.row];
        cell.timerLabel.text = record.date.length > 16 ? [record.date substringWithRange:NSMakeRange(11, 5)] : record.date;
        if ([record.open_type isEqualToString:@"0"]){
            cell.unlockModeLabel.text = Localized(@"pwdOpenDoor");
        }else if ([record.open_type isEqualToString:@"1"]){
            cell.unlockModeLabel.text = Localized(@"appUnlock");
        }else if ([record.open_type isEqualToString:@"2"]){
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
    }
    else
    {
        cell.topLine.hidden = indexPath.row == 0;
        cell.bottomLine.hidden = indexPath.row == self.alarmRecordSectionArr[indexPath.section].count - 1;
        cell.alarmRecLabel.hidden = NO;
        cell.userNameLabel.hidden = YES;
        cell.unlockModeLabel.hidden = YES;
        cell.dynamicImageView.image = [UIImage imageNamed:@"Alert message_icon 拷贝"];
        KDSAlarmModel *m = self.alarmRecordSectionArr[indexPath.section][indexPath.row];
        //        cell.timerLabel.text = m.date;
        cell.timerLabel.text = m.date.length > 16 ?[m.date substringWithRange:NSMakeRange(11, 5)] : m.date;
        if ([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
        || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) {
            //预警类型：1低电量 2钥匙开门 3验证错误 4防撬提醒 5即时性推送消息 6胁迫开门 7上锁故障  预警信息从服务器获取
            switch (m.warningType) {
                case 1://低电量
                    cell.alarmRecLabel.text = @"您的门锁电量过低，请及时更换";
                    break;
                case 2://机械方式开门
                    cell.alarmRecLabel.text = @"门锁正在被机械方式开启，请回家或联系保安查看";
                    break;
                case 3://多次密码错误验证
                    cell.alarmRecLabel.text = @"您的门锁错误验证多次，请回家或联系保安查看！";
                    break;
                case 4://防撬
                    cell.alarmRecLabel.text = @"已监测到您的门锁被撬，请联系家人或小区保安";
                    break;
                case 5://即使推送消息
                    cell.alarmRecLabel.text = @"已监测到您的门锁被撬，请联系家人或小区保安";
                    break;
                case 6://胁迫密码开门
                    cell.alarmRecLabel.text =  @"有人使用劫持密码开启门锁，赶紧联系或报警";
                    break;
                case 7://上锁故障
                    cell.alarmRecLabel.text = @"您的门锁有故障，请注意";
                    break;
                    
                default:
                    cell.alarmRecLabel.text = @"未知警报";
                    break;
            }
        }else{
             cell.alarmRecLabel.text = self.alarmMaps[@(m.warningType)];//收到推送的信息缓存到本地的数据
        }
    }
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = self.view.backgroundColor;
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(216, 216, 216);
    line.frame = CGRectMake(10, 0, KDSScreenWidth-20, 1);
    line.hidden = section == 0;
    [headerView addSubview:line];
    
    ///显示日期：今天、昨天、///开锁时间:（yyyy-MM-dd ）
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
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
    if (tableView == self.unlockTableView)
    {
        dateStr = self.unlockRecordSectionArr[section].firstObject.date;
    }
    else
    {
        dateStr = self.alarmRecordSectionArr[section].firstObject.date;
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
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

@end

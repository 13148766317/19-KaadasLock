//
//  KDSRecordDetailsVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/18.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSRecordDetailsVC.h"
#import "Masonry.h"
#import "KDSHttpManager+Ble.h"
#import "KDSHomePageLockStatusCell.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "KDSDBManager.h"
#import "UIButton+Color.h"
#import "KDSBleAssistant.h"

///专门测试开锁、报警记录完整性时，将此宏设置为1
#define kRecordDebug 0

@interface KDSRecordDetailsVC () <UITableViewDataSource, UITableViewDelegate>

///格式yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *fmt;
///开锁记录按钮。
@property (nonatomic, strong) UIButton *unlockRecBtn;
///报警记录按钮。
@property (nonatomic, strong) UIButton *alarmRecBtn;
///绿色移动游标。
@property (nonatomic, strong) UIView *cursorView;
///同步门锁状态标签。
@property (nonatomic, strong) UILabel *label;
///同步记录按钮。
@property (nonatomic, strong) UIButton *syncRecBtn;
@property (nonatomic,strong) UIButton * selectedBtn;
///横向滚动的滚动视图，装着开锁记录和报警记录的表视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///显示开锁记录的表视图。
@property (nonatomic, strong) UITableView *unlockTableView;
///显示报警记录的表视图。
@property (nonatomic, strong) UITableView *alarmTableView;
///服务器请求回来的开锁记录数组。
@property (nonatomic, strong) NSMutableArray<News *> *unlockRecordArr;
///服务器请求回来开锁记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<News *> *> *unlockRecordSectionArr;
//@property (nonatomic, strong)NSMutableArray<News *> * unlockRecordNews;
///服务器请求回来的操作记录数组。
@property (nonatomic, strong) NSMutableArray<KDSOperationalRecord *> * czOperationalArr;
///服务器请求回来操作记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong)NSArray<NSArray<KDSOperationalRecord *> *> *czOPerationalSectionArr;
///服务器请求回来的报警记录数组。
@property (nonatomic, strong) NSMutableArray<KDSAlarmModel *> *alarmRecordArr;
///服务器请求回来报警记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSAlarmModel *> *> *alarmRecordSectionArr;
///开锁记录页数，初始化1.
@property (nonatomic, assign) int unlockIndex;
///报警记录页数，初始化1.
@property (nonatomic, assign) int alarmIndex;
///获取开锁记录时转的菊花。
@property (nonatomic, strong) UIActivityIndicatorView *unlockActivity;
///获取报警记录时转的菊花。
@property (nonatomic, strong) UIActivityIndicatorView *alarmActivity;
///点同步开锁记录时获取的蓝牙任务凭证，由于获取全部记录耗时久，因此退出控制器时要删除队列中的任务，否则任务未完成立即再进入无法查询。
@property (nonatomic, strong) NSString *uReceipt;
///点同步报警记录时获取的蓝牙任务凭证，由于获取全部记录耗时久，因此退出控制器时要删除队列中的任务，否则任务未完成立即再进入无法查询。。
@property (nonatomic, strong) NSString *aReceipt;
///报警记录映射。
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *alarmMaps;
///密匙列表。
@property (nonatomic, strong) NSArray<KDSPwdListModel *> *keys;
///是否支持查询操作记录：YES支持，NO不支持
@property (nonatomic, assign) BOOL isOperationalRecords;
///是否是简易版本蓝牙：功能集返回0x00；
@property (nonatomic, strong) NSString *FunctionSetKey;
///蓝牙同步锁端信息的时候会遇到各种情况（模块假死、通信堵塞等）超时同步失败120秒
@property (nonatomic,strong)NSTimer * timeOut;

@end

@implementation KDSRecordDetailsVC

#pragma mark - getter setter
- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
        _fmt.timeZone = [NSTimeZone localTimeZone];
        _fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _fmt;
}

- (NSMutableArray<News *> *)unlockRecordArr
{
    if (!_unlockRecordArr)
    {
        _unlockRecordArr = [NSMutableArray array];
    }
    return _unlockRecordArr;
}
- (NSMutableArray<KDSOperationalRecord *> *)czOperationalArr
{
    if (!_czOperationalArr) {
        _czOperationalArr = [NSMutableArray array];
    }
    return _czOperationalArr;
}

- (NSMutableArray<KDSAlarmModel *> *)alarmRecordArr
{
    if (!_alarmRecordArr)
    {
        _alarmRecordArr = [NSMutableArray array];
    }
    return _alarmRecordArr;
}

- (UIActivityIndicatorView *)unlockActivity
{
    if (!_unlockActivity)
    {
        _unlockActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint center = CGPointMake(kScreenWidth / 2.0, self.scrollView.bounds.size.height / 2.0);
        _unlockActivity.center = center;
        [self.scrollView addSubview:_unlockActivity];
    }
    return _unlockActivity;
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
        _alarmMaps = @{@1:Localized(@"num1Alarm"), @2:Localized(@"num2Alarm"), @3:Localized(@"num3Alarm"), @4:Localized(@"num4Alarm"), @8:Localized(@"num8Alarm"), @16:Localized(@"num16Alarm"), @32:Localized(@"num32Alarm"), @64:Localized(@"num64Alarm")};
    }
    return _alarmMaps;
}

#pragma mark - 生命周期、界面设置相关方法。
- (void)viewDidLoad {
    [super viewDidLoad];
    self.unlockIndex = 1;
    self.alarmIndex = 1;
    ////根据蓝牙锁的功能集判断是开始记录/操作记录
    self.FunctionSetKey = self.lock.lockFunctionSet;//?:self.lock.bleTool.connectedPeripheral.functionSet;
    //功能集
    self.isOperationalRecords = [KDSLockFunctionSet[self.FunctionSetKey] containsObject:@23];
    [self setupUI];
    [self loadNewUnlockRecord];
    [self loadNewAlarmRecord];
}

- (void)dealloc
{
    [self.lock.bleTool cancelTaskWithReceipt:self.uReceipt];
    [self.lock.bleTool cancelTaskWithReceipt:self.aReceipt];
    !self.didViewDynamic ?: self.didViewDynamic();
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
    if (self.lock.device.bleVersion.intValue >= 3 && ![self.FunctionSetKey isEqualToString:@"0x00"])
    {//bleVersion为3以后才有预警记录
        [self.view addSubview:view];
    }
    
    self.unlockRecBtn = [UIButton new];
    [self.unlockRecBtn setTitle:Localized(@"OpRecord") forState:UIControlStateNormal];
    self.unlockRecBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.unlockRecBtn.adjustsImageWhenHighlighted = NO;
    [self.unlockRecBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    self.selectedBtn = self.unlockRecBtn;
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
    self.cursorView = [[UIView alloc] init];
    self.cursorView.layer.cornerRadius = 1.5;
    self.cursorView.backgroundColor = UIColor.clearColor;
    [view addSubview:self.cursorView];
    [self.cursorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.unlockRecBtn);
        make.bottom.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(34, 3));
    }];
    
    //中间同步功能视图
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(view.frame) + 10, kScreenWidth - 20, 48)];
    if (self.lock.device.bleVersion.intValue >= 3 && ![self.FunctionSetKey isEqualToString:@"0x00"])
    {//bleVersion为3以后才有预警记录
        [self.view addSubview:view];
    }else{
        cornerView.frame = CGRectMake(10, CGRectGetMaxY(bgView.frame) + 10, kScreenWidth - 20, 48);
    }
    cornerView.layer.cornerRadius = 3;
    cornerView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:cornerView];
    self.label = [[UILabel alloc] init];
    self.label.textColor = KDSRGBColor(0x89, 0x89, 0x89);
    self.label.font = [UIFont systemFontOfSize:14];
    self.label.text = Localized(@"bleSyncLockOpRecord");
    [cornerView addSubview:self.label];
    self.syncRecBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.syncRecBtn setTitle:Localized(@"syncRecord") forState:UIControlStateNormal];
    [self.syncRecBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    self.syncRecBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    self.syncRecBtn.layer.cornerRadius = 10;
    self.syncRecBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    self.syncRecBtn.layer.borderWidth = 1;
    self.syncRecBtn.exclusiveTouch = YES;
    [self.syncRecBtn addTarget:self action:@selector(clickSyncRecBtnSyncUnlockOrAlarmRecord:) forControlEvents:UIControlEventTouchUpInside];
    [cornerView addSubview:self.syncRecBtn];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.equalTo(cornerView).offset(10);
        make.right.equalTo(self.syncRecBtn.mas_left).offset(-10);
    }];
    [self.syncRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cornerView);
        make.right.equalTo(cornerView).offset(-10);
        make.width.mas_equalTo(ceil([self.syncRecBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : self.syncRecBtn.titleLabel.font}].width) + 20);
        make.height.mas_equalTo(20);
    }];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    self.unlockTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.unlockTableView.showsVerticalScrollIndicator = NO;
    self.unlockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.unlockTableView.dataSource = self;
    self.unlockTableView.delegate = self;
    self.unlockTableView.backgroundColor = self.view.backgroundColor;
    self.unlockTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
    self.unlockTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewUnlockRecord)];
    self.unlockTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreUnlockRecord)];
    [self.unlockTableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    [self.scrollView addSubview:self.unlockTableView];
    
    if (self.lock.device.bleVersion.intValue >= 3 && ![self.FunctionSetKey isEqualToString:@"0x00"])
    {
        self.alarmTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.alarmTableView.showsVerticalScrollIndicator = NO;
        self.alarmTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.alarmTableView.dataSource = self;
        self.alarmTableView.delegate = self;
        self.alarmTableView.backgroundColor = self.view.backgroundColor;
        self.alarmTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
        self.alarmTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewAlarmRecord)];
        self.alarmTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreAlarmRecord)];
        [self.alarmTableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
        [self.scrollView addSubview:self.alarmTableView];
    }
    
    self.alarmTableView.rowHeight = self.unlockTableView.rowHeight = 40;
    if (@available(iOS 11.0, *)) {
        self.unlockTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.alarmTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewDidLayoutSubviews
{
    if (CGRectIsEmpty(self.unlockTableView.frame))
    {
        self.scrollView.contentSize = CGSizeMake(kScreenWidth * (self.lock.device.bleVersion.intValue >= 3 && ![self.FunctionSetKey isEqualToString:@"0x00"] ? 2 : 1), self.scrollView.bounds.size.height);
        CGRect frame = self.scrollView.bounds;
        frame.origin.x += 10;
        frame.size.width -= 20;
        self.unlockTableView.frame = frame;
        frame.origin.x += kScreenWidth;
        self.alarmTableView.frame = frame;
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
            label.text = Localized(@"noUnlockRecord,pleaseSync");
        }else{
            if ([self.FunctionSetKey isEqualToString:@"0x00"]) {
                label.text = Localized(@"information is not supported");
            }else{
                label.text = Localized(@"No alarm record synchronize");
            }
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    if (tableView == self.unlockTableView)
    {
        if (self.isOperationalRecords) {
            //操作记录
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
            if (self.czOperationalArr.count == 0)
            {
                noRecord(self.unlockTableView);
            }
            else
            {
                self.unlockTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
            }
            [self.unlockTableView reloadData];
            
        }else{
            //开锁记录
            NSMutableArray *sections = [NSMutableArray array];
            NSMutableArray<News *> *section = [NSMutableArray array];
            __block NSString *date = nil;
            [self.unlockRecordArr sortUsingComparator:^NSComparisonResult(News *  _Nonnull obj1, News *  _Nonnull obj2) {
                return [obj2.open_time compare:obj1.open_time];
            }];
            [self.unlockRecordArr enumerateObjectsUsingBlock:^(News * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!date)
                {
                    if (obj.open_time) {
                        date = [obj.open_time componentsSeparatedByString:@" "].firstObject;
                        [section addObject:obj];
                    }else{
                        [self.unlockRecordArr removeObject:obj];
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
                    }else{
                        [self.unlockRecordArr removeObject:obj];
                    }
                }
            }];
            if (section.count >0) {
                [sections addObject:[NSArray arrayWithArray:section]];
            }
            self.unlockRecordSectionArr = [NSArray arrayWithArray:sections];
            if (self.unlockRecordArr.count == 0)
            {
                noRecord(self.unlockTableView);
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.unlockTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
                    [self.unlockTableView reloadData];
                });
            }
        }
        
    }
    else
    {
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray<KDSAlarmModel *> *section = [NSMutableArray array];
        __block NSString *date = nil;
        [self.alarmRecordArr sortUsingComparator:^NSComparisonResult(KDSAlarmModel *  _Nonnull obj1, KDSAlarmModel *  _Nonnull obj2) {
            if (obj1.warningTime>0 && obj2.warningTime>0)
            {
                return obj2.warningTime < obj1.warningTime ? NSOrderedAscending : NSOrderedDescending;
            }
            else
            {
                return [obj2.date compare:obj1.date];
            }
        }];
        [self.alarmRecordArr enumerateObjectsUsingBlock:^(KDSAlarmModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        self.alarmRecordSectionArr = [NSArray arrayWithArray:sections];
        if (self.alarmRecordArr.count == 0)
        {
            noRecord(self.alarmTableView);
        }
        else
        {
            self.alarmTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
        }
        [self.alarmTableView reloadData];
    }
}

#pragma mark - 控件等事件方法。
///点击开锁记录、预警信息按钮调整滚动视图的偏移，切换页面。
- (void)clickRecordBtnAdjustScrollViewContentOffset:(UIButton *)sender
{
    if (sender!= self.selectedBtn) {
        self.selectedBtn.selected = NO;
        sender.selected = YES;
        self.selectedBtn = sender;
    }else{
        self.selectedBtn.selected = YES;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.cursorView.center = CGPointMake(sender.center.x, self.cursorView.center.y);
        self.scrollView.contentOffset = CGPointMake(sender == self.unlockRecBtn ? 0 : kScreenWidth, 0);
    }];
}

/**
 *@abstract 点击同步记录按钮同步开锁或报警记录。
 *@param sender button.
 */

//MARK:点击同步记录按钮同步开锁或报警记录
- (void)clickSyncRecBtnSyncUnlockOrAlarmRecord:(UIButton *)sender
{
    self.timeOut = [NSTimer scheduledTimerWithTimeInterval:120.f target:self selector:@selector(timerOutClick:) userInfo:nil repeats:NO];
    if (!self.lock.connected)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    CGFloat offsetX = self.scrollView.contentOffset.x;
    NSUInteger index = offsetX / self.scrollView.bounds.size.width;
    if (ceil(offsetX / self.scrollView.bounds.size.width) != index) return;
    //获取开锁记录，如果获取到的记录跟本地记录的最后一个记录的时间一样就停止。
    if (index == 0)
    {
#if kRecordDebug
        [self.unlockRecordArr removeAllObjects];//测试用
        [self reloadTableView:self.unlockTableView];
#endif
        if (self.uReceipt) return;
        [self.unlockActivity startAnimating];
        [self updateAllUnlockRecord];
    }
    else
    {
#if kRecordDebug
        [self.alarmRecordArr removeAllObjects];//测试用
        [self reloadTableView:self.alarmTableView];
#endif
        if (self.aReceipt) return;
        if ([self.FunctionSetKey isEqualToString:@"0x00"]) {
            [MBProgressHUD showError:Localized(@"information is not supported")];
            return;
        }
        [self updateAllAlarmRecord];
    }
}

/**
 *@abstract 获取锁中指定数据后的的开锁记录，然后更新最后一次更新时间后的开锁记录。
 */
- (void)updateAllUnlockRecord
{
    if (self.isOperationalRecords) {
        ///操作记录
        [self updateAllCzRecord];
    }else{
        ///开锁记录
        __weak typeof(self) weakSelf = self;
        KDSDBManager *manager = [KDSDBManager sharedManager];
        NSString *bleName = self.lock.device.lockName;///
        NSString *data = nil;
        KDSBleUnlockRecord *cachedRec = [[KDSBleUnlockRecord alloc] initWithHexString:data];
        self.uReceipt = [self.lock.bleTool updateRecord:1 afterData:data completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleUnlockRecord *> * _Nullable records) {
            
            if (error != KDSBleErrorSuccess && finished)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                    [weakSelf.unlockActivity stopAnimating];
                    weakSelf.uReceipt = nil;
                    //单独对于开门和报警记录返回错误8B提示
                    error != KDSBleErrorNotFound?[MBProgressHUD showError:[NSString stringWithFormat:@"error: %ld", (long)error]]:[MBProgressHUD showError:Localized(@"noRecord")];
                });
                
                return;
            }
            if (finished)
            {
                [self.timeOut invalidate];
                self.timeOut = nil;
                [weakSelf.unlockActivity stopAnimating];
                weakSelf.uReceipt = nil;
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
                    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
                        for (KDSBleUnlockRecord *record in mRecords)
                        {
                            News *n = [News new];
                            n.open_time = record.date;
                            n.open_type = record.unlockType;
                            n.user_num = record.userNum;
                            if (![weakSelf.unlockRecordArr containsObject:n])
                            {
                                [weakSelf.unlockRecordArr addObject:n];
                            }
                        }
                        [weakSelf reloadTableView:weakSelf.unlockTableView];
                        return ;
                    }
                    
                    [manager insertRecord:mRecords type:0 bleName:bleName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf reloadTableView:self.unlockTableView];
                    });
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
                            [manager deleteRecord:0 bleName:bleName];
                            [weakSelf loadNewUnlockRecord];
                        } error:^(NSError * _Nonnull error) {
                            [manager insertRecord:mRecords type:0 bleName:bleName];
                        } failure:^(NSError * _Nonnull error) {
                            [manager insertRecord:mRecords type:0 bleName:bleName];
                        }];
                    } error:^(NSError * _Nonnull error) {
                        [manager insertRecord:mRecords type:0 bleName:bleName];
                    } failure:^(NSError * _Nonnull error) {
                        [manager insertRecord:mRecords type:0 bleName:bleName];
                    }];
                    
                });
            }
            !self.uReceipt ?: [self.unlockActivity startAnimating];
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
    self.uReceipt = [self.lock.bleTool getOpRecAfterData:data completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleOpRec *> * _Nullable records) {
        if (!records)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [weakSelf.unlockActivity stopAnimating];
                weakSelf.uReceipt = nil;
                //单独对于开门和报警记录返回错误8B提示
                error != KDSBleErrorNotFound?[MBProgressHUD showError:[NSString stringWithFormat:@"error: %ld", (long)error]]:[MBProgressHUD showError:Localized(@"noRecord")];
            });
            return;
        }
        NSInteger index = -1;
        for (KDSBleOpRec *record in records)
        {
            if (data.length > 12 && [[record.hexString substringFromIndex:12] isEqualToString:[data substringFromIndex:12]] && index==-1)
            {
                index = [records indexOfObject:record];
                break;
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
        [weakSelf reloadTableView:weakSelf.unlockTableView];
        
        if (finished) {
            [self.timeOut invalidate];
            self.timeOut = nil;
            [weakSelf.unlockActivity stopAnimating];
            [MBProgressHUD showSuccess:Localized(@"syncComplete")];
            weakSelf.uReceipt = nil;
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
                [weakSelf reloadTableView:weakSelf.unlockTableView];
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
    !self.uReceipt ?: [self.unlockActivity startAnimating];
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
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSString *bleName = self.lock.device.lockName;
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
        [manager deleteRecord:0 bleName:bleName];
    } error:^(NSError * _Nonnull error) {
        [manager insertRecord:totalArr type:0 bleName:bleName];
    } failure:^(NSError * _Nonnull error) {
        [manager insertRecord:totalArr type:0 bleName:bleName];
    }];
    
}

/**
 *@abstract 获取锁中指定数据后的的报警记录，然后更新最后一次更新时间后的报警记录。
 */
- (void)updateAllAlarmRecord
{
    __weak typeof(self) weakSelf = self;
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSString *bleName = self.lock.device.lockName;
//    NSString *data = [manager queryUploadRecordDataWithBleName:bleName type:1];
    NSString * data = nil;
#if kRecordDebug
    data = nil;
#endif
    KDSBleAlarmRecord *cachedRec = [[KDSBleAlarmRecord alloc] initWithHexString:data];
    self.aReceipt = [self.lock.bleTool updateRecord:2 afterData:data completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleAlarmRecord *> * _Nullable records) {
        
        if (!records)
        {
            [weakSelf.alarmActivity stopAnimating];
            weakSelf.aReceipt = nil;
            //error != KDSBleErrorNotFound?[MBProgressHUD showError:[NSString stringWithFormat:@"error: %ld", (long)error]]:[MBProgressHUD showError:Localized(@"noRecord")];
            //锁处于管理员模式和相邻2条命令重复，或者正在进行鉴权，不提示error。先避免不必要的bug
            error != KDSBleErrorNotFound?:[MBProgressHUD showError:Localized(@"noRecord")];
            
            return;
        }
        NSInteger index = -1;
        for (KDSBleAlarmRecord *record in records)
        {
            if ([cachedRec isEqual:record] && index==-1)
            {
                index = [records indexOfObject:record];
                break;
            }
            KDSAlarmModel *m = [[KDSAlarmModel alloc] init];
            m.date = record.date;
            m.warningType = (int)record.type;
            m.warningTime = [self.fmt dateFromString:record.date].timeIntervalSince1970 * 1000;
            m.devName = bleName;
            if (![weakSelf.alarmRecordArr containsObject:m])
            {
                [weakSelf.alarmRecordArr addObject:m];
            }
        }
        [weakSelf reloadTableView:weakSelf.alarmTableView];
#if kRecordDebug
        weakSelf.label.text = @(weakSelf.alarmRecordArr.count).stringValue;//测试用
#endif
        if (finished/* || records.firstObject.total == records.count || index != -1*/)
        {
            [self.timeOut invalidate];
            self.timeOut = nil;
            [weakSelf.alarmActivity stopAnimating];
            [MBProgressHUD showSuccess:Localized(@"syncComplete")];
            weakSelf.aReceipt = nil;
            NSArray *unuploadRecords = [manager queryRecord:1 bleName:bleName];
            if (unuploadRecords.count)//最后把未上传的记录也显示一下
            {
                for (KDSBleAlarmRecord *rec in unuploadRecords)
                {
                    KDSAlarmModel *m = [[KDSAlarmModel alloc] init];
                    m.date = rec.date;
                    m.warningType = (int)rec.type;
                    m.devName = bleName;
                    m.warningTime = [self.fmt dateFromString:rec.date].timeIntervalSince1970 * 1000;
                    if (![weakSelf.alarmRecordArr containsObject:m])
                    {
                        [weakSelf.alarmRecordArr addObject:m];
                    }
                }
                [weakSelf reloadTableView:weakSelf.alarmTableView];
            }
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (records.firstObject.total == records.count)
                {
                    [manager updateUploadRecordData:records.firstObject.hexString withBleName:bleName type:1];
                    [weakSelf uploadAlarmRecord:records];
                }
                else if (index != -1)
                {
                    [manager updateUploadRecordData:records.firstObject.hexString withBleName:bleName type:1];
                    [weakSelf uploadAlarmRecord:[records subarrayWithRange:NSMakeRange(0, index)]];
                }
                else
                {
                    [weakSelf uploadAlarmRecord:records];
                }
            });
        }
    }];
    !self.aReceipt ?: [self.alarmActivity startAnimating];
}

///dismiss控制器。
- (void)clickCloseBtnDismissController:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 网络请求相关方法。
///获取第一页的开锁记录。
- (void)loadNewUnlockRecord
{
#if kRecordDebug
    return;
#endif
    [[KDSHttpManager sharedManager] getBlePwdListWithUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName pwdType:KDSServerKeyTpyeAll success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
        self.keys = pwdlistArray;
        [self reloadTableView:self.unlockTableView];
    } error:nil failure:nil];
    if (self.isOperationalRecords) {
        ///操作记录
        [self loadOperationalRecords];
    }else{
        
        [[KDSHttpManager sharedManager] getBindedDeviceUnlockRecordWithUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName index:1 success:^(NSArray<News *> * _Nonnull news) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self.unlockTableView.mj_footer resetNoMoreData];
            BOOL contain = NO;
            for (News *n in news)
            {
                if ([self.unlockRecordArr containsObject:n])
                {
                    contain = YES;
                    break;
                }
                [self.unlockRecordArr insertObject:n atIndex:[news indexOfObject:n]];
            }
            //如果第一页的数据部分包含于之前已加载的数据，那么不要改变当前页数，将首页没有加载过的数据添加到已加载的数据后刷新。否则用首页的数据刷新页面。
            if (!contain)
            {
                self.unlockIndex = 1;
                [self.unlockRecordArr removeAllObjects];
                [self.unlockRecordArr addObjectsFromArray:news];
            }
            [self reloadTableView:self.unlockTableView];
            [self cachePwdAttrWithNews:news];
            self.unlockTableView.mj_header.state = MJRefreshStateIdle;
            
        } error:^(NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
            self.unlockTableView.mj_header.state = MJRefreshStateIdle;
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
            self.unlockTableView.mj_header.state = MJRefreshStateIdle;
        }];
    }
    
}

////操作记录
-(void)loadOperationalRecords
{
    [[KDSHttpManager sharedManager] getBindedDeviceOperationalRecordsWithBleName:self.lock.device.lockName index:1 success:^(NSArray<KDSOperationalRecord *> * _Nonnull news) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (news.count == 0)
        {
            self.czOperationalArr = nil;
            self.unlockTableView.mj_header.state = MJRefreshStateIdle;
            UILabel *label = [[UILabel alloc] initWithFrame:self.unlockTableView.bounds];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = Localized(@"noUnlockRecord,pleaseSync");
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
            label.font = [UIFont systemFontOfSize:12];
            self.unlockTableView.tableHeaderView = label;
            return;
        }
        NSMutableArray * opArrs = [NSMutableArray array];
        [self.unlockTableView.mj_footer resetNoMoreData];
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
        [self reloadTableView:self.unlockTableView];
        self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    } error:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
        self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
        self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    }];
}
///加载更多操作记录
-(void)loadMoreOperationalRecords
{
    [[KDSHttpManager sharedManager] getBindedDeviceOperationalRecordsWithBleName:self.lock.device.lockName index:self.unlockIndex + 1 success:^(NSArray<KDSOperationalRecord *> * _Nonnull news) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (news.count == 0)
        {
            self.unlockTableView.mj_footer.state = MJRefreshStateNoMoreData;
            return;
            
        }
        self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
        NSMutableArray * opArrs = [NSMutableArray array];
        self.unlockIndex++;
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
        [self reloadTableView:self.unlockTableView];
    } error:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
    }];
}

///获取第一页的报警记录。
- (void)loadNewAlarmRecord
{
#if kRecordDebug
    return;
#endif
    [[KDSHttpManager sharedManager] getBindedDeviceAlarmRecordWithDevName:self.lock.device.lockName index:1 success:^(NSArray<KDSAlarmModel *> * _Nonnull models) {
        
        [self.alarmTableView.mj_footer resetNoMoreData];
        BOOL contain = NO;
        for (KDSAlarmModel *model in models)
        {
            if ([self.alarmRecordArr containsObject:model])
            {
                contain = YES;
                break;
            }
            model.date = [self.fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.warningTime / 1000]];
            [self.alarmRecordArr insertObject:model atIndex:[models indexOfObject:model]];
        }
        if (!contain)
        {
            self.alarmIndex = 1;
            [self.alarmRecordArr removeAllObjects];
            [self.alarmRecordArr addObjectsFromArray:models];
        }
        [self reloadTableView:self.alarmTableView];
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
        
    } error:^(NSError * _Nonnull error) {
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
    }];
}

///上拉开锁记录表视图加载新的开锁记录。
- (void)loadMoreUnlockRecord
{
#if kRecordDebug
    return;
#endif
    [[KDSHttpManager sharedManager] getBlePwdListWithUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName pwdType:KDSServerKeyTpyeAll success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
        self.keys = pwdlistArray;
        [self reloadTableView:self.unlockTableView];
    } error:nil failure:nil];
    if (self.isOperationalRecords) {
        ///加载更多操作记录
        [self loadMoreOperationalRecords];
    }else{
        [[KDSHttpManager sharedManager] getBindedDeviceUnlockRecordWithUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName index:self.unlockIndex + 1 success:^(NSArray<News *> * _Nonnull news) {
            
            if (news.count == 0)
            {
                self.unlockTableView.mj_footer.state = MJRefreshStateNoMoreData;
                return;
            }
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
            self.unlockIndex++;
            BOOL contain = NO;
            for (News *n in news)
            {
                for (News *s in self.unlockRecordArr)
                {
                    if ([s isEqual:n])
                    {
                        [self.unlockRecordArr replaceObjectAtIndex:[self.unlockRecordArr indexOfObject:s] withObject:n];//更新昵称。
                        contain = YES;
                        break;
                    }
                    contain = NO;
                }
                contain ?: [self.unlockRecordArr addObject:n];
            }
            [self reloadTableView:self.unlockTableView];
            [self cachePwdAttrWithNews:news];
            
        } error:^(NSError * _Nonnull error) {
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
        } failure:^(NSError * _Nonnull error) {
            self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
        }];
    }
}

///上拉报警记录表视图加载新的报警记录。
- (void)loadMoreAlarmRecord
{
    [[KDSHttpManager sharedManager] getBindedDeviceAlarmRecordWithDevName:self.lock.device.lockName index:self.alarmIndex + 1 success:^(NSArray<KDSAlarmModel *> * _Nonnull models) {
        
        if (models.count == 0)
        {
            self.alarmTableView.mj_footer.state = MJRefreshStateNoMoreData;
            return;
        }
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
        self.alarmIndex++;
        for (KDSAlarmModel *model in models)
        {
            if ([self.alarmRecordArr containsObject:model]) continue;
            model.date = [self.fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.warningTime / 1000]];
            [self.alarmRecordArr addObject:model];
        }
        [self reloadTableView:self.alarmTableView];
    } error:^(NSError * _Nonnull error) {
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
    }];
}

/**
 *@abstract 上传开锁记录到服务器。
 *@param records 要上传的开锁记录。
 */
- (void)uploadUnlockRecord:(nullable NSArray<KDSBleUnlockRecord *> *)records
{
#if kRecordDebug
    return;
#endif
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSString *bleName = self.lock.device.lockName;
    NSArray *unuploadRecords = [manager queryRecord:0 bleName:bleName];
    //总的上传记录。
    NSMutableArray *totalArr = [NSMutableArray arrayWithArray:records ?: @[]];
    for (KDSBleUnlockRecord *record in unuploadRecords)
    {
        if (![records containsObject:record])
        {
            [totalArr addObject:record];
        }
    }
    [totalArr sortUsingComparator:^NSComparisonResult(KDSBleUnlockRecord *  _Nonnull obj1, KDSBleUnlockRecord *  _Nonnull obj2) {
        return [obj2.date compare:obj1.date];
    }];
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    [[KDSHttpManager sharedManager] getBlePwdListWithUid:uid bleName:bleName pwdType:KDSServerKeyTpyeAll success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
        NSMutableArray *news = [NSMutableArray array];
        for (KDSBleUnlockRecord *record in totalArr)
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
        [[KDSHttpManager sharedManager] uploadBindedDeviceUnlockRecord:news withUid:uid device:self.lock.device success:^{
            [manager deleteRecord:0 bleName:bleName];
        } error:^(NSError * _Nonnull error) {
            [manager insertRecord:totalArr type:0 bleName:bleName];
        } failure:^(NSError * _Nonnull error) {
            [manager insertRecord:totalArr type:0 bleName:bleName];
        }];
    } error:^(NSError * _Nonnull error) {
        [manager insertRecord:totalArr type:0 bleName:bleName];
    } failure:^(NSError * _Nonnull error) {
        [manager insertRecord:totalArr type:0 bleName:bleName];
    }];
}

/**
 *@abstract 上传报警记录到服务器。
 *@param records 要上传的开锁记录。
 */
- (void)uploadAlarmRecord:(nullable NSArray<KDSBleAlarmRecord *> *)records
{
#if kRecordDebug
    return;
#endif
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSString *bleName = self.lock.device.lockName;
    NSArray *unuploadRecords = [manager queryRecord:1 bleName:bleName];
    NSMutableArray *totalArr = [NSMutableArray arrayWithArray:records ?: @[]];
    for (KDSBleAlarmRecord *record in unuploadRecords)
    {
        if (![records containsObject:record])
        {
            [totalArr addObject:record];
        }
    }
    NSMutableArray *models = [NSMutableArray array];
    for (KDSBleAlarmRecord *record in totalArr)
    {
        KDSAlarmModel *m = [KDSAlarmModel new];
        m.warningType = (int)record.type;
        m.devName = bleName;
        m.warningTime = [self.fmt dateFromString:record.date].timeIntervalSince1970 * 1000;
        [models addObject:m];
    }
    [[KDSHttpManager sharedManager] uploadBindedDeviceAlarmRecord:models success:^{
        [[KDSDBManager sharedManager] deleteRecord:1 bleName:bleName];
        [self loadNewAlarmRecord];
    } error:^(NSError * _Nonnull error) {
        [[KDSDBManager sharedManager] insertRecord:totalArr type:1 bleName:bleName];
    } failure:^(NSError * _Nonnull error) {
        [[KDSDBManager sharedManager] insertRecord:totalArr type:1 bleName:bleName];
    }];
}

///根据请求回来的开锁记录信息，提取密码属性(主要是昵称)缓存到本地，此方法在子线程异步执行。
- (void)cachePwdAttrWithNews:(NSArray<News *> *)news
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray<KDSUnlockAttr *> *attrs = [NSMutableArray array];
        NSMutableArray<NSNumber *> *users = [NSMutableArray array];
        for (News *n in news)
        {
            if ([users containsObject:@(n.user_num.intValue)]) continue;
            KDSUnlockAttr *attr = [KDSUnlockAttr new];
            attr.bleName = self.lock.device.lockName;
            attr.unlockType = n.open_type;
            attr.number = n.user_num.intValue;
            attr.nickname = n.nickName;
            [attrs addObject:attr];
            [users addObject:@(n.user_num.intValue)];
        }
        [[KDSDBManager sharedManager] insertUnlockAttr:attrs];
        
    });
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
        if (self.isOperationalRecords) {
            return self.czOPerationalSectionArr.count;
        }else{
            return self.unlockRecordSectionArr.count;
        }
    }else{
        return self.alarmRecordSectionArr.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.unlockTableView)
    {
        if (self.isOperationalRecords) {
            return self.czOPerationalSectionArr[section].count;
        }else{
            return self.unlockRecordSectionArr[section].count;
        }
    }else{
        return self.alarmRecordSectionArr[section].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KDSHomePageLockStatusCell"];
    cell.topLine.hidden = indexPath.row == 0;
    if (tableView == self.unlockTableView)
    {
        if (self.isOperationalRecords) {
            ///操作记录
            cell.bottomLine.hidden = indexPath.row == self.czOPerationalSectionArr[indexPath.section].count - 1;
            cell.alarmRecLabel.hidden = YES;
            cell.userNameLabel.hidden = NO;
            cell.unlockModeLabel.hidden = NO;
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
            ///开锁记录
            cell.bottomLine.hidden = indexPath.row == self.unlockRecordSectionArr[indexPath.section].count - 1;
            cell.alarmRecLabel.hidden = YES;
            cell.userNameLabel.hidden = NO;
            cell.unlockModeLabel.hidden = NO;
            cell.dynamicImageView.image = [UIImage imageNamed:@"未选择"];
            News *n = self.unlockRecordSectionArr[indexPath.section][indexPath.row];
            cell.timerLabel.text = [[n.open_time substringToIndex:n.open_time.length - 3] componentsSeparatedByString:@" "].lastObject;
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
    }
    else
    {
        cell.bottomLine.hidden = indexPath.row == self.alarmRecordSectionArr[indexPath.section].count - 1;
        cell.alarmRecLabel.hidden = NO;
        cell.userNameLabel.hidden = YES;
        cell.unlockModeLabel.hidden = YES;
        cell.dynamicImageView.image = [UIImage imageNamed:@"Alert message_icon 拷贝"];
        KDSAlarmModel *m = self.alarmRecordSectionArr[indexPath.section][indexPath.row];
        //        cell.timerLabel.text = m.date;
        cell.timerLabel.text = m.date.length > 16 ? [m.date substringWithRange:NSMakeRange(11, 5)] : @"未知";
        cell.alarmRecLabel.text = self.alarmMaps[@(m.warningType)];
    }
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = self.view.backgroundColor;
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(236, 236, 236);
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
    
    NSString *todayStr = [[self.fmt stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger today = [todayStr substringToIndex:8].integerValue;
    NSString *dateStr = nil;
    if (tableView == self.unlockTableView)
    {
        if (self.isOperationalRecords) {
            dateStr = self.czOPerationalSectionArr[section].firstObject.open_time;
        }else{
            dateStr = self.unlockRecordSectionArr[section].firstObject.open_time;
        }
    }else
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

#pragma mark 定时器响应

-(void)timerOutClick:(NSTimer *)timer
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    NSUInteger index = offsetX / self.scrollView.bounds.size.width;
    if (ceil(offsetX / self.scrollView.bounds.size.width) != index) return;
    //获取开锁记录，如果获取到的记录跟本地记录的最后一个记录的时间一样就停止。
    if (index == 0)
    {
        [self.unlockActivity stopAnimating];
        self.uReceipt = nil;
        [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];

    }
    else
    {
        [self.alarmActivity stopAnimating];
        self.aReceipt = nil;
        [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];

    }
  
}

@end

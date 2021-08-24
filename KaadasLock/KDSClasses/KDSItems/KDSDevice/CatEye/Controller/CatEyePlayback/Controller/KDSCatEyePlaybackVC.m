//
//  KDSCatEyePlaybackVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/7.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyePlaybackVC.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "KDSDBManager.h"
#import "UIButton+Color.h"
#import "MJRefresh.h"
#import "KDSCatEyeLookbackVC.h"
#import "KDSCatEyeSnapshotVC.h"
#import "YCMenuView.h"
#import "WeekDayCollectionCell.h"


#define kCollectionWidth ([UIScreen mainScreen].bounds.size.width-40)

@interface KDSCatEyePlaybackVC ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

///回看（录屏）按钮。
@property (nonatomic, strong) UIButton *lookBackBtn;
///快照按钮。
@property (nonatomic, strong) UIButton *snapshotBtn;
///绿色移动游标。
@property (nonatomic, strong) UIView *cursorView;
///横向滚动的滚动视图，装着开锁记录和报警记录的表视图。
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton * selectedBtn;
///点击选择年份按钮
@property (nonatomic,strong)UIButton *yearBtn;
///点击选中月份按钮
@property (nonatomic,strong)UIButton * mBtn;
///状态筛选弹出来的下拉view
@property (nonatomic,strong)YCMenuView    *chooseMenuView;
///状态筛选弹出来的下拉view
@property (nonatomic,strong)YCMenuView    *mchooseMenuView;
@property (nonatomic,strong)NSMutableArray *chooseMenuViewDataList;
@property (nonatomic,strong)NSMutableArray *mchooseMenuViewDataList;
///用来展示一周的日历collectionview
@property (nonatomic,strong)UICollectionView *calendarCollectionView;
///当前月最大天数
@property (nonatomic,assign)NSInteger maxCurrentDayNum;
///上一个月的最大天数
@property (nonatomic,assign)NSInteger previousDayNum;
@property (nonatomic,strong)NSMutableArray * zxpDataSoucrArr;
///当前选中的年月日
@property (nonatomic,strong)NSString * seleteYMStr;
///当前年的上一年
@property (nonatomic,strong)NSString * previousYearString;
///系统当前年
@property (nonatomic,assign) NSInteger currentYear;
///系统当前月
@property (nonatomic,assign)NSInteger currentMonth;
///系统当前日
@property (nonatomic,assign)NSInteger currentDay;
@property (nonatomic,assign)CGFloat CWidth;
@property (nonatomic,copy)NSString * selectStr;//进入页面后未未点击daycell时，默认的日期



@end

@implementation KDSCatEyePlaybackVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.snapshotBtn.selected) {
//        self.cursorView.center = CGPointMake(sender.center.x, self.cursorView.center.y);
        self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    };
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"回看");
    self.view.backgroundColor = UIColor.whiteColor;
    self.CWidth =  kCollectionWidth/7;
    [self setDataSouce];
    [self setUI];
    [[NSNotificationCenter defaultCenter] postNotificationName:(self.lookBackBtn.selected ? @"KDSLookbackTimeSelected":@"KDSSnapshotTimeSelected")object:nil userInfo:@{@"time" : _selectStr}];
}
-(void)setDataSouce{
    KDSWeakSelf(self);
    NSDate *date =[NSDate date];//简书 FlyElephant
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy"];
    
    self.currentYear=[[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"MM"];
    self.currentMonth=[[formatter stringFromDate:date]integerValue];
    [formatter setDateFormat:@"dd"];
    self.currentDay=[[formatter stringFromDate:date] integerValue];
    
    [self.yearBtn setTitle:[NSString stringWithFormat:@"%ld",(long)self.currentYear] forState:UIControlStateNormal];
    [self.mBtn setTitle:[NSString stringWithFormat:@"%ld",(long)self.currentMonth] forState:UIControlStateNormal];
    
    self.seleteYMStr = [NSString stringWithFormat:@"%ld-%ld",(long)self.currentYear,(long)self.currentMonth];
    
    NSString * str1 = [self.yearBtn.titleLabel.text substringToIndex:4];
    NSString * str2 ;
    if (self.mBtn.titleLabel.text.length == 2) {
        str2 = [self.mBtn.titleLabel.text substringToIndex:2];
    }else{
        str2 = [self.mBtn.titleLabel.text substringToIndex:1];
    }
    ///上一个月字符串
    NSString * zxpStr = [NSString stringWithFormat:@"%d",str2.intValue-1];
    NSString * zxpMString = [NSString stringWithFormat:@"%@-%@",str1,zxpStr];
    
    self.previousDayNum = [self numberOfDayInMonthWithDateStr:zxpMString];
    NSDate * currentdate = [self nsstringConversionNSDate:[NSString stringWithFormat:@"%ld-%ld",(long)self.currentYear,(long)self.currentMonth]];
    if (currentdate)
    {
        self.maxCurrentDayNum = [self numberOfDayInMonthWithDateStr:[NSString stringWithFormat:@"%ld-%ld",(long)self.currentYear,(long)self.currentMonth]];
        
        [self getWeekDaysWithDate:currentdate withNum:self.maxCurrentDayNum];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1/*延迟执行时间*/ * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [weakself.calendarCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:weakself.zxpDataSoucrArr.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
    });
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.zxpDataSoucrArr.count-1 inSection:0];
    [self.calendarCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    NSString *mStr;
    NSString *dStr;
    mStr = self.mBtn.titleLabel.text.length == 1? [NSString stringWithFormat:@"0%@",self.mBtn.titleLabel.text]:self.mBtn.titleLabel.text;
    dStr = [NSString stringWithFormat:@"%@",self.zxpDataSoucrArr.lastObject].length == 1? [NSString stringWithFormat:@"0%@",self.zxpDataSoucrArr.lastObject]:self.zxpDataSoucrArr.lastObject;
    _selectStr = [NSString stringWithFormat:@"%@-%@-%@",self.yearBtn.titleLabel.text,mStr,dStr];
}
-(void)setUI{
    //顶部功能选择按钮
    KDSWeakSelf(self);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(25, 0, kScreenWidth-50, 30)];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 14;
    [self.view addSubview:view];
    self.lookBackBtn = [UIButton new];
    [self.lookBackBtn setTitle:Localized(@"录屏") forState:UIControlStateNormal];
    self.lookBackBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.lookBackBtn.adjustsImageWhenHighlighted = NO;
    self.lookBackBtn.tag = 0;
    [self.lookBackBtn addTarget:self action:@selector(lookBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.lookBackBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.lookBackBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.lookBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.lookBackBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    self.selectedBtn = self.lookBackBtn;
    self.lookBackBtn.selected = YES;
    self.lookBackBtn.layer.masksToBounds = YES;
    self.lookBackBtn.layer.cornerRadius = 13.5;
    [view addSubview:self.lookBackBtn];
    
    self.snapshotBtn = [UIButton new];
    [self.snapshotBtn setTitle:Localized(@"快照") forState:UIControlStateNormal];
    self.snapshotBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.snapshotBtn.adjustsImageWhenHighlighted = NO;
    [self.snapshotBtn addTarget:self action:@selector(lookBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.snapshotBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.snapshotBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.snapshotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.snapshotBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    self.snapshotBtn.layer.masksToBounds = YES;
    self.snapshotBtn.tag = 1;
    self.snapshotBtn.layer.cornerRadius = 13.5;
    [view addSubview:self.snapshotBtn];
    
    CGFloat width = (KDSScreenWidth-30)/2;
    [self.lookBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    [self.snapshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    self.cursorView = [[UIView alloc] init];
    self.cursorView.layer.cornerRadius = 1.5;
    self.cursorView.backgroundColor = UIColor.clearColor;
    [view addSubview:self.cursorView];
    [self.cursorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.lookBackBtn);
        make.bottom.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(34, 3));
    }];
    
    UIView * selectiontimeView = [UIView new];
    selectiontimeView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:selectiontimeView];
    [selectiontimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view.mas_bottom).offset(15);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(120);
        make.centerX.mas_equalTo(weakself.view.mas_centerX).offset(0);
    }];
    [selectiontimeView addSubview:self.yearBtn];
    [self.yearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(selectiontimeView.mas_left).offset(0);
        make.top.mas_equalTo(selectiontimeView.mas_top).offset(0);
        make.bottom.mas_equalTo(selectiontimeView.mas_bottom).offset(0);
        make.width.mas_equalTo(40);
    }];
    
    UIImageView * imag = [UIImageView new];
    imag.image = [UIImage imageNamed:@"Expand downward_icon"];
    [selectiontimeView addSubview:imag];
    [imag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.yearBtn.mas_right).offset(2);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(5);
        make.centerY.mas_equalTo(selectiontimeView.mas_centerY).offset(0);
    }];
    ///(-)
    UIView * line1 = [UIView new];
    line1.backgroundColor = UIColor.lightGrayColor;
    [selectiontimeView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imag.mas_right).offset(8);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(1);
        make.centerY.mas_equalTo(selectiontimeView.mas_centerY).offset(0);
    }];
    
    [selectiontimeView addSubview:self.mBtn];
    [self.mBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(line1.mas_right).offset(2);
        make.top.mas_equalTo(selectiontimeView.mas_top).offset(0);
        make.bottom.mas_equalTo(selectiontimeView.mas_bottom).offset(0);
        make.width.mas_equalTo(20);
    }];
    UIImageView * img1 = [UIImageView new];
    img1.image = [UIImage imageNamed:@"Expand downward_icon"];
    [selectiontimeView addSubview:img1];
    [img1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.mBtn.mas_right).offset(2);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(5);
        make.centerY.mas_equalTo(selectiontimeView.mas_centerY).offset(0);
    }];
    
    [self.view addSubview:self.calendarCollectionView];
    
    [self.calendarCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).offset(0);
        make.right.mas_equalTo(weakself.view.mas_right).offset(0);
        make.top.mas_equalTo(selectiontimeView.mas_bottom).offset(20);
        make.height.mas_equalTo(50);
        
    }];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.calendarCollectionView.mas_bottom);
        make.left.bottom.right.equalTo(weakself.view);
    }];
    UIView *grayLineView = [[UIView alloc] init];
    grayLineView.backgroundColor = KDSRGBColor(221, 221, 221);
    [self.view addSubview:grayLineView];
    [grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.view.mas_left).offset(0);
        make.right.mas_equalTo(weakself.view.mas_right).offset(0);
        make.top.mas_equalTo(weakself.calendarCollectionView.mas_bottom).offset(10);
        make.height.mas_equalTo(0.5);
    }];
    
    CGFloat height = kScreenHeight-200;
    KDSCatEyeLookbackVC * vc1 = [KDSCatEyeLookbackVC new];
    vc1.gatewayDeviceModel = self.gatewayDeviceModel;
    vc1.currentRecordDate = self.selectStr;
    [self addChildViewController:vc1];
    vc1.view.frame = CGRectMake(0, 10, kScreenWidth, height);
    [self.scrollView addSubview:vc1.view];
    
    KDSCatEyeSnapshotVC *vc2 = [KDSCatEyeSnapshotVC new];
    vc2.gatewayDeviceModel = self.gatewayDeviceModel;
    vc2.currentPicDate = self.selectStr;
    [self addChildViewController:vc2];
    vc2.view.frame = CGRectMake(kScreenWidth, 10, kScreenWidth, height);
    [self.scrollView addSubview:vc2.view];
}

#pragma mark 手势

-(void)lookBackBtnClick:(UIButton *)sender
{
    KDSWeakSelf(self);
    if (sender!= self.selectedBtn) {
        self.selectedBtn.selected = NO;
        sender.selected = YES;
        self.selectedBtn = sender;
    }else{
        self.selectedBtn.selected = YES;
    }
    [UIView animateWithDuration:0.3 animations:^{
        weakself.cursorView.center = CGPointMake(sender.center.x, weakself.cursorView.center.y);
        weakself.scrollView.contentOffset = CGPointMake(sender == weakself.lookBackBtn ? 0 : kScreenWidth, 0);
    }];
//    [[NSNotificationCenter defaultCenter] postNotificationName:(self.lookBackBtn.selected ? @"KDSLookbackTimeSelected":@"KDSSnapshotTimeSelected")object:nil userInfo:@{@"time" : _selectStr}];
}

-(void)yearButtonClick:(UIButton *)btn{
    NSLog(@"点击了年");
    if (self.chooseMenuView != nil) {
        self.chooseMenuView = nil;
    }
    self.chooseMenuView = [YCMenuView menuWithActions:self.chooseMenuViewDataList width:71 relyonView:btn];
    self.chooseMenuView.layer.cornerRadius = 2;
    self.chooseMenuView.maxDisplayCount = 7;
    [self.chooseMenuView show];
}
-(void)mButtonClick:(UIButton *)btn
{
    NSLog(@"点击了yue");
    if (self.mchooseMenuView != nil) {
        self.mchooseMenuView = nil;
    }
    self.mchooseMenuView = [YCMenuView menuWithActions:self.mchooseMenuViewDataList width:50 relyonView:btn];
    self.mchooseMenuView.layer.cornerRadius = 2;
    self.mchooseMenuView.maxDisplayCount = 7;
    [self.mchooseMenuView show];
    
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.zxpDataSoucrArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WeekDayCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:WeekDayCollectionCell.ID forIndexPath:indexPath];
    
    if (self.zxpDataSoucrArr.count>0) {
        
        NSInteger index1 = [self.zxpDataSoucrArr indexOfObject:@"1"];
        
        NSDate * date = [self dateWithDataStr:[NSString stringWithFormat:@"%@-01",self.seleteYMStr]];
        NSInteger qixing = [self weekdayStringFromDate:date]-1;
        NSString * currentString = [NSString stringWithFormat:@"%ld",(indexPath.row - index1 + qixing) % 7];
        if ([currentString isEqualToString:@"0"]) {
            cell.weekDayLbl.text= @"日";
        }if ([currentString isEqualToString:@"1"]) {
            cell.weekDayLbl.text= @"一";
        }
        if ([currentString isEqualToString:@"2"]) {
            cell.weekDayLbl.text= @"二";
        }
        if ([currentString isEqualToString:@"3"]) {
            cell.weekDayLbl.text= @"三";
        }
        if ([currentString isEqualToString:@"4"]) {
            cell.weekDayLbl.text= @"四";
        }
        if ([currentString isEqualToString:@"5"]) {
            cell.weekDayLbl.text= @"五";
        }if ([currentString isEqualToString:@"6"]) {
            cell.weekDayLbl.text= @"六";
        }
        cell.dayLbl.text = self.zxpDataSoucrArr[indexPath.row];
        UIView* selectedBGView = [[UIView alloc] initWithFrame:cell.frame];
        selectedBGView.backgroundColor = KDSRGBColor(94, 183, 255);
        selectedBGView.layer.cornerRadius=4;
        cell.selectedBackgroundView = selectedBGView;
        
    }
    return cell;
}

-(NSInteger)weekdayStringFromDate:(NSDate*)inputDate {
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    NSString * weekday = [weekdays objectAtIndex:theComponents.weekday];
    return [weekdays indexOfObject:weekday];
    
}

// 返回每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.CWidth, self.CWidth);
}
#pragma mark - UICollectionViewDelegate点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    WeekDayCollectionCell *cell = (WeekDayCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString *mStr;
    NSString *dStr;
    mStr = self.mBtn.titleLabel.text.length == 1? [NSString stringWithFormat:@"0%@",self.mBtn.titleLabel.text]:self.mBtn.titleLabel.text;
    dStr = cell.dayLbl.text.length == 1? [NSString stringWithFormat:@"0%@",cell.dayLbl.text]:cell.dayLbl.text;
    _selectStr = [NSString stringWithFormat:@"%@-%@-%@",self.yearBtn.titleLabel.text,mStr,dStr];
    [[NSNotificationCenter defaultCenter] postNotificationName:(self.lookBackBtn.selected ? @"KDSLookbackTimeSelected":@"KDSSnapshotTimeSelected")object:nil userInfo:@{@"time" : _selectStr}];
//    NSLog(@"选择日期为%@-%@-%@",self.yearBtn.titleLabel.text,self.mBtn.titleLabel.text,cell.dayLbl.text);
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark -- NSDate get & set


///根据当前时间字符串本月有多少天
- (NSInteger)numberOfDayInMonthWithDateStr:(NSString *)dateStr {
    NSDate * date = [self dateWithdateSr:dateStr];
    
    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 通过该方法计算特定日期月份的天数
    NSRange monthRange =  [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    return monthRange.length;
}

/**
 根据给出的日期获得NSDate
 @param dateStr 日期
 @return 对应的NSDate
 */
- (NSDate *)dateWithdateSr:(NSString *)dateStr {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    // 此处根据需求改对应的日期格式
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate * date = [dateFormatter dateFromString:dateStr];
    
    return date;
}

-(NSDate *)dateWithDataStr:(NSString *)dateStr
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    // 此处根据需求改对应的日期格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [dateFormatter dateFromString:dateStr];
    
    return date;
}

-(void)getWeekDaysWithDate:(NSDate *)now withNum:(NSInteger)num{
    NSMutableArray * addArr = [NSMutableArray array];
    int curnNUm = (int)self.maxCurrentDayNum;
    ///如果选择的是当前年当前月要判断当前日，只能选择比当前年月日小的时间
    if ([self.seleteYMStr isEqualToString:[NSString stringWithFormat:@"%ld-%ld",(long)self.currentYear,(long)self.currentMonth]] || [[NSString stringWithFormat:@"%@-%@",self.yearBtn.titleLabel.text,self.mBtn.titleLabel.text] isEqualToString:[NSString stringWithFormat:@"%ld-%ld",(long)self.currentYear,(long)self.currentMonth]]) {
        
        for (int j = 1; j <= self.currentDay; j ++) {
            [addArr addObject:[NSString stringWithFormat:@"%d",j]];
        }
    }else{
        
        for (int i = 1;i <= curnNUm ; i++ ) {
            [addArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    [self.zxpDataSoucrArr removeAllObjects];
    [self.zxpDataSoucrArr addObjectsFromArray:addArr];
    [self.calendarCollectionView reloadData];
}

#pragma mark -- lazy load
-(UIButton *)yearBtn{
    if (!_yearBtn) {
        _yearBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"2019" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            [btn addTarget:self action:@selector(yearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
    }
    return _yearBtn;
}
- (UIButton *)mBtn
{
    if (!_mBtn) {
        _mBtn = ({
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"5月" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            [btn addTarget:self action:@selector(mButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn;
            
        });
    }
    return _mBtn;
}
-(NSMutableArray *)chooseMenuViewDataList{
    KDSWeakSelf(self);
    if (_chooseMenuViewDataList == nil) {
        _chooseMenuViewDataList = [NSMutableArray new];
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy"];
        NSString *thisYearString=[dateformatter stringFromDate:senddate];
        self.previousYearString= [NSString stringWithFormat:@"%d",thisYearString.intValue-1];
        YCMenuAction *menuItem = [YCMenuAction actionWithTitle:self.previousYearString image:nil handler:^(YCMenuAction *action) {
            NSLog(@"点击了:%@",action.title);
            [weakself.yearBtn setTitle:[NSString stringWithFormat:@"%@",action.title] forState:UIControlStateNormal];
             [weakself setCurrentYDDate];
        }];
        YCMenuAction *menuItem1 = [YCMenuAction actionWithTitle:thisYearString image:nil handler:^(YCMenuAction *action) {
            NSLog(@"点击了:%@",action.title);
            [weakself.yearBtn setTitle:[NSString stringWithFormat:@"%@",action.title] forState:UIControlStateNormal];
             [weakself setCurrentYDDate];
        }];
        
        [_chooseMenuViewDataList addObject:menuItem];
        [_chooseMenuViewDataList addObject:menuItem1];
    }
    return _chooseMenuViewDataList;
}
-(NSMutableArray *)mchooseMenuViewDataList
{
    KDSWeakSelf(self);
    if (!_mchooseMenuViewDataList) {
        _mchooseMenuViewDataList = [NSMutableArray array];
        
    }else{
        [_mchooseMenuViewDataList removeAllObjects];
    }
    if ([self.yearBtn.titleLabel.text isEqualToString:self.previousYearString])
    {///如果选中当前年的前一年就是可以有12个月的选项
        for (int i = 1; i<=12; i++) {
            
            YCMenuAction * menuItem = [YCMenuAction actionWithTitle:[NSString stringWithFormat:@"%d",i] image:nil handler:^(YCMenuAction *action) {
                NSLog(@"点击了:%@",action.title);
                [weakself.mBtn setTitle:[NSString stringWithFormat:@"%@",action.title] forState:UIControlStateNormal];
                [weakself setCurrentYDDate];
            } ];
            [_mchooseMenuViewDataList addObject:menuItem];
        }
        
    }else{///如果是当前年要判断当前是几月
        
        for (NSInteger k = 1; k <= self.currentMonth; k++) {
            
            YCMenuAction * menuItem = [YCMenuAction actionWithTitle:[NSString stringWithFormat:@"%ld",k] image:nil handler:^(YCMenuAction *action) {
                NSLog(@"点击了:%@",action.title);
                [weakself.mBtn setTitle:[NSString stringWithFormat:@"%@",action.title] forState:UIControlStateNormal];
                [weakself setCurrentYDDate];
            } ];
            [_mchooseMenuViewDataList addObject:menuItem];
        }
    }
    
    return _mchooseMenuViewDataList;
}

-(void)setCurrentYDDate
{
    NSString * str1 = [self.yearBtn.titleLabel.text substringToIndex:4];
    NSString * str2 ;
    if (self.mBtn.titleLabel.text.length == 2) {
        str2 = [self.mBtn.titleLabel.text substringToIndex:2];
    }else{
        str2 = [self.mBtn.titleLabel.text substringToIndex:1];
    }
    ///上一个月字符串
    NSString * zxpStr = [NSString stringWithFormat:@"%d",str2.intValue-1];
    NSString * zxpMString = [NSString stringWithFormat:@"%@-%@",str1,zxpStr];
    
    self.previousDayNum = [self numberOfDayInMonthWithDateStr:zxpMString];
    
    self.seleteYMStr = [NSString stringWithFormat:@"%@-%@",str1,str2];
    NSDate * date = [self nsstringConversionNSDate:self.seleteYMStr];
    if (date)
    {
        self.maxCurrentDayNum = [self numberOfDayInMonthWithDateStr:self.seleteYMStr];
        
        [self getWeekDaysWithDate:date withNum:self.maxCurrentDayNum];
    }
}
-(NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}
-(UICollectionView *)calendarCollectionView{
    if (!_calendarCollectionView) {
        _calendarCollectionView = ({
            UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            UICollectionView *c = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            c.backgroundColor = [UIColor clearColor];
            c.dataSource = self;
            c.delegate = self;
            c.bounces = NO;
            c.alwaysBounceHorizontal = YES;
            c.alwaysBounceVertical = NO;
            c.showsHorizontalScrollIndicator = NO;
            c.showsVerticalScrollIndicator = NO;
            [c registerClass:[WeekDayCollectionCell class] forCellWithReuseIdentifier:WeekDayCollectionCell.ID];
            c;
        });
    }
    return _calendarCollectionView;
}

- (NSMutableArray *)zxpDataSoucrArr
{
    if (!_zxpDataSoucrArr) {
        _zxpDataSoucrArr = [NSMutableArray array];
    }
    return _zxpDataSoucrArr;
}

- (void)dealloc
{
    NSLog(@"执行了dealloc---palyback");
}
@end

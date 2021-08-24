//
//  KDSLongConnectionPeriodVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSLongConnectionPeriodVC.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSWeekPickerVC.h"
#import "KDSDatePickerVC.h"
#import "KDSTimelinessView.h"
#import "KDSMQTTManager+SmartHome.h"
#import "NSString+extension.h"

@interface KDSLongConnectionPeriodVC ()<UITableViewDataSource, UITableViewDelegate>
///表视图。
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * titles;
///时间设置
@property(nonatomic, strong) NSString * settingTimeStr;
///周期设置
@property(nonatomic, strong) NSString * settingWeekStr;
///date formatter, format HH:mm
@property (nonatomic, strong) NSDateFormatter *fmt;
///周期密码时，位域标记选中日期的变量，从低到高分别表示周日 ~ 周六，最高位保留0，1选中。
@property (nonatomic, assign) char mask;
///设置长连接的重复周期
@property (nonatomic, strong)NSArray * keep_alive_snooze;
///开始时间:时分的秒数和
@property (nonatomic, assign)int snooze_start_time;
///结束时间:时分的秒数和
@property (nonatomic, assign)int snooze_end_time;

@end

@implementation KDSLongConnectionPeriodVC

#pragma mark - getter setter
- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
        _fmt.dateFormat = @"HH:mm";
    }
    return _fmt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"长连接周期";
    [self.titles addObjectsFromArray:@[@"规则重复",@"时间设置"]];
    NSDictionary * dic = self.lock.wifiDevice.alive_time;
    NSString * snooze_start_time = dic[@"snooze_start_time"];
    NSString * snooze_end_time = dic[@"snooze_end_time"];
    self.snooze_start_time = snooze_start_time.intValue;
    self.snooze_end_time = snooze_end_time.intValue;
    self.keep_alive_snooze = dic[@"keep_alive_snooze"];
    
    self.settingTimeStr = [NSString stringWithFormat:@"%@-%@",[NSString timeFormatted:self.snooze_start_time],[NSString timeFormatted:self.snooze_end_time]];
    self.settingWeekStr  = [NSString getWeekStrWithWeekDic:dic];
  
    [self setUI];
    
}

- (void)setUI
{
    CGFloat offset = 0;
    if (kStatusBarHeight + kNavBarHeight + 9*60 + 84 > kScreenHeight)
    {
        offset = -44;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.title = self.titles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    if ([cell.title isEqualToString:@"规则重复"]){
        cell.subtitle = self.settingWeekStr ?: @"周一 周三 周四 周五 周六 周日";
        cell.hideSwitch = YES;
    }else if ([cell.title isEqualToString:@"时间设置"]) {
        cell.subtitle = self.settingTimeStr ?: @"00:00-23:59";
        cell.hideSwitch = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSLockMoreSettingCell * cell = (KDSLockMoreSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    if ([cell.title isEqualToString:@"规则重复"]) {
        KDSWeekPickerVC *vc = [KDSWeekPickerVC new];
        vc.mask = self.mask;
        //  回调设置值
        vc.didSelectWeekBlock = ^(char mask) {
            NSLog(@"zhu-xx 回调传递过来的值==%c",mask);
            if (mask == 0x00) {
                mask = 0x7f;
            }
            if (mask == 0x7f)
            {
                self.settingWeekStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",Localized(@"everySunday"),Localized(@"everyMonday"),Localized(@"everyTue"),Localized(@"everyWed"),Localized(@"everyThu"),Localized(@"everyFri"),Localized(@"everySat")];//Localized(@"everyday");
               // self.settingWeekStr = [NSString  stringWithFormat:@"%@",Localized(@"everyday")];
                
            }
            else
            {  // 进行字符串的拆分 
                NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
                NSMutableString *ms = [NSMutableString string];
                NSString *separator = @" ";//[[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
                for (int i = 0; i < 7; ++i)
                {
                    !((mask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
                }
                [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
                self.settingWeekStr = ms;
            }
            self.mask = mask;
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.title isEqualToString:@"时间设置"]){
        [self tapBeginTimelinessViewAction];
    }
}

///点击时效图执行的事件。
- (void)tapBeginTimelinessViewAction
{
    KDSDatePickerVC *vc = [[KDSDatePickerVC alloc] init];
    vc.mode = 1;
    vc.didPickupDateBlock = ^(NSDate * _Nonnull beginDate, NSDate * _Nullable endDate) {
        self.settingTimeStr = [NSString stringWithFormat:@"%@-%@", [self.fmt stringFromDate:beginDate], [self.fmt stringFromDate:endDate]];
        [self.tableView reloadData];
    };
    [self presentViewController:vc animated:YES completion:nil];
    
}
///返回即触发设置视频长连接的参数
-(void)navBackClick
{
    NSArray * startAndEndTimeArr = [self.settingTimeStr componentsSeparatedByString:@"-"];
    if (startAndEndTimeArr.count ==2) {
        NSArray *startTimeArr = [startAndEndTimeArr[0] componentsSeparatedByString:@":"];
        if (startTimeArr.count == 2) {
            NSString * startHour = startTimeArr[0];
            NSString * startMinute = startTimeArr[1];
            self.snooze_start_time = startHour.intValue * 60*60 + startMinute.intValue*60;
        }
        NSArray *endTimeArr = [startAndEndTimeArr[1] componentsSeparatedByString:@":"];
        if (endTimeArr.count == 2) {
            NSString * endHour = endTimeArr[0];
            NSString * endMinute = endTimeArr[1];
            self.snooze_end_time = endHour.intValue * 60*60 + endMinute.intValue*60;
        }
    }
    NSArray * weekArr = [self.settingWeekStr componentsSeparatedByString:@" "];
    NSMutableArray * WeekStrarr = [NSMutableArray array];
    for (NSString * temStr in weekArr) {
        if ([temStr containsString:@"周一"]) {
            [WeekStrarr addObject:@(1)];
        }else if ([temStr containsString:@"周二"]){
            [WeekStrarr addObject:@(2)];
        }else if ([temStr containsString:@"周三"]){
            [WeekStrarr addObject:@(3)];
        }else if ([temStr containsString:@"周四"]){
            [WeekStrarr addObject:@(4)];
        }else if ([temStr containsString:@"周五"]){
            [WeekStrarr addObject:@(5)];
        }else if ([temStr containsString:@"周六"]){
            [WeekStrarr addObject:@(6)];
        }else if ([temStr containsString:@"周日"]){
            [WeekStrarr addObject:@(7)];
        }
    }
    self.keep_alive_snooze = WeekStrarr;
   
    !_didSelectWeekAndTimeBlock ?: _didSelectWeekAndTimeBlock (self.keep_alive_snooze,self.snooze_start_time,self.snooze_end_time);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma Lazy --load

- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

@end

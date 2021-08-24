//
//  KDSAddDanpTimingVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddDanpTimingVC.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSTimelinessView.h"
#import "KDSDanPDatePickerVC.h"
#import "KDSWeekPickerVC.h"
#import "KDSDeviceTimingCell.h"


@interface KDSAddDanpTimingVC ()<UITableViewDataSource, UITableViewDelegate>
///定时选项
@property (nonatomic, strong) UITableView *tableView;
///数据源
@property (nonatomic, strong) NSArray * titleArray;
///保存按钮
@property (nonatomic, strong) UIButton * preserBtn;
///开始时间
@property(nonatomic, strong) NSString * beginTimeStr;
///结束时间
@property(nonatomic, strong) NSString * endTimeStr;
///重复（周日～周六）
@property(nonatomic, strong) NSString * ruleStr;
///周期密码时，位域标记选中日期的变量，从低到高分别表示周日 ~ 周六，最高位保留0，1选中。
@property (nonatomic, assign) char mask;


@end

@implementation KDSAddDanpTimingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"添加定时";
    self.titleArray = @[@"生效时间",@"结束时间",@"规则重复",@"添加设备"];
    [self setUI];
}

-(void)setUI{
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.equalTo(@(60 * self.titleArray.count + (self.titleArray.count-1) * 10));
    }];
    self.preserBtn = [UIButton new];
    [self.preserBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.preserBtn.layer.cornerRadius = 22;
    [self.preserBtn addTarget:self action:@selector(preserBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.preserBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.preserBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [self.view addSubview:self.preserBtn];
    [self.preserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(KDSScreenHeight < 667 ? 50 : 110);
    }];
   
    
}

#pragma mark 点击事件

-(void)preserBtnClick:(UIButton *)sender
{
    
}
///点击时效图执行的事件。
- (void)tapBeginTimelinessViewAction
{
    KDSDanPDatePickerVC *vc = [[KDSDanPDatePickerVC alloc] init];
    vc.beginStr = self.beginTimeStr;
    vc.titleStr = Localized(@"effectiveDate");
    vc.didPickupDateBlock = ^(NSString * _Nonnull beginStr) {
        self.beginTimeStr = beginStr;
        [self.tableView reloadData];
    };
    [self presentViewController:vc animated:YES completion:nil];
    
}
///点击时效图执行的事件。
- (void)tapEndTimelinessViewAction
{
    KDSDanPDatePickerVC *vc = [[KDSDanPDatePickerVC alloc] init];
    vc.endStr = self.endTimeStr;
    vc.titleStr = Localized(@"terminationDate");
    vc.didPickupDateBlock = ^(NSString * _Nonnull beginStr) {
        self.endTimeStr = beginStr;
        [self.tableView reloadData];
    };
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark  UITableViewDelegate 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        NSString *oneReuseId = NSStringFromClass([self class]);
        KDSDeviceTimingCell * oneCell = [tableView dequeueReusableCellWithIdentifier:oneReuseId];
        if (!oneCell)
        {
            oneCell = [[KDSDeviceTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:oneReuseId];
        }
        __weak typeof(self) weakSelf = self;
        oneCell.powerStateBtnDidChangeBlock = ^(UIButton * _Nonnull sender) {
//            [weakSelf switchClickSetNotificationMode:sender];
            NSLog(@"点击更改开关状态的按钮");
        };
        return oneCell;
    }
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.hideSeparator = YES;
    cell.title = self.titleArray[indexPath.section];
    switch (indexPath.section) {
        case 0:
            cell.subtitle = self.beginTimeStr ?: @"";
            cell.hideSwitch = YES;
            break;
        case 1:
            cell.subtitle = self.endTimeStr ?: @"";
            cell.hideSwitch = YES;
            break;
        case 2:
            cell.subtitle = self.ruleStr ?: @"不重复";
            cell.hideSwitch = YES;
            break;
        default:
            break;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            [self tapBeginTimelinessViewAction];
            break;
        case 1:
            [self tapEndTimelinessViewAction];
            break;
        case 2:
        {
            KDSWeekPickerVC * vc = [KDSWeekPickerVC new];
            vc.mask = self.mask;
            vc.didSelectWeekBlock = ^(char mask) {
                if (mask == 0x7f)
                {
                    self.ruleStr = Localized(@"everyday");
                }
                else
                {
                    NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
                    NSMutableString *ms = [NSMutableString string];
                    NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
                    for (int i = 0; i < 7; ++i)
                    {
                        !((mask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
                    }
                    if (ms.length < 1) {
                        self.ruleStr = @"不重复";
                    }else{
                        [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
                        self.ruleStr = ms;
                    }
                }
                self.mask = mask;
            };
            [self.navigationController pushViewController:vc animated:YES];
        
        }
            break;
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = [UIColor clearColor];
    return headView;
    
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
            b.rowHeight = 60;
            b.separatorStyle = UITableViewCellSeparatorStyleNone;
            b;
        });
    }
    return _tableView;
}

- (void)setMask:(char)mask
{
    _mask = mask;
    if (mask == 0x7f)
    {
        self.ruleStr = Localized(@"everyday");
    }
    else
    {
        NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
        NSMutableString *ms = [NSMutableString string];
        NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
        for (int i = 0; i < 7; ++i)
        {
            !((mask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
        }
        if (ms.length < 1) {
            self.ruleStr = @"不重复";
        }else{
            [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
            self.ruleStr = ms;
        }
    }
    [self.tableView reloadData];
}

@end

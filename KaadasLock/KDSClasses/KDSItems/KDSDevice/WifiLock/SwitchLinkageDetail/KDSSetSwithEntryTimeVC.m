//
//  KDSSetSwithEntryTimeVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/21.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSetSwithEntryTimeVC.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSTimelinessView.h"
#import "KDSDanPDatePickerVC.h"
#import "KDSWeekPickerVC.h"
#import "KDSDeviceTimingCell.h"
#import "KDSMQTTManager+SmartHome.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSDevSwithModel.h"

@interface KDSSetSwithEntryTimeVC ()<UITableViewDataSource, UITableViewDelegate>

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
///全天按钮
@property (nonatomic, strong) UIButton * timEnBtn;
///装开关按键设置的数组
@property (nonatomic, strong) NSMutableArray*stModels;
///对应的按钮的设置
@property (nonatomic, strong) NSMutableDictionary * switchArrayDict;
///单火开关基本信息
@property (nonatomic, strong) NSMutableArray * switchArray;

@end

@implementation KDSSetSwithEntryTimeVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"生效时间";
    self.titleArray = @[@"生效时间",@"结束时间",@"规则重复"];
    self.switchArrayDict[@"type"] = @(self.swithType.intValue);
    self.switchArrayDict[@"timeEn"] = @(1);
    self.switchArrayDict[@"week"] = @(127);
    NSArray * tempArr = self.lock.wifiDevice.switchDev[@"switchArray"];
    NSMutableArray * arr = [NSMutableArray arrayWithArray:tempArr];
    
    NSString * tempStartTime = arr[self.swithType.intValue-1][@"startTime"];
    NSString * tempEndTime = arr[self.swithType.intValue-1][@"stopTime"];
    self.beginTimeStr = [NSString stringWithFormat:@"%02d:%02d",tempStartTime.intValue/60,tempStartTime.intValue%60];
    self.endTimeStr = [NSString stringWithFormat:@"%02d:%02d",tempEndTime.intValue/60,tempEndTime.intValue%60];
    NSString * m = arr[self.swithType.intValue -1][@"week"];
    self.mask = m.intValue;
    
    self.switchArrayDict[@"startTime"] = @(tempStartTime.intValue);
    self.switchArrayDict[@"stopTime"] = @(tempEndTime.intValue);
    
    [self setUI];
}

-(void)setUI{
    
    UIView * topView = [UIView new];
    topView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(10);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    
    self.timEnBtn = [UIButton new];
    [self.timEnBtn setImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateNormal];
    [self.timEnBtn setImage:[UIImage imageNamed:@"on-powerStatusIcon"] forState:UIControlStateSelected];
    [self.timEnBtn addTarget:self action:@selector(timeEnChangeClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:self.timEnBtn];
    [self.timEnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView.mas_right).offset(-15);
        make.width.equalTo(@42);
        make.height.equalTo(@21);
        make.centerY.equalTo(topView);
    }];
    
    UILabel * tipsLb = [UILabel new];
    tipsLb.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    tipsLb.font = [UIFont systemFontOfSize:13];
    tipsLb.text = @"全天";
    tipsLb.textAlignment = NSTextAlignmentLeft;
    [topView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView);
        make.left.equalTo(topView.mas_left).offset(15);
        make.right.equalTo(self.timEnBtn.mas_left).offset(-10);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(0);
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
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.hideSeparator = YES;
    cell.title = self.titleArray[indexPath.section];
    if (self.timEnBtn.selected) {
        cell.containerView.backgroundColor = KDSRGBColor(238, 238, 238);
    }else{
        cell.containerView.backgroundColor = UIColor.whiteColor;
    }
    switch (indexPath.section) {
        case 0:
            cell.subtitle = self.beginTimeStr ?: @"";
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
            break;
        case 1:
            cell.subtitle = self.endTimeStr ?: @"";
            cell.hideSwitch = YES;
            cell.hideArrow = NO;
            break;
        case 2:
            cell.subtitle = @"每天"; //self.ruleStr ?: @"不重复";//需求暂时不修改重复日期，默认每天
            cell.hideSwitch = YES;
            cell.hideArrow = YES;
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
            /*
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
                self.lock.swithDevModel.mask = self.mask;
                self.switchArrayDict[@"week"] = @(self.mask);
            };
            [self.navigationController pushViewController:vc animated:YES];
             */
            
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

#pragma mark 点击事件
//保存
-(void)preserBtnClick:(UIButton *)sender
{
    if (self.timEnBtn.selected) {
        self.switchArrayDict[@"startTime"] = @(0);
        self.switchArrayDict[@"stopTime"] = @(1439);
    }else{
        
        BOOL result = [self.beginTimeStr compare:self.endTimeStr]==NSOrderedAscending;
        if (self.beginTimeStr.length == 0) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"生效时间不能为空" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertVC addAction:ok];
            [self presentViewController:alertVC animated:YES completion:nil];
            return;
        }if (self.endTimeStr.length == 0) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"结束时间不能为空" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertVC addAction:ok];
            [self presentViewController:alertVC animated:YES completion:nil];
            return;
        }
        if (!result) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"结束时间不能小于生效时间" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertVC addAction:ok];
            [self presentViewController:alertVC animated:YES completion:nil];
            return;
        }
    }
    
    [self.stModels removeAllObjects];
    [self.stModels addObject:self.switchArrayDict];
    
    self.switchArrayDict[@"nickname"] = self.lock.wifiDevice.switchDev[@"switchArray"][self.swithType.intValue-1][@"nickname"];
    [self.switchArray addObjectsFromArray:self.lock.wifiDevice.switchDev[@"switchArray"]];
    [self.switchArray replaceObjectAtIndex:self.swithType.intValue -1 withObject:self.switchArrayDict];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"switchEn":self.lock.wifiDevice.switchDev[@"switchEn"],@"switchArray":self.switchArray,@"mac":self.lock.wifiDevice.switchDev[@"mac"],@"updateTime":self.lock.wifiDevice.switchDev[@"updateTime"],@"total":self.lock.wifiDevice.switchDev[@"total"]}];
    !self.didSelectTimeBlock ?: self.didSelectTimeBlock(self.switchArrayDict[@"startTime"],self.switchArrayDict[@"stopTime"]);
    [self.navigationController popViewControllerAnimated:YES];
    
    /*
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"用手触碰按键区，唤醒门锁\n确保门锁数字键盘灯亮" toView:self.view];
    [[KDSMQTTManager sharedManager] setSwitchWithWf:self.lock.wifiDevice stParams:dict[@"switchArray"] switchEn:1 completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD show:@"设置成功" icon:@"showSuccessImg.png" view:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD show:@"设置失败，请重新设置" icon:@"showErrorIconImg.png" view:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
     */
    
}

///点击时效图执行的事件。
- (void)tapBeginTimelinessViewAction
{
    KDSDanPDatePickerVC *vc = [[KDSDanPDatePickerVC alloc] init];
    vc.beginStr = self.beginTimeStr;
    vc.titleStr = Localized(@"effectiveDate");
    __weak typeof(self) weakSelf = self;
    vc.didPickupDateBlock = ^(NSString * _Nonnull beginStr) {
        weakSelf.beginTimeStr = beginStr;
        NSArray *arr = [beginStr componentsSeparatedByString:@":"];
        if (arr.count == 2) {
            NSString * hour = arr[0];
            NSString * minute = arr[1];
            weakSelf.switchArrayDict[@"startTime"] = @(hour.intValue * 60 + minute.intValue);
        }
        [weakSelf.tableView reloadData];
    };
    [self presentViewController:vc animated:YES completion:nil];
    
}
///点击时效图执行的事件。
- (void)tapEndTimelinessViewAction
{
    KDSDanPDatePickerVC *vc = [[KDSDanPDatePickerVC alloc] init];
    vc.endStr = self.endTimeStr;
    vc.titleStr = Localized(@"terminationDate");
    __weak typeof(self) weakSelf = self;
    vc.didPickupDateBlock = ^(NSString * _Nonnull beginStr) {
        weakSelf.endTimeStr = beginStr;
        NSArray *arr = [beginStr componentsSeparatedByString:@":"];
        if (arr.count == 2) {
            NSString * hour = arr[0];
            NSString * minute = arr[1];
            weakSelf.switchArrayDict[@"stopTime"] = @(hour.intValue * 60 + minute.intValue);
        }
        [weakSelf.tableView reloadData];
    };
    [self presentViewController:vc animated:YES completion:nil];
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

#pragma mark 点击事件

///是否全天开启的按钮
-(void)timeEnChangeClick:(UIButton *)sender
{
    self.timEnBtn.selected = !self.timEnBtn.selected;
    if (self.timEnBtn.selected) {
        _tableView.allowsSelection = NO;
    }else{
        _tableView.allowsSelection = YES;
    }
    [self.tableView reloadData];
}

#pragma mark --Lzay load

- (NSMutableArray *)stModels
{
    if (!_stModels) {
        _stModels = [NSMutableArray array];
    }
    return _stModels;
}

- (NSMutableDictionary *)switchArrayDict
{
    if (!_switchArrayDict) {
        
        _switchArrayDict = [[NSMutableDictionary alloc] init];
    }
    return _switchArrayDict;
}
- (NSMutableArray *)switchArray
{
    if (!_switchArray) {
        _switchArray = [NSMutableArray array];
    }
    return _switchArray;
}

@end

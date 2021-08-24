//
//  KDSSwitchLinkageDetailVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSwitchLinkageDetailVC.h"
#import "KDSSingleSwithCell.h"
#import "KDSMQTTManager+SmartHome.h"
#import "KDSWifiLockFPDetailsVC.h"
#import "KDSAddSwitchVC.h"
#import "KDSSettingSwithVC.h"
#import "KDSSetSwithEntryTimeVC.h"
#import "KDSDevSwithModel.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSAddSwitchStep2VC.h"
#import "KDSHttpManager+WifiLock.h"

@interface KDSSwitchLinkageDetailVC ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate>

///表视图。
@property (nonatomic, strong) UITableView * tableView;
///table footer view, use for displaying no data.
@property (nonatomic, strong) UIView * footerView;
@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) NSMutableArray * dataSourceArr;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;
///开门联动智能开关(总开关控制)
@property (nonatomic, strong) UIButton * swithBtn;
///单火开关的设备模型
@property (nonatomic, strong) KDSDevSwithModel * stModel;
@property (nonatomic, strong) UIButton * executionBtn;
///单火开关的json数据(要设置的数据)
@property (nonatomic, strong)NSDictionary * tempSwitchDev;


@end

@implementation KDSSwitchLinkageDetailVC

#pragma mark - getter setter
- (NSMutableArray *)dataSourceArr
{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

- (UIView *)footerView
{
    if (!_footerView)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, KDSScreenHeight)];
        headerView.backgroundColor = UIColor.clearColor;
        
        UIView * natView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavBarHeight +kStatusBarHeight)];
        natView.backgroundColor = UIColor.whiteColor;
        [headerView addSubview:natView];
        
        UIView * line1 = [UIView new];
        line1.backgroundColor = KDSRGBColor(248, 248, 248);
        [natView addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@1);
            make.left.right.bottom.equalTo(natView);
        }];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
        [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [natView addSubview:backBtn];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = UIColor.blackColor;
        titleLabel.text = @"开关联动";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [natView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(natView).offset(kStatusBarHeight + 11);
            make.centerX.equalTo(natView);
            make.left.mas_equalTo(natView.mas_left).offset(50);
            make.right.mas_equalTo(natView.mas_right).offset(-50);
        }];
        
        UILabel *label = [UILabel new];
        label.textColor = KDSRGBColor(0x8e, 0x8e, 0x93);
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"您还没有配置智能开关";
        UILabel *label1 = [UILabel new];
        label1.textColor = KDSRGBColor(0x8e, 0x8e, 0x93);
        label1.font = [UIFont systemFontOfSize:12];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"添加智能开关后，门锁可打开联动";
        UIImageView * tipsImgView = [UIImageView new];
        tipsImgView.image = [UIImage imageNamed:@"noSwitchLinkageIconImg"];
        [headerView addSubview:tipsImgView];
        [headerView addSubview:label];
        [headerView addSubview:label1];
        [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(natView.mas_bottom).offset(31);
            make.width.equalTo(@175.5);
            make.height.equalTo(@118.5);
            make.centerX.equalTo(headerView);
            
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).offset(20);
            make.top.mas_equalTo(tipsImgView.mas_bottom).offset(30);
            make.right.equalTo(headerView).offset(-20);
            make.height.equalTo(@20);
        }];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).offset(20);
            make.top.mas_equalTo(label.mas_bottom).offset(1);
            make.right.equalTo(headerView).offset(-20);
            make.height.equalTo(@20);
            
        }];
        UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.backgroundColor = KDSRGBColor(31, 150, 247);
        addBtn.layer.cornerRadius = 22;
        addBtn.layer.masksToBounds = YES;
        [addBtn setImage:[UIImage imageNamed:@"addSwitchLinkageImg"] forState:UIControlStateNormal];
        [addBtn setTitle:@"添加智能开关" forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [addBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [addBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [addBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.centerX.equalTo(headerView);
            make.centerY.equalTo(headerView);
        }];
        _footerView = headerView;
    }
    return _footerView;
}

- (UIView *)headerView
{
    if (!_headerView) {
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 491.5)];
        headerView.backgroundColor = UIColor.clearColor;
        UIImageView * bgImgView = [UIImageView new];
        bgImgView.image = [UIImage imageNamed:@"singleSwithDetailBgImg"];
        [headerView addSubview:bgImgView];
        [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(headerView);
            make.height.equalTo(@341.5);
        }];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
        backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
        [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:backBtn];
        
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingBtn setImage:[UIImage imageNamed:@"singlieSwithsettingImg"] forState:UIControlStateNormal];
        settingBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        settingBtn.frame = CGRectMake(KDSScreenWidth-54, kStatusBarHeight, 44, 44);
        [settingBtn addTarget:self action:@selector(settingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:settingBtn];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.text = @"开关联动";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView).offset(kStatusBarHeight + 11);
            make.centerX.equalTo(headerView);
            make.left.mas_equalTo(headerView.mas_left).offset(50);
            make.right.mas_equalTo(headerView.mas_right).offset(-50);
        }];
        
        UIImageView * singleSwithIconImg = [UIImageView new];
        NSString * singleStImgName;
        if (self.dataSourceArr.count == 1) {
            singleStImgName = @"detailSingleKeyimg";
        }if (self.dataSourceArr.count == 2) {
            singleStImgName = @"detailTwoKeyIconimg";
        }if (self.dataSourceArr.count == 3) {
            singleStImgName = @"detailThreeKeyIconImg";
        }if (self.dataSourceArr.count == 4) {
            singleStImgName = @"detailFourKeyIconImg";
        }
        singleSwithIconImg.image = [UIImage imageNamed:singleStImgName];
        [headerView addSubview:singleSwithIconImg];
        [singleSwithIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bgImgView);
            make.centerY.equalTo(bgImgView.mas_centerY).offset(30);
            make.size.equalTo(@(singleSwithIconImg.image.size));
        }];
        
        UIView * devNameSupView = [UIView new];
        devNameSupView.backgroundColor = UIColor.clearColor;
        [headerView addSubview:devNameSupView];
        [devNameSupView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(singleSwithIconImg.mas_bottom).offset(10);
            make.height.equalTo(@20);
            make.centerX.equalTo(headerView);
            make.width.equalTo(@(singleSwithIconImg.image.size.width));
        }];
        
        for (int i = 0; i < self.dataSourceArr.count ; i ++) {
            UILabel * lb = [UILabel new];
            lb.text = [NSString stringWithFormat:@"键位%d",i+1];
            lb.textColor = UIColor.whiteColor;
            lb.font = [UIFont systemFontOfSize:13];
            lb.textAlignment = NSTextAlignmentCenter;
            [devNameSupView addSubview:lb];
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(devNameSupView).offset(i * (singleSwithIconImg.image.size.width/self.dataSourceArr.count));
                make.height.equalTo(@20);
                make.width.equalTo(@(singleSwithIconImg.image.size.width/self.dataSourceArr.count));
                make.bottom.equalTo(devNameSupView);
            }];
        }
        
        UIView * inkageIntelligentView = [UIView new];
        inkageIntelligentView.backgroundColor = UIColor.whiteColor;
        inkageIntelligentView.layer.masksToBounds = YES;
        inkageIntelligentView.layer.cornerRadius = 5;
        [headerView addSubview:inkageIntelligentView];
        [inkageIntelligentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgImgView.mas_bottom).offset(10);
            make.left.equalTo(headerView.mas_left).offset(10);
            make.right.equalTo(headerView.mas_right).offset(-10);
            make.height.equalTo(@90);
        }];
        
        UIImageView * lockImgIcon = [UIImageView new];
        lockImgIcon.image = [UIImage imageNamed:@"lockBindSwithIconImg"];
        [inkageIntelligentView addSubview:lockImgIcon];
        [lockImgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@35);
            make.left.equalTo(inkageIntelligentView).offset(5);
            make.top.equalTo(inkageIntelligentView).offset(10);
        }];
        UIImageView * addImgIcon = [UIImageView new];
        addImgIcon.image = [UIImage imageNamed:@"singleSwithSettingImgImg"];
        [inkageIntelligentView addSubview:addImgIcon];
        [addImgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@34);
            make.height.equalTo(@16);
            make.left.equalTo(lockImgIcon.mas_right).offset(5);
            make.top.equalTo(inkageIntelligentView).offset(22);
        }];
        UIImageView * singleSwithImgIcon = [UIImageView new];
        singleSwithImgIcon.image = [UIImage imageNamed:@"singleSwithIconImg"];
        [inkageIntelligentView addSubview:singleSwithImgIcon];
        [singleSwithImgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@35);
            make.left.equalTo(addImgIcon.mas_right).offset(5);
            make.top.equalTo(inkageIntelligentView).offset(10);
        }];
        
        UILabel * tipsLb = [UILabel new];
        tipsLb.text = @"开门联动智能开关";
        tipsLb.font = [UIFont systemFontOfSize:12];
        tipsLb.textColor = KDSRGBColor(111, 111, 111);
        tipsLb.textAlignment = NSTextAlignmentLeft;
        [inkageIntelligentView addSubview:tipsLb];
        [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(inkageIntelligentView.mas_left).offset(12);
            make.bottom.equalTo(inkageIntelligentView.mas_bottom).offset(-12);
            make.height.equalTo(@20);
        }];
        self.swithBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.swithBtn setImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateNormal];
        [self.swithBtn setImage:[UIImage imageNamed:@"on-powerStatusIconGreenImg"] forState:UIControlStateSelected];
        [self.swithBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        NSString * switchEn = self.lock.wifiDevice.switchDev[@"switchEn"];
        self.swithBtn.selected = switchEn.intValue == 0 ? NO : YES;
        [inkageIntelligentView addSubview:self.swithBtn];
        [self.swithBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@42);
            make.height.equalTo(@21);
            make.right.equalTo(inkageIntelligentView.mas_right).offset(-19);
            make.centerY.equalTo(inkageIntelligentView);
        }];
        
        UILabel * swithtipsLabel = [UILabel new];
        swithtipsLabel.font = [UIFont systemFontOfSize:14];
        swithtipsLabel.textAlignment = NSTextAlignmentLeft;
        swithtipsLabel.text = @"联动的智能开关";
        swithtipsLabel.textColor = [UIColor blackColor];
        [headerView addSubview:swithtipsLabel];
        [swithtipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@20);
            make.left.equalTo(headerView).offset(20);
            make.top.equalTo(inkageIntelligentView.mas_bottom).offset(20);
        }];
        _headerView = headerView;
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self setupUI];
    [self refreshDataSource];
    self.isRefreshPage = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    if (self.isRefreshPage) {
        [self refreshDataSource];
        self.isRefreshPage = NO;
    }
}

-(void)refreshDataSource
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
       [[KDSHttpManager sharedManager] getSwitchInfoWithWifiSN:self.lock.wifiDevice.wifiSN userUid:[KDSUserManager sharedManager].user.uid success:^(NSDictionary * _Nonnull obj) {
           [hud hideAnimated:YES];
           NSDictionary * switchDev = obj[@"switch"];
           self.lock.wifiDevice.switchDev = switchDev;
           NSArray * switchArray = self.lock.wifiDevice.switchDev[@"switchArray"];
           if (switchArray.count >0) {
               [self.dataSourceArr removeAllObjects];
           }
           NSString * switchEn = self.lock.wifiDevice.switchDev[@"switchEn"];
           self.swithBtn.selected = switchEn.intValue == 0 ? NO : YES;
           self.tempSwitchDev = nil;
           [self.dataSourceArr addObjectsFromArray:switchArray];
           [self reloadData];
           
       } error:^(NSError * _Nonnull error) {
           [hud hideAnimated:YES];
           [self.dataSourceArr removeAllObjects];
           [self reloadData];
       } failure:^(NSError * _Nonnull error) {
           [hud hideAnimated:YES];
           [self.dataSourceArr removeAllObjects];
           [self reloadData];
       }];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}

- (void)setupUI
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 95;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 5;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight > 667 ? -60 : -50);
    }];
    self.executionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.executionBtn setTitle:@"确定执行" forState:UIControlStateNormal];
    [self.executionBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.executionBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    self.executionBtn.hidden = YES;
    [self.executionBtn addTarget:self action:@selector(executionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.executionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.executionBtn];
    [self.executionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(KDSScreenHeight > 667 ? @60 : @45);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
}

///刷新表视图。调用此方法前请确保已经对数据源进行了更新。
- (void)reloadData
{
    if (!self.dataSourceArr.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.tableFooterView = self.footerView;
            self.tableView.tableHeaderView = [UIView new];
            self.executionBtn.hidden = YES;
        });
    }else
    {
        self.tableView.tableFooterView = [UIView new];
        self.tableView.tableHeaderView = self.headerView;
        self.executionBtn.hidden  = NO;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSSingleSwithCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSSingleSwithCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSString * tempName = self.dataSourceArr[indexPath.row][@"nickname"];
    cell.singleSwithNameLb.text = tempName.length >0 ? tempName :
    [NSString stringWithFormat:@"键位%d",indexPath.row+1];
    NSString * cellStBtnStatuse = self.dataSourceArr[indexPath.row][@"timeEn"];
    cell.singleSwithBtn.selected = cellStBtnStatuse.intValue == 0 ? NO : YES;
    cell.tag = indexPath.row;
    NSString * startTime = self.dataSourceArr[indexPath.row][@"startTime"];
    NSString * endTime = self.dataSourceArr[indexPath.row][@"stopTime"];
    cell.timeLb.text = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%02d:%02d",startTime.intValue/60,startTime.intValue%60],[NSString stringWithFormat:@"%02d:%02d",endTime.intValue/60,endTime.intValue%60]];
     __weak typeof(self) weakSelf = self;
    cell.selectedBtnClickBlock = ^{
        NSLog(@"更改了单火开关的状态");
        NSMutableDictionary * switchArrayDict = [[NSMutableDictionary alloc] initWithDictionary:weakSelf.dataSourceArr[indexPath.row]];
        int tempTimeEn;
        NSString * ttt = weakSelf.dataSourceArr[indexPath.row][@"timeEn"];
        if(ttt.intValue == 0){
            tempTimeEn = 1;
        }else{
            tempTimeEn = 0;
        }
        [switchArrayDict setObject:@(tempTimeEn) forKey:@"timeEn"];
        [switchArrayDict setObject:@(127) forKey:@"week"];
        [weakSelf.dataSourceArr replaceObjectAtIndex:indexPath.row withObject:switchArrayDict];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSSetSwithEntryTimeVC * vc = [KDSSetSwithEntryTimeVC new];
    vc.lock = self.lock;
    vc.stModel = self.stModel;
    __weak typeof(self) weakSelf = self;
    vc.didSelectTimeBlock = ^(NSString * _Nonnull startTime, NSString * _Nonnull stopTime) {
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] initWithDictionary:weakSelf.dataSourceArr[indexPath.row]];
        tempDict[@"startTime"] = startTime;
        tempDict[@"stopTime"] = stopTime;
        tempDict[@"week"] = @(127);
        NSLog(@"当前字典的值%@",tempDict);
        [weakSelf.dataSourceArr replaceObjectAtIndex:indexPath.row withObject:tempDict];
        [self.tableView reloadData];
    };
    vc.swithType = [NSString stringWithFormat:@"%d",indexPath.row +1];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark 点击事件

///去添加单火开关
-(void)addBtnClick:(UIButton *)btn
{
    KDSAddSwitchVC * vc = [KDSAddSwitchVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

///右上角的设置按钮
-(void)settingBtnAction:(UIButton *)btn
{
    KDSSettingSwithVC * vc = [KDSSettingSwithVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///开门联动智能开关(总开关控制)
-(void)switchBtnClick:(UIButton *)btn
{
    self.swithBtn.selected = !self.swithBtn.selected;
}

///确定执行
-(void)executionBtnClick:(UIButton *)sender
{
    for (id obj in self.dataSourceArr) {
        NSString * tempStopTime = obj[@"stopTime"];
        if (tempStopTime.intValue == 0) {
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"你还没有设置生效时段，\n请重新设置" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"good") style:UIAlertActionStyleDefault handler:nil];
            [alerVC addAction:action];
            [self presentViewController:alerVC animated:YES completion:nil];
            return;
        }
    }
    int switchEn = self.swithBtn.selected == YES ? 1 : 0;
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"switchArray":self.dataSourceArr,@"switchEn":@(switchEn),@"mac":self.lock.wifiDevice.switchDev[@"mac"],@"total":self.lock.wifiDevice.switchDev[@"total"],@"createTime":self.lock.wifiDevice.switchDev[@"createTime"],@"updateTime":self.lock.wifiDevice.switchDev[@"updateTime"]}];
    self.tempSwitchDev = dict;
    KDSAddSwitchStep2VC * vc = [KDSAddSwitchStep2VC new];
    vc.lock = self.lock;
    vc.tempSwitchDev = self.tempSwitchDev;
    vc.actionSting = @"SetSwitch";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[KDSSwitchLinkageDetailVC class]]) {
         [navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

@end

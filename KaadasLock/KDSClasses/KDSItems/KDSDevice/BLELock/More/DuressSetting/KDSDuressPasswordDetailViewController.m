//
//  KDSDuressPasswordDetailViewController.m
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSDuressPasswordDetailViewController.h"
#import "KDSDuressAlarmCell.h"
#import "KDSDuressPasswordCell.h"
#import "KDSDuressSettingAccountController.h"
#import "KDSDuressAlarmHub.h"
#import "KDSHttpManager+WifiLock.h"


@interface KDSDuressPasswordDetailViewController ()<UITableViewDelegate,UITableViewDataSource,KDSDuressAlarmHubDelegate>

//开锁方式主UITableView
@property (nonatomic, strong) UITableView *tableView;

//数据源
@property (nonatomic, strong) NSArray *dataArr;

//蒙板
@property (nonatomic, strong) UIView *maskView;

//提示框
@property (nonatomic, strong) KDSDuressAlarmHub *duressAlarmHub;

@property (nonatomic, assign) BOOL isAlarmOpen;

@end

@implementation KDSDuressPasswordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化主视图
    [self setupMainView];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //刷新数据列表
    [self loadPwdbListData];
}

#pragma mark - 初始化主界面
-(void) setupMainView{
    
    self.navigationTitleLabel.text = @"设置胁迫密码";
    self.view.backgroundColor = KDSRGBColor(248, 248, 248);

    //设置右Button 胁迫报警提示
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"philips_icon_help"] forState:UIControlStateNormal];
    
    //初始化UITableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = KDSRGBColor(248, 248, 248);
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - 修改胁迫报警属性接口
-(void) loadNewData:(int)index{

    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSHttpManager sharedManager] setDuressAlarmSinglePwdSwitchWithUid:[KDSUserManager sharedManager].user.uid WifiSN:self.lock.wifiDevice.wifiSN PwdType:self.model.pwdType Num:self.model.num.intValue PwdDuressSwitch:index success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        [self loadPwdbListData];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark - loading密码、指纹、卡片 密码列表数据
- (void)loadPwdbListData
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    
    [[KDSHttpManager sharedManager] getWifiLockPwdListWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdList, NSArray<KDSPwdListModel *> * _Nonnull fingerprintList, NSArray<KDSPwdListModel *> * _Nonnull cardList, NSArray<KDSPwdListModel *> * _Nonnull faceList, NSArray<KDSPwdListModel *> * _Nonnull pwdNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull cardNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull faceNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull pwdDuressArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintDuressArr) {
        
        //停止菊花转动
        [hud hideAnimated:YES];
        
        if (self.accountType == 1) {//密码列表
            [self updatePwdListDataSource:pwdList PwdDuressArr:pwdDuressArr];
        }else{
            [self updatePwdListDataSource:fingerprintList PwdDuressArr:fingerprintDuressArr];
        }
        
        //刷新列表
        [self.tableView reloadData];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark - 更新数据 -- 密码列表
-(void) updatePwdListDataSource:(NSArray *) pwdListArr PwdDuressArr:(NSArray *)duressArr{
    
    //填充数据--密码列表
    for (NSInteger i=0; i< duressArr.count; i++) {
        KDSPwdListModel *duressModel = duressArr[i];
        if ([duressModel.num isEqualToString:self.model.num]) {
            self.model.pwdDuressSwitch = duressModel.pwdDuressSwitch;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2) {
        return 100;
    }else{
        return 65;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        
        return 40;
    }else{
        
        return 15;;
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.model.pwdDuressSwitch == 1) {
        return 3;
    }else{
        return 1;
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
        headerView.backgroundColor = self.view.backgroundColor;
        
        //显示密码类型
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = @"接收胁迫报警消息";
        [headerView addSubview:titleLabel];
        
        return headerView;
    }else{
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 15)];
        headerView.backgroundColor = self.view.backgroundColor;
        
        return headerView;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        
        static NSString *cellId = @"KDSDuressAlarmCell";
        KDSDuressAlarmCell *cell = (KDSDuressAlarmCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"KDSDuressAlarmCell" owner:nil options:nil];
            cell = [nibArr objectAtIndex:0];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        if (indexPath.section == 0) {
            cell.markImageView.hidden = YES;
            cell.alarmSwitch.hidden = NO;
            cell.titleLabel.text = self.dataArr[indexPath.row];
            cell.subtitleLabel.text = @"开启后，输入密码或指纹，APP实时接收报警信息";
            cell.alarmSwitch.on = self.model.pwdDuressSwitch;
            [cell.alarmSwitch addTarget:self action:@selector(alarmSwitchClick:) forControlEvents:UIControlEventValueChanged];
        }else{
            cell.markImageView.hidden = NO;
            cell.alarmSwitch.hidden = YES;
            cell.titleLabel.text = @"APP接收";
            cell.subtitleLabel.text = @"APP实时推送胁迫报警消息";
        }
        
        return cell;
    }else{
        
        static NSString *cellIdOne = @"KDSDuressPasswordCell";
        KDSDuressPasswordCell *cellOne = (KDSDuressPasswordCell *)[tableView dequeueReusableCellWithIdentifier:cellIdOne];
        if (!cellOne) {
            NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"KDSDuressPasswordCell" owner:nil options:nil];
            cellOne = [nibArr objectAtIndex:0];
            cellOne.backgroundColor = [UIColor whiteColor];
            cellOne.selectionStyle = UITableViewCellSelectionStyleNone;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        cellOne.markImageView.hidden = YES;
        cellOne.alarmTypeLabel.text = @"添加时间";
        cellOne.nameLabel.text = [NSString stringWithFormat:@"编号%02d",self.model.num.intValue] ?: @"";
        cellOne.alarmStatusLabel.text = [KDSTool timeStringYYMMDDFromTimestamp:[NSString stringWithFormat:@"%f",self.model.createTime]] ?: @"";

        return cellOne;
    }
}

#pragma mark - UITableView 点击代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
    
        KDSDuressSettingAccountController *settingAccountVC = [KDSDuressSettingAccountController new];
        settingAccountVC.lock = self.lock;
        settingAccountVC.model = self.model;
        [self.navigationController pushViewController:settingAccountVC animated:YES];
    }
}

#pragma mark - 顶部导航栏右Button点击事件
-(void) navRightClick{
    
    [self showContactView];
}

#pragma mark - 顶部胁迫报警开关按钮
-(void) alarmSwitchClick:(UISwitch *)sender{
    
    //提交数据
    [self loadNewData:sender.on ? 1 : 0];
}

#pragma mark - KDSDuressAlarmHub显示视图
-(void)showContactView{
    
    [_maskView removeFromSuperview];
    [_duressAlarmHub removeFromSuperview];
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _maskView.alpha = 0.5;
    _maskView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    
    _duressAlarmHub = [[KDSDuressAlarmHub alloc] initWithFrame:CGRectMake(15, kNavBarHeight + kStatusBarHeight, kScreenWidth-30, kScreenHeight - kNavBarHeight - kStatusBarHeight)];
    _duressAlarmHub.backgroundColor = [UIColor clearColor];
    _duressAlarmHub.duressAlarmHubDelegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:_duressAlarmHub];
}

#pragma mark - KDSDuressAlarmHub删除视图
-(void)dismissContactView
{
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.maskView removeFromSuperview];
        [weakSelf.duressAlarmHub removeFromSuperview];
    }];
}

#pragma mark -KDSDuressAlarmHub代理事件
-(void) removeDuressAlarmHub{
    
    [self dismissContactView];
}

#pragma mark - 懒加载

-(NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[@"胁迫报警"];
    }
    
    return _dataArr;
}


@end

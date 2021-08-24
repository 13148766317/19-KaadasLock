//
//  KDSDuressPasswordViewController.m
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/12.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSDuressPasswordViewController.h"
#import "KDSDuressAlarmCell.h"
#import "KDSDuressPasswordCell.h"
#import "KDSDuressPasswordDetailViewController.h"
#import "KDSPwdListModel.h"
#import "KDSHttpManager+WifiLock.h"

@interface KDSDuressPasswordViewController ()<UITableViewDelegate,UITableViewDataSource>

//开锁方式主UITableView
@property (nonatomic, strong) UITableView *tableView;

//数据源
@property (nonatomic, strong) NSArray *dataArr;

//密码类型数据源
@property (nonatomic, strong) NSArray *passworTpypeDataArr;

//胁迫报警总开关标志
//@property (nonatomic, assign) BOOL isDuressOpen;

//列表数组
@property (nonatomic, strong) NSMutableArray *pwdDataSourceArr;

//指纹数组列表
@property (nonatomic, strong) NSMutableArray *fingerprintDataSourceArr;


@end

@implementation KDSDuressPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化主视图
    [self setupMainView];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadNewData];
}

#pragma mark - 初始化主界面
-(void) setupMainView{
    
    //self.isDuressOpen = YES;
    self.navigationTitleLabel.text = @"胁迫报警";
    self.view.backgroundColor = KDSRGBColor(248, 248, 248);
    
    //初始化UITableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, kScreenHeight- kNavBarHeight - kStatusBarHeight - 15) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = KDSRGBColor(248, 248, 248);
    tableView.estimatedRowHeight = 0;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - loading密码、指纹、卡片 密码列表数据
- (void)loadNewData
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSHttpManager sharedManager] getWifiLockPwdListWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdList, NSArray<KDSPwdListModel *> * _Nonnull fingerprintList, NSArray<KDSPwdListModel *> * _Nonnull cardList, NSArray<KDSPwdListModel *> * _Nonnull faceList, NSArray<KDSPwdListModel *> * _Nonnull pwdNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull cardNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull faceNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull pwdDuressArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintDuressArr) {
        
        //停止菊花转动
        [hud hideAnimated:YES];
        
        //处理密码列表数据
        [self updatePwdListDataSource:pwdList PwdDuressArr:pwdDuressArr];
        
        //处理指纹密码列表
        [self updateFingerPrintListDataSource:fingerprintList FingerPrintDuressArr:fingerprintDuressArr];
        
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
    
    //清空数据源
    [self.pwdDataSourceArr removeAllObjects];
    
    //填充数据--密码列表
    for (NSInteger i=0; i< pwdListArr.count; i++) {
        
        //最终添加到数组的对象
        KDSPwdListModel *endModel = [KDSPwdListModel new];
        
        KDSPwdListModel *pwdListModel = pwdListArr[i];
        endModel.num = pwdListModel.num;
        endModel.createTime = pwdListModel.createTime;
        endModel.pwdType = pwdListModel.pwdType;
        for (NSInteger j=0; j< duressArr.count; j++) {
            KDSPwdListModel *duressListModel = duressArr[j];
            if ([pwdListModel.num isEqualToString:duressListModel.num]) {
                endModel.pwdDuressSwitch = duressListModel.pwdDuressSwitch ?: 0;;
                endModel.duressAlarmAccount = duressListModel.duressAlarmAccount ?: @"";
                break;
            }
        }
        
        [self.pwdDataSourceArr addObject:endModel];
    }
}

#pragma mark - 更新数据 -- 指纹列表
-(void) updateFingerPrintListDataSource:(NSArray *) pingerPrintListArr FingerPrintDuressArr:(NSArray *)duressArr{
    
    //清空数据源
    [self.fingerprintDataSourceArr removeAllObjects];
    
    //填充数据--指纹列表
    for (NSInteger i=0; i< pingerPrintListArr.count; i++) {
        
        //最终添加到数组的对象
        KDSPwdListModel *endModel = [KDSPwdListModel new];
        
        KDSPwdListModel *pingerPrintListModel = pingerPrintListArr[i];
        endModel.num = pingerPrintListModel.num;
        endModel.createTime = pingerPrintListModel.createTime;
        endModel.pwdType = pingerPrintListModel.pwdType;
        for (NSInteger j=0; j< duressArr.count; i++) {
            KDSPwdListModel *duressModel = duressArr[j];
            if ([pingerPrintListModel.num isEqualToString:duressModel.num]) {
                endModel.pwdDuressSwitch = duressModel.pwdDuressSwitch ?: 0;;
                endModel.duressAlarmAccount = duressModel.duressAlarmAccount ?: @"";
                break;
            }
        }
        
        [self.fingerprintDataSourceArr addObject:endModel];
    }
}

#pragma mark - 设置胁迫报警总开关接口
-(void) setupDuressSwitch:(int) index{
    
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSHttpManager sharedManager] setDuressAlarmSwitchWithUid:[KDSUserManager sharedManager].user.uid WifiSN:self.lock.wifiDevice.wifiSN DuressAlarmSwitch:index success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //更新本地缓存数据
        strongSelf.lock.wifiDevice.duressAlarmSwitch = index;
        
        //刷新数据
        if (self.lock.wifiDevice.duressAlarmSwitch == 1) {
            _passworTpypeDataArr = @[@"",@"密码",@"指纹"];
        }else{
            _passworTpypeDataArr = @[@""];
        }
        
        [self.tableView reloadData];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count >0) {
        if (indexPath.section == 0) {//65,100,140  头部胁迫报警总开关
            return 65;
        }else if (indexPath.section == 1){//密码列表
            KDSPwdListModel *pwdModel = self.pwdDataSourceArr[indexPath.row];
            if (pwdModel.pwdDuressSwitch == 1) {
                return 140;
            }else{
                return 100;
            }
        }else{//指纹列表
            KDSPwdListModel *fingerPrintModel = self.fingerprintDataSourceArr[indexPath.row];
            if (fingerPrintModel.pwdDuressSwitch == 1) {
                return 140;
            }else{
                return 100;
            }
        }
    }else if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count <= 0){
        if (indexPath.section == 0) {
            return 65;
        }else{
            KDSPwdListModel *pwdModel = self.pwdDataSourceArr[indexPath.row];
            if (pwdModel.pwdDuressSwitch == 1) {
                return 140;
            }else{
                return 100;
            }
        }
    }else if (self.pwdDataSourceArr.count <= 0 && self.fingerprintDataSourceArr.count > 0){
        if (indexPath.section == 0) {
            return 65;
        }else{
            KDSPwdListModel *fingerprintModel = self.fingerprintDataSourceArr[indexPath.row];
            if (fingerprintModel.pwdDuressSwitch == 1) {
                return 140;
            }else{
                return 100;
            }
        }
    }else{
        return 65;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        return 0.01;
    }else{
        return 40;
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.lock.wifiDevice.duressAlarmSwitch == 1) {
        if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count > 0) {
            return 3;
        }else if (self.pwdDataSourceArr.count > 0 || self.fingerprintDataSourceArr.count > 0){
            return 2;
        }else{
            return 1;
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count >0) {
        if (section == 0) {
            return 1;
        }else if (section == 1){
            return self.pwdDataSourceArr.count;
        }else{
            return self.fingerprintDataSourceArr.count;
        }
    }else if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count <= 0){
        if (section == 0) {
            return 1;
        }else if (section == 1){
            return self.pwdDataSourceArr.count;
        }
    }else if (self.pwdDataSourceArr.count <= 0 && self.fingerprintDataSourceArr.count > 0){
        if (section == 0) {
            return 1;
        }else if (section == 1){
            return self.fingerprintDataSourceArr.count;
        }
    }
    
    return 1;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = self.view.backgroundColor;
    
    //显示密码类型
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count >0) {
        titleLabel.text = self.passworTpypeDataArr[section];
    }else if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count <= 0){
        if (section == 0) {
            titleLabel.text = @"";
        }else if (section == 1){
            titleLabel.text = @"密码";
        }
    }else if (self.pwdDataSourceArr.count <= 0 && self.fingerprintDataSourceArr.count > 0){
        if (section == 0) {
            titleLabel.text = @"";
        }else if (section == 1){
            titleLabel.text = @"指纹";
        }
    }else{
        titleLabel.text = @"";
    }

    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        static NSString *cellId = @"KDSDuressAlarmCell";
        KDSDuressAlarmCell *cell = (KDSDuressAlarmCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"KDSDuressAlarmCell" owner:nil options:nil];
            cell = [nibArr objectAtIndex:0];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        cell.markImageView.hidden = YES;
        cell.titleLabel.text = self.dataArr[indexPath.row];
        cell.subtitleLabel.text = @"开启后，输入指纹APP实时接收报警信息";
        if (self.lock.wifiDevice.duressAlarmSwitch == 1) {
            cell.alarmSwitch.on = YES;
        }else{
            cell.alarmSwitch.on = NO;
        }
        [cell.alarmSwitch addTarget:self action:@selector(duressAlarmSwitch:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }else{
        if (self.pwdDataSourceArr.count > 0 || self.fingerprintDataSourceArr.count > 0) {
            
            static NSString *cellIdOne = @"KDSDuressPasswordCell";
            KDSDuressPasswordCell *cellOne = (KDSDuressPasswordCell *)[tableView dequeueReusableCellWithIdentifier:cellIdOne];
            if (!cellOne) {
                NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:@"KDSDuressPasswordCell" owner:nil options:nil];
                cellOne = [nibArr objectAtIndex:0];
                cellOne.backgroundColor = [UIColor whiteColor];
                cellOne.selectionStyle = UITableViewCellSelectionStyleNone;
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
            if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count >0) {
                KDSPwdListModel *pwdModel = nil;
                if (indexPath.section == 1) {
                    pwdModel = self.pwdDataSourceArr[indexPath.row];
                    //分割线
                    if (indexPath.row == self.pwdDataSourceArr.count -1) {
                        cellOne.lineView.hidden = YES;
                    }else{
                        cellOne.lineView.hidden = NO;
                    }
                }else{
                    pwdModel = self.fingerprintDataSourceArr[indexPath.row];
                    //分割线
                    if (indexPath.row == self.fingerprintDataSourceArr.count -1) {
                        cellOne.lineView.hidden = YES;
                    }else{
                        cellOne.lineView.hidden = NO;
                    }
                }
                    
                cellOne.nameLabel.text = [NSString stringWithFormat:@"%02d",pwdModel.num.intValue];
                cellOne.alarmTypeLabel.text = @"胁迫报警";
                if (pwdModel.pwdDuressSwitch == 1) {
                    cellOne.alarmStatusLabel.text = @"开启";
                    cellOne.alarmNumberTitleLabel.text = @"报警通知";
                    //胁迫报警账号
                    NSString *accountStr = nil;
                    if (pwdModel.duressAlarmAccount.length == 11) {
                        accountStr = [pwdModel.duressAlarmAccount stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    }else if (pwdModel.duressAlarmAccount.length == 13){
                        accountStr = [pwdModel.duressAlarmAccount stringByReplacingCharactersInRange:NSMakeRange(5, 4) withString:@"****"];
                    }else{
                        accountStr = pwdModel.duressAlarmAccount;
                    }
                    cellOne.alarmNumberLabel.text = accountStr;
                }else{
                    cellOne.alarmStatusLabel.text = @"关闭";
                    cellOne.alarmNumberTitleLabel.text = @"";
                    cellOne.alarmNumberLabel.text = @"";
                }
            }else if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count <= 0){
                KDSPwdListModel *pwdModel = self.pwdDataSourceArr[indexPath.row];
                cellOne.nameLabel.text = [NSString stringWithFormat:@"%02d",pwdModel.num.intValue];
                cellOne.alarmTypeLabel.text = @"胁迫报警";
                if (pwdModel.pwdDuressSwitch == 1) {
                    cellOne.alarmStatusLabel.text = @"开启";
                    cellOne.alarmNumberTitleLabel.text = @"报警通知";
            
                    //胁迫报警账号
                    NSString *accountStr = nil;
                    if (pwdModel.duressAlarmAccount.length == 11) {
                        accountStr = [pwdModel.duressAlarmAccount stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    }else if (pwdModel.duressAlarmAccount.length == 13){
                        accountStr = [pwdModel.duressAlarmAccount stringByReplacingCharactersInRange:NSMakeRange(5, 4) withString:@"****"];
                    }else{
                        accountStr = pwdModel.duressAlarmAccount;
                    }
                    cellOne.alarmNumberLabel.text = accountStr;
                }else{
                    cellOne.alarmStatusLabel.text = @"关闭";
                    cellOne.alarmNumberTitleLabel.text = @"";
                    cellOne.alarmNumberLabel.text = @"";
                }
                //分割线
                if (indexPath.row == self.pwdDataSourceArr.count -1) {
                    cellOne.lineView.hidden = YES;
                }else{
                    cellOne.lineView.hidden = NO;
                }
            }else if (self.pwdDataSourceArr.count <= 0 && self.fingerprintDataSourceArr.count > 0){
                KDSPwdListModel *fingerprintModel = self.fingerprintDataSourceArr[indexPath.row];
                cellOne.nameLabel.text = [NSString stringWithFormat:@"%02d",fingerprintModel.num.intValue];
                cellOne.alarmTypeLabel.text = @"胁迫报警";
                if (fingerprintModel.pwdDuressSwitch == 1) {
                    cellOne.alarmStatusLabel.text = @"开启";
                    cellOne.alarmNumberTitleLabel.text = @"报警通知";
                    //胁迫报警账号
                    NSString *accountStr = nil;
                    if (fingerprintModel.duressAlarmAccount.length == 11) {
                        accountStr = [fingerprintModel.duressAlarmAccount stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    }else if (fingerprintModel.duressAlarmAccount.length == 13){
                        accountStr = [fingerprintModel.duressAlarmAccount stringByReplacingCharactersInRange:NSMakeRange(5, 4) withString:@"****"];
                    }else{
                        accountStr = fingerprintModel.duressAlarmAccount;
                    }
                    cellOne.alarmNumberLabel.text = accountStr;
                }else{
                    cellOne.alarmStatusLabel.text = @"关闭";
                    cellOne.alarmNumberTitleLabel.text = @"";
                    cellOne.alarmNumberLabel.text = @"";
                }
                //分割线
                if (indexPath.row == self.fingerprintDataSourceArr.count -1) {
                    cellOne.lineView.hidden = YES;
                }else{
                    cellOne.lineView.hidden = NO;
                }
            }
            
            return cellOne;
        }
        
        return nil;
    }
}

#pragma mark - UITableView 点击代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section !=0) {
        
        KDSDuressPasswordDetailViewController *passwordDetailVC = [KDSDuressPasswordDetailViewController new];
        passwordDetailVC.lock = self.lock;
        
        if (self.pwdDataSourceArr.count > 0 && self.fingerprintDataSourceArr.count > 0) {
            if (indexPath.section == 1) {
                passwordDetailVC.model = self.pwdDataSourceArr[indexPath.row];
                passwordDetailVC.accountType = 1;
            }else{
                passwordDetailVC.model = self.fingerprintDataSourceArr[indexPath.row];
                passwordDetailVC.accountType = 2;
            }
        }else if (self.pwdDataSourceArr.count >0 && self.fingerprintDataSourceArr.count <= 0){
            passwordDetailVC.model = self.pwdDataSourceArr[indexPath.row];
            passwordDetailVC.accountType = 1;
        }else if (self.pwdDataSourceArr.count <= 0 && self.fingerprintDataSourceArr.count > 0){
            passwordDetailVC.model = self.fingerprintDataSourceArr[indexPath.row];
            passwordDetailVC.accountType = 2;
        }
        
        [self.navigationController pushViewController:passwordDetailVC animated:YES];
    }
}

#pragma mark - 胁迫密码开关
-(void) duressAlarmSwitch:(UISwitch *)btn{
    
    //同步数据
    [self setupDuressSwitch:btn.on ? 1 : 0];
}

#pragma mark - 懒加载

-(NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[@"胁迫报警"];
    }
    
    return _dataArr;
}

-(NSArray *)passworTpypeDataArr{
    if (!_passworTpypeDataArr) {
        _passworTpypeDataArr = @[@"",@"密码",@"指纹"];
    }
    
    return _passworTpypeDataArr;
}

-(NSMutableArray *)pwdDataSourceArr{
    if (!_pwdDataSourceArr) {
        _pwdDataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _pwdDataSourceArr;
}

-(NSMutableArray *)fingerprintDataSourceArr{
    if (!_fingerprintDataSourceArr) {
        _fingerprintDataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _fingerprintDataSourceArr;
}

@end

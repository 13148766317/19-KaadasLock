//
//  KDSDoorbellSettingVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDoorbellSettingVC.h"
#import "KDSDBManager+CY.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "KDSCateyeMoreCell.h"


@interface KDSDoorbellSettingVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,readwrite,strong)NSMutableArray * dataSourceArr;
@property (nonatomic,readwrite,strong)UITableView * tableView;
///当前铃声
@property(nonatomic,assign)NSUInteger currentIndex;
///选中铃声
@property(nonatomic,assign)NSNumber* currentDoorbell;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;

@end

@implementation KDSDoorbellSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setDataArray];
    _currentIndex= [[KDSDBManager sharedManager] getBellSelectWithDeviceID:self.cateyeParam.deviceId].integerValue;
    _currentDoorbell = @(_currentIndex);
    self.navigationTitleLabel.text = Localized(@"RingTone");
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.saveBtn];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_offset(0);
        make.height.mas_equalTo(self.dataSourceArr.count * 60);
    }];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}
-(void)setDataArray
{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    for (int i = 1; i<= self.maxBellNuml; i++) {
        [_dataSourceArr addObject:[NSString stringWithFormat:@"%@%d",Localized(@"RingTone"),i]];
    }
}
#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.maxBellNuml;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    cell.titleNameLb.text = self.dataSourceArr[indexPath.row];
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(doorBellClick:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == _currentIndex) {
        cell.selectBtn.selected = YES;
    }
    else{
        cell.selectBtn.selected = NO;
    }
    return cell;
}

#pragma mark 手势

-(void)doorBellClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [KDSUserDefaults setObject:[NSString stringWithFormat:@"%ld",sender.tag] forKey:[NSString stringWithFormat:@"%@-%@",DoorBellSelect,self.cateye.gatewayDeviceModel.deviceId]];
    _currentIndex = sender.tag;
    [self.tableView reloadData];
    _currentDoorbell = @(sender.tag);
  
}

-(void)saveBtnClick:(UIButton *)sender
{
    [self setDoorBell];
}

-(void)setDoorBell{
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] cy:self.cateye.gatewayDeviceModel setBell:(int)_currentDoorbell completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [[KDSDBManager sharedManager] updatBellSelect:[NSString stringWithFormat:@"%@",_currentDoorbell] deviceID:self.cateye.gatewayDeviceModel.deviceId];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
}

#pragma mark -- lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [tv registerClass:[KDSCateyeMoreCell class] forCellReuseIdentifier:KDSCateyeMoreCell.ID];
            tv.delegate = self;
            tv.dataSource = self;
            tv.scrollEnabled = NO;
            tv.tableFooterView = [UIView new];
            tv.backgroundColor = UIColor.whiteColor;
            tv.rowHeight = 60;
            tv;
        });
    }
    return _tableView;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = ({
            UIButton * b = [UIButton new];
            [b setTitle:Localized(@"save") forState:UIControlStateNormal];
            b.backgroundColor = KDSRGBColor(31, 150, 247);
            [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            b.layer.cornerRadius = 22;
            [b addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            b;
        });
    }
    return _saveBtn;
}

@end

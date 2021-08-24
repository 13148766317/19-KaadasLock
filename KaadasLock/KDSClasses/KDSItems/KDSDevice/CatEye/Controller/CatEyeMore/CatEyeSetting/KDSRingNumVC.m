//
//  KDSRingNumVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSRingNumVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "KDSDBManager+CY.h"
#import "KDSCateyeMoreCell.h"


@interface KDSRingNumVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * dataSourceArr;
////当前响铃次数
@property(nonatomic,assign)NSUInteger currentIndex;
///选中的响铃次数
@property(nonatomic,assign)NSNumber* selectRingNum;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;

@end

@implementation KDSRingNumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"Ring number");
    [self setDataArray];
    _currentIndex = [[KDSDBManager sharedManager] getBellAcount:self.cateyeParam.deviceId].integerValue-1;
    _selectRingNum = @(_currentIndex+1);
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
    if (_dataSourceArr == nil) {
        _dataSourceArr = [NSMutableArray array];
    }
    for (int i = 1; i<=5; i++) {
        [_dataSourceArr addObject:[NSString stringWithFormat:@"%d%@",i,Localized(@"times")]];
    }
}

#pragma UITableviewdelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    cell.titleNameLb.text = self.dataSourceArr[indexPath.row];
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(ringNumClick:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == _currentIndex) {
        cell.selectBtn.selected = YES;
    }
    else{
        cell.selectBtn.selected = NO;
    }
    return cell;
}

#pragma mark 手势
-(void)ringNumClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currentIndex = sender.tag;
    [self.tableView reloadData];
    _selectRingNum = @(sender.tag+1);
    
}
-(void)saveBtnClick:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] cy:self.cateye.gatewayDeviceModel setBellTimes:_selectRingNum.intValue completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [[KDSDBManager sharedManager] updatbellNum:[NSString stringWithFormat:@"%@",_selectRingNum] deviceID:self.cateye.gatewayDeviceModel.deviceId];
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
            tv.tableFooterView = [UIView new];
            tv.delegate = self;
            tv.dataSource = self;
            tv.scrollEnabled = NO;
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

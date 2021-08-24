//
//  KDSBellvolumeSettingVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/13.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBellvolumeSettingVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "KDSDBManager+CY.h"
#import "KDSCateyeMoreCell.h"

@interface KDSBellvolumeSettingVC ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>

@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * dataSourceArr;
///当前铃声音量
@property(nonatomic,assign)NSUInteger currentIndex;
///选中的铃声音量
@property(nonatomic,assign)NSNumber* selectVolum;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;

@end

@implementation KDSBellvolumeSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"ringer volume");
    [self setDataArray];
    _currentIndex = [[KDSDBManager sharedManager] getBellVolumeWithDeviceID:self.cateyeParam.deviceId].integerValue;
    
    if (_currentIndex == 0) {//高
        _selectVolum = @(0);
    }else if (_currentIndex ==1){//中
       _selectVolum = @(1);
    }else if (_currentIndex ==2){//低
       _selectVolum = @(2);
    }else if (_currentIndex == 3){//静音
       _selectVolum = @(3);
    }
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
-(void)setDataArray{
    /*门铃音量0（HIGHVOLUME），1（NORMALVOLUME）,2（LOWVOLUME）,3（MUTE）(静音)*/
    _dataSourceArr = [[NSArray alloc] initWithObjects:Localized(@"high"),Localized(@"middle"),Localized(@"low"), nil];
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
    cell.backgroundColor = UIColor.whiteColor;
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
    _selectVolum = @(sender.tag);
   
}
-(void)saveBtnClick:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] cy:self.cateye.gatewayDeviceModel setVolume:_selectVolum.stringValue completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [[KDSDBManager sharedManager] updateBellVolum:[NSString stringWithFormat:@"%@",_selectVolum] deviceID:self.cateye.gatewayDeviceModel.deviceId];
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

//
//  KDSMediaLockPIRSensitivityVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaLockPIRSensitivityVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSCateyeMoreCell.h"
#import "KDSMQTTManager+SmartHome.h"

@interface KDSMediaLockPIRSensitivityVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * dataSourceArr;
////选中的PIR灵敏度
@property(nonatomic,assign)NSUInteger currentIndex;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;
///PIR灵敏度服务器的值
@property (nonatomic, assign)int PIRSensitivity;

@end

@implementation KDSMediaLockPIRSensitivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"探测距离选择";
    [self setUpUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

- (void)setUpUI
{
    NSDictionary * dic = self.lock.wifiDevice.setPir;
    NSString * pir_sen = dic[@"pir_sen"];
    self.PIRSensitivity = pir_sen.intValue;
    [self setDataArray];
    if (self.PIRSensitivity == 35) {
        _currentIndex = 2;
    }if (self.PIRSensitivity == 70) {
        _currentIndex = 1;
    }if (self.PIRSensitivity == 90) {
        _currentIndex = 0;
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

-(void)setDataArray
{
    if (_dataSourceArr == nil) {
        _dataSourceArr = [NSMutableArray array];
    }
    [_dataSourceArr addObject:@"远（3米内）"];
    [_dataSourceArr addObject:@"中（2米内）"];
    [_dataSourceArr addObject:@"近（1米内）"];
}

#pragma UITableviewdelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    cell.titleNameLb.text = self.dataSourceArr[indexPath.row];
    cell.hideSeparator = indexPath.row == self.dataSourceArr.count -1;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentIndex = indexPath.row;
    [self.tableView reloadData];
}
#pragma mark 手势
-(void)ringNumClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currentIndex = sender.tag;
    [self.tableView reloadData];
}
-(void)saveBtnClick:(UIButton *)sender
{
    //保存按钮事件
}

///返回按钮：返回即触发设置事件
-(void)navBackClick{
    
    if (_currentIndex == 0) {
        self.PIRSensitivity = 90;
    }else if (_currentIndex == 1){
        self.PIRSensitivity = 70;
    }else{
        self.PIRSensitivity = 35;
    }
    !_didSelectPIRSensitivityBlock ?: _didSelectPIRSensitivityBlock(self.PIRSensitivity);
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleNone;
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
            b.hidden = YES;
            [b addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            b;
        });
    }
    return _saveBtn;
}


@end

//
//  KDSMediaWanderingTimeVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaWanderingTimeVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSCateyeMoreCell.h"
#import "KDSMQTTManager+SmartHome.h"

@interface KDSMediaWanderingTimeVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * dataSourceArr;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;
////当前徘徊判定时间次数
@property(nonatomic,assign)int currentIndex;

@end

@implementation KDSMediaWanderingTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"判定时间选择";
    [self setDataArray];
    [self setUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

- (void)setUI
{
    NSDictionary * dic = self.lock.wifiDevice.setPir;
    NSString * stay_time = dic[@"stay_time"];
    self.currentIndex = stay_time.intValue;
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
    [_dataSourceArr addObject:@"来回走动10秒报警"];
    [_dataSourceArr addObject:@"来回走动20秒报警"];
    [_dataSourceArr addObject:@"来回走动30秒报警"];
    [_dataSourceArr addObject:@"来回走动40秒报警"];
    [_dataSourceArr addObject:@"来回走动50秒报警"];
    [_dataSourceArr addObject:@"来回走动60秒报警"];
}

#pragma UITableviewdelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    cell.titleNameLb.text = self.dataSourceArr[indexPath.row];
    cell.hideSeparator = indexPath.row == self.dataSourceArr.count -1;
    cell.selectBtn.tag = (indexPath.row+1)*10;
    [cell.selectBtn addTarget:self action:@selector(ringNumClick:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == (_currentIndex/10)-1) {
        cell.selectBtn.selected = YES;
    }
    else{
        cell.selectBtn.selected = NO;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentIndex = (int)(indexPath.row+1)*10;
    [self.tableView reloadData];
}

#pragma mark 手势
-(void)ringNumClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currentIndex = (int)sender.tag;
    [self.tableView reloadData];
}
-(void)saveBtnClick:(UIButton *)sender
{
    // MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    
}

///返回按钮：返回即触发设置事件
-(void)navBackClick{
    !_didSelectWanderingTimeBlock ?: _didSelectWanderingTimeBlock(self.currentIndex);
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

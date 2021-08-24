//
//  KDSResolutionSettingsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSResolutionSettingsVC.h"
#import "KDSDBManager+CY.h"
#import "MBProgressHUD+MJ.h"
#import "KDSCatEyeMoreSettingVC.h"
#import "KDSCateyeMoreCell.h"


@interface KDSResolutionSettingsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,readwrite,strong)NSArray * dataSourceArr;
@property (nonatomic,readwrite,strong)UITableView * tableView;
///当前视频分辨率
@property(nonatomic,assign)NSUInteger currentIndex;
///选中的视频分辨率
@property(nonatomic,copy)NSString* selectVedioRes;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;
@property(nonatomic,strong)NSString *resolutionStr;


@end

@implementation KDSResolutionSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"Video Resolution");
    [self setDataArray];
     self.resolutionStr= [[KDSDBManager sharedManager] getResolution:self.cateyeParam.deviceId];
    if ([self.resolutionStr isEqualToString:@"960x540"]) {
        _currentIndex = 0;
        _selectVedioRes = @"960x540";
    }else{
        _currentIndex = 1;
        _selectVedioRes = @"1280x720";
    }
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.saveBtn];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_offset(0);
        make.height.mas_equalTo(_dataSourceArr.count*60);
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
    _dataSourceArr = [[NSArray alloc] initWithObjects:@"960x540",@"1280x720",nil];
    
}

#pragma mark UITableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    cell.titleNameLb.text = self.dataSourceArr[indexPath.row];
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == _currentIndex) {
        cell.selectBtn.selected = YES;
    }
    else{
        cell.selectBtn.selected = NO;
    }
    return cell;
}

#pragma mark 手势
-(void)selectBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [KDSUserDefaults setObject:[NSString stringWithFormat:@"%ld",sender.tag] forKey:@"lastSelectResolution"];
    _currentIndex = sender.tag;
    [self.tableView reloadData];
    if (sender.tag == 0) {
        _selectVedioRes = @"960x540";
    }else if (sender.tag == 1){
        _selectVedioRes = @"1280x720";
    }
   
}
///保存
-(void)saveBtnClick:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] cy:self.cateye.gatewayDeviceModel setResolution:_selectVedioRes completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [[KDSDBManager sharedManager] updatResolution:_selectVedioRes deviceID:self.cateye.gatewayDeviceModel.deviceId];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[KDSCatEyeMoreSettingVC class]]) {
                    KDSCatEyeMoreSettingVC *cateyeSetVC =(KDSCatEyeMoreSettingVC *)controller;
                    cateyeSetVC.cateye.cateyeModel.resolution = [NSString stringWithFormat:@"%@",_selectVedioRes];
                }
            }
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
            tv.tableFooterView = [UIView new];
            [tv registerClass:[KDSCateyeMoreCell class ] forCellReuseIdentifier:KDSCateyeMoreCell.ID];
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
